# Lesson 12 Lab — Toasts and Error Handling, Staff and the Rest of the App

Two parts. **First**, retrofit your **Staff** CRUD (list, create/edit, delete) with
**success/error toasts** and the shared **`checkStatus`/`parseJSON`** helpers — the same
feedback the guide added to Menu Items, on your own entity. **Then** finish the job across
the app: the guide converted one API module and one set of screens, and left the rest
deliberately half-converted for you.

Refer back to the guide for the `checkStatus` helper and the try/success/catch shape.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`) with
> Staff seed data loaded, and you have the Staff CRUD from earlier lessons.

---

## Part 1 — Staff

1. Nothing to create — `src/utility/fetchUtilities.ts` already exists from the guide.
2. Refactor `StaffAPI.ts` so every method chains `.then(checkStatus).then(parseJSON)`
   (`delete` just `.then(checkStatus)`), importing `BASE_URL` for the `url`. One special case:
   the inline `if (!response.ok) throw` you wrote in Lesson 11's `findByAccount` becomes a
   plain `.then(checkStatus)` — that hand-rolled guard was always a placeholder for this.
3. In `StaffPage`'s `loadStaff`, wrap the fetch in `try/catch` and
   `toast.error(error.message, { duration: 6000 })` on failure.
4. In `StaffForm`'s `save`, `toast.success("Successfully saved.")` after POST/PUT and
   `toast.error(error.message)` in the `catch` (with a `return` so you stay on the form).
5. In the `StaffCard` delete handler (Lesson 6 lab), wrap the `delete` + `onRemove` in a
   `try/catch` — `toast.success("Successfully deleted.")` on success, `toast.error(error.message)`
   in the `catch`. Now that `staffAPI.delete` runs through `checkStatus`, a failed delete throws.
6. **✅ Checkpoint:** a save shows the green toast; a delete removes the card and toasts; with
   the API stopped, `/staff` shows a red error toast instead of a silent blank page.

---

## Part 2 — the rest of the app

You've now done the whole pattern twice: once with the instructor on Menu Items, once on your
own with Staff. What's left is mechanical repetition, and it's what makes the app consistent —
right now three modules still swallow their errors.

**The API modules** — same three edits as Staff: import `{ BASE_URL, checkStatus, parseJSON }`,
switch `const url` to use `BASE_URL`, and chain `.then(checkStatus).then(parseJSON)` on every
method that returns data (`.then(checkStatus)` alone where there's no body — `delete`, and
workflow calls like `cancel`).

- [ ] `OrderAPI.ts`
- [ ] `OrderItemAPI.ts`
- [ ] `CategoryAPI.ts`

**The screens** — now that every call throws, a fetch with no `catch` fails silently:

- [ ] **`OrdersPage`** — `loadOrders` has **no `try`/`catch` at all**. Add one (plus `finally`
  if you set a loading flag) and toast `error.message`. This is the one that matters most:
  before this lesson a failed fetch quietly rendered an empty table; now it throws into nothing.
- [ ] **`CategoriesPage`** — swap the `console.error` placeholder you copied from
  `MenuItemsPage` for a toast.

**The delete handlers** — the ⋮ menus you wrote before this lesson call `delete` and then
`onRemove` with nothing guarding them. Give each the same `try`/`catch` treatment you just gave
`StaffCard`: success toast inside the `try`, `toast.error(error.message)` in the `catch`. Until
you do, a rejected delete throws unhandled **and still removes the row** from the list:

- [ ] **`OrderRow`** (Lesson 6)
- [ ] **`CategoryCard`** (Lesson 9 lab)

**Already correct, don't touch:** `OrderDetailPage`, `MenuItemForm`, `OrderItemForm`, and
`SignInPage` all toast in their `catch` already — written that way in Lessons 8–11, they just
had no `<Toaster />` to render into until Lesson 11. And **`ErrorPage`'s `console.error` stays**
— it's the router's error boundary, not a fetch catch.

**✅ Checkpoint:** stop the API and load `/orders`, `/categories`, and `/menuitems` in turn —
each shows a **red error toast** rather than an empty table or blank grid. Restart the API, then
delete a category and an order — each confirms, removes the row, and toasts
**"Successfully deleted."**

---

## Verify in the browser

Browser checks are covered in the guide — section 5. With your API running and
`npm run dev` up:

1. Save a valid staff member → green **"Successfully saved."**; delete one → green
   **"Successfully deleted."**
2. Stop the API and reload `/staff` → a red error toast, and the **Console** logs the
   `http error status` detail from `checkStatus`. Restart and confirm recovery.
3. Trigger a server rejection (e.g. a duplicate username, which is unique) on create →
   red toast, and you **stay on the form**.
4. Toasts auto-dismiss and stack.
5. With the API stopped, every list page — `/staff`, `/orders`, `/categories`, `/menuitems` —
   toasts instead of failing silently. **That consistency is the deliverable**: one helper
   decides how failure reads, and no screen is exempt.

Same toast + centralized-error pattern, a different entity, then every entity — exactly how
you'll add feedback to every PRS CRUD screen in the capstone.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **Position a toast** — [Reinforce] — pass `{ position: "bottom-center" }` to a
  `toast.success` and compare it to the default top position. Worth trying on a form
  reached from a detail page (the Order Item form), where a top toast can land far from
  where the user is looking.
- **A loading toast** — [Reinforce] — replace a save's success/error with
  `toast.promise(staffAPI.post(staff), { loading: "Saving…", success: "Saved!", error:
  "Save failed" })` so one call handles all three states.
- **Custom error messages** — [Reinforce] — extend `translateStatusToErrorMessage` with
  a `409` case ("That username is already taken") and confirm a duplicate-username
  create surfaces it.
- **Dismiss on navigation** — [Reach] — explore `toast.dismiss()` to clear lingering
  toasts when leaving a page, and read the API surface for custom toasts. Reference:
  [react-hot-toast — the `toast()` API](https://react-hot-toast.com/docs/toast).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that
span the whole React pass.
