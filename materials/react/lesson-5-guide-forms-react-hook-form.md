# Lesson 5 Guide — Forms with react-hook-form and the Shared Create/Edit Pattern

**Goal:** by the end of this lesson you have the **Menu Item form** — one component
that handles both **Create** and **Edit**, built with **react-hook-form**, validating
required fields, and populating a **Category FK dropdown** from a fetch. You'll wire it
to thin `MenuItemCreatePage` and `MenuItemEditPage` route targets.

**The general pattern you're learning:** **create and edit are one form**. A form
registers its fields with react-hook-form, loads default values (empty for create, the
fetched record for edit), validates on submit, and on success POSTs (no id) or PUTs
(has id) then navigates away. An **FK dropdown** is a `<select>` whose options are
fetched from another entity. This is the single most repeated pattern in the app.

---

## 1. Why react-hook-form

You *could* wire each input with `useState` and an `onChange` (a "controlled input").
For a multi-field form that's a lot of boilerplate and re-renders on every keystroke.
**react-hook-form** manages all of it: you **register** each field, and it tracks
values, runs validation, and hands you the final object on submit — with minimal
re-rendering. The whole app's forms use it.

The core pieces from `useForm`:

```tsx
import { useForm, SubmitHandler } from "react-hook-form";

const {
  register,               // connect an input to the form
  handleSubmit,           // wrap your submit handler
  formState: { errors },  // per-field validation errors
} = useForm<IMenuItem>({ defaultValues: async () => { … } });
```

---

## 2. Registering fields and validating

`register("name", rules)` connects an input and declares its validation:

```tsx
<label htmlFor="name" className="form-label">Name</label>
<input
  id="name"
  {...register("name", { required: "Name is required" })}
  type="text"
  className={`form-control ${errors?.name && "is-invalid"}`}
  placeholder="Enter menu item name"
/>
<div className="invalid-feedback">{errors?.name?.message}</div>
```

- `{...register("name", …)}` **spreads** the props react-hook-form needs onto the input
  (name, ref, onChange). This is the spread operator from Lesson 3 doing real work.
- `{ required: "Name is required" }` — validation rules; the string is the error
  message. Other rules: `maxLength: { value: 50, message: "…" }`, `min`, `pattern`.
- `errors?.name` is set when the field is invalid → the template literal adds
  Bootstrap's `is-invalid` class → the `invalid-feedback` div shows
  `errors.name.message`. This is **conditional rendering** (Lesson 4) applied to
  validation.

Number and select fields register the same way; use `valueAsNumber: true` so the value
comes back as a number, not a string:

```tsx
{...register("price", { required: "Price is required" })}
{...register("categoryId", { valueAsNumber: true, required: "Category is required" })}
```

---

## 3. The submit handler

Wrap your handler in `handleSubmit` — it runs validation first and only calls you with
a valid object:

```tsx
const save: SubmitHandler<IMenuItem> = async (menuItem) => {
  try {
    delete menuItem.category; // the nested object isn't persisted — only categoryId
    if (!menuItem.id) {
      menuItem = await menuItemAPI.post(menuItem);   // Create → POST
    } else {
      await menuItemAPI.put(menuItem);               // Edit → PUT
    }
  } catch (error: any) {
    toast.error(error.message, { duration: 6000 });
    return;
  }
  toast.success("Successfully saved.");
  navigate("/menuitems");
};

// …
<form onSubmit={handleSubmit(save)}> … </form>
```

- **`if (!menuItem.id)` decides create vs. edit** — no id means a new record (POST);
  an id means an existing one (PUT). One handler, both operations. This is the crux of
  the shared form.
- On success, `navigate("/menuitems")` (from `useNavigate`, Lesson 6) returns to the
  list; a toast confirms (Lesson 10 covers toasts — the calls are shown here so the
  form is complete).
- `delete menuItem.category` drops the nested nav object before sending — the API wants
  `categoryId`, not the embedded category.

---

## 4. Default values — the switch that makes one form serve both

The form fills itself differently for create vs. edit via `defaultValues`, an **async
function** that runs before the form renders:

```tsx
let { id } = useParams<{ id: string }>();

const { register, handleSubmit, formState: { errors } } = useForm<IMenuItem>({
  defaultValues: async () => {
    await loadCategories();                       // fetch dropdown options either way
    if (!id) return Promise.resolve(emptyMenuItem);   // Create → blank record
    const menuItemId = Number(id);
    return await menuItemAPI.find(menuItemId);         // Edit → fetch the record
  },
});
```

- On **`/menuitems/create`** there's no `:id` param → return `emptyMenuItem` (a blank
  object) → empty fields.
- On **`/menuitems/edit/5`** the `:id` is `5` → fetch that menu item → its values
  pre-fill every registered field automatically.
- Either way, `loadCategories()` runs first so the FK dropdown has options ready.

`emptyMenuItem` is a module-level blank:

```ts
let emptyMenuItem: IMenuItem = {
  id: undefined, name: "", price: undefined, categoryId: undefined, category: {} as ICategory,
};
```

---

## 5. The FK dropdown — options from a fetch

Category is a **foreign-key dropdown**: its options are *other records*. Fetch them
into state and `.map()` them into `<option>`s:

```tsx
const [categories, setCategories] = useState<ICategory[]>([]);

async function loadCategories() {
  const data = await categoryAPI.list();
  setCategories(data);
}
```

```tsx
<label className="form-label" htmlFor="categoryId">Category</label>
<select
  id="categoryId"
  {...register("categoryId", { valueAsNumber: true, required: "Category is required" })}
  className={`form-select ${errors?.categoryId && "is-invalid"}`}
>
  <option value="">Select Category…</option>
  {categories.map((c) => (
    <option key={c.id} value={c.id}>{c.name}</option>
  ))}
</select>
<div className="invalid-feedback">{errors?.categoryId?.message}</div>
```

Each `<option value={c.id}>{c.name}</option>` carries the category's **id** in `value`
(what the API stores as `CategoryId`) and its **name** as the label. This is the static
pass's hardcoded FK dropdown, now populated live from the API. On edit, the record's
`categoryId` auto-selects the matching option.

---

## 6. The thin Create/Edit page wrappers

The route targets are tiny — a heading plus `<MenuItemForm />`. Both render the *same*
form; the URL (with or without `:id`) is what makes it behave as create or edit:

```tsx
function MenuItemCreatePage() {
  return (
    <section className="content container-fluid mx-5 my-2 py-4">
      <div className="d-flex justify-content-between pb-4 mb-5 border-bottom border-2">
        <h2>New Menu Item</h2>
      </div>
      <MenuItemForm />
    </section>
  );
}
```

`MenuItemEditPage` is identical but titled "Edit Menu Item". Wire both routes under
`Layout` in `main.tsx`:

```tsx
{ path: "menuitems/create", element: <MenuItemCreatePage /> },
{ path: "menuitems/edit/:id", element: <MenuItemEditPage /> },
```

The `:id` in the edit path is what `useParams` reads in section 4.

---

## 7. Verifying in the browser

Verify in the **browser**. With your API running and `npm run dev` up:

1. From `/menuitems`, click **Add Item** → `/menuitems/create`. Fields are empty; the
   **Category** dropdown lists your seeded categories.
2. Click **Save** with the Name empty — the field turns red and "Name is required"
   shows (react-hook-form validation, no network call). Fill it and a price, pick a
   category, Save → you return to the list with the new card present. Check **Network**
   for a **201** `POST`.
3. Open a card's **⋮ → Edit** → `/menuitems/edit/{id}`. Every field is **pre-filled**,
   including the selected category. Change the price, Save → back to the list, updated.
   Check **Network** for a **200** `PUT`.
4. Confirm the create page and edit page are the *same form* rendering differently —
   the only difference is whether the URL carried an `:id`.
5. Console clean.

---

## The General Pattern (what to take away)

- **One `Form` component serves create and edit.** `defaultValues` returns a blank
  object when there's no `:id`, or the fetched record when there is; `save` POSTs when
  `!id`, PUTs otherwise.
- **react-hook-form**: `{...register("field", rules)}` wires + validates each input;
  `handleSubmit(save)` runs validation then calls you; `errors.field` drives the
  `is-invalid` / `invalid-feedback` conditional display.
- **FK dropdown** = a `<select>` whose `<option value={id}>{name}</option>` come from a
  fetched list.
- Thin `CreatePage` / `EditPage` wrappers render the same form; the **route** (`:id` or
  not) decides its mode.

On PRS, the **Product** form is this exact pattern with a **Vendor** FK dropdown, and
the **Request** form is a shared create/edit form too.

---

## Build Steps

1. Add `find(id)`, `post(item)`, and `put(item)` to `MenuItemAPI.ts`.
2. Build `MenuItemForm` with `useForm<IMenuItem>`; read `:id` with `useParams`.
3. In `defaultValues` (async), `loadCategories()` first, then return `emptyMenuItem`
   when there's no `:id` or `menuItemAPI.find(id)` when there is.
4. Register **Name** (required), **Price** (required, number), and a **Category** FK
   `<select>` (`valueAsNumber`, required) fetched into `categories` state; render
   `errors` via `is-invalid` + `invalid-feedback`.
5. Write `save` (`handleSubmit`): `delete menuItem.category`, then POST when `!id` else
   PUT; on success `navigate("/menuitems")`.
6. Create thin `MenuItemCreatePage` / `MenuItemEditPage` and add both routes
   (`menuitems/create`, `menuitems/edit/:id`) under `Layout`.
7. Verify in the browser using section 7 — empty create, validation, pre-filled edit,
   201/200 in Network.
```
