# Lesson 2 Lab — Typing a Menu Item

Practice TypeScript by giving types to the kind of data the app is built from. Same
`js-ts-playground` scratch project, same `src/main.ts` — this time you're watching the
**type errors**, not just the Console. Refer back to the guide for the type map.

> **Prerequisite:** the `js-ts-playground` project from Lesson 1, running with
> `npm run dev`, editor open on `src/main.ts`.

---

## Steps

1. **An interface.** Define an `IMenuItem` interface with:
   - `id: number | undefined`
   - `name: string`
   - `price: number`
   - `categoryId: number`
   - `available?: boolean` (optional)

2. **A matching object.** Declare `const nachos: IMenuItem = { ... }` with real values.
   Leave `available` off — allowed, because it's optional.

3. **Break it, read it, fix it.** Temporarily assign `price: "9.99"` (a string). Read the
   red underline / terminal error, then fix it back to a number. This is the whole point
   of TypeScript — see it catch the mistake.

4. **A typed function.** Write
   `function lineTotal(item: IMenuItem, quantity: number): number` that returns
   `item.price * quantity`. Call it with `nachos` and `3`; log the result.

5. **Wrong on purpose.** Call `lineTotal(nachos, "3")` and confirm the compiler rejects
   the string argument. Fix it.

6. **A typed array.** Declare `const menu: IMenuItem[] = [ ... ]` with two or three items.
   Log `menu.length`.

7. **A union "enum".** Add `status: "Placed" | "Preparing" | "Ready"` to a small `order`
   object. Assign `"Placed"` — fine. Assign `"Done"` — confirm the compiler rejects it
   (it's not one of the allowed strings).

---

## Verify in the browser

Verification for this pass is by observation (guide section 9):

1. Steps 3, 5, and 7 each produce a **type error** you can read in the editor and the
   Vite terminal/Console — then clear once fixed. Catching these is success.
2. The valid steps `console.log` their results with no errors — proof the types compile
   away to working JavaScript.
3. Removing the `?` from `available` and re-checking `nachos` surfaces a new error
   (missing required property), showing what optional buys you.

You just described the shape of app data exactly the way every feature folder does — an
`IStaff`, `IProduct`, or `IRequest` interface is the first file you'll write for each
entity, on TableServe in Lesson 3 and on PRS in the capstone.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **Add a nested type** — [Reinforce] — define an `ICategory { id: number; name: string }`
  and add `category?: ICategory` to `IMenuItem`. Assign an item both with and without a
  nested category object. This mirrors the API's nav-property shape.
- **A reusable list type** — [Reinforce] — declare `Record<number, IMenuItem>` mapping id
  to item, and populate it from your array. That's the `Dictionary<int, MenuItem>`
  equivalent.
- **A generic function** — [Reach] — write a `first<T>(items: T[]): T | undefined` that
  returns the first element of any typed array (not covered in the guide — research
  generic functions). Reference:
  [TypeScript: Generics](https://www.typescriptlang.org/docs/handbook/2/generics.html).
- **A utility type** — [Reach] — use `Partial<IMenuItem>` to type an object holding just
  *some* menu-item fields (the shape an edit form's changes take), and note how it makes
  every property optional (not in the guide — research it). Reference:
  [TypeScript: Utility Types](https://www.typescriptlang.org/docs/handbook/utility-types.html).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that
span the whole React pass.
