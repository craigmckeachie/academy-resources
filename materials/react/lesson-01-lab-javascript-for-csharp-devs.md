# Lesson 1 Lab — Translating C# to JavaScript

Practice the JavaScript from the guide by translating small C# snippets into JS in your
scratch project. No React, no API — just `src/main.ts` and the browser **Console**.
Refer back to the guide for syntax.

> **Prerequisite:** the `js-ts-playground` scratch project from the guide, running with
> `npm run dev` and its DevTools **Console** open.

---

## Steps

1. In `src/main.ts`, clear any starter code. You'll log everything with `console.log(...)`.

2. **Variables & equality.** Declare `const restaurant = "TableServe";` and
   `let coversTonight = 40;`. Reassign `coversTonight` to `55`. Log both. Then log
   `1 === 1` and `1 === "1"` — note the second is `false` (no coercion).

3. **Template literal.** Given `const item = "Ribeye"; const price = 24.99;`, build and
   log `` `${item} costs $${price}` ``.

4. **Object + destructuring.** Create
   `const staff = { id: 1, firstName: "Sam", lastName: "Diaz", isManager: true };`.
   **Destructure** `firstName` and `lastName` out of it and log a full name with a
   template literal.

5. **Spread.** Make `const promoted = { ...staff, isManager: true, isAdmin: true };` and
   log it. Confirm `staff` itself is unchanged (log it too) — spread made a **new** object.

6. **The loop evolution.** Start from:
   ```ts
   const prices = [9.99, 24.99, 7.5, 15];
   ```
   Translate this C# in three stages, logging each result:
   ```csharp
   // C#: give each price a 10% markup
   var marked = new List<decimal>();
   foreach (var p in prices) marked.Add(p * 1.1m);
   ```
   - **Stage 1:** a `for` loop that pushes into a new `marked` array.
   - **Stage 2:** `prices.forEach(...)` pushing into a new array.
   - **Stage 3:** `prices.map((p) => p * 1.1)` — one line.

7. **`.filter()` = LINQ `.Where()`.** From the same `prices`, log only those under `$16`
   with `prices.filter(...)`. (C#: `prices.Where(p => p < 16)`.)

8. **Modules.** Create `src/money.ts` that `export`s a named `format` helper — the same
   `function format(n: number)` from the guide (§9), returning a currency string.
   `import { format }` into `main.ts` and log `format(24.99)` (→ `$24.99`).

---

## Verify in the browser

With `npm run dev` running (verification details are in the guide, section 10):

1. Every step prints to **DevTools → Console** (F12) with no red errors.
2. After the spread step, the original `staff` object logs unchanged — proof spread
   copies rather than mutates.
3. All three loop stages produce the **same** array — proof `.map()` is just the concise
   form of the `for` loop.
4. `format(24.99)` logs `$24.99`, imported from another file — proof modules connect files.

Same language, different shape from C# — and exactly the JavaScript you'll be writing in
every React component starting in Lesson 3.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **Chain `.filter()` then `.map()`** — [Reinforce] — from an array of menu-item objects,
  filter to items under `$10` and then map them to just their names, in one chained
  expression: `items.filter(...).map(...)`. This is the LINQ `.Where(...).Select(...)`
  chain you'll use to shape data before rendering.
- **Nested destructuring** — [Reinforce] — given
  `const order = { id: 5, staff: { firstName: "Sam" } }`, pull `firstName` out in one
  destructuring statement (`const { staff: { firstName } } = order;`) and log it.
- **Sum with `.reduce()`** — [Reach] — add up an array of prices into a single total with
  `.reduce()` (not covered in the guide — you'll need to research it). This is how the
  running order total is computed later. Reference:
  [Array.prototype.reduce() (MDN)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce).
- **Optional chaining `?.`** — [Reach] — given an object whose nested property might be
  missing, safely read it with `?.` so you get `undefined` instead of a crash (not in the
  guide — research it). You'll use this constantly on API data. Reference:
  [Optional chaining (?.) (MDN)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Optional_chaining).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that
span the whole React pass.
