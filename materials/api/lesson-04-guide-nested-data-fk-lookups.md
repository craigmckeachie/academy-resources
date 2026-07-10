# Lesson 4 Guide — Nested & Related Data

**Goal:** by the end of this lesson your `MenuItemsController` returns each
menu item with its **full `Category` object** embedded, not just a bare
`categoryId` number. You'll learn navigation properties, `Include()`, why you
must re-fetch related data after a write, and how to stop EF Core from
serializing objects in an infinite loop.

**The general pattern you're learning:** a foreign-key column (`CategoryId`) tells
you *which* related row exists; a **navigation property** (`Category`) lets you
pull that whole related row into the response. `Include()` is the switch that
turns the navigation property on for a given query.

---

## 1. The problem with a bare foreign key

In the previous lesson your `GET api/menuitems` returned this:

```json
{ "id": 1, "name": "Mozzarella Sticks", "price": 9.99, "categoryId": 1 }
```

The front end knows the category is `1` — but not that `1` means "Appetizers." It
would have to make a *second* request to `api/categories/1` just to show the name.
That's wasteful. What we want is the category name to ride along:

```json
{
  "id": 1,
  "name": "Mozzarella Sticks",
  "price": 9.99,
  "categoryId": 1,
  "category": { "id": 1, "name": "Appetizers", "sortOrder": 1 }
}
```

---

## 2. Navigation properties

A **navigation property** is a property whose type is another entity (or a
collection of them). Add one to `MenuItem` — a `Category` property beside the
existing `CategoryId`:

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TableServe.Api.Models;

public class MenuItem
{
    public int Id { get; set; }
    [StringLength(30)]
    public string Name { get; set; } = string.Empty;
    [Column(TypeName = "decimal(11,2)")]
    public decimal Price { get; set; }

    public int CategoryId { get; set; }
    public Category? Category { get; set; }   // ← navigation property
}
```

Things to notice:

- **`CategoryId` and `Category` work as a pair.** `CategoryId` is the actual FK
  column in the database; `Category` is the C# object EF Core can populate from it.
- **The navigation property is nullable (`Category?`).** It's only populated when
  you explicitly ask for it — otherwise it's null. No `virtual` keyword: this
  course does not use lazy loading, so a navigation property is *never* filled in
  automatically.
- **No new migration needed for this** — adding a navigation property that maps to
  an FK column you already have doesn't change the schema. (If your `CategoryId`
  column already exists from the previous lesson, you're set.)

---

## 3. `Include()` — pulling in related data

By default EF Core does **not** load navigation properties — you'd get `null`
back. `Include()` tells EF Core to `JOIN` the related table and populate the
property. Update `GetAll` and `GetById`:

```csharp
// GET: api/MenuItems
[HttpGet]
public async Task<ActionResult<IEnumerable<MenuItem>>> GetAll()
{
    return await _db.MenuItems
                    .Include(menuItem => menuItem.Category)
                    .ToListAsync();
}

// GET: api/MenuItems/5
[HttpGet("{id}")]
public async Task<ActionResult<MenuItem>> GetById(int id)
{
    var menuItem = await _db.MenuItems
                           .Include(menuItem => menuItem.Category)
                           .SingleOrDefaultAsync(menuItem => menuItem.Id == id);

    if (menuItem == null) return NotFound();
    return menuItem;
}
```

Things to notice:

- **`.Include(menuItem => menuItem.Category)`** — the lambda names the navigation
  property to load. That's what makes the `category` object appear in the JSON.
- **`SingleOrDefaultAsync(...)` replaces `FindAsync` on GetById.** `FindAsync`
  can't be combined with `Include`, so once you need related data, switch to
  `SingleOrDefaultAsync` with a predicate. It returns the matching entity or
  `null`.
- **Navigation properties are always explicitly `Include`d — never assumed.** If
  you forget the `Include`, the `Category` comes back null. This is a very common
  "why is it null?" bug.

---

## 4. Re-fetching after a write

Here's the subtle part. When you `Create` a menu item, the incoming object only
has a `categoryId` — EF Core hasn't loaded the `Category` object. If you return it
directly, the `category` field is null even though the FK is set. The fix: after
saving, **re-fetch the row with `Include`** before returning it.

```csharp
// POST: api/MenuItems
[HttpPost]
public async Task<ActionResult<MenuItem>> Create(MenuItem newMenuItem)
{
    _db.MenuItems.Add(newMenuItem);
    await _db.SaveChangesAsync();

    var menuItemWithCategory = await _db.MenuItems
                                        .Include(menuItem => menuItem.Category)
                                        .SingleOrDefaultAsync(menuItem => menuItem.Id == newMenuItem.Id);

    return CreatedAtAction(nameof(GetById), new { id = newMenuItem.Id }, menuItemWithCategory);
}
```

```csharp
// PUT: api/MenuItems/5
[HttpPut("{id}")]
public async Task<ActionResult<MenuItem>> Update(int id, MenuItem updatedMenuItem)
{
    if (id != updatedMenuItem.Id) return BadRequest();

    var currentMenuItem = await _db.MenuItems.FindAsync(id);
    if (currentMenuItem == null) return NotFound();

    _db.Entry(currentMenuItem).CurrentValues.SetValues(updatedMenuItem);
    await _db.SaveChangesAsync();

    var menuItemWithCategory = await _db.MenuItems
                                        .Include(menuItem => menuItem.Category)
                                        .SingleOrDefaultAsync(menuItem => menuItem.Id == id);

    return Ok(menuItemWithCategory);
}
```

Things to notice:

- The re-fetch variable is named **`menuItemWithCategory`** — a `{entity}With{nav}`
  name that makes it obvious *why* this second query exists.
- The `Update` still uses **`FindAsync` for the fetch-then-set step** (no Include
  needed to copy values), then re-fetches *with* Include only for the response.
- `Delete` doesn't change from the previous lesson — there's nothing to return, so no Include.

---

## 5. Avoiding circular JSON references

When two entities point at each other, serializing one can loop forever:
`Order → OrderItems → Order → OrderItems → …`. This throws a runtime error the
moment you `GET` an order with its items.

The fix used in this course is `[JsonIgnore]` on the **child's back-reference to
the parent**. On `OrderItem`, the `Order` navigation property is marked so it's
never serialized downward:

```csharp
using System.Text.Json.Serialization;

public class OrderItem
{
    public int Id { get; set; }
    public int Quantity { get; set; } = 1;
    public string? Notes { get; set; }

    public int OrderId { get; set; }
    [JsonIgnore]
    public Order? Order { get; set; }        // ← never serialize parent back down

    public int MenuItemId { get; set; }
    public MenuItem? MenuItem { get; set; }
}
```

The rule of thumb: **serialize parent → child, never child → parent.** An `Order`
includes its `OrderItems`; each `OrderItem` includes its `MenuItem`; but an
`OrderItem` does **not** re-serialize its `Order`. You'll rely on this in this
lesson's lab when you build `OrdersController`.

---

## 6. Nested Include with `ThenInclude`

A single `Include` goes one level deep. To go deeper — an order, its items, *and*
each item's menu item — chain `ThenInclude`:

```csharp
var order = await _db.Orders
                    .Include(order => order.Staff)
                    .Include(order => order.OrderItems)
                        .ThenInclude(orderItem => orderItem.MenuItem)
                    .SingleOrDefaultAsync(order => order.Id == id);
```

Read it as: include the `Staff`; include the `OrderItems` collection; and for each
of those items, then include its `MenuItem`. This is the shape you'll build in
this lesson's lab.

---

## 7. Route parameters vs query parameters

So far every value in a URL has been a **route parameter** — the `{id}` in
`[HttpGet("{id}")]` that picks one specific row. There's a second way to pass data to
an endpoint: the **query string**, the `?key=value` part after the path. In this
lesson's lab you'll give `OrdersController.GetAll` an optional `?status=` filter with
`[FromQuery]`, so it's worth seeing where each kind of value sits and how they differ:

```text
       Protocol & Domain         Route (Path) Parameters         Query Parameters
     ┌───────────────────┐    ┌───────────────────────────┐    ┌─────────────────┐
     │                   │    │                           │    │                 │
     https://example.com / api / users / 123 / collections / 5 ? sort=desc & page=2
                                         ▲                   ▲   ▲         ▲
                                         │                   │   │         │
                                  Specific User ID           │ Key=Value   │
                                                       Separator       Separator
                                                      (Starts Query)  (Adds More)
```

**Route (path) parameters** — bound with `[FromRoute]` (the default for a value that
appears in the route template, like `{id}`). They identify *which* specific resource
you want and are **required** — the route doesn't even match if the segment is
missing. In `GET /api/menuitems/5`, the `5` is required.

**Query parameters** — bound with `[FromQuery]` (everything after the `?`). They are
**optional** and usually **multi-variate**: several `key=value` pairs joined with `&`
(`?status=PLACED&sort=desc&page=2`), used for filtering, sorting, and paging. You
declare one as an optional method parameter with a default —
`GetAll([FromQuery] string? status = null)` — so it's null when absent and you only
filter when a value is supplied. `GET /api/orders` returns everything;
`GET /api/orders?status=PLACED` narrows it.

In a controller the two are bound with different attributes:

```csharp
// Route parameter — GET /api/menuitems/5
[HttpGet("{id}")]                        // {id} is a token in the route template
public async Task<ActionResult<MenuItem>> GetById([FromRoute] int id)
{
    // id comes from the /5 segment — required
}

// Query parameter — GET /api/orders?status=PLACED
[HttpGet]                                // no token in the route
public async Task<ActionResult<IEnumerable<Order>>> GetAll([FromQuery] string? status = null)
{
    // status comes from ?status= — optional, null when omitted
}
```

Because of `[ApiController]`, both attributes are actually **optional**: a parameter
whose name matches a route token binds from the route, and a plain simple-type
parameter that isn't in the route binds from the query string. That's why
`GetById(int id)` back in section 3 works with no attribute at all — writing
`[FromRoute]` / `[FromQuery]` just makes the binding source explicit.

Rule of thumb: **route params say *which* resource (required, one at a time); query
params say *how* to shape the response (optional, often several at once).**

---

## 8. Verifying with Insomnia

With the project running (no login required — the endpoints are open), expand the
**MenuItems** folder:

1. **Get All Menu Items** → Send → expect **200 OK**; each item now has a nested
   `category` object, not just a `categoryId`.
2. **Get Menu Item by Id** → Send → confirm the `category` object is present.
3. **Create Menu Item** → Send → expect **201 Created**; the response body
   includes the full `category` (thanks to the re-fetch).
4. **Update Menu Item** → Send → expect **200 OK** with the `category` populated.

Check the **Tests** tab on each — green means the status code and structure are
correct.

### Troubleshooting

- **`category` is `null` in the response** — you forgot the `.Include()` on that
  query, or you're still using `FindAsync` (which ignores Include).
- **`JsonException` / "possible object cycle detected"** — a circular reference.
  Make sure the child's back-reference navigation property has `[JsonIgnore]`.

---

## The General Pattern (what to take away)

Returning related data is always the same four moves:

1. **Navigation property** on the model (`Category`, `Staff`, `OrderItems`).
2. **`Include()`** (and `ThenInclude()` for deeper levels) on every read query
   that should carry the related data.
3. **Re-fetch with `Include`** after Create/Update so the write response matches
   the read shape.
4. **`[JsonIgnore]`** on the child→parent back-reference to prevent cycles.

On PRS in the capstone, `ProductsController` includes its `Vendor` exactly the way
`MenuItemsController` includes its `Category`, and `RequestsController` nests
`RequestLines` the way `OrdersController` nests `OrderItems`.

---

## Build Steps

1. Add the `Category` navigation property to `Models/MenuItem.cs` (beside
   `CategoryId`)
2. Add `.Include(menuItem => menuItem.Category)` to `GetAll` and `GetById`, and
   switch `GetById` from `FindAsync` to `SingleOrDefaultAsync`
3. In `Create` and `Update`, re-fetch the saved item with `Include` into a
   `menuItemWithCategory` variable and return that
4. Add `[JsonIgnore]` (from `System.Text.Json.Serialization`) to the `Order`
   navigation property on `Models/OrderItem.cs` — you'll need it for the lab
5. Run the project and verify in the **MenuItems** folder that each item now
   carries a nested `category` object — see section 8
