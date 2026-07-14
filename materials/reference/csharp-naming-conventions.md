# C# Naming Conventions — Cheat Sheet

An evergreen reference for the whole API pass and the capstone. C# uses **casing** to
signal what an identifier *is* — so once you can name the parts of a class (see
[Anatomy of a Class](anatomy-of-a-class.md)), casing tells you how to write each one.
Match these and your code reads like the reference implementation.

---

## The core rules

| Identifier | Casing | Example (from this course) |
|---|---|---|
| **Classes, structs, enums** | PascalCase | `class CategoriesController` |
| **Methods** | PascalCase | `public async Task<...> GetById(...)` |
| **Properties** (public members) | PascalCase | `public string Name { get; set; }` |
| **Constants** | PascalCase | `public const string Placed = "PLACED";` |
| **Parameters** (values passed in) | camelCase | `GetById(int id)`, `Create(Category newCategory)` |
| **Local variables** | camelCase | `var category = ...;` |
| **Private fields** | `_camelCase` | `private readonly TableServeDbContext _db;` |
| **Namespaces** | PascalCase (dotted) | `namespace TableServe.Api.Controllers` |
| **Interfaces** | `I` + PascalCase | `IActionResult`, `IEnumerable<Category>` |

---

## Key takeaways

- **PascalCase** — everything "public" or structural: **types** (classes, enums,
  interfaces), **methods**, **properties**, and **constants**. First letter capitalized,
  every word capitalized: `CreatedAtAction`, `SortOrder`.
- **camelCase** — the "internal" data you move around: **parameters**, **local
  variables**, and (with a leading underscore) **private fields**. First letter
  lowercase, later words capitalized: `newCategory`, `updatedStaff`.
- **The underscore rule** — always prefix a **private field** with `_` (`_db`). That one
  character is how you tell a field from a local variable at a glance — the single most
  useful casing signal in the codebase.

---

## Casing as a clue

Because the rules are consistent, casing lets you *guess a token's role* before you even
know the code:

| You see… | It's almost certainly a… |
|---|---|
| `_db`, `_name` | **private field** (underscore) |
| `Name`, `Price`, `Id` | **property** (PascalCase member of a model) |
| `GetAll`, `FindAsync` | **method** (PascalCase, followed by `(...)`) |
| `id`, `newCategory` | **parameter** or **local variable** (camelCase, no underscore) |
| `Category`, `MenuItem` | **class / type** (PascalCase, used to declare things) |
| `RequestStatus`, `OrderStatus` | **class** — usually a `static` holder of **constants** |

The one place casing *can't* help: `public Category? Category { get; set; }` — the type
and the property share a name. There, only **position** tells you which is which.

---

## Two honest footnotes

- **The `Async` suffix.** The .NET methods you *call* end in `Async` (`ToListAsync`,
  `FindAsync`) because they're awaitable. This course's own controller **actions**
  deliberately keep short names (`GetAll`, `GetById`) even though they're `async` — a
  chosen simplification, so don't rename yours to `GetAllAsync`.
- **This is convention, not compiler law.** C# will happily compile `myclass` or `ID` —
  the casing rules are a shared style so the whole cohort's code (and the reference
  implementation) reads the same way. Copilot will sometimes suggest names that break
  these; the [Copilot quick-start](copilot-quickstart.md) covers catching that.
