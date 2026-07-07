# Lesson 2 Lab — CategoriesController

Build a `CategoriesController` following the same pattern as the `StaffController`
from the guide. Refer to the guide and the `StaffController` you already built as
your model.

---

## The Category entity

Add `Models/Category.cs`:

```csharp
namespace TableServe.Api.Models;

public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int SortOrder { get; set; }
}
```

---

## Steps

1. Add `Category.cs` to `Models/`
2. Add `DbSet<Category> Categories` to `TableServeDbContext`
3. Run `Add-Migration AddCategory` then `Update-Database`
4. Verify the `Categories` table exists in SQL Server Object Explorer
5. Run this in SSMS to seed the Categories:

```sql
SET IDENTITY_INSERT [dbo].[Categories] ON

INSERT INTO [dbo].[Categories] ([Id], [Name], [SortOrder]) VALUES (1, 'Appetizers', 1)
INSERT INTO [dbo].[Categories] ([Id], [Name], [SortOrder]) VALUES (2, 'Entrees', 2)
INSERT INTO [dbo].[Categories] ([Id], [Name], [SortOrder]) VALUES (3, 'Sides', 3)
INSERT INTO [dbo].[Categories] ([Id], [Name], [SortOrder]) VALUES (4, 'Desserts', 4)
INSERT INTO [dbo].[Categories] ([Id], [Name], [SortOrder]) VALUES (5, 'Drinks', 5)

SET IDENTITY_INSERT [dbo].[Categories] OFF
```

6. Create `Controllers/CategoriesController.cs` with `GetAll` and `GetById`
7. Run the project and verify your endpoints using the **Categories** folder
   in the Insomnia collection

---

## Verify in Insomnia

Insomnia setup (importing the collection, setting `baseUrl`) is covered in
detail in this lesson's guide — section 12. Once that's done (no need to log in
first — the endpoints are open):

1. Expand the **Categories** folder
2. Run **Get All Categories** → expect `200 OK` with all 5 categories
3. Run **Get Category by Id** → expect `200 OK` with Appetizers
4. Run **Get Category by Id (Not Found)** → expect `404 Not Found`
5. Check the **Tests** tab on each response — all tests should be green

You just repeated the same pattern on a different entity — this is exactly
what you'll do five times when building the PRS backend in the capstone.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and
needs some research.

- **Sort the list** — [Reinforce] — return categories from `GetAll` ordered by
  `SortOrder`, then `Name`, using `OrderBy` / `ThenBy`.
- **Filter by name** — [Reinforce] — accept an optional `?name=` query string on
  `GetAll` and return only categories whose `Name` contains it. (This is the same
  shape as the `?status=` filter you'll write on Orders in Lesson 4.)
- **404 on a bad id** — [Reinforce] — make `GetById` return `NotFound()` when the
  id doesn't exist, ahead of Lesson 3 formally covering status codes in controllers.

Finished these and want more? See
[stretch-api-challenges.md](stretch-api-challenges.md) for bigger challenges that
span the whole API pass.
