# Lesson 5 Guide — Side-Effect Recalculation & Workflow Endpoints

**Goal:** by the end of this lesson your `OrderItemsController` handles full
CRUD **and** keeps the parent `Order.Total` in sync automatically — add an item
and the order's total goes up; delete one and it goes down. You'll also learn to
write **custom, non-CRUD endpoints** that model a business action rather than a
database operation, starting with `Cancel`.

**The general pattern you're learning:** two ideas. First, a write to a child
record can have a **side effect** on its parent — after every change to an
`OrderItem`, recompute the `Order.Total`. Second, not every endpoint is CRUD;
sometimes the URL names a **verb** (`/orders/5/cancel`) that performs a specific
state change.

The bulk of this lesson is the recalculation pattern. The workflow endpoints are a
shorter segment — you'll build `Cancel` here and write the linear status endpoints
yourself in the lab.

---

## Part 1 — Side-effect recalculation

### 1. Why the parent needs recalculating

`Order.Total` isn't something the client sends — it's **derived** from the order's
items: the sum of `Quantity × MenuItem.Price` across every `OrderItem`. If the
client could set it directly, it could lie. So the API owns it: every time the set
of items changes, the API recomputes the total from scratch.

### 2. A private recalculation helper

Because Create, Update, and Delete all need to do the same recompute, factor it
into one private method:

```csharp
private async Task RecalculateOrderTotal(int orderId)
{
    var order = await _db.Orders.FindAsync(orderId);
    order!.Total = await _db.OrderItems
                            .Where(oi => oi.OrderId == orderId)
                            .SumAsync(oi => oi.Quantity * oi.MenuItem!.Price);
    await _db.SaveChangesAsync();
}
```

Things to notice:

- **It recomputes from the database, not from the request.** It sums whatever
  items currently exist for that order — so it's always correct regardless of what
  changed.
- **`SumAsync(oi => oi.Quantity * oi.MenuItem!.Price)`** — EF Core translates this
  into a SQL `SUM` with a join; the `MenuItem!` null-forgiving operator tells the
  compiler "trust me, the FK is valid." An order with no items sums to `0`.
- **It's `private`** — it's an internal helper, not an endpoint. No `[HttpGet]`
  attribute, no route.
- **It saves its own change** — after setting `Total`, it calls
  `SaveChangesAsync` so the new total persists.

### 3. Calling the helper after every mutation

The recalculation runs **after** the item change is saved, so the sum reflects the
new reality:

```csharp
// POST: api/OrderItems
[HttpPost]
public async Task<ActionResult<OrderItem>> Create(OrderItem newOrderItem)
{
    _db.OrderItems.Add(newOrderItem);
    await _db.SaveChangesAsync();
    await RecalculateOrderTotal(newOrderItem.OrderId);   // ← side effect

    var orderItemWithMenuItem = await _db.OrderItems
                                         .Include(oi => oi.MenuItem)
                                         .SingleOrDefaultAsync(oi => oi.Id == newOrderItem.Id);

    return CreatedAtAction(nameof(GetById), new { id = newOrderItem.Id }, orderItemWithMenuItem);
}
```

```csharp
// PUT: api/OrderItems/5
[HttpPut("{id}")]
public async Task<ActionResult<OrderItem>> Update(int id, OrderItem updatedOrderItem)
{
    if (id != updatedOrderItem.Id) return BadRequest();

    var currentOrderItem = await _db.OrderItems.FindAsync(id);
    if (currentOrderItem == null) return NotFound();

    _db.Entry(currentOrderItem).CurrentValues.SetValues(updatedOrderItem);
    await _db.SaveChangesAsync();
    await RecalculateOrderTotal(updatedOrderItem.OrderId);   // ← side effect

    var orderItemWithMenuItem = await _db.OrderItems
                                         .Include(oi => oi.MenuItem)
                                         .SingleOrDefaultAsync(oi => oi.Id == id);

    return Ok(orderItemWithMenuItem);
}
```

```csharp
// DELETE: api/OrderItems/5
[HttpDelete("{id}")]
public async Task<IActionResult> Delete(int id)
{
    var orderItem = await _db.OrderItems.FindAsync(id);
    if (orderItem == null) return NotFound();

    var orderId = orderItem.OrderId;        // ← capture BEFORE removing
    _db.OrderItems.Remove(orderItem);
    await _db.SaveChangesAsync();
    await RecalculateOrderTotal(orderId);   // ← side effect

    return NoContent();
}
```

Things to notice:

- **Delete captures `orderId` before `Remove`.** Once the entity is removed you
  can't read its `OrderId`, so grab it into a local first, then recalculate after
  the save.
- **The `GetAll`/`GetById` reads** Include `MenuItem` just like MenuItems included
  Category in the previous lesson — nothing new there.
- Create/Update re-fetch into an **`orderItemWithMenuItem`** variable so the
  response carries the menu item, same re-fetch idea as the previous lesson.

---

## Part 2 — Custom workflow endpoints

### 4. When a URL is a verb, not a resource

CRUD covers "create/read/update/delete a thing." But "cancel this order" isn't
really an update to arbitrary fields — it's a specific **business action** that
sets the status and records a reason. We model it as its own endpoint using the
course's URL convention:

```
/{resource}/{id}/{verb}     →  PUT /api/orders/5/cancel
```

**Id before verb, always.** Order status has a linear workflow with one branch:

```
PLACED → PREPARING → READY → SERVED
   └──────────┴─→ CANCELLED   (branch off PLACED or PREPARING, reason required)
```

That's four workflow endpoints: `startpreparing`, `markready`, `markserved`, and
`cancel`.

### 5. Building `Cancel` — a plain-string body

`Cancel` is the interesting one: it needs a **cancellation reason** from the
caller. The reason is a single string, so instead of wrapping it in an object we
bind the raw JSON string body with `[FromBody]`:

```csharp
// PUT: api/Orders/5/cancel
[HttpPut("{id}/cancel")]
public async Task<ActionResult<Order>> Cancel(int id, [FromBody] string cancellationReason)
{
    var currentOrder = await _db.Orders.FindAsync(id);
    if (currentOrder == null) return NotFound();

    currentOrder.Status = OrderStatus.Cancelled;
    currentOrder.CancellationReason = cancellationReason;
    await _db.SaveChangesAsync();

    return Ok(currentOrder);
}
```

Things to notice:

- **`[FromBody] string cancellationReason`** — the request body is a bare
  JSON-encoded string, e.g. `"Customer changed mind"` (with the quotes). Because
  it's still JSON, the request must send `Content-Type: application/json` — sending
  `text/plain` returns **415 Unsupported Media Type**.
- **The verb comes after the id in the route:** `[HttpPut("{id}/cancel")]`.
- **It uses the `OrderStatus` constant**, never the literal `"CANCELLED"`.
- **It sets two fields** — the status *and* the reason — then saves. This is a
  focused state change, not a general update.

### 6. The linear status endpoints (you'll build these in the lab)

The other three are simpler — no body, they just advance the status. Here's the
shape of `StartPreparing`; `MarkReady` and `MarkServed` are identical except for
which status they set:

```csharp
// PUT: api/Orders/5/startpreparing
[HttpPut("{id}/startpreparing")]
public async Task<ActionResult<Order>> StartPreparing(int id)
{
    var currentOrder = await _db.Orders.FindAsync(id);
    if (currentOrder == null) return NotFound();

    currentOrder.Status = OrderStatus.Preparing;
    await _db.SaveChangesAsync();

    return Ok(currentOrder);
}
```

Each workflow action fetches its own `currentOrder` independently — they don't
call each other. You'll write all three in this lesson's lab.

---

## 7. Verifying with Insomnia

With the project running (no login required — the endpoints are open):

**Recalculation** (the **OrderItems** folder):

1. Note the current `total` of order 1 (**Get Order by Id** in the Orders folder).
2. **Create Order Item** against order 1 → **201 Created**.
3. **Get Order by Id** for order 1 again → the `total` has increased by
   `quantity × price` of the item you added.
4. **Delete Order Item** you just created → **204**, then re-check the order
   `total` → back down.

**Cancel** (the **Orders** folder):

5. **Cancel Order** → Send → expect **200 OK**; the response `status` is
   `CANCELLED` and `cancellationReason` holds your text.

Check the **Tests** tab on each — green means the status code and response shape
are correct.

### Troubleshooting

- **415 Unsupported Media Type on Cancel** — the body needs
  `Content-Type: application/json` and the value must be a *quoted* JSON string.
- **`total` didn't change** — confirm `RecalculateOrderTotal` is actually called
  after `SaveChangesAsync` in the OrderItem method you exercised.
- **`NullReferenceException` in the sum** — the recalculation joins to `MenuItem`;
  make sure the item's `MenuItemId` points at a real menu item.

---

## The General Pattern (what to take away)

**Side effects:** when a child write changes something derived on the parent,
factor the recompute into a `private` helper and call it after *every* mutation
(Create, Update, Delete). Always recompute from the database, never trust a
client-sent total.

**Workflow endpoints:** a business action that isn't plain CRUD gets its own
`/{resource}/{id}/{verb}` endpoint. Fetch the entity, apply the specific state
change (using status constants), save, return the entity.

On PRS in the capstone these map directly: `RequestLinesController` recalculates
`Request.Total` exactly the way `OrderItemsController` recalculates `Order.Total`,
and the `Reject` endpoint takes a plain-string reason body exactly like `Cancel`.
(PRS adds a `$50 auto-approve` rule to its `Review` endpoint that TableServe has no
equivalent for — that one's taught directly on PRS.)

---

## Build Steps

1. Add the `private async Task RecalculateOrderTotal(int orderId)` helper to
   `OrderItemsController`
2. Build `OrderItemsController` CRUD — `GetAll`/`GetById` Include `MenuItem`;
   `Create`/`Update`/`Delete` each call `RecalculateOrderTotal` after saving
3. In `Delete`, capture `orderId` into a local before `Remove`
4. Add the `Cancel` workflow endpoint to `OrdersController` —
   `[HttpPut("{id}/cancel")]`, `[FromBody] string cancellationReason`, set status +
   reason
5. Run the project and verify recalculation and cancel in Insomnia — see section 7
6. Leave `StartPreparing`, `MarkReady`, and `MarkServed` for the lab
