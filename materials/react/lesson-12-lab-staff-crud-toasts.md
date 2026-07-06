# Lesson 12 Lab — Toasts and Error Handling for Staff CRUD

Retrofit your **Staff** CRUD (list, create/edit, delete) with **success/error toasts**
and the shared **`checkStatus`/`parseJSON`** fetch helpers — the same feedback and
centralized error handling the guide added to Menu Items. Refer back to the guide for
the `checkStatus` helper and the try/success/catch shape.

---

## Steps

1. If you haven't already, create `src/utility/fetchUtilities.ts` (from the guide) with
   `BASE_URL`, `checkStatus`, and `parseJSON`.
2. Refactor `StaffAPI.ts` so every method chains `.then(checkStatus).then(parseJSON)`
   (`delete` just `.then(checkStatus)`), importing `BASE_URL` for the `url`.
3. In `StaffList`'s `loadStaff`, wrap the fetch in `try/catch` and
   `toast.error(error.message, { duration: 6000 })` on failure.
4. In `StaffForm`'s `save`, `toast.success("Successfully saved.")` after POST/PUT and
   `toast.error(error.message)` in the `catch` (with a `return` so you stay on the form).
5. In the `StaffCard` delete handler, `toast.success("Successfully deleted.")` after the
   delete + `onRemove`.

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

Same toast + centralized-error pattern, a different entity — exactly how you'll add
feedback to every PRS CRUD screen in the capstone.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **Position a toast** — [Reinforce] — pass `{ position: "bottom-center" }` to a
  `toast.success` (as the OrderItem form does) and compare it to the default top
  position.
- **A loading toast** — [Reinforce] — replace a save's success/error with
  `toast.promise(staffAPI.post(staff), { loading: "Saving…", success: "Saved!", error:
  "Save failed" })` so one call handles all three states.
- **Custom error messages** — [Reinforce] — extend `translateStatusToErrorMessage` with
  a `409` case ("That username is already taken") and confirm a duplicate-username
  create surfaces it.
- **Dismiss on navigation** — [Reach] — explore `toast.dismiss()` to clear lingering
  toasts when leaving a page, and read the API surface for custom toasts. Reference:
  [react-hot-toast docs](https://react-hot-toast.com/docs).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that
span the whole React pass.
```
