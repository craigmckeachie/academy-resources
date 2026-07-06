# Lesson 4 Lab — OrdersController (Nested Data)

Build an `OrdersController` that returns orders with their related data nested:
the `Staff` member who took the order, and — on the detail view — the full list of
`OrderItems`, each with its `MenuItem`. This is a step up from the guide: two
navigation properties and a two-level `ThenInclude`.

Use the finished `MenuItemsController` as your model for the `Include` pattern.

---

## The Order and OrderItem entities

Add `Models/Order.cs`:

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TableServe.Api.Models;

public class Order
{
    public int Id { get; set; }
    public int TableNumber { get; set; }
    [StringLength(200)]
    public string? Notes { get; set; }
    [StringLength(10)]
    public string Status { get; set; } = OrderStatus.Placed;
    [StringLength(200)]
    public string? CancellationReason { get; set; }
    [Column(TypeName = "decimal(11,2)")]
    public decimal Total { get; set; }
    public DateTime OrderedAt { get; set; } = DateTime.Now;

    public int StaffId { get; set; }
    public Staff? Staff { get; set; }

    public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}
```

Add `Models/OrderItem.cs` (note the `[JsonIgnore]` from this lesson's guide):

```csharp
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace TableServe.Api.Models;

public class OrderItem
{
    public int Id { get; set; }
    public int Quantity { get; set; } = 1;
    [StringLength(200)]
    public string? Notes { get; set; }

    public int OrderId { get; set; }
    [JsonIgnore]
    public Order? Order { get; set; }

    public int MenuItemId { get; set; }
    public MenuItem? MenuItem { get; set; }
}
```

Add `Models/OrderStatus.cs` — status values live in a constants class, never as
magic strings:

```csharp
namespace TableServe.Api.Models;

public static class OrderStatus
{
    public const string Placed = "PLACED";
    public const string Preparing = "PREPARING";
    public const string Ready = "READY";
    public const string Served = "SERVED";
    public const string Cancelled = "CANCELLED";
}
```

---

## Steps

1. Add `Order.cs`, `OrderItem.cs`, and `OrderStatus.cs` to `Models/`
2. Add `DbSet<Order> Orders` and `DbSet<OrderItem> OrderItems` to
   `TableServeDbContext`
3. Run `Add-Migration AddOrders` then `Update-Database`
4. Verify the `Orders` and `OrderItems` tables exist in SQL Server Object Explorer
5. Seed a few orders and items (Staff and MenuItems must already exist):

```sql
SET IDENTITY_INSERT [dbo].[Orders] ON
INSERT INTO [dbo].[Orders] ([Id],[TableNumber],[Notes],[Status],[CancellationReason],[Total],[OrderedAt],[StaffId])
    VALUES (1, 4, NULL, 'PLACED', NULL, 0.00, '2026-07-02 17:15:00', 6)
INSERT INTO [dbo].[Orders] ([Id],[TableNumber],[Notes],[Status],[CancellationReason],[Total],[OrderedAt],[StaffId])
    VALUES (2, 7, 'Anniversary dinner', 'PREPARING', NULL, 0.00, '2026-07-02 17:32:00', 7)
INSERT INTO [dbo].[Orders] ([Id],[TableNumber],[Notes],[Status],[CancellationReason],[Total],[OrderedAt],[StaffId])
    VALUES (3, 12, NULL, 'READY', NULL, 0.00, '2026-07-02 17:48:00', 8)
SET IDENTITY_INSERT [dbo].[Orders] OFF

INSERT INTO [dbo].[OrderItems] ([Quantity],[Notes],[OrderId],[MenuItemId]) VALUES (1, 'no onions', 1, 4)
INSERT INTO [dbo].[OrderItems] ([Quantity],[Notes],[OrderId],[MenuItemId]) VALUES (2, NULL, 1, 6)
INSERT INTO [dbo].[OrderItems] ([Quantity],[Notes],[OrderId],[MenuItemId]) VALUES (1, 'medium rare', 2, 3)
INSERT INTO [dbo].[OrderItems] ([Quantity],[Notes],[OrderId],[MenuItemId]) VALUES (1, NULL, 3, 5)
```

> The `StaffId` and `MenuItemId` values above assume the seed ids from the Lesson 2
> and Lesson 3 labs. If your ids differ, adjust them to point at rows that exist.

6. Create `Controllers/OrdersController.cs`:
   - **`GetAll`** — `.Include(order => order.Staff)`, and support an optional
     `?status=` query filter:
     ```csharp
     [HttpGet]
     public async Task<ActionResult<IEnumerable<Order>>> GetAll([FromQuery] string? status = null)
     {
         var query = _db.Orders.Include(order => order.Staff).AsQueryable();
         if (status != null) query = query.Where(order => order.Status == status);
         return await query.ToListAsync();
     }
     ```
   - **`GetById`** — Include `Staff`, and Include `OrderItems` with
     `.ThenInclude(orderItem => orderItem.MenuItem)`
   - **`Create`**, **`Update`**, **`Delete`** — same CRUD pattern as before;
     re-fetch with `.Include(order => order.Staff)` after Create/Update into an
     `orderWithStaff` variable
7. Run the project and verify using the **Orders** folder in Insomnia

---

## Verify in Insomnia

With the project running (no login required — the endpoints are open), expand the
**Orders** folder:

1. **Get All Orders** → expect **200 OK**; each order has a nested `staff` object
2. **Get Order by Id** → expect **200 OK**; the order has `staff` *and* an
   `orderItems` array, and each item has a nested `menuItem`
3. **Create Order** → expect **201 Created** with `staff` populated
4. **Update Order** → expect **200 OK**
5. **Delete Order** → expect **204 No Content**
6. Check the **Tests** tab — all green

If you see a "possible object cycle" error on **Get Order by Id**, confirm the
`[JsonIgnore]` is on `OrderItem.Order`.

The `Include`/`ThenInclude` pattern you just used is exactly what you'll write for
`RequestsController` on PRS in the capstone — a request that nests its `RequestLines`,
each with its `Product`, plus the `User` who submitted it.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and
needs some research.

- **Filter menu items by category** — [Reinforce] — add an optional `?categoryId=`
  filter to `MenuItemsController.GetAll`, returning only that category's items.
  (Same shape as PRS's `?status=` filter you'll write on requests.)
- **Deeper include** — [Reinforce] — on **Get Order by Id**, extend the include
  chain so each `OrderItem`'s `MenuItem` also brings back its `Category`, and
  confirm you don't trip a "possible object cycle" error.
- **Availability flag** — [Reinforce] — add a `bool IsAvailable` property to
  `MenuItem`, then return only available items from a new `?available=true` filter
  or a dedicated `menu` endpoint. Since you're adding a column to a table that
  already has rows, give it a database default of `true` so existing menu items
  stay available. EF Core ignores `[DefaultValue]` for the schema, so set the
  default with the Fluent API in `TableServeDbContext.OnModelCreating` (add that
  method if it isn't there yet, and keep the `base.OnModelCreating(modelBuilder)`
  call):
  ```csharp
  modelBuilder.Entity<MenuItem>()
      .Property(menuItem => menuItem.IsAvailable)
      .HasDefaultValue(true);
  ```
  Then run `Add-Migration AddMenuItemIsAvailable` and `Update-Database` to apply
  the change to your database.

Finished these and want more? See
[stretch-api-challenges.md](stretch-api-challenges.md) for bigger challenges that
span the whole API pass.
