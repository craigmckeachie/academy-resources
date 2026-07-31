# TypeScript / React Naming Conventions — Cheat Sheet

An evergreen reference for the whole React pass and the capstone. Like C#, TypeScript uses
**casing** to signal what an identifier *is* — but a few rules **flip** from the API pass,
because JavaScript and React have their own conventions. Once you can name the parts of a
component (see [Anatomy of TypeScript Code](anatomy-of-typescript-code.md)), casing tells you
how to write each one. Match these and your code reads like the reference implementation.

---

## The core rules

| Identifier | Casing | Example (from this course) |
|---|---|---|
| **Components** | PascalCase | `function MenuItemCard()`, `<OrderDetailPage />` |
| **Interfaces** (API entities) | `I` + PascalCase | `interface IMenuItem`, `IStaff`, `IOrderItem` |
| **Types / local shapes** | PascalCase | `StaffContextType`, `SubmitHandler<IOrder>` |
| **Custom hooks** | `use` + PascalCase | `useStaffContext()` (built-ins: `useState`, `useEffect`) |
| **Functions** | camelCase | `loadMenuItems()`, `formatPhoneNumber()`, `persistStaff()` |
| **API modules** | camelCase object | `menuItemAPI`, `orderAPI` |
| **Object methods** | camelCase | `menuItemAPI.list()`, `.find()`, `.post()` |
| **Variables & state** | camelCase | `const menuItems`, `let orderId`, `[loading, setLoading]` |
| **Interface properties** | camelCase | `menuItem.name`, `order.tableNumber`, `staff.isAdmin` |
| **Booleans** | `is` / `has` + PascalCase | `isAdmin`, `isManager`, `isCancelOpen`, `isOwnOrder` |
| **Local event handlers** | `handle…` / a verb | `handleSubmit`, `handleStatusChange`, `openCancel` |
| **Callback props** (passed to a child) | `on…` | `onRemove`, `onHide` |
| **App-wide constants** | UPPER_SNAKE_CASE | `BASE_URL` (ordinary `const`s stay camelCase: `url`, `emptyStaff`) |

---

## File & folder naming

TypeScript/React also uses casing in **file and folder names**, which C# doesn't. The file name
matches the **main thing it exports**:

| Thing | Casing | Example |
|---|---|---|
| **Feature folders** | camelCase (plural for entities) | `menuItems/`, `orders/`, `orderItems/`, `staff/` |
| **Component files** | PascalCase `.tsx` | `MenuItemCard.tsx`, `OrderDetailPage.tsx` |
| **Interface files** | `I` + PascalCase `.ts` | `IMenuItem.ts`, `IStaff.ts` |
| **API module files** | PascalCase + `API.ts` | `MenuItemAPI.ts`, `OrderAPI.ts` |
| **Utility files** | camelCase `.ts` | `fetchUtilities.ts`, `formatUtilities.ts` |

`MenuItemCard.tsx` exports `MenuItemCard`; `IMenuItem.ts` exports `IMenuItem`. (Initialisms stay
upper — it's `MenuItemAPI`, not `MenuItemApi`.)

---

## Key takeaways

- **PascalCase** — **types and components**: interfaces (`IMenuItem`), type/shape names
  (`StaffContextType`), and every **component** (`OrderRow`). React *requires* the capital on a
  component (see the footnotes) — the one casing rule that's a real rule, not just style.
- **camelCase** — nearly everything else you write: **functions** (`loadMenuItems`), **object
  methods** (`.list()`), **variables/state** (`menuItems`, `setLoading`), and **interface
  properties** (`name`, `tableNumber`). If it *holds* or *does* something rather than *being* a
  type or component, it's camelCase.
- **Prefixes carry meaning:** `use…` marks a **hook**, `is…`/`has…` marks a **boolean**, and
  `on…` marks a **callback prop** (versus `handle…` for the local handler behind it).
- **UPPER_SNAKE_CASE** is reserved for a true app-wide constant like `BASE_URL`; an ordinary
  `const` that just holds data stays camelCase.

---

## The three flips from C#

You already know C# naming from the API pass. Three rules **change** in TypeScript — miss these
and your front-end code fights the reference:

| | C# (API pass) | TypeScript (React pass) |
|---|---|---|
| **Methods / functions** | PascalCase — `GetAll()`, `Create()` | camelCase — `list()`, `loadMenuItems()` |
| **Properties** | PascalCase — `Name`, `TableNumber` | camelCase — `name`, `tableNumber` |
| **Interfaces** | `I` + PascalCase — `IActionResult` | *same* — `I` + PascalCase — `IMenuItem` |

The property flip has a reason: the API serializes your C# `MenuItem.Name` to **camelCase JSON**
(`"name"`), so the TypeScript interface that models that JSON uses **`name`** to match the wire
format. Casing changes at the serialization boundary — the C# side is PascalCase; everything the
front end receives is camelCase.

---

## Casing as a clue

Because the rules are consistent, casing lets you *guess a token's role* before you know the code:

| You see… | It's almost certainly a… |
|---|---|
| `IMenuItem`, `IStaff` | **interface** (`I` + PascalCase) |
| `MenuItemCard`, `OrdersPage` | **component** (PascalCase, returns JSX) |
| `menuItemAPI`, `orderAPI` | **API module** (camelCase object with `.list()` etc.) |
| `useStaffContext`, `useParams` | **hook** (`use` prefix) |
| `loadMenuItems`, `formatPhoneNumber` | **function** (camelCase, called with `(...)`) |
| `menuItems`, `orderId` | **variable / state** (camelCase) |
| `isAdmin`, `isCancelOpen` | **boolean** (`is`/`has` prefix) |
| `onRemove`, `onHide` | **callback prop** (`on` prefix) |
| `BASE_URL` | **app-wide constant** (UPPER_SNAKE) |
| `[menuItems, setMenuItems]` | a **`useState` pair** (value + its setter) |

---

## Three honest footnotes

- **Components must be capitalized — this one's a real rule.** React reads a lowercase name as an
  HTML tag and a capitalized one as your component, so `<menuItemCard />` silently renders
  nothing. Everywhere else casing is convention; here it's enforced by React.
- **The `I` on interfaces is a course choice.** Keeping `IMenuItem` matches the C# you already
  know and signals "this models an API entity." Much of the TypeScript community **drops** the
  `I` (just `MenuItem`) — both are valid, but **match the reference and keep the `I`**. The `I`
  is for **entity** interfaces; a local-shape interface like the Context value is named
  descriptively instead (`StaffContextType`).
- **Convention, not compiler law.** TypeScript compiles any casing; these are shared style so
  every cohort's code (and the reference app) reads alike. Copilot will sometimes break them —
  suggesting `import type` (this course keeps plain `import`) or dropping the `I` prefix. The
  [Copilot quick-start](copilot-quickstart.md) covers catching that.
