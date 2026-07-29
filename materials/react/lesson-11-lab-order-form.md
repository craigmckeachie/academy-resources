# Lesson 11 Lab — The Order Create/Edit Form

Right now an order can be **viewed** and **advanced through its workflow**, but not **created**
from the UI — you've been relying on seed data. Build the Order form and close that gap. It's
the shared create/edit form from Lesson 7, with one twist that **uses the Context you just
built**: the **Staff** dropdown is pre-set to the *signed-in* user and disabled — you record
orders as yourself.

> **Prerequisite:** your API on the **HTTP profile** with **Staff + Orders seed data**, and
> you are **signed in** (Lesson 11) — the form reads the current user from `useStaffContext()`.

## The form fields

- **Table Number** — required, `valueAsNumber`.
- **Notes** — optional textarea.
- **Status** — a `<select>` (Placed … Cancelled) defaulting to **PLACED** and **disabled**: a
  new order is always Placed, and status advances through the **Lesson 9 workflow buttons**,
  not this form.
- **Staff** — an FK `<select>` of staff (options from `staffAPI.list()`), **pre-filled from the
  signed-in user and disabled** — you place orders as yourself.

## Steps

The form is the Lesson 7 pattern; the genuinely new parts are the **context pre-fill** and the
**disabled** fields.

1. Add `post(order)` and `put(order)` to `OrderAPI.ts` (`find` and the workflow endpoints
   already exist).
2. **`OrderForm`** — `useForm<IOrder>`, read `:id` with `useParams`. In async `defaultValues`:
   `loadStaff()` (options for the dropdown), read `const { staff } = useStaffContext()` and set
   the blank order's `staffId` to `staff?.id`, then return the blank order (create) or
   `orderAPI.find(Number(id))` (edit). `save`: POST/PUT, then
   `navigate(`/orders/detail/${order.id}`)`.
   - **Table Number** and **Notes** register like any form fields.
   - **Staff `<select>`** — options from your `staffList`, plus `disabled` (it's pre-set to you):
     ```tsx
     <select id="staffId" {...register("staffId", { required: "Staff is required" })}
       disabled className="form-select">
       {staffList.map((s) => (
         <option key={s.id} value={s.id}>{s.firstName} {s.lastName}</option>
       ))}
     </select>
     ```
   - **Status `<select>`** — the five status options, `disabled`, `defaultValue="PLACED"`.
   - Lay the fields out with **flex utilities** (`d-flex flex-wrap gap-4`, `w-75`/`w-50`) — no
     custom CSS (`App.css` is empty).
3. Thin **`OrderCreatePage`** / **`OrderEditPage`** (heading + `<OrderForm />`) and routes
   `orders/create` and `orders/edit/:id` under `Layout`.
4. **Wire it up** — add an **Add Order** button on `OrdersPage` (→ `/orders/create`), and the
   order **Edit affordances** (there was nowhere for them to go until now): an **⋮ → Edit** item
   on `OrderRow` and a pencil `Link` on **Order Detail** (both → `/orders/edit/:id`).
5. **✅ Checkpoint:** **Add Order** → the form opens with **your name** filled and disabled in
   Staff and **PLACED** disabled in Status; enter a table number, Save → you land on the new
   order's **detail** page (**201**), and it appears in the Orders list. **⋮ → Edit** pre-fills.

## Verify in the browser

With your API running, `npm run dev` up, and signed in:

1. `/orders` → **Add Order** → the form; Staff shows **your** name (disabled), Status **PLACED**
   (disabled). Save with Table Number empty → inline error. Fill it, Save → the new order's
   **detail** page, **201** `POST`, and a new row in the list.
2. **⋮ → Edit** an order → the form pre-fills; change Notes, Save → **200** `PUT`.
3. Console clean; **Network** shows the `POST` / `PUT`.

This is the last CRUD screen — **TableServe is now a complete app**. On PRS this is the
**Request** create/edit form (a **User** FK instead of Staff, `description` / `justification`
fields, status likewise set by the workflow).

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you've done; **[Reach]** goes past it and needs some research.

- **Role-gate the maintenance screens** — [Reinforce] — the payoff of Lesson 11's role flags.
  Using `isAdmin` on the signed-in staff (`useStaffContext`), **hide the Categories / Staff /
  Menu Items management** from non-admins: wrap those `AppNav` items and their **Add** / **Edit**
  buttons in `{staff?.isAdmin && …}`. Sign in as an admin vs. a non-admin (seed data) and
  confirm the maintenance UI appears only for admins. *(This is the exact client-side role rule
  PRS uses — admins get the maintenance pages; reviewers get Approve/Reject.)*
- **Cancel returns to the list** — [Reinforce] — confirm the form's **Cancel** link goes back to
  `/orders` (not the detail page) on create, and consider sending edit's Cancel to the order's
  detail instead — a small UX call about where "cancel" should land.
- **Order the staff dropdown** — [Reach] — even though it's disabled, sort `staffList` by last
  name before rendering so the (pre-selected) option reads naturally, and read why a disabled
  `<select>`'s value still submits. Reference:
  [MDN — the disabled attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/select#disabled).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that span
the whole React pass.
