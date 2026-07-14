# Anatomy of a Class — Quiz

Name every numbered token below. This is the blank version of the
[Anatomy of a Class](anatomy-of-a-class.md) reference — match each token to a term from
the word bank, then check yourself against that sheet.

You can print this and fill it in by hand, or copy the
[electronic version](#prefer-to-type-your-answers) at the bottom into your own file and
type your answers. Both specimens are real code from the TableServe API.

---

## Word bank — match each numbered token to one of these

> namespace · class · base class · attribute · type · property · navigation property ·
> field · constructor · parameter · method · method call · local variable · argument ·
> object

*(A term may be used more than once, and not every term is necessarily used.)*

---

## Specimen A — a model class (`Models/MenuItem.cs`)

```csharp
namespace TableServe.Api.Models;              // ①

public class MenuItem {                        // ②

    public int Id { get; set; } = 0;           // ③ ④
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; } = decimal.Zero;

    public int CategoryId { get; set; } = 0;
    public Category? Category { get; set; } = null;   // ⑤ ⑥
}
```

| # | Token | What it is — write the matching term here |
|---|---|---|
| ① | `TableServe.Api.Models` | |
| ② | `MenuItem` | |
| ③ | `Id` | |
| ④ | `int` | |
| ⑤ | `Category?` | |
| ⑥ | `Category` | |

---

## Specimen B — a controller class (`Controllers/CategoriesController.cs`)

```csharp
[ApiController]                                              // ①
public class CategoriesController : ControllerBase {         // ② ③
    private readonly TableServeDbContext _db;                // ④ ⑤

    public CategoriesController(TableServeDbContext db) {    // ⑥ ⑦
        _db = db;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Category>>> GetAll() {   // ⑧
        return await _db.Categories.ToListAsync();           // ⑨
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Category>> GetById(int id) {   // ⑩
        var category = await _db.Categories.FindAsync(id);   // ⑪ ⑫
        if (category == null) return NotFound();
        return category;
    }

    [HttpPost]
    public async Task<ActionResult<Category>> Create(Category newCategory) {
        _db.Categories.Add(newCategory);
        return CreatedAtAction(nameof(GetById), new { id = newCategory.Id }, newCategory);  // ⑬
    }
}
```

| # | Token | What it is — write the matching term here |
|---|---|---|
| ① | `[ApiController]` | |
| ② | `CategoriesController` | |
| ③ | `ControllerBase` | |
| ④ | `TableServeDbContext` | |
| ⑤ | `_db` | |
| ⑥ | `CategoriesController(...)` | |
| ⑦ | `db` | |
| ⑧ | `GetAll` | |
| ⑨ | `ToListAsync()` | |
| ⑩ | `id` | |
| ⑪ | `category` | |
| ⑫ | `id` (in `FindAsync(id)`) | |
| ⑬ | `new { id = ... }` | |

---

## Prefer to type your answers?

Copy everything in the box below into a new file (e.g. `my-anatomy-answers.md`), keep
this page open to see the code, and fill in the last column. This is the same two tables
plus the word bank, as raw Markdown.

````markdown
Word bank: namespace · class · base class · attribute · type · property ·
navigation property · field · constructor · parameter · method · method call ·
local variable · argument · object

### Specimen A — Models/MenuItem.cs

| # | Token | What it is |
|---|---|---|
| ① | `TableServe.Api.Models` | |
| ② | `MenuItem` | |
| ③ | `Id` | |
| ④ | `int` | |
| ⑤ | `Category?` | |
| ⑥ | `Category` | |

### Specimen B — Controllers/CategoriesController.cs

| # | Token | What it is |
|---|---|---|
| ① | `[ApiController]` | |
| ② | `CategoriesController` | |
| ③ | `ControllerBase` | |
| ④ | `TableServeDbContext` | |
| ⑤ | `_db` | |
| ⑥ | `CategoriesController(...)` | |
| ⑦ | `db` | |
| ⑧ | `GetAll` | |
| ⑨ | `ToListAsync()` | |
| ⑩ | `id` | |
| ⑪ | `category` | |
| ⑫ | `id` (in FindAsync(id)) | |
| ⑬ | `new { id = ... }` | |
````

---

## Stretch questions

Not from the word bank — explain in your own words:

1. Why is `_db` a **field** but `category` a **local variable**? What's different about
   how long each one lives?
2. `id` appears as both a **parameter** (⑩) and an **argument** (⑫). What's the difference?
3. Where is an **object** actually created in Specimen B, and why is there no visible
   `new Category()` even though the code clearly works with `Category` objects?

Answers are all on the [reference sheet](anatomy-of-a-class.md).

---

## In the capstone: annotate your own code

The best version of this exercise is on code *you* wrote. Once your PRS backend is
underway, open your own `UsersController.cs`, pick out the same parts — class, base
class, field, constructor, parameter, method, method call, local variable, argument,
object — and name each one. If you can label your own controller, you understand what
you built; if a token stumps you, that's the thing to go look up.
