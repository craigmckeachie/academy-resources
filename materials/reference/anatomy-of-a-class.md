# Anatomy of a Class — Naming the Parts

An evergreen reference for the whole API pass and the capstone. You can *write* C#
before you can *talk* about it — this sheet closes that gap. It points at every token
in a real model and a real controller and names what it is: **class**, **object**,
**method**, **parameter**, **field**, **local variable**, and the rest.

Keep it open from **API Lesson 2** (your first controller) onward. There's a blank
[quiz version](anatomy-of-a-class-quiz.md) for practice, and a companion
[C# naming conventions](csharp-naming-conventions.md) sheet — once you can *name* a
part, its casing tells you how to *write* it.

Both specimens below are copied verbatim from the TableServe reference API.

---

## Specimen A — a model class (`Models/MenuItem.cs`)

A **model** is a plain class whose whole job is to hold data. Its parts are almost all
**properties**.

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

| # | Token | What it is |
|---|---|---|
| ① | `TableServe.Api.Models` | **Namespace** — the folder-like grouping this class lives in |
| ② | `MenuItem` | **Class** — the blueprint you're defining; the type of a menu-item object |
| ③ | `Id` | **Property** — a public member with `{ get; set; }` that holds one piece of data |
| ④ | `int` | **Type** — what kind of value the `Id` property holds |
| ⑤ | `Category?` | **Class used as a type** — the property's type is *another class* |
| ⑥ | `Category` | **Navigation property** — a property whose type is a related entity |

> ⑤ and ⑥ are the same word on the same line: the first `Category` is a **type**, the
> second is the **property name**. That reuse is legal and common — the position tells
> you which is which.

---

## Specimen B — a controller class (`Controllers/CategoriesController.cs`)

A **controller** is a class whose members are the **methods** that answer HTTP requests.
Trimmed slightly to keep the callouts readable.

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

| # | Token | What it is |
|---|---|---|
| ① | `[ApiController]` | **Attribute** — metadata attached to the class (also `[HttpGet]`, `[Route]`) |
| ② | `CategoriesController` | **Class** — the blueprint you're defining |
| ③ | `ControllerBase` | **Base class** — the class this one *inherits* from (after the `:`) |
| ④ | `TableServeDbContext` | **Class used as a type** — the type of the `_db` field |
| ⑤ | `_db` | **Field** — a private variable that lives for the whole life of the object (note the `_`) |
| ⑥ | `CategoriesController(...)` | **Constructor** — the special method that builds the object |
| ⑦ | `db` | **Parameter** — a value handed *into* the constructor |
| ⑧ | `GetAll` | **Method** — a named block of behavior you *define* |
| ⑨ | `ToListAsync()` | **Method call** — *invoking* a method (also `.Add(...)`, `.FindAsync(...)`) |
| ⑩ | `id` | **Parameter** — a value handed into the `GetById` method |
| ⑪ | `category` | **Local variable** — a variable that exists only inside this one method |
| ⑫ | `id` (in `FindAsync(id)`) | **Argument** — the actual value passed *at the call site* |
| ⑬ | `new { id = ... }` | **Object** — an instance created at runtime with `new` |

---

## The six distinctions students trip on

These pairs use similar words for different things. Getting them straight is the whole
point of the exercise.

**1. Class vs. object.** A **class** is the blueprint, written once (`Category`). An
**object** is a specific instance living in memory while the program runs. In a
controller you rarely *see* `new Category()` — the objects arrive from model binding
(`newCategory`) or the database (`category`). The one object literally created with
`new` here is the anonymous object at ⑬.

**2. Field vs. local variable.** Both are variables. A **field** (`_db`) belongs to the
object and survives across every method call — declared at class level, `_`-prefixed by
convention. A **local variable** (`category`) is born inside a method and gone the
instant that method returns.

**3. Property vs. field.** A **property** has `{ get; set; }` and is normally public
(`Name`, `Id`) — it's the public face of the data. A **field** is a bare variable,
normally private (`_db`). Rule of thumb in this codebase: *models expose properties,
controllers keep one private field*.

**4. Parameter vs. argument.** A **parameter** is the placeholder in the method
*definition* (`int id` in `GetById(int id)`). An **argument** is the real value you pass
at the *call* (`id` inside `FindAsync(id)`). Same word, opposite ends of the call.

**5. Method vs. method call.** *Defining* `GetById` is a **method**. *Running*
`_db.Categories.FindAsync(id)` is a **method call** (an invocation). And `nameof(GetById)`
refers to a method *by name without calling it*.

**6. Type vs. variable.** On `public Category? Category { get; set; }`, the first
`Category` is a **type** (a class used to declare something); the second is the
**variable/property** being declared. Casing can't help you here — only position can.

---

## Bonus: value types vs. classes (the two kinds of datatype)

Every property, parameter, and variable has a **type** (callouts ④ and ⑤). Those types
come in two families — and knowing which is which explains *why* the class-vs-object
distinction (#1 above) matters.

| Type in the specimens | Family | A variable of this type holds… |
|---|---|---|
| `int` (`Id`), `decimal` (`Price`), `bool` | **value type** — built-in, often called a "primitive" | the value itself, stored directly |
| `Category`, `MenuItem` — classes you defined | **reference type** | a *reference* pointing to an object |
| `string` (`Name`) | **reference type** — a class, but used like a value | text you can treat like a simple value |

- **Value types** are the built-in simple kinds: `int`, `decimal`, `bool`, `char`,
  `DateTime`. The variable *is* the value — copy it and you copy the number.
- **Reference types** are **classes** — every model in this app (`MenuItem`, `Category`,
  `Order`) plus arrays and lists. The variable doesn't hold the object; it holds a
  *reference* to an object that lives elsewhere in memory. This is exactly why, at ⑬, the
  variable `newCategory` and the **object** it points to are two different things.
- **The famous surprise: `string` is a class, not a primitive.** It's a reference type,
  yet C# lets you use it like a simple value (`"Loaded Nachos"`), so it *feels* built-in.
  If you assumed every capitalized-but-lowercase-keyword type was a primitive, `string`
  is the exception to remember.

> A quick tell: the built-in value types are C# **keywords** (lowercase — `int`, `decimal`,
> `bool`, `string`). Types written in PascalCase (`Category`, `DateTime`, `ActionResult`)
> are **classes/structs** with a name you could go read. `string` is the odd one — a
> keyword that's really a class.

---

## How to use this in a lesson

- **As a warm-up quiz:** hand out the [blank version](anatomy-of-a-class-quiz.md) — same
  code, empty legend, a word bank — and have students fill it in before revealing this key.
- **As a live callout:** during the Lesson 2 build, pause on each new token and ask
  "class, object, method, parameter, field, or local?" before moving on.
- **In the capstone:** the exact same parts appear in `UsersController` and every other
  PRS controller. The vocabulary transfers unchanged.
