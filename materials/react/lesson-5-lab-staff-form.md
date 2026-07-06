# Lesson 5 Lab — The Staff Create/Edit Form

Build the shared **Staff** form — one component for create and edit, with
**react-hook-form** — following the Menu Item form from the guide. Staff has **no FK
dropdown**; instead it has **role checkboxes**. Refer back to the guide for `register`,
validation, `defaultValues`, and the create-vs-edit switch.

---

## The Staff form fields

First Name (required), Last Name (required), Email (optional, `type="email"`), Phone
(optional), Username (required, max 50), Password (required, max 60), and two role
**checkboxes** — `isManager` and `isAdmin`.

---

## Steps

1. Add `find(id)`, `post(staff)`, and `put(staff)` to `StaffAPI.ts`.
2. Build `StaffForm` with `useForm<IStaff>`; read `:id` with `useParams`.
3. In `defaultValues` (async), return an `emptyStaff` blank when there's no `:id`, else
   `staffAPI.find(Number(id))`.
4. Register each field with validation:
   - `firstName`, `lastName`, `username` (add `maxLength: { value: 50, message: … }`),
     `password` (`maxLength: 60`) — all `required`.
   - `email`, `phone` — no rules (optional).
   - Show errors with the `is-invalid` class + `invalid-feedback` div, like the guide.
5. **Role checkboxes** — register as plain checkboxes (no rules); react-hook-form binds
   the boolean automatically:
   ```tsx
   <div className="form-check form-check-inline">
     <input {...register("isManager")} type="checkbox" className="form-check-input" />
     <label className="form-check-label">Manager</label>
   </div>
   ```
   (and the same for `isAdmin`).
6. Write `save` (`handleSubmit`): POST when `!staff.id` else PUT; on success
   `navigate("/staff")`.
7. Create thin `StaffCreatePage` / `StaffEditPage` and add routes `staff/create` and
   `staff/edit/:id` under `Layout`.

> **No FK dropdown, no `valueAsNumber`, no nested-object delete** — Staff has no
> foreign key, so its form is plain inputs plus checkboxes. Simpler than the Menu Item
> form. On PRS this is exactly the **Users** form (also no FK, also role flags).

---

## Verify in the browser

Browser checks are covered in the guide — section 7. With your API running and
`npm run dev` up:

1. **Add Staff** → `/staff/create`: empty fields, unchecked role boxes. Save with First
   Name empty → red field + "First name is required" (no network call). Fill it in,
   Save → back to the list, new card present. **Network** shows a **201** `POST`.
2. **⋮ → Edit** on a card → `/staff/edit/{id}`: fields pre-filled, the right role boxes
   `checked`. Toggle a role, Save → **200** `PUT`, card updates.
3. Confirm create and edit are the *same form* — only the URL's `:id` differs.
4. Console clean.

Same shared-form + react-hook-form pattern, checkboxes instead of an FK dropdown —
exactly how you'll build the PRS **Users** form in the capstone.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **Email format validation** — [Reinforce] — add a `pattern` rule to the email field
  so a malformed address shows an inline error, while still allowing it to be empty.
- **Password max-length message** — [Reinforce] — confirm the `maxLength: { value: 60 }`
  rule surfaces its message when exceeded; try pasting a long string and watch the
  `invalid-feedback` appear.
- **Disable Save while submitting** — [Reinforce] — pull `formState.isSubmitting` from
  `useForm` and set `disabled={isSubmitting}` on the Save button so a slow POST can't be
  double-submitted.
- **Watch a field live** — [Reach] — use react-hook-form's `watch("firstName")` to show
  a live "Hello, {firstName}" preview above the form as the user types. `watch` is the
  hook Lesson 8 leans on for derived fields — this is a gentle first look. Reference:
  [react-hook-form `watch`](https://react-hook-form.com/docs/useform/watch).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that
span the whole React pass.
```
