# Lesson 2 Guide — TypeScript for C# Developers

**This is an intro / overview lesson.** JavaScript (Lesson 1) has no compile-time types.
**TypeScript** adds them back — and as a C# developer, this is the most familiar ground
in the whole pass. TypeScript is JavaScript plus static types; the person who created
C# (Anders Hejlsberg) also leads TypeScript, and it shows. This lesson maps C#'s type
system onto TypeScript's so you can read and write the typed data every React component
uses. You keep using the **same scratch project** from Lesson 1, verifying by watching
the type errors your editor reports.

**Goal:** by the end of this lesson you can annotate values, parameters, and return types;
define an **interface** to describe a data shape; use **optional** (`?`) and **union**
(`|`) types for nullable data; and recognize arrays, `Record`, and generics — all mapped
to their C# equivalents. You'll understand every type annotation you meet in the React
code.

**The general pattern you're learning:** TypeScript is a translation of C#'s type system
onto JavaScript. `string` is `string`, `List<T>` is `T[]`, an `interface` is a model
class. Learn the mapping and the one real surprise — **structural** typing — and you can
read any typed React file.

> **Same scratch project.** The `js-ts-playground` from Lesson 1 is already TypeScript
> (`.ts` files), so keep using it. There's no React or reference app here yet — that
> starts in Lesson 3. Verify by observation: the editor underlines type errors, and the
> Vite dev server reports them in the terminal/Console. For each **▶ Try it**, replace the
> code in `src/main.ts` and save.

---

## 1. Why TypeScript — and the one real surprise

In JavaScript, `const price = 9.99` has no declared type, and nothing stops you writing
`price.toUpperCase()` until it explodes at runtime. TypeScript checks types **before**
the code runs — exactly the safety net C# gave you. The TypeScript compiler (`tsc`)
checks your types and then **erases** them, emitting plain JavaScript the browser runs
(Vite does this for you on every save).

One genuine difference from C# to know up front: TypeScript is **structurally typed**,
not nominally typed. In C#, a type matches only if it's *named* — a class must explicitly
implement `IStaff`. In TypeScript, anything with the right **shape** matches, name or
not:

```ts
interface IStaff { firstName: string; lastName: string; }

const p = { firstName: "Sam", lastName: "Diaz", extra: 1 };
const s: IStaff = p;   // ✅ allowed — p has the required shape, name doesn't matter
```

> **▶ Try it** — paste it: no error, because `p` has the required shape. Now add an object
> that's missing a field:
> ```ts
> const bad: IStaff = { firstName: "Sam" };
> ```
> **You'll see:** *Property 'lastName' is missing in type '{ firstName: string; }' but
> required in type 'IStaff'.*

If it has the properties the type requires, it fits. That's the mental adjustment; the
rest is familiar.

---

## 2. The C# → TypeScript type map

This table is the heart of the lesson — keep it handy:

| C# | TypeScript | Note |
|---|---|---|
| `string` | `string` | same |
| `int` / `long` / `double` / `decimal` | `number` | one numeric type |
| `bool` | `boolean` | |
| `T[]` / `List<T>` | `T[]` or `Array<T>` | `IStaff[]` = "array of staff" |
| `Dictionary<string, T>` | `Record<string, T>` | key/value map |
| `string?` (nullable) | `string \| null` or optional `?` | see §5 |
| `class` / model | `interface` | shape of an object (§4) |
| `interface IFoo` | `interface IFoo` | same keyword, structural |
| generic `List<T>`, `Func<T>` | generic `Array<T>`, `<T>(...)` | `<T>` syntax (§6) |
| lambda `x => x` | arrow `x => x` | from Lesson 1 |
| `async Task<T>` | `async (): Promise<T>` | see §8 |
| `void` | `void` | |
| `object` (anything) | `unknown` / `any` | prefer `unknown` (§7) |

---

## 3. Type annotations

Add a type after a colon. On variables it's usually optional (TypeScript **infers** it,
like C# `var`), but on function parameters and return types it's where the value lives:

```ts
const price: number = 9.99;          // explicit — but `const price = 9.99` infers `number`
let name: string;                    // declared, not yet assigned

function total(price: number, qty: number): number {
  return price * qty;                // params typed; return type after the ) 
}

const format = (n: number): string => `$${n.toFixed(2)}`;   // arrow with types
```

> **▶ Try it** — call `total` right, then wrong:
> ```ts
> console.log(total(9.99, 2));   // 19.98
> total("9.99", 2);              // ← the string argument is flagged
> ```
> **Console:** `19.98`. **You'll see** on the second line: *Argument of type 'string' is not
> assignable to parameter of type 'number'.*

Annotate **parameters and return types**; let inference handle obvious locals. If you
call `total("9.99", 2)`, the compiler stops you — the C# safety you're used to.

---

## 4. Interfaces — your C# model, restated

An **interface** describes the shape of an object: a named set of properties and their
types. It's the front-end echo of your C# model class. We prefix ours with **`I`**
(`IStaff`, `IMenuItem`, `IOrder`):

```ts
export interface IStaff {
  id: number;
  firstName: string;
  lastName: string;
  isManager: boolean;
  isAdmin: boolean;
}

const s: IStaff = {
  id: 1, firstName: "Sam", lastName: "Diaz", isManager: true, isAdmin: false,
};
```

> **▶ Try it** — with the interface and `s` above in the file, log a field, then declare one
> that omits a required property:
> ```ts
> console.log(s.firstName);   // Sam
> const partial: IStaff = { id: 2, firstName: "Ana", lastName: "Cruz", isManager: false };
> ```
> **Console:** `Sam`. **You'll see** on the second line: *Property 'isAdmin' is missing in
> type … but required in type 'IStaff'.*

Compare the C# `Staff` model from the API pass — same properties, same intent. The
interface is how the front end knows what the API returns and what a form must collect.
Interfaces are **erased** at runtime (they're types, not values), so they cost nothing;
they exist purely to check your code.

---

## 5. Optional and nullable — `?` and union types

C#'s `string?` marks a value that may be absent. TypeScript has two related tools:

**Optional properties** with `?` — the property may be missing entirely:

```ts
interface IStaff {
  id: number;
  firstName: string;
  phone?: string;        // may be absent — like C# `string? Phone`
  email?: string;
}
```

**Union types** with `|` — the value is one of several types. `string | null` means "a
string or null"; you'll also see it for ids that don't exist until the server assigns one:

```ts
id: number | undefined;         // a number, or not set yet
status: "Placed" | "Preparing" | "Ready";   // a literal union — one of these exact strings
```

> **▶ Try it** — declare a status with the literal-union type and give it a bad value:
> ```ts
> let status: "Placed" | "Preparing" | "Ready" = "Done";
> ```
> **You'll see:** *Type '"Done"' is not assignable to type '"Placed" | "Preparing" |
> "Ready"'.* Change `"Done"` to `"Placed"` and it clears.

That last form — a **literal union** — is TypeScript's lightweight alternative to an
enum: it pins a value to a fixed set of strings with no separate `enum` declaration.
TypeScript has an `enum` keyword too, but this course never uses it — and the reference
app goes lighter still, typing `status` as plain `string`. Treat the literal union as the
stricter option you *could* reach for, not what the app actually does. Optional `?` and
`| undefined` overlap; you'll see both in the reference code.

---

## 6. Arrays, `Record`, and generics

- **Arrays:** `IStaff[]` is "array of staff" — the type you give a fetched list.
  `Array<IStaff>` is the same thing, spelled with generics.
- **Generics** are the same idea as C# — a type parameter in angle brackets. You mostly
  *consume* generics rather than write them: `useState<IStaff[]>([])` says "this state
  holds an array of staff," just like `List<Staff>`.
- **`Record<K, V>`** is C#'s `Dictionary<K, V>` (`Record<string, number>` maps string keys
  to number values). Worth **recognizing** as the `Dictionary` mapping — but you'll rarely
  reach for it in this app, which shapes its data with interfaces and arrays.

```ts
const staff: IStaff[] = [];    // List<Staff>
```

> **▶ Try it** — with `IStaff` in the file, build a typed array and push an incomplete item:
> ```ts
> const roster: IStaff[] = [];
> roster.push({ id: 1, firstName: "Sam" });   // ← flagged
> ```
> **You'll see:** *Argument … is missing the following properties from type 'IStaff':
> lastName, isManager, isAdmin.*

---

## 7. `any` and `unknown` — the escape hatches

`any` turns type-checking **off** for a value — it accepts anything and checks nothing.
It's the "trust me" hatch; avoid it, because it discards the safety you came here for.
`unknown` is the safe sibling: it holds anything but forces you to narrow the type before
use. Prefer `unknown` (or a real type) over `any`. You'll rarely need either once your
interfaces describe the data.

> **▶ Try it** — watch `any` switch type-checking off:
> ```ts
> const raw: any = "not a number";
> console.log(raw * 2);
> ```
> **Console:** `NaN` — the compiler let it through with no complaint; that's exactly what
> `any` costs you.

---

## 8. A first look at `async`/`await`

You already know `async`/`await` from C# — **the keywords are identical in JavaScript**.
The only new piece is the return type: a JS async function returns a **`Promise<T>`**
(C#'s `Task<T>`).

```ts
async function loadStaff(): Promise<IStaff[]> {
  const response = await fetch("http://localhost:5556/api/staff");
  return await response.json();
}
```

That's all for now — a preview so the syntax isn't new when it matters. You'll learn
`fetch`, Promises, and `async`/`await` **properly in Lesson 4**, where you load real data
into a page. Recognize the shape here; use it there.

---

## 9. Verifying in the editor and browser

TypeScript's feedback shows up as you type — you verify by **making the compiler
complain, then satisfying it**. In `src/main.ts`:

1. Type an interface and assign a matching object — no error.
2. **Break it on purpose:** remove a required property, or assign a `string` to a
   `number`. The editor underlines it in red and the Vite terminal/Console reports the
   type error. Read the message — this is the safety net doing its job.
3. Fix it and the error clears.
4. Add an optional `phone?` and assign an object *without* it — allowed. Make it required
   (remove the `?`) and the same object now errors.
5. `console.log(...)` a typed value to confirm it still runs — types are erased, the JS
   underneath is what executes.

---

## The General Pattern (what to take away)

- TypeScript is **JavaScript + C#-style types**, checked before run and then erased.
- The **type map** is the whole game: `number` for all numerics, `T[]` for `List<T>`,
  `Record<K,V>` for `Dictionary`, `interface` for a model class.
- An **interface** (`IStaff`) names a data shape — the front-end echo of your C# model —
  and TypeScript matches it **structurally** (by shape, not name).
- **`?`** marks optional properties; **`|`** builds union types (`number | undefined`, or
  literal-string unions — a lightweight stand-in for an enum, though the app types
  `status` as plain `string`).
- **`async`/`await`** are the same keywords as C#; a JS async function returns a
  `Promise<T>` — full treatment in Lesson 4.

Lesson 3 puts this to work: you'll write an `IMenuItem` interface and a typed
`IMenuItem[]` array, then render it — types and components together.

---

## Build Steps

1. In the same `js-ts-playground` project, open `src/main.ts`.
2. Add a `number`/`string`/`boolean` value with explicit annotations; remove the
   annotations and confirm inference gives the same types (hover to check).
3. Write a typed function with typed **parameters and a return type**; call it wrong
   (pass a `string` for a `number`) and watch the error, then fix it.
4. Define an `IStaff` **interface** (id, names, `isManager`, `isAdmin`) and assign a
   matching object.
5. Add an **optional** `phone?` and a **union** `id: number | undefined`; test each by
   assigning objects with and without them.
6. Type an array as `IStaff[]` and a map as `Record<number, IStaff>`.
7. Break a type on purpose, read the compiler error, and fix it (verification section 9).
