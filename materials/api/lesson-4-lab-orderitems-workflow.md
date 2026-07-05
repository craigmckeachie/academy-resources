# Lesson 4 Lab — Order Status Workflow Endpoints

In this lesson's guide you built `OrderItemsController` with total recalculation and added
the `Cancel` workflow endpoint to `OrdersController`. Now finish the workflow:
write the three **linear status-advance endpoints** yourself, using `Cancel` and
the `StartPreparing` sketch from the guide as your model.

The workflow, for reference:

```
PLACED → PREPARING → READY → SERVED
```

Each endpoint moves an order one step along that chain. None of them takes a body —
they just set the next status.

---

## Steps

Add these three actions to `OrdersController` (id-before-verb routing, each fetches
its own order, each returns the updated order):

1. **`StartPreparing`** — `PUT api/orders/{id}/startpreparing` — sets
   `Status = OrderStatus.Preparing`
2. **`MarkReady`** — `PUT api/orders/{id}/markready` — sets
   `Status = OrderStatus.Ready`
3. **`MarkServed`** — `PUT api/orders/{id}/markserved` — sets
   `Status = OrderStatus.Served`

Each follows the exact shape of `StartPreparing` from the guide:

```csharp
// PUT: api/Orders/5/markready
[HttpPut("{id}/markready")]
public async Task<ActionResult<Order>> MarkReady(int id)
{
    var currentOrder = await _db.Orders.FindAsync(id);
    if (currentOrder == null) return NotFound();

    currentOrder.Status = OrderStatus.Ready;
    await _db.SaveChangesAsync();

    return Ok(currentOrder);
}
```

Use the **`OrderStatus`** constants — never the literal strings `"READY"` etc.

---

## Verify in Insomnia

With the project running (no login required — the endpoints are open), use the
**Orders** folder to walk an order all the way through its lifecycle. Start with
an order that's `PLACED` (order 1 in the seed data):

1. **Start Preparing** on order 1 → expect **200 OK**; response `status` is
   `PREPARING`
2. **Mark Ready** on order 1 → expect **200 OK**; `status` is `READY`
3. **Mark Served** on order 1 → expect **200 OK**; `status` is `SERVED`
4. Try a workflow endpoint on an id that doesn't exist (e.g. 9999) → expect
   **404 Not Found**
5. Check the **Tests** tab on each — all green

Insomnia setup and the recalculation checks are covered in this lesson's guide,
section 7.

These custom workflow endpoints are exactly what you'll rehearse on PRS in the capstone:
`Request` advances through `Send for Review → Approve`, with `Reject` as the
reason-carrying branch — the same pattern as `Cancel`. PRS also layers a
`$50 auto-approve` rule onto its `Review` endpoint, which has no TableServe
equivalent — watch for it when you get there.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and
needs some research.

- **Timestamp the transition** — [Reinforce] — add a nullable datetime (e.g.
  `ReadyAt`) that you set at the moment an order reaches that status, alongside
  setting `Status`.
- **Duplicate an order** — [Reinforce] — add an endpoint that copies an existing
  order's items into a brand-new `PLACED` order (a "re-order" convenience).
- **Guard illegal transitions** — [Reach] — return a `400` when a caller attempts
  an invalid move (cancelling a `SERVED` order, or marking a `CANCELLED` order as
  served). No external link needed — use the `OrderStatus` constants and decide
  which moves are legal yourself.

Finished these and want more? See
[stretch-api-challenges.md](stretch-api-challenges.md) for bigger challenges that
span the whole API pass.
