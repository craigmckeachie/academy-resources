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
- **Status** — a `<select>` (Placed … Cancelled) defaulting to **PLACED**, **disabled on
  create** and editable on edit: a new order is always Placed, and day to day the status
  advances through the **Lesson 9 workflow buttons**, not this form. *(Same rule PRS's Request
  form uses — Status disabled on Create, editable on Edit.)*
- **Staff** — an FK `<select>` of staff (options from `staffAPI.list()`), **pre-filled from the
  signed-in user and disabled** — you place orders as yourself.

## Steps

The form is the Lesson 7 pattern; the genuinely new parts are the **context pre-fill**, the
**disabled** fields, and **redirecting to the new record** (every form so far went back to a
list, where the new id didn't matter).

1. Add `post(order)` and `put(order)` to `OrderAPI.ts` (`find` and the workflow endpoints
   already exist).
2. **`OrderForm`** — `useForm<IOrder>`, read `:id` with `useParams`, and read the signed-in
   user at the **top of the component**: `const { staff } = useStaffContext();`. It's a hook,
   so it can't go inside the `defaultValues` callback — read it up top, use it below. You also
   need the dropdown's options in state, as in the Lesson 7 form:
   ```tsx
   const [staffList, setStaffList] = useState<IStaff[]>([]);

   async function loadStaff() {
     setStaffList(await staffAPI.list());
   }
   ```
   Start from this blank order (`IOrder` picked up `cancellationReason` in Lesson 8 and
   `orderItems` in Lesson 10):
   ```tsx
   let emptyOrder: IOrder = {
     id: undefined,
     tableNumber: undefined,
     notes: undefined,
     status: "PLACED",
     cancellationReason: undefined,
     total: 0,
     orderedAt: new Date().toISOString(),
     staffId: undefined,
     orderItems: [],
   };
   ```
   Then in async `defaultValues`: `await loadStaff()` (options for the dropdown), set
   `emptyOrder.staffId = staff?.id`, and return `emptyOrder` (create) or
   `orderAPI.find(Number(id))` (edit).
   - **`save`** — both branches land on the order's **detail** page, but only edit already
     knows the id. On create you have to read it back off the POST response:
     ```tsx
     if (!order.id) {
       const newOrder = await orderAPI.post(order);   // the response carries the new id
       navigate(`/orders/detail/${newOrder.id}`);
     } else {
       await orderAPI.put(order);
       navigate(`/orders/detail/${order.id}`);
     }
     ```
   - **Table Number** (`required`, `valueAsNumber`) and **Notes** register like any form
     fields, each with the `is-invalid` + `invalid-feedback` display from Lesson 7.
   - **Staff `<select>`** — options from your `staffList`, plus `disabled` (it's pre-set to you):
     ```tsx
     <select id="staffId" {...register("staffId", { required: "Staff is required" })}
       disabled className="form-select">
       {staffList.map((s) => (
         <option key={s.id} value={s.id}>{s.firstName} {s.lastName}</option>
       ))}
     </select>
     ```
   - **Status `<select>`** — the five status options and `defaultValue="PLACED"`, disabled on
     create only: `const isEdit = Boolean(id);` then `disabled={!isEdit}`. Both disabled fields
     still submit their values — react-hook-form sends what's in *its* state, not what the DOM
     would post — so a created order arrives as **PLACED**, assigned to **you**. (Stretch #3
     digs into why that differs from a plain HTML form.)
   - A **Cancel** `Link` back to `/orders` and a **Save order** submit button, as on every form
     since Lesson 7.
   - Lay the fields out with **flex utilities** (`d-flex flex-wrap gap-4`, `w-75`/`w-50`) — the
     only custom CSS in this app is the skeleton and Sign In rules you already added.
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
2. **⋮ → Edit** an order → the form pre-fills and **Status is now editable** (it was disabled on
   create); change Notes, Save → **200** `PUT`.
3. Console clean; **Network** shows the `POST` / `PUT`.
4. Open the order you just created and advance it to **Preparing** — **Cancel Order** is
   enabled, because the order is **yours**. That's the guide's `isOwnOrder || isManager` check,
   now demonstrable on a record you own rather than on seed data.

This is the last CRUD screen — **TableServe is now a complete app**. On PRS this is the
**Request** create/edit form (a **User** FK instead of Staff, `description` / `justification`
fields, status likewise set by the workflow).

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you've done; **[Reach]** goes past it and needs some research.

- **Finish role-gating the maintenance screens** — [Reinforce] — the payoff of Lesson 11's role
  flags. The guide wrapped the **Staff** nav link in `{staff?.isAdmin && …}`; do the same for
  **Menu Items** and **Categories**, then for the **Add** and **Edit** buttons on those three
  pages (a non-admin shouldn't see a create button for a screen they can't navigate to). Sign in
  as an admin vs. a non-admin from the seed data and confirm the maintenance UI appears only for
  admins. *(This is the exact client-side role rule PRS uses — admins get the maintenance pages;
  reviewers get Approve/Reject.)*
- **Cancel returns to the list** — [Reinforce] — confirm the form's **Cancel** link goes back to
  `/orders` (not the detail page) on create, and consider sending edit's Cancel to the order's
  detail instead — a small UX call about where "cancel" should land.
- **Order the staff dropdown** — [Reach] — even though it's disabled, sort `staffList` by last
  name before rendering so the (pre-selected) option reads naturally. Then work out why your
  `staffId` still reaches the server: MDN says a **disabled control's value is not submitted**,
  yet your POST carries it. (Hint: react-hook-form submits its own form state, not the DOM's —
  and note that RHF's `register(name, { disabled: true })` *option* behaves differently from the
  plain HTML attribute you used.) References:
  [MDN — the `disabled` attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/disabled)
  and [react-hook-form — `register` options](https://react-hook-form.com/docs/useform/register).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that span
the whole React pass.
