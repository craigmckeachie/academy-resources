# Lesson 10 Lab — The Categories Create/Edit Form

Finish Categories CRUD with its form — the **simplest form in the app**: no FK dropdown, just
two fields. You've built two shared create/edit forms already: the **Menu Item** form (guide,
with a Category FK dropdown) and the **Staff** form (lab, no FK). This one is closest to
**Staff** — build it from memory, using `StaffForm` as your model.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`) with
> **Categories seed data**, and you have the Categories list from the Lesson 9 lab.

## The form fields

**Name** (required) and **Sort Order** (required, `valueAsNumber`). That's it — no FK, no
dropdown.

## Steps

Same arc as the Staff form: **API calls → the shared form → thin pages + routes.**

1. Add `post(category)` and `put(category)` to `CategoryAPI.ts` — the last two methods (your
   module already has `list` from Lesson 7, `find` from the Lesson 8 lab, and `delete` from the
   Lesson 9 lab).
2. **`CategoryForm`** — `useForm<ICategory>`; read `:id` with `useParams`; async
   `defaultValues` returns an `emptyCategory` (no `:id`) or `categoryAPI.find(Number(id))`.
   Register **Name** (`required`) and **Sort Order** (`required`, `valueAsNumber`), each with
   the `is-invalid` + `invalid-feedback` display. `save`: POST when `!category.id` else PUT,
   then `navigate("/categories")`.
3. Thin **`CategoryCreatePage`** / **`CategoryEditPage`** (heading + `<CategoryForm />`) and
   routes `categories/create` and `categories/edit/:id` under `Layout`.
4. **✅ Checkpoint:** **Add Category** opens an empty form; Save-empty shows inline errors; a
   valid save returns to the list (**201**); **⋮ → Edit** pre-fills the form and saves (**200**).

## Verify in the browser

With your API running and `npm run dev` up:

1. **Add Category** → `/categories/create`: empty form. Save with Name empty → red field +
   "Name is required" (no request). Fill both fields, Save → back to the list, new card,
   **201** `POST`.
2. **⋮ → Edit** a card → fields pre-filled; change the sort order, Save → **200** `PUT`, card
   updates.
3. Confirm create and edit are the *same form* — only the URL's `:id` differs. Console clean.

That completes Categories CRUD — list, card, form — the same shared-form pattern a third
time, on the simplest entity. On PRS this is the **Vendors** form (also no FK).

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you've done; **[Reach]** goes past it and needs some research.

- **`maxLength` rule** — [Reinforce] — add a `maxLength` **rule** (not the native attribute)
  to Name and paste a long string to watch the message fire — the paste-bypass demo from the
  Lesson 7 guide, on your own form.
- **Disable Save while submitting** — [Reinforce] — pull `formState.isSubmitting` and set
  `disabled={isSubmitting}` on the Save button so a slow POST can't be double-submitted.
- **Sensible default sort order** — [Reach] — default a new category's `sortOrder` to one past
  the current max (fetch the list, `Math.max(...sortOrders) + 1`) so new categories land at the
  end. Research react-hook-form default values:
  [useForm defaultValues](https://react-hook-form.com/docs/useform).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that span
the whole React pass.
