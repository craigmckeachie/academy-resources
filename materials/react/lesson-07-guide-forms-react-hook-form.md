# Lesson 7 Guide — Forms with react-hook-form and the Shared Create/Edit Pattern

**Goal:** by the end of this lesson you have the **Menu Item form** — one component that
handles both **Create** and **Edit**, built with **react-hook-form**, validating fields,
and populating a **Category FK dropdown** from a fetch — wired to thin `MenuItemCreatePage`
and `MenuItemEditPage` route targets. You'll also learn the **validation rule vocabulary**
and why client validation is **UX, not a security boundary**.

**The general pattern you're learning:** **create and edit are one form**. A form registers
its fields with react-hook-form, loads default values (empty for create, the fetched record
for edit), validates on submit, and on success POSTs (no id) or PUTs (has id) then navigates
away. An **FK dropdown** is a `<select>` whose options are fetched from another entity. This
is the single most repeated pattern in the app.

> **How to use this guide.** Sections headed **▶ Code along** are ones you **build into your
> project** — type them as you go, and each ends with a quick **Save and check**. Unmarked
> sections are concept: read them (or watch). Each code block carries its file name as a
> title bar. The **Build Steps** at the end recap every ▶ Code along action.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`) with
> **Menu Items and Categories seed data** loaded (the form's dropdown fetches categories),
> and you have the Menu Items list + shell from Lessons 4–6.

---

## 1. Why react-hook-form

*(Read this.)*

You *could* wire each input with `useState` and an `onChange` (a "controlled input"). For a
multi-field form that's a lot of boilerplate and a re-render on every keystroke.
**react-hook-form** manages it: you **register** each field, and it tracks values, runs
validation, and hands you the final object on submit — with minimal re-rendering. Every form
in the app uses it. The pieces from `useForm`:

```tsx
import { useForm, SubmitHandler } from "react-hook-form";

const {
  register,               // connect an input to the form
  handleSubmit,           // wraps your submit handler; runs validation first
  formState: { errors },  // per-field validation errors
} = useForm<IMenuItem>({ defaultValues: async () => { /* … */ } });
```

---

## 2. Registering a field — what `register` actually returns

*(Read this — you'll apply it in section 3.)*

The one function you use on every input is **`register`**. Before the shorthand, it helps to
see what it hands back. `register("name")` returns a plain **object** of the props an input
needs to be tracked — log it and look:

```tsx
console.log(register("name"));
// { name: "name", onChange: ƒ, onBlur: ƒ, ref: ƒ }
```

Four things, each a piece the input needs:

- **`name`** — the field's name (`"name"`), also the key react-hook-form stores its value
  under (it matches your `IMenuItem` property).
- **`onChange`** — the handler react-hook-form uses to record the value as the user types.
- **`onBlur`** — fires when the field loses focus, so rhf knows it's been "touched."
- **`ref`** — a callback ref that gives react-hook-form direct access to the DOM `<input>` to
  read its value. (Reading the input directly, instead of re-rendering on every keystroke, is
  what makes rhf fast.)

**Wire it by hand first, so there's no magic.** You could take that object and set each prop
on the input yourself:

```tsx
const nameField = register("name");   // { name, onChange, onBlur, ref }

<input
  id="name"
  name={nameField.name}
  ref={nameField.ref}
  onChange={nameField.onChange}
  onBlur={nameField.onBlur}
/>
```

That works — but setting four props on every field is tedious, and **`register` returns
exactly the object you'd spread.** So the shortcut does all four at once:

```tsx
<input id="name" {...register("name")} />   // identical to wiring name/ref/onChange/onBlur by hand
```

`{...register("name")}` is just the **spread operator** (Lesson 5) copying every property of
that returned object onto the `<input>` — same result, no boilerplate. This is how you'll
write every field from here on.

### Adding the validation rules

`register` takes a **second argument** — a `rules` object — that declares validation.
`errors` (from `formState`) then drives a **conditional** `is-invalid` class + an
`invalid-feedback` message (the Lesson 6 conditional pattern, applied to validation):

```tsx
<input
  id="name"
  {...register("name", { required: "Name is required" })}
  className={`form-control ${errors?.name && "is-invalid"}`}
/>
<div className="invalid-feedback">{errors?.name?.message}</div>
```

- The rules object declares validation; the string is the message shown on failure.
- `errors?.name && "is-invalid"` turns the field red only when it has an error;
  `errors?.name?.message` renders that message below it.

**The rule vocabulary** (you'll meet all four across the app's forms):

| Rule | Example | Notes |
|---|---|---|
| `required` | `{ required: "Name is required" }` | nearly every field |
| `maxLength` | `{ maxLength: { value: 50, message: "Too long" } }` | a **rule with a message**, *not* the native `maxlength` attribute |
| `min` | `{ min: { value: 1, message: "At least 1" } }` | e.g. quantity |
| `pattern` | `{ pattern: { value: /.../, message: "Invalid email" } }` | e.g. email format |

Two subtleties worth knowing:

- **`valueAsNumber: true`** on number/`<select>` fields returns a number, not a string:
  `{...register("price", { valueAsNumber: true, required: "Price is required" })}`.
- **`maxLength` is a rule, not the HTML `maxlength` attribute.** The native attribute
  *blocks* typing past the limit (and truncates a paste), so its message can never fire.
  The react-hook-form rule lets an over-long value in and then shows the message — which is
  what makes the "paste a long string and watch the error" demo possible.

---

## 3. ▶ Code along — Build the shared Menu Item form

First add the CRUD calls to the API module:

```diff title="src/menuItems/MenuItemAPI.ts"
  export const menuItemAPI = {
    ...  // list (Lesson 4)

+   find(id: number): Promise<IMenuItem> {
+     return fetch(`${url}/${id}`).then((response) => response.json());
+   },
+   post(menuItem: IMenuItem): Promise<IMenuItem> {
+     return fetch(url, {
+       method: "POST",
+       body: JSON.stringify(menuItem),
+       headers: { "Content-Type": "application/json" },
+     }).then((response) => response.json());
+   },
+   put(menuItem: IMenuItem): Promise<IMenuItem> {
+     return fetch(`${url}/${menuItem.id}`, {
+       method: "PUT",
+       body: JSON.stringify(menuItem),
+       headers: { "Content-Type": "application/json" },
+     }).then((response) => response.json());
+   },
  };
```

Now the form — one component for both create and edit:

```tsx title="src/menuItems/MenuItemForm.tsx"
import { Link, useNavigate, useParams } from "react-router-dom";
import bootstrapIcons from "../assets/bootstrap-icons.svg";
import { useForm, SubmitHandler } from "react-hook-form";
import { useState } from "react";
import { IMenuItem } from "./IMenuItem";
import { ICategory } from "../categories/ICategory";
import { menuItemAPI } from "./MenuItemAPI";
import { categoryAPI } from "../categories/CategoryAPI";
import toast from "react-hot-toast";

const emptyMenuItem: IMenuItem = {
  id: undefined, name: "", price: undefined, categoryId: undefined, category: {} as ICategory,
};

function MenuItemForm() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const [categories, setCategories] = useState<ICategory[]>([]);

  async function loadCategories() {
    setCategories(await categoryAPI.list());
  }

  const { register, handleSubmit, formState: { errors } } = useForm<IMenuItem>({
    defaultValues: async () => {
      await loadCategories();                 // dropdown options, either mode
      if (!id) return emptyMenuItem;          // Create → blank record
      return await menuItemAPI.find(Number(id)); // Edit → fetch the record
    },
  });

  const save: SubmitHandler<IMenuItem> = async (menuItem) => {
    try {
      delete menuItem.category;               // send categoryId, not the embedded object
      if (!menuItem.id) await menuItemAPI.post(menuItem);   // no id → Create
      else await menuItemAPI.put(menuItem);                 // has id → Edit
    } catch (error: any) {
      toast.error(error.message, { duration: 6000 });
      return;
    }
    toast.success("Successfully saved.");
    navigate("/menuitems");
  };

  return (
    <form className="d-flex flex-wrap w-75 gap-2" onSubmit={handleSubmit(save)}>
      <div className="mb-3 w-75">
        <label htmlFor="name" className="form-label">Name</label>
        <input id="name" type="text"
          {...register("name", { required: "Name is required" })}
          className={`form-control ${errors?.name && "is-invalid"}`} />
        <div className="invalid-feedback">{errors?.name?.message}</div>
      </div>
      <div className="mb-3 w-25">
        <label htmlFor="price" className="form-label">Price</label>
        <input id="price" type="number" step="0.01"
          {...register("price", { valueAsNumber: true, required: "Price is required" })}
          className={`form-control ${errors?.price && "is-invalid"}`} />
        <div className="invalid-feedback">{errors?.price?.message}</div>
      </div>
      <div className="mb-3 w-50">
        <label htmlFor="categoryId" className="form-label">Category</label>
        <select id="categoryId"
          {...register("categoryId", { valueAsNumber: true, required: "Category is required" })}
          className={`form-select ${errors?.categoryId && "is-invalid"}`}>
          <option value="">Select Category…</option>
          {categories.map((c) => (
            <option key={c.id} value={c.id}>{c.name}</option>
          ))}
        </select>
        <div className="invalid-feedback">{errors?.categoryId?.message}</div>
      </div>
      <div className="d-flex justify-content-end w-100 mt-4">
        <Link to="/menuitems" className="btn btn-outline-primary me-2">Cancel</Link>
        <button type="submit" className="btn btn-primary">
          <svg className="bi pe-none me-2" width={16} height={16} fill="#FFFFFF">
            <use xlinkHref={`${bootstrapIcons}#save`} />
          </svg>
          Save menu item
        </button>
      </div>
    </form>
  );
}

export default MenuItemForm;
```

> **What's `toast`?** `react-hot-toast` (installed back in Lesson 3) shows a small,
> auto-dismissing pop-up for feedback — `toast.success(...)` after a good save,
> `toast.error(...)` in a `catch`. One catch: it only renders if a `<Toaster>` component is
> mounted at the app root, which you add in **Lesson 11** (and **Lesson 12** covers toasts +
> error handling properly). So these calls are **wired now but won't show anything on screen
> until Lesson 11** — that's expected, not a bug. Here, navigating back to the list on success
> is your real confirmation for now.

The three ideas that make it one form for both modes:

- **`defaultValues` (async) is the create-vs-edit switch.** No `:id` in the URL → return
  `emptyMenuItem` (blank fields). An `:id` → `menuItemAPI.find(id)` → the record's values
  pre-fill every registered field automatically. Either way `loadCategories()` runs first so
  the dropdown has options.
- **The FK dropdown** is a `<select>` whose `<option value={c.id}>{c.name}</option>` come
  from the fetched `categories`. `value` carries the id (stored as `categoryId`); on edit the
  record's `categoryId` auto-selects the matching option.
- **`save` decides create vs. edit by `!menuItem.id`** — no id → `post` (Create), id →
  `put` (Edit). `delete menuItem.category` drops the nested nav object before sending. (See
  the `toast` note above — the calls are here for completeness; toasts render from Lesson 11
  and are covered in Lesson 12.)

> **Try it — see what `register` returns (ties back to §2).** Temporarily drop a
> `console.log(register("name"))` just above the `return`. Once the routes exist (next
> section) and you open the form, the DevTools **Console** shows the
> `{ name, onChange, onBlur, ref }` object that `{...register("name")}` spreads onto the
> input — the manual wiring from §2, now live. Delete the log once you've seen it.

### Optional: watch react-hook-form work (a temporary debug view)

Want to *see* what react-hook-form tracks as you interact with the form? Pull a few extra
pieces from `useForm` and drop a debug `<pre>` inside the form. **This is a throwaway teaching
aid — you'll delete it once it clicks.**

Pull `watch` and two more `formState` fields (and, so errors show *as you go* instead of only
after a submit, add `mode: "onTouched"`):

```tsx title="src/menuItems/MenuItemForm.tsx"
const {
  register, handleSubmit, watch,
  formState: { errors, touchedFields, dirtyFields },
} = useForm<IMenuItem>({
  mode: "onTouched",   // validate on blur, then on change — so errors appear live
  defaultValues: async () => {
    /* … unchanged from above … */
  },
});
```

Then add this just inside the `<form>` (above the first field):

```tsx
{/* 🔎 TEMPORARY — delete once you've seen how rhf tracks the form */}
<pre className="bg-light border rounded p-3 small w-100">
{JSON.stringify(
  {
    values: watch(),                       // updates as you TYPE (onChange)
    touched: Object.keys(touchedFields),   // a field lands here when you BLUR (leave) it
    dirty: Object.keys(dirtyFields),       // lands here once its value differs from the default
    errors: Object.fromEntries(
      Object.entries(errors).map(([field, e]) => [field, e?.message]),
    ),
  },
  null,
  2,
)}
</pre>
```

Open the form (after the next section wires the routes) and interact with it while watching
the `<pre>`:

- **Type** in a field → `values` updates on every keystroke (that's `onChange`), and the field
  name appears in `dirty`.
- **Click into a field, then click out** without a valid value → the field name appears in
  `touched` (that's `onBlur`), and `errors` gains its message (because `mode: "onTouched"`).
- **Fix the field** → its error disappears.

That's the difference between **change** (value tracking → `values`/`dirty`) and **blur**
(→ `touched`, where errors first appear), live — the `onChange`/`onBlur` from the `register`
object in §2, doing their jobs. (`watch()` is the same hook you'll use for real in Lesson 10's
derived fields.) **Remove the `<pre>`, the extra `formState` fields, and `mode` when you're
done** — the reference form validates on submit, without them.

**Save and check:** you can't reach the form until its routes exist (next section) — for now
confirm the editor shows **no red errors** in `MenuItemForm.tsx` and `MenuItemAPI.ts`.

---

## 4. ▶ Code along — Thin Create/Edit pages + routes

The route targets are tiny — a heading plus `<MenuItemForm />`. Both render the *same* form;
the URL (with or without `:id`) makes it create or edit:

```tsx title="src/menuItems/MenuItemCreatePage.tsx"
import MenuItemForm from "./MenuItemForm";

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

export default MenuItemCreatePage;
```

`MenuItemEditPage` is identical but titled "Edit Menu Item". Add both routes under `Layout`
in `main.tsx`:

```diff title="src/main.tsx"
+ import MenuItemCreatePage from "./menuItems/MenuItemCreatePage";
+ import MenuItemEditPage from "./menuItems/MenuItemEditPage";
  ...
  children: [
    { path: "menuitems", element: <MenuItemsPage /> },
+   { path: "menuitems/create", element: <MenuItemCreatePage /> },
+   { path: "menuitems/edit/:id", element: <MenuItemEditPage /> },
    ...
  ],
```

The `:id` in the edit path is what `useParams` reads in the form.

**Now reach the form from the list** — the routes exist, but nothing links to them yet. Add an
**Add Item** button to `MenuItemsPage` and an **Edit** item to a `MenuItemCard` **⋮** dropdown
(the same react-bootstrap `Dropdown` + sprite-icon pattern as Lesson 6's `OrderRow`):

```diff title="src/menuItems/MenuItemsPage.tsx"
+ import { Link } from "react-router-dom";
  ...
  function MenuItemsPage() {
    ...
    return (
      <section className="content container-fluid mx-5 my-2 py-4">
-       <h2 className="pb-4 mb-4 border-bottom border-2">Menu</h2>
+       <div className="d-flex justify-content-between pb-4 mb-4 border-bottom border-2">
+         <h2>Menu</h2>
+         <Link to="/menuitems/create" className="btn btn-primary">Add Item</Link>
+       </div>
        ...
      </section>
    );
  }
```

```diff title="src/menuItems/MenuItemCard.tsx"
+ import { Link } from "react-router-dom";
+ import Dropdown from "react-bootstrap/Dropdown";
+ import bootstrapIcons from "../assets/bootstrap-icons.svg";
  ...
  function MenuItemCard({ menuItem }: IMenuItemCardProps) {
    return (
      <div className="card p-4" style={{ width: "23rem" }}>
+       <div className="d-flex justify-content-end">
+         <Dropdown>
+           <Dropdown.Toggle className="btn btn-light" style={{ background: "none" }}>
+             <svg className="bi pe-none" width={20} height={20} fill="#007AFF">
+               <use xlinkHref={`${bootstrapIcons}#three-dots-vertical`} />
+             </svg>
+           </Dropdown.Toggle>
+           <Dropdown.Menu>
+             <Dropdown.Item as={Link} to={`/menuitems/edit/${menuItem.id}`}>Edit</Dropdown.Item>
+           </Dropdown.Menu>
+         </Dropdown>
+       </div>
        <span className="fs-4 fw-medium">{menuItem.name}</span>
        <span className="fs-5 fw-light">${menuItem.price}</span>
      </div>
    );
  }
```

(A **Delete** item joins this same ⋮ dropdown in **Lesson 12**, where `menuItemAPI.delete` +
toasts are added.)

**Save and check:** from `/menuitems`, click **Add Item** → `/menuitems/create` shows an empty
form with the **Category** dropdown listing your seeded categories. Save with Name empty → the
field turns red and "Name is required" shows (no network call); fill it in + a price + a
category, Save → back to the list with the new card (**Network** shows a **201** `POST`). Open
a card's **⋮ → Edit** → the form is **pre-filled**; change the price, Save → **200** `PUT`.

---

## 5. Client validation is UX, not a security boundary

*(Read this — an important idea, plus a quick demo.)*

react-hook-form's validation runs **in the browser**. It's **UX** — it guides the user to a
valid entry before a request goes out. It is **not** a security boundary: anyone can bypass
it. Two ways to see that:

- **Disable JavaScript** (DevTools → Command Palette → "Disable JavaScript") and the form's
  checks are simply gone.
- **Call the API directly** in Insomnia (from the API pass) — nothing on the client is even
  involved.

A production app validates **again on the server** and enforces **auth** there. This course
**deliberately leaves those out** — the same intentional simplifications as the API pass: no
DTOs, no server-side request validation, no `[Authorize]`. So treat the react-hook-form rules
as the *friendly first line* (good UX), and know that the *real* line — server validation and
authorization — is out of scope here on purpose. When you build the PRS forms, the same
applies: the client rules are for the user, not for security.

---

## 6. Verifying in the browser

You've checked each piece as you built it; this is the full pass. With your API running and
`npm run dev` up:

1. From `/menuitems`, **Add Item** → empty form, **Category** dropdown populated. Save empty →
   inline validation, no request. Fill + Save → back to the list, **201** `POST` in Network.
2. **⋮ → Edit** a card → every field pre-filled (including the category); change + Save →
   **200** `PUT`.
3. Confirm create and edit are the *same form* — only the URL's `:id` differs.
4. (Optional) Disable JavaScript and submit an empty form — the client checks vanish (the
   section 5 point).
5. Console clean.

---

## The General Pattern (what to take away)

- **One `Form` component serves create and edit.** `defaultValues` returns a blank object
  when there's no `:id`, or the fetched record when there is; `save` POSTs when `!id`, PUTs
  otherwise.
- **react-hook-form**: `{...register("field", rules)}` wires + validates each input;
  `handleSubmit(save)` runs validation then calls you; `errors.field` drives the
  `is-invalid` / `invalid-feedback` conditional display. Rules: `required`, `maxLength`
  (rule, not attribute), `min`, `pattern`; `valueAsNumber` for numbers.
- **FK dropdown** = a `<select>` whose `<option value={id}>{name}</option>` come from a
  fetched list.
- Thin `CreatePage` / `EditPage` wrappers render the same form; the **route** (`:id` or not)
  decides its mode.
- **Client validation is UX, not security** — it's bypassable; the server (out of scope here)
  is the real boundary.

On PRS, the **Product** form is this exact pattern with a **Vendor** FK dropdown; the **User**
form has no FK (role checkboxes) and `maxLength` rules; the **Request** form is a shared
create/edit form too.

---

## Build Steps

1. Add `find(id)`, `post(item)`, `put(item)` to `MenuItemAPI.ts`.
2. Build `MenuItemForm` with `useForm<IMenuItem>`; read `:id` with `useParams`; in
   `defaultValues` (async) `loadCategories()` then return `emptyMenuItem` (no `:id`) or
   `menuItemAPI.find(id)`.
3. Register **Name** (required), **Price** (required, `valueAsNumber`), and the **Category**
   FK `<select>` (`valueAsNumber`, required) from `categories` state; show `errors` via
   `is-invalid` + `invalid-feedback`.
4. Write `save` (`handleSubmit`): `delete menuItem.category`, POST when `!id` else PUT, then
   `navigate("/menuitems")`. **Check** create + edit both work (201 / 200).
5. Create thin `MenuItemCreatePage` / `MenuItemEditPage` and add both routes under `Layout`.
6. Add an **Add Item** button on `MenuItemsPage` (→ `/menuitems/create`) and an **Edit** item
   in a `MenuItemCard` **⋮** dropdown (→ `/menuitems/edit/:id`) so the forms are reachable.
   (Delete joins that dropdown in Lesson 12.)
7. Verify using section 6, including the "disable JS" bypass from section 5.
