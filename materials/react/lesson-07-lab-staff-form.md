# Lesson 7 Lab — The Staff Create/Edit Form

Build the shared **Staff** form — one component for create and edit, with
**react-hook-form** — following the Menu Item form from the guide. Staff has **no FK
dropdown**; instead it has **role checkboxes**. Refer back to the guide for `register`,
the rule vocabulary, `defaultValues`, and the create-vs-edit switch.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`) with
> Staff seed data loaded. You're extending the `StaffPage` from earlier lessons.

## The Staff form fields

First Name (required), Last Name (required), Email (optional, with a format `pattern`),
Phone (optional), Username (required, `maxLength` 50), Password (required, `maxLength` 60),
and two role **checkboxes** — `isManager` and `isAdmin`.

---

## Steps

Same arc as the guide: **API calls → the form (fields + validation) → save → thin
pages + routes.**

1. Add `find(id)`, `post(staff)`, and `put(staff)` to `StaffAPI.ts`.
2. Build `StaffForm` with `useForm<IStaff>`; read `:id` with `useParams`. In `defaultValues`
   (async), return an `emptyStaff` blank when there's no `:id`, else
   `staffAPI.find(Number(id))`.
3. Register each field with validation (`is-invalid` + `invalid-feedback`, like the guide):
   - `firstName`, `lastName` — `required`.
   - `username` — `required` + `maxLength: { value: 50, message: "Username is too long" }`.
   - `password` — `required` + `maxLength: { value: 60, message: "Password is too long" }`.
   - `email` — **optional**, but add a **`pattern`** rule that still allows empty:
     ```tsx
     {...register("email", {
       pattern: { value: /^$|^\S+@\S+\.\S+$/, message: "Enter a valid email" },
     })}
     ```
     (The `^$|` lets an empty email pass; a malformed one shows the message. This is the one
     new client rule from the guide — email is otherwise unvalidated under react-hook-form.)
   - `phone` — optional, no rules.
4. **Role checkboxes** — register as plain checkboxes (no rules); react-hook-form binds the
   boolean automatically:
   ```tsx
   <div className="form-check form-check-inline">
     <input {...register("isManager")} type="checkbox" className="form-check-input" />
     <label className="form-check-label">Manager</label>
   </div>
   ```
   (and the same for `isAdmin`).
5. Write `save` (`handleSubmit`): POST when `!staff.id` else PUT; on success
   `navigate("/staff")`.
6. Create thin `StaffCreatePage` / `StaffEditPage` and add routes `staff/create` and
   `staff/edit/:id` under `Layout`. **✅ Checkpoint:** **Add Staff** opens an empty form;
   Save-empty shows inline errors; a valid save returns to the list (201), and **⋮ → Edit**
   pre-fills the form (200 on save).

> **No FK dropdown, no `valueAsNumber`, no nested-object delete** — Staff has no foreign
> key, so its form is plain inputs plus checkboxes. Simpler than the Menu Item form. On PRS
> this is exactly the **Users** form (also no FK, also role flags, also `maxLength` rules).

---

## Verify in the browser

Browser checks are covered in the guide — section 6. With your API running and
`npm run dev` up:

1. **Add Staff** → `/staff/create`: empty fields, unchecked role boxes. Save with First
   Name empty → red field + "First name is required" (no network call). Fill it in, Save →
   back to the list, new card present. **Network** shows a **201** `POST`.
2. **⋮ → Edit** on a card → `/staff/edit/{id}`: fields pre-filled, the right role boxes
   `checked`. Toggle a role, Save → **200** `PUT`, card updates.
3. Type a malformed email (e.g. `nope`) and Save → the email field shows its error; clear it
   (empty) and it passes.
4. Confirm create and edit are the *same form* — only the URL's `:id` differs. Console clean.

Same shared-form + react-hook-form pattern, checkboxes instead of an FK dropdown —
exactly how you'll build the PRS **Users** form in the capstone.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **Watch the paste-bypass** — [Reinforce] — paste a 70-character string into Password and
  Save; the `maxLength: { value: 60 }` **rule** fires its message (a native `maxlength`
  attribute would have silently truncated the paste instead — that's why the app uses the
  rule).
- **Disable Save while submitting** — [Reinforce] — pull `formState.isSubmitting` from
  `useForm` and set `disabled={isSubmitting}` on the Save button so a slow POST can't be
  double-submitted.
- **Watch a field live** — [Reach] — use react-hook-form's `watch("firstName")` to show a
  live "Hello, {firstName}" preview above the form as the user types. `watch` is the hook
  Lesson 10 leans on for derived fields — a gentle first look. Reference:
  [react-hook-form `watch`](https://react-hook-form.com/docs/useform/watch).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that
span the whole React pass.
