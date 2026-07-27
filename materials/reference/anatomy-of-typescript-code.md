# Anatomy of TypeScript Code — Naming the Parts

An evergreen reference for the whole **React/TypeScript pass** and the capstone. You can
*write* TypeScript and React before you can *talk* about it — this sheet closes that gap.
It points at every token in the three files you build for one feature — an **interface**,
an **API module**, and a **list component** — and names what each is: **interface**,
**property**, **type**, **object**, **method**, **function**, **hook**, **parameter**,
**argument**, and the rest.

Keep it open from **React Lesson 3–4** (your first component and your first fetch) onward.
There's a blank [quiz version](anatomy-of-typescript-code-quiz.md) for practice. This is the
TypeScript companion to the API pass's
[Anatomy of C# Code](anatomy-of-csharp-code.md) — same idea, different language: C# concentrates
everything in a **class**; React spreads it across a small **interface**, a plain **object**
of functions, and a **function** that returns UI.

All three specimens are the **Staff** feature — the exact code you write in Lessons 3–4.

---

## Specimen A — a model interface (`staff/IStaff.ts`)

An **interface** describes the *shape* of your data — which properties an object has and
what type each one is. It's TypeScript's answer to a C# data class, with no methods: just
**properties**.

```ts
// src/staff/IStaff.ts
export interface IStaff {          // ① ②
  id: number | undefined;          // ③ ④
  firstName: string;               // ⑤
  lastName: string;
  username: string;
  isManager: boolean;              // ⑥
  isAdmin: boolean;
}
```

| # | Token | What it is |
|---|---|---|
| ① | `export` | **Named export** — makes `IStaff` importable from other files (matched by `import { IStaff }`) |
| ② | `IStaff` | **Interface** — the *shape* of a staff object; a type *you* define (React's answer to a data class) |
| ③ | `id` | **Property** — one named field in the shape |
| ④ | `number \| undefined` | **Union type** — the value is *either* a `number` *or* `undefined` (a new staff has no id until the server assigns one) |
| ⑤ | `string` | **Type annotation** — the type written after the `:`; `string` here is a **primitive type** |
| ⑥ | `boolean` | **Primitive type** — a built-in true/false type |

> An interface is a **type, not a value** — it exists only while TypeScript checks your code
> and is *erased* from the JavaScript that actually runs. You never create an `IStaff` with
> `new`; you create plain **objects** that *match* its shape (see Specimen C).

---

## Specimen B — an API module (`staff/StaffAPI.ts`)

An **API module** is a plain **object** that groups an entity's fetch calls as **methods**,
so components call `staffAPI.list()` instead of scattering `fetch` everywhere. It's the
closest React analog to a controller: an object whose members are the functions that talk to
the server.

```ts
// src/staff/StaffAPI.ts
import { IStaff } from "./IStaff";                          // ①
const url = "http://localhost:5556/api/staff";             // ②

export const staffAPI = {                                  // ③ ④
  list(): Promise<IStaff[]> {                              // ⑤ ⑥
    return fetch(url).then((response) => response.json()); // ⑦ ⑧ ⑨ ⑩
  },
};
```

| # | Token | What it is |
|---|---|---|
| ① | `import { IStaff } …` | **Named import** — pulls `IStaff` in from its file (curly braces, exact name) |
| ② | `url` | **Constant** — a `const` variable, set once and never reassigned |
| ③ | `staffAPI` | **Object** — an object literal grouping related functions (your "API module") |
| ④ | `list` | **Method** — a function stored as a property of that object |
| ⑤ | `Promise<IStaff[]>` | **Type argument (generic)** — `list` returns a `Promise` *of* `IStaff[]`; the `<…>` fills in the generic |
| ⑥ | `IStaff[]` | **Array type** — "an array of `IStaff`" |
| ⑦ | `fetch(url)` | **Function call** — invoking the browser's built-in `fetch` |
| ⑧ | `url` (in `fetch(url)`) | **Argument** — the actual value passed at the call site |
| ⑨ | `.then(…)` | **Method call** — invoking `then` on the promise `fetch` returned |
| ⑩ | `(response) => …` | **Arrow function** — an inline function; `response` is its **parameter** |

---

## Specimen C — a list component (`staff/StaffPage.tsx`)

A **function component** is a function that returns **JSX** (the UI). This one holds the
fetched staff in **state**, loads them once on mount, and renders them with `.map()`. Trimmed
slightly (no loading flag or styling) to keep the callouts readable.

```tsx
// src/staff/StaffPage.tsx
import { useEffect, useState } from "react";        // ①
import { IStaff } from "./IStaff";
import { staffAPI } from "./StaffAPI";

function StaffPage() {                               // ②
  const [staff, setStaff] = useState<IStaff[]>([]);  // ③ ④

  async function loadStaff() {                       // ⑤
    const data = await staffAPI.list();              // ⑥ ⑦
    setStaff(data);                                  // ⑧
  }

  useEffect(() => {                                  // ⑨
    loadStaff();
  }, []);

  return (
    <section className="list">
      {/* ⑩ = <section>, ⑪ = .map, ⑫ = staffMember */}
      {staff.map((staffMember) => (
        <div className="card" key={staffMember.id}>
          {staffMember.firstName} {staffMember.lastName}
        </div>
      ))}
    </section>
  );
}

export default StaffPage;                            // ⑬
```

| # | Token | What it is |
|---|---|---|
| ① | `import { useEffect, useState } …` | **Named import** — brings the two hooks in from React |
| ② | `StaffPage` | **Function component** — a function that returns JSX (React's unit of UI) |
| ③ | `useState<IStaff[]>([])` | **Function call** to a **hook**; `[]` is its **argument** (the initial value) |
| ④ | `<IStaff[]>` | **Type argument (generic)** — tells `useState` the state holds an `IStaff[]` |
| ⑤ | `loadStaff` | **Function** — a named function you *define* (here, nested inside the component) |
| ⑥ | `data` | **Local variable** — a `const` that lives only inside `loadStaff` |
| ⑦ | `staffAPI.list()` | **Method call** — invoking `list` on the `staffAPI` object |
| ⑧ | `setStaff(data)` | **Function call**; `data` is the **argument** passed to the state setter |
| ⑨ | `useEffect(() => {…}, [])` | **Function call** to a hook; its first **argument** is an **arrow function** |
| ⑩ | `<section>…</section>` | **JSX element** — the UI this component returns (its one root element) |
| ⑪ | `staff.map(…)` | **Method call** — invoking `.map` on the `staff` array |
| ⑫ | `(staffMember) => …` | **Arrow function**; `staffMember` is its **parameter** (one item per element) |
| ⑬ | `export default StaffPage` | **Default export** — the file's single main export (imported without braces) |

---

## The distinctions students trip on

These pairs use similar words for different things. Getting them straight is the whole point
of the exercise.

**1. Interface vs. object.** An **interface** (`IStaff`) is a compile-time *blueprint* — a
type that describes a shape and then *disappears* from the running code. An **object**
(`{ id: 1, firstName: "Sam", … }`, or each item `.json()` hands back) is a real value living
in memory. You never write `new IStaff()`; you make plain objects that *match* the interface.

**2. Local variable vs. state.** Both hold data. A **local variable** (`data` in `loadStaff`)
is born inside a function and gone the instant it returns. **State** (`staff` from `useState`)
*persists across renders* and, when you change it with its setter (`setStaff`), tells React to
re-render. State is React's version of "a value the object keeps."

**3. Type vs. value.** `IStaff` is a **type**; `staff` is a **value**. Anything after a `:`
(`: IStaff[]`) or inside `<…>` (`<IStaff[]>`) is a type — checked at build time, then erased.
Everything else is a real value the program moves around. Casing can't tell them apart; only
position can.

**4. Parameter vs. argument.** A **parameter** is the placeholder in a function's
*definition* (`staffMember` in `(staffMember) => …`). An **argument** is the real value passed
at the *call* (`data` in `setStaff(data)`). Same idea, opposite ends of the call.

**5. Function vs. function call.** *Defining* `loadStaff` or `StaffPage` is a **function**.
*Running* `staffAPI.list()`, `useState(...)`, or `useEffect(...)` is a **call**. A **hook** is
simply a function call whose name starts with `use` and that React treats specially.

**6. Named vs. default export.** `export interface IStaff` and `import { IStaff }` are
**named** — curly braces, exact name, a file can have many. `export default StaffPage` and
`import StaffPage from …` are **default** — no braces, one per file, and the importer may
rename it. Mixing them up ("why won't my import find it?") is the #1 import bug.

---

## Bonus: primitive types vs. object types (the two kinds of type)

Every property, parameter, and variable has a **type**. Those types come in two families —
and knowing which is which explains *why* the interface-vs-object distinction (#1) matters.

| Type in the specimens | Family | A variable of this type holds… |
|---|---|---|
| `number` (`id`), `string` (`firstName`), `boolean` (`isManager`) | **primitive type** — built-in, a lowercase keyword | the value itself, stored directly |
| `IStaff`, `IStaff[]`, `{ … }` (an object literal) | **object type** — interfaces, arrays, objects | a *reference* pointing to an object elsewhere in memory |

- **Primitive types** are the built-in simple kinds: `number`, `string`, `boolean` (plus
  `null` and `undefined`). Lowercase keywords. The variable *is* the value — copy it and you
  copy the number.
- **Object types** are interfaces you define (`IStaff`), arrays (`IStaff[]`), and object
  literals. The variable doesn't hold the object; it holds a *reference* to one. That's why
  `staff` (the state) and the array it points to are two different things, and why
  `staff.map(...)` reaches through the reference to the real array.
- **Two things that surprise C# developers:** there's a single **`number`** — no separate
  `int`/`decimal`/`double`. And TypeScript's types are **structural and erased**: it checks
  that an object has the right *shape* at build time, then throws the types away — the app
  that runs is plain JavaScript with no `IStaff` in sight.

> A quick tell: primitive types are lowercase keywords (`number`, `string`, `boolean`). Types
> in PascalCase (`IStaff`, `Promise`) are ones with a *name you could go read* — an interface,
> class, or built-in object type.

---

## How to use this in a lesson

- **As a warm-up quiz:** hand out the [blank version](anatomy-of-typescript-code-quiz.md) — same
  code, empty legend, a word bank — and have students fill it in before revealing this key.
- **As a live callout:** during the Lesson 3–4 build, pause on each new token and ask
  "interface, object, function, call, parameter, or hook?" before moving on.
- **In the capstone:** the exact same parts appear in `UserAPI.ts` and every other PRS
  feature (`ProductsPage`, `VendorAPI`, …). The vocabulary transfers unchanged — open your own
  file and name each part; if a token stumps you, that's the thing to go look up.
