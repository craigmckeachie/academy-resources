# Lesson 3 Lab — MenuItemsController (Full CRUD)

Build a `MenuItemsController` with all five CRUD operations, following the
finished `StaffController` from the guide as your model. `MenuItem` has no
password, so there's no BCrypt here — it's the plainest possible full-CRUD
entity.

`MenuItem` has a `CategoryId`, but for this lesson treat it as **just an integer
column** — a plain foreign-key value. In the next lesson you'll learn how to return
the related `Category` object alongside it.

---

## The MenuItem entity

Add `Models/MenuItem.cs`:

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
}
```

---

## Steps

1. Add `MenuItem.cs` to `Models/`
2. Add `DbSet<MenuItem> MenuItems` to `TableServeDbContext`
3. Run `Add-Migration AddMenuItem` then `Update-Database`
4. Verify the `MenuItems` table exists in SQL Server Object Explorer
5. Seed some menu items (Categories must already exist from the Lesson 2 lab):

```sql
INSERT INTO [dbo].[MenuItems] ([Name], [Price], [CategoryId]) VALUES ('Mozzarella Sticks', 9.99, 1)
INSERT INTO [dbo].[MenuItems] ([Name], [Price], [CategoryId]) VALUES ('Spinach Artichoke Dip', 11.99, 1)
INSERT INTO [dbo].[MenuItems] ([Name], [Price], [CategoryId]) VALUES ('Grilled Salmon', 21.99, 2)
INSERT INTO [dbo].[MenuItems] ([Name], [Price], [CategoryId]) VALUES ('Classic Burger', 14.99, 2)
INSERT INTO [dbo].[MenuItems] ([Name], [Price], [CategoryId]) VALUES ('Caesar Salad', 7.99, 3)
INSERT INTO [dbo].[MenuItems] ([Name], [Price], [CategoryId]) VALUES ('Chocolate Lava Cake', 8.99, 4)
INSERT INTO [dbo].[MenuItems] ([Name], [Price], [CategoryId]) VALUES ('Iced Tea', 3.99, 5)
```

6. Create `Controllers/MenuItemsController.cs` with `GetAll`, `GetById`, `Create`,
   `Update`, `Delete` — same shape as `StaffController`, minus the password hashing
7. Run the project and verify your endpoints using the **MenuItems** folder in
   the Insomnia collection

---

## Verify in Insomnia

With the project running (no login required — the endpoints are open), expand the
**MenuItems** folder:

1. **Get All Menu Items** → expect **200 OK** with an array
2. **Get Menu Item by Id** → expect **200 OK** with Mozzarella Sticks
3. **Create Menu Item** → expect **201 Created** with a generated `id`
4. **Update Menu Item** → expect **200 OK** with the changed fields
5. **Delete Menu Item** → expect **204 No Content**
6. Check the **Tests** tab on each response — all green

You just wrote your first full-CRUD controller on your own. This is exactly the
pattern you'll repeat when you build `ProductsController` on PRS in the capstone — same
five methods, a `PartNumber` and `VendorId` instead of a `CategoryId`.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and
needs some research.

- **Search endpoint** — [Reinforce] — add an optional `?name=` filter to `GetAll`
  that returns only menu items whose `Name` contains the search text.
- **Reject duplicates** — [Reinforce] — before creating, fetch to check no menu
  item with the same `Name` already exists (the same "confirm by fetch" idea you
  use everywhere else), and return `BadRequest` with a message if it does.
- **Model validation** — [Reach] — add data-annotation attributes (`[Required]`,
  `[StringLength]`, `[Range]` on `Price`) to the model and watch `[ApiController]`
  return a `400` automatically when they're violated. Not covered in the guide —
  research: [Model validation in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/mvc/models/validation).

Finished these and want more? See
[stretch-api-challenges.md](stretch-api-challenges.md) for bigger challenges that
span the whole API pass.
