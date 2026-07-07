# Lesson 1 Guide — JavaScript for C# Developers

**This is an intro / overview lesson.** It comes *before* the React build. You just
spent the API pass writing C#; React is written in **JavaScript** (and TypeScript, next
lesson), the language of the browser. The good news: you already know how to program —
loops, methods, types, classes are all here. This lesson maps what you know in C# onto
the JavaScript syntax you'll see in every React file, and spends the most time on the
few things that have **no C# equivalent** (destructuring, spread, modules). There's no
React, no API, and no reference app yet — you verify everything **by observation** in a
tiny throwaway project's **browser console**.

**Goal:** by the end of this lesson you can read and write the JavaScript that React
code is made of: `let`/`const`, arrow functions, template literals, objects and
**destructuring**, the **spread** operator, array methods (`.map()`/`.filter()`), and
**ES module** `import`/`export` — each anchored to the C# feature it corresponds to.

**The general pattern you're learning:** most C# concepts have a direct JavaScript
twin — a `List<T>` is a `T[]`, a LINQ `.Select()` is a `.map()`, a lambda `x => x` is an
arrow function `x => x`. Learn the handful of genuinely new pieces and the rest is
translation.

> **Where you'll run this:** you'll create one small **scratch project** with Vite and
> write plain JavaScript/TypeScript in `src/main.ts`, reading the output in the browser's
> DevTools **Console**. It is deliberately separate from the real React app you build in
> Lesson 3 — a sandbox to try the language in, nothing more. This lesson has no
> `tableserve/` reference code because it precedes the build; that's intentional.

---

## 1. From C# to JavaScript

| You know (C#) | You're learning (JavaScript) |
|---|---|
| Compiled, runs on .NET | Interpreted, runs in the browser |
| Statically typed at compile time | Dynamically typed (types added by **TypeScript**, next lesson) |
| `List<T>`, LINQ, lambdas | arrays, array methods, arrow functions |
| `namespace` / `using` | ES **modules** (`import` / `export`) |
| `Console.WriteLine(...)` | `console.log(...)` → shows in the browser Console |

The mental shift: JavaScript is more permissive than C#. It won't stop you at compile
time — a typo becomes a runtime surprise. That looseness is exactly why TypeScript
(Lesson 2) exists, and why we use it everywhere in this course.

---

## 2. The scratch project

Create a one-off sandbox to run snippets in. From a folder outside your API work:

```bash
npm create vite@latest js-ts-playground -- --template vanilla-ts
cd js-ts-playground
npm install
npm run dev
```

- `--template vanilla-ts` gives you plain TypeScript — **no framework**, just a file to
  run code in. (It's TypeScript, so it also serves Lesson 2 — you won't make a second
  project.)
- `npm run dev` prints a URL (usually `http://localhost:5173`). Open it, then open
  **DevTools → Console** (F12).
- Open `src/main.ts`, delete the starter counter code, and write your own. Anything you
  `console.log(...)` appears in that Console. Save and the page reloads automatically.

Throughout this lesson, "run it" means: paste into `src/main.ts`, save, read the
Console. This is the equivalent of the C# console app you used to try language features.

We'll use one small menu throughout this lesson. Put it at the top of `src/main.ts`:

```ts
const menu = [
  { id: 1, name: "Nachos", price: 9.99 },
  { id: 2, name: "Ribeye", price: 24.99 },
  { id: 3, name: "Mozzarella Sticks", price: 7.5 },
];
```

Keep `menu` at the top of the file; for each **▶ Try it** below, replace the code
*beneath* it and save. That way `menu` stays put and you never declare the same `const`
twice.

---

## 3. Variables — `let`, `const`, and no more `var`

C# infers types with `var`; JavaScript declares variables with `let` (reassignable) and
`const` (not reassignable). **Prefer `const`**; reach for `let` only when the value
changes.

```ts
const price = 9.99;     // like C#'s `var price = 9.99;` but can't be reassigned
let quantity = 1;       // reassignable
quantity = 2;           // fine
// price = 10;          // error: can't reassign a const

console.log(price, quantity);
```

> **▶ Try it** — paste below `menu` and save, then uncomment `// price = 10;`.
> **Console:** `9.99 2`. Uncommenting the reassignment turns that line red in the editor:
> *Cannot assign to 'price' because it is a constant.*

- There's an older keyword, **`var`** — you'll see it in old code. **Don't use it**; its
  scoping rules are surprising. `let`/`const` are block-scoped like C# locals.
- **Always compare with `===` / `!==`** (strict equality), never `==`. `==` does
  surprising type coercion (`0 == ""` is `true`); `===` behaves like C#'s `==`.
- JavaScript has the idea of **truthy/falsy**: in a condition, `0`, `""`, `null`,
  `undefined`, and `NaN` act false; everything else acts true. You'll lean on this for
  conditional rendering later (`{items.length && ...}`).

---

## 4. The primitive types (mapped to C#)

JavaScript has far fewer number types than C# — just one:

| C# | JavaScript | Note |
|---|---|---|
| `string` | `string` | double **or** single quotes; backticks for templates (§5) |
| `int`, `long`, `double`, `decimal` | `number` | **one** numeric type for all of them |
| `bool` | `boolean` | `true` / `false` |
| `null` | `null` **and** `undefined` | two "nothings" — `undefined` = never set, `null` = explicitly empty |
| `T[]` / `List<T>` | array `[...]` | `[1, 2, 3]` |
| object / `Dictionary` | object `{...}` | `{ name: "Nachos", price: 9.99 }` |

```ts
const name = "Loaded Nachos";     // string
const price = 9.99;               // number
const onMenu = true;              // boolean
const tags = ["spicy", "shared"]; // string[]
```

> **▶ Try it** — log the values and a couple of their types:
> ```ts
> console.log(name, price, onMenu, tags);
> console.log(typeof price, typeof onMenu);
> ```
> **Console:** `Loaded Nachos 9.99 true ['spicy', 'shared']`, then `number boolean` — note
> `9.99` reports as `number`, not a separate decimal type.

The two-nothings distinction (`null` vs `undefined`) is the one surprise here — a value
that was never assigned is `undefined`; you use `null` when you deliberately mean "empty."

---

## 5. Arrow functions and template literals

You wrote lambdas in LINQ (`staff => staff.LastName`). JavaScript's **arrow function** is
the same idea and the same `=>` token:

```ts
const double = (n) => n * 2;         // one expression: value is returned implicitly
const greet = (first, last) => {     // a block body needs an explicit return
  const full = first + " " + last;
  return full;
};
console.log(double(5));              // 10
```

Arrow functions are *everywhere* in React — every event handler and every `.map()`
callback is one.

**Template literals** are C#'s `$"..."` string interpolation, using **backticks** and
`${ }`:

```ts
const item = "Nachos", price = 9.99;
const label = `${item} — $${price}`;   // C#: $"{item} — ${price}"
console.log(label);                    // Nachos — $9.99
```

> **▶ Try it** — paste both snippets beneath `menu`. **Console:** `10`, then
> `Nachos — $9.99`.

---

## 6. Objects and destructuring

An object literal is a bag of key/value properties — the JS stand-in for a C# object or
`Dictionary`:

```ts
const menuItem = { id: 1, name: "Nachos", price: 9.99 };
console.log(menuItem.name);          // dot access, like C#
```

**Destructuring** has no C# equivalent and is worth slowing down for — it pulls
properties out into their own variables in one line:

```ts
const { name, price } = menuItem;    // two consts in one statement
console.log(name, price);            // Nachos 9.99
```

Arrays destructure by position:

```ts
const [first, second] = ["a", "b"];  // first = "a", second = "b"
```

> **▶ Try it** — destructure the first item from the `menu` in section 2:
> ```ts
> const { name, price } = menu[0];
> console.log(name, price);
> ```
> **Console:** `Nachos 9.99`

You'll see destructuring constantly in React — `const [value, setValue] = useState()`,
and pulling props out of a component's argument. **The payoff lands in Lesson 5**, where
you'll receive your first component prop and destructure it across three steps until it
clicks.

---

## 7. The spread operator (`...`)

`...` **spreads** the contents of one array or object into another — a copy-and-extend
in one token. No direct C# equivalent.

```ts
const base = ["spicy", "shared"];
const more = [...base, "popular"];        // ["spicy", "shared", "popular"] — a NEW array

const item = { id: 1, name: "Nachos" };
const priced = { ...item, price: 9.99 };  // { id, name, price } — a NEW object
```

> **▶ Try it** — spread a menu item into a new object, then check the original is untouched:
> ```ts
> const special = { ...menu[0], onSpecial: true };
> console.log(special);
> console.log(menu[0]);
> ```
> **Console:** `{ id: 1, name: 'Nachos', price: 9.99, onSpecial: true }`, then the original
> `{ id: 1, name: 'Nachos', price: 9.99 }` — spread copied, it didn't mutate.

The key idea: spread makes a **new** value rather than mutating the original — the
functional style React relies on for state updates. You'll also meet spread in
react-hook-form (`{...register("name")}` spreads several props onto an input) and in
route setup. For now just recognize the token and that it copies.

---

## 8. The evolution of loops — from `for` to `.map()`

This is the single most important pattern to bring into React, so watch how it evolves.
Say you have numbers and want each one times ten.

**Stage 1 — the `for` loop.** The C-style loop you know from C#: manage an index, push
into a new array.

```ts
const numbers = [1, 2, 3];
const tens = [];
for (let i = 0; i < numbers.length; i++) {
  tens.push(numbers[i] * 10);
}
```

**Stage 2 — `forEach`.** A method that calls a function once per element — no index to
manage, but you still push manually.

```ts
const tens = [];
numbers.forEach((number) => tens.push(number * 10));
```

**Stage 3 — `.map()`.** `map` **transforms** an array into a new one: give it a function,
get back a new array of the results. No temp array, no `push`.

```ts
const tens = numbers.map((number) => number * 10);
```

> **▶ Try it** — run the three stages one at a time (each one replaces the last beneath
> `menu`). Each logs the same thing:
> ```ts
> console.log(tens);
> ```
> **Console:** `[10, 20, 30]`

`.map()` is exactly **LINQ's `.Select()`** (`numbers.Select(n => n * 10)` in C#), and
**`.filter()`** is **LINQ's `.Where()`** — run it on the `menu` from section 2:

> **▶ Try it** — paste and save.
> ```ts
> const cheap = menu.filter((item) => item.price < 10);
> console.log(cheap);
> ```
> **Console:** two items — `Nachos` ($9.99) and `Mozzarella Sticks` ($7.5); `Ribeye` is
> filtered out.

Both `.map()` and `.filter()` return a **new** array and don't touch the original — same
functional spirit as LINQ.

Why does this matter for React? Because rendering a list *is* a transform: an array of
data mapped into an array of UI. In Lesson 3 you'll write exactly this — and you'll walk
the same `for → forEach → map` progression again, but transforming data into **JSX
elements** instead of numbers. `.map()` is how React renders every list.

---

## 9. ES Modules — `import` and `export`

C# organizes code with `namespace` and `using`. JavaScript uses **modules**: each file
exports what it wants to share, and other files import it. Two flavors:

**Named exports** — export several things by name; import them in `{ }` braces:

```ts
// money.ts
export const TAX_RATE = 0.07;
export function format(n: number) { return `$${n.toFixed(2)}`; }

// main.ts
import { TAX_RATE, format } from "./money";
```

**Default export** — one "main" thing per file; import it with any name, no braces:

```ts
// MenuItemsPage.tsx
export default function MenuItemsPage() { /* ... */ }

// App.tsx
import MenuItemsPage from "./menuItems/MenuItemsPage";
```

You'll use both against real libraries this course installs — the pattern is the same:

```ts
import App from "./App";                          // default: the app's root component
import { BrowserRouter } from "react-router-dom";  // named: one of many router exports
import { useForm } from "react-hook-form";         // named: the form hook
```

Rule of thumb we follow: **components are default exports** (one per file), while
**helpers, interfaces, and hooks are named exports**. When you see `{ }` in an import,
it's a named export; no braces means default. This is how every file in the Lesson 3
project will connect to the others.

> **▶ Try it** — make `src/money.ts` with the named `format` export shown above. Add the
> import at the **top** of `main.ts`, then log below `menu`:
> ```ts
> import { format } from "./money";
> // ...menu and the rest below...
> console.log(format(menu[0].price));
> ```
> **Console:** `$9.99` — pulled from another file and wired by a named export.

---

## 10. Verifying in the browser

There's no API and no reference app — you verify **by reading the Console**. With
`npm run dev` running and `src/main.ts` open:

1. `console.log(...)` a value and confirm it prints in **DevTools → Console** (F12).
2. Try to reassign a `const` — the editor/Console shows an error. Change it to `let` and
   it works. That's the difference between the two.
3. `.map()` an array and log the result — confirm you get a **new** array and the
   original is unchanged (`console.log(original)` after).
4. Split a helper into its own file, `export` from it, `import` into `main.ts`, and log
   the result — proof that modules connect files.

If a change doesn't show, check the Console for an error and confirm the page reloaded.

---

## The General Pattern (what to take away)

- **`const` by default, `let` when it changes**; never `var`; compare with `===`.
- One `number` type; `string`, `boolean`; two nothings (`null` / `undefined`).
- **Arrow functions** (`x => ...`) are lambdas; **template literals** (`` `${x}` ``) are
  `$"..."`.
- **Destructuring** (`const { a, b } = obj`) and **spread** (`{...obj}`) are the two new
  ideas with no C# twin — spread makes new values instead of mutating.
- **`.map()`** = LINQ `.Select()`, **`.filter()`** = LINQ `.Where()`; both return new
  arrays. This is how React renders lists.
- **Modules**: default export for components, named exports (`{ }`) for helpers/hooks.

Everything in this pass is built from these. Lesson 2 adds **types** back on top; Lesson
3 renders your first real components with `.map()`.

---

## Build Steps

1. Scaffold the scratch project:
   `npm create vite@latest js-ts-playground -- --template vanilla-ts`, then `cd` in,
   `npm install`, `npm run dev`.
2. Open the printed URL and its **DevTools → Console**; clear `src/main.ts`.
3. Declare values with `const`/`let`; log them; try reassigning a `const` to see the
   error.
4. Write an arrow function and a template-literal string; log both.
5. Build an object; **destructure** two properties out of it; **spread** it into a new
   object with an added property.
6. Take an array and transform it three ways — `for` loop, `forEach`, then **`.map()`** —
   and **`.filter()`** it; confirm each result in the Console.
7. Move a helper into its own file, `export` it, `import` it into `main.ts`, and log the
   result.
