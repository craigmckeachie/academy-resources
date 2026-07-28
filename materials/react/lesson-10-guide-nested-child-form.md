# Lesson 10 Guide — The Nested Child Form with Derived Fields

**Goal:** by the end of this lesson you have the **Order Item** create/edit form — a
child record created *under* an order, with a Menu Item **FK dropdown**, a **derived
Price** that fills in when you pick an item, a **derived Amount** that recomputes as
Quantity changes, a Notes field, and a parent **Order.Total** that updates after every
change. This is a dedicated lesson because the derived-field mechanic — one field
reacting to another — is new.

> **This is a worked-example lesson — there is no paired lab.** OrderItem is the
> *child-collection CRUD* pattern, and its PRS analog (RequestLine) is built directly
> during the capstone. It's a named exception with no second TableServe entity to
> repeat it on, so you build it once here alongside the instructor.

**The general pattern you're learning:** a **nested child form** is scoped to a parent
(reached from the parent's detail page, Cancel returns there). It has **derived display
fields** — values *computed* from other fields with react-hook-form's **`watch`**,
shown as read-only text, not inputs. Saving the child triggers the API to recalculate
the parent's total (the side-effect recalculation you built in the API pass). You'll also
build the **items table** on the order detail page — where these child rows are listed,
edited, and deleted (with a delete-confirmation modal, the state-driven `Modal` pattern from
Lesson 9 applied to a destructive action).

> **How to use this guide.** Sections headed **▶ Code along** are ones you build into your
> project (each ends with a quick **Save and check**); unmarked sections are concept. Each
> code block carries its file name as a title bar.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`), and
> you have the **Order Detail** page from Lessons 8–9 (this lesson adds the items table to it).

---

## 1. ▶ Code along — The OrderItem type, API module, and a form scoped to its parent

First the child's **type** and its **API module**. Like the other modules so far, these use
plain `fetch` — Lesson 12 hardens every module with the shared `checkStatus`/`parseJSON`
helpers:

```ts title="src/orderItems/IOrderItem.ts"
import { IMenuItem } from "../menuItems/IMenuItem";
import { IOrder } from "../orders/IOrder";

export interface IOrderItem {
  id: number | undefined;
  quantity: number;
  notes: string | undefined;
  orderId: number | undefined;
  menuItemId: number | undefined;
  menuItem: IMenuItem | undefined;
  order: IOrder | undefined;
}
```

```ts title="src/orderItems/OrderItemAPI.ts"
import { IOrderItem } from "./IOrderItem";

const url = "http://localhost:5556/api/orderitems";

export const orderItemAPI = {
  find(id: number): Promise<IOrderItem> {
    return fetch(`${url}/${id}`).then((r) => r.json());
  },
  post(orderItem: IOrderItem): Promise<IOrderItem> {
    return fetch(url, {
      method: "POST",
      body: JSON.stringify(orderItem),
      headers: { "Content-Type": "application/json" },
    }).then((r) => r.json());
  },
  put(orderItem: IOrderItem) {
    return fetch(`${url}/${orderItem.id}`, {
      method: "PUT",
      body: JSON.stringify(orderItem),
      headers: { "Content-Type": "application/json" },
    });
  },
  delete(id: number) {
    return fetch(`${url}/${id}`, { method: "DELETE" });
  },
};
```

The Order Item form is reached from an order's detail page and always belongs to that
order. Two route params carry the context — the parent order `id` and (on edit) the
item's `itemId`:

```tsx
{ path: "orders/detail/:id/orderitem/create", element: <OrderItemCreatePage /> },
{ path: "orders/detail/:id/orderitem/edit/:itemId", element: <OrderItemEditPage /> },
```

```tsx title="src/orderItems/OrderItemForm.tsx"
let { itemId, id } = useParams<{ itemId: string; id: string }>();
const orderItemId = Number(itemId);
const orderId = Number(id);
```

The blank child pre-fills its `orderId` from the route, so a new item knows its parent:

```tsx
let emptyOrderItem: IOrderItem = {
  id: undefined, quantity: 0, notes: undefined,
  orderId: orderId,          // ← from the parent route param
  menuItemId: 0, menuItem: undefined, order: undefined,
};
```

And **Cancel returns to the parent detail**, not a top-level list — the signature of a
nested form:

```tsx
<Link to={`/orders/detail/${orderId}`} className="btn btn-outline-primary me-2">Cancel</Link>
```

---

## 2. ▶ Code along — The FK dropdown, again

Menu Item is an FK dropdown just like Category on the Menu form (Lesson 7) — options
fetched from another entity:

```tsx
const [menuItems, setMenuItems] = useState<IMenuItem[]>([]);
async function loadMenuItems() {
  const data = await menuItemAPI.list();
  setMenuItems(data);
}
// loaded in defaultValues, like the category dropdown

<select
  {...register("menuItemId", { valueAsNumber: true, required: "Menu item is required" })}
  className={`form-select ${errors?.menuItemId && "is-invalid"}`}
>
  <option value="0">Select…</option>
  {menuItems.map((m) => (
    <option key={m.id} value={m.id}>{m.name}</option>
  ))}
</select>
```

The new part is what happens *after* you pick one.

---

## 3. `watch` — reacting to a field's current value

react-hook-form's **`watch`** returns a field's current value and **re-renders the
component whenever it changes**. That's how a derived field stays live:

```tsx
const { register, handleSubmit, watch, formState: { errors } } = useForm<IOrderItem>({ … });

let menuItemId = watch("menuItemId");
let quantity = watch("quantity");
```

Now `menuItemId` and `quantity` update on every change to those inputs — and because
`watch` re-renders, anything computed from them re-renders too.

### Deriving Price from the selected menu item

When the chosen `menuItemId` changes, look up that menu item (for its price). Track it
in state via an effect keyed on `menuItemId`:

```tsx
const [selectedMenuItem, setSelectedMenuItem] = useState<IMenuItem | undefined>(undefined);

useEffect(() => {
  let currentMenuItem = menuItems.find((m) => m?.id === menuItemId);
  setSelectedMenuItem(currentMenuItem);
}, [menuItemId]);
```

This is a **non-empty dependency array** again (like the Orders filter): the effect
re-runs whenever `menuItemId` changes, refreshing which menu item is selected.

---

## 4. ▶ Code along — Derived display fields (read-only, not inputs)

Price and Amount are **computed**, so they're rendered as **text**, not `<input>`s — a
user can't type them:

```tsx
{/* Price — from the selected menu item */}
<div className="mb-3">
  <label className="form-label">Price</label>
  <div className="form-label">
    {new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })
      .format(selectedMenuItem?.price ?? 0)}
  </div>
</div>

{/* Quantity — a real input */}
<div className="mb-3">
  <label htmlFor="quantity" className="form-label">Quantity</label>
  <input id="quantity" type="number"
    {...register("quantity", {
      required: "Quantity is required",
      min: { value: 1, message: "Quantity must be at least 1" },
      valueAsNumber: true,
    })}
    className={`form-control ${errors?.quantity && "is-invalid"}`} />
  <div className="invalid-feedback">{errors?.quantity?.message}</div>
</div>

{/* Amount — Price × Quantity, recomputed live */}
<div className="mb-3">
  <label className="form-label">Amount</label>
  <div className="form-label">
    {new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })
      .format((selectedMenuItem?.price ?? 0) * quantity)}
  </div>
</div>
```

- **Price** shows `selectedMenuItem?.price` — fills in the moment you pick an item.
- **Amount** is `price × quantity`, recomputed on every keystroke in Quantity because
  `watch("quantity")` re-renders. Change the quantity → Amount updates instantly, no
  submit needed.
- `?? 0` guards the pre-selection state (nothing chosen yet → `$0.00`).
- **Notes** is a normal optional text input — TableServe's addition over PRS's
  RequestLine.

This "pick a dropdown value → a related field fills → a third field recomputes from it"
is the dropdown-triggers-derived-field mechanic, and it's the whole reason this lesson
stands alone.

---

## 5. ▶ Code along — Saving (the parent total recalculates)

Save POSTs (no id) or PUTs (has id), then returns to the parent detail:

```tsx title="src/orderItems/OrderItemForm.tsx"
const save: SubmitHandler<IOrderItem> = async (orderItem) => {
  try {
    if (!orderItem.id) {
      orderItem = await orderItemAPI.post(orderItem);
    } else {
      await orderItemAPI.put(orderItem);
    }
    toast.success("Successfully saved.");
    navigate(`/orders/detail/${orderItem.orderId}`);
  } catch (error: any) {
    toast.error(error.message);
  }
};
```

You don't recompute `Order.Total` in the front end — **the API does it** as a
side-effect of the POST/PUT/DELETE (the recalculation you built in the API pass). When
`navigate` returns to the detail page, it re-fetches the order and shows the new
running total in the items-table footer. The front end computes Amount *for display*;
the back end owns the persisted Total.

The items table on the detail page (built next, in section 6) shows each line's Amount and
the footer Total, both with `Intl.NumberFormat` — the same currency formatting used here.

**Save and check:** you can't reach the form yet (its routes and the "Add Order Item" link
come in section 6). For now confirm the editor shows no errors in `OrderItemForm.tsx`.

---

## 6. ▶ Code along — The items table on the detail page (and the delete modal)

The form needs somewhere to launch from. On `OrderDetailPage`, below `<OrderHeader />`, add a
**card holding the items table** — one row per `order.orderItems`, a footer **Add Order Item**
link and running **Total**, and per-row **Edit** / **trash** actions. The trash button opens a
**delete-confirmation modal** — the same state-driven `Modal` you built for Cancel in Lesson 9,
now for a destructive action.

```diff title="src/orders/OrderDetailPage.tsx"
  function OrderDetailPage() {
    ...
    return (
      <section className="content container-fluid mx-5 my-2 py-4">
        ...
        {order && <OrderHeader order={order} />}
+       {order && (
+         <div className="card p-4 mt-5">
+           <h5 className="card-title">Order Items</h5>
+           <table className="table w-75">
+             <thead>
+               <tr>
+                 <th>Menu Item</th><th>Price</th><th>Quantity</th><th>Notes</th><th>Amount</th><th />
+               </tr>
+             </thead>
+             <tbody>
+               {order.orderItems.map((orderItem) => (
+                 <tr key={orderItem.id}>
+                   <td>{orderItem.menuItem?.name}</td>
+                   <td>{money(orderItem.menuItem?.price ?? 0)}</td>
+                   <td>{orderItem.quantity}</td>
+                   <td className="text-body-secondary small">{orderItem.notes || "—"}</td>
+                   <td>{money((orderItem.menuItem?.price ?? 0) * orderItem.quantity)}</td>
+                   <td>
+                     <Link to={`/orders/detail/${order.id}/orderitem/edit/${orderItem.id}`}
+                       className="btn btn-outline">Edit</Link>
+                     <button type="button" className="btn btn-outline"
+                       onClick={() => handleShowDeleteItemModal(orderItem)}>Delete</button>
+                   </td>
+                 </tr>
+               ))}
+             </tbody>
+             <tfoot>
+               <tr>
+                 <td>
+                   <Link to={`/orders/detail/${order.id}/orderitem/create`}
+                     className="btn btn-outline-primary">Add Order Item</Link>
+                 </td>
+                 <td /><td /><td>{money(order.total)}</td><td />
+               </tr>
+             </tfoot>
+           </table>
+         </div>
+       )}
      </section>
    );
  }
```

> `money(...)` is shorthand here for the `Intl.NumberFormat("en-US", { style: "currency",
> currency: "USD" }).format(...)` you've been writing — inline the full call, or (nicer) lift
> it into a small helper in `formatUtilities` and import it. Swap the plain `Edit`/`Delete`
> text for the pencil/trash SVG icons from the design if you want the finished look (same
> sprite + `xlinkHref` pattern as Lesson 6).

Now the **trash button** calls `handleShowDeleteItemModal(orderItem)`. Add its state,
handlers, and the confirm modal — storing the *item* to delete (not just a boolean) so the
confirm handler knows exactly which one to remove:

```diff title="src/orders/OrderDetailPage.tsx"
  function OrderDetailPage() {
    ...  // useParams, order/loading state, Cancel-modal state, loadOrder (Lessons 8–9)

+   const [orderItemToDelete, setOrderItemToDelete] = useState<IOrderItem | undefined>(undefined);
+   function handleShowDeleteItemModal(orderItem: IOrderItem) { setOrderItemToDelete(orderItem); }
+   function handleCloseDeleteItemModal() { setOrderItemToDelete(undefined); }
+
+   async function removeOrderItem() {
+     if (!orderItemToDelete?.id) return;
+     await orderItemAPI.delete(orderItemToDelete.id);
+     setOrderItemToDelete(undefined);
+     toast.success("Successfully deleted.");
+     await loadOrder();                     // re-fetch → the row is gone and Total drops
+   }
    ...
    return ( ... );
  }
```

```diff title="src/orders/OrderDetailPage.tsx"
  return (
    <section className="content container-fluid mx-5 my-2 py-4">
      {/* …the Cancel modal from Lesson 9… */}
+     <Modal show={!!orderItemToDelete} onHide={handleCloseDeleteItemModal}>
+       <Modal.Header closeButton><Modal.Title>Delete Order Item</Modal.Title></Modal.Header>
+       <Modal.Body>
+         <p>Are you sure you want to delete this order item?</p>
+         <div className="d-flex justify-content-end gap-2">
+           <button type="button" className="btn btn-outline-primary"
+             onClick={handleCloseDeleteItemModal}>Cancel</button>
+           <button type="button" className="btn btn-danger" onClick={removeOrderItem}>Delete</button>
+         </div>
+       </Modal.Body>
+     </Modal>
      ...
    </section>
  );
```

- `show={!!orderItemToDelete}` — storing the *item* (not a boolean) means `removeOrderItem`
  knows exactly which one to delete; `undefined` closes the modal.
- After `orderItemAPI.delete(...)`, `loadOrder()` re-fetches the order — the row disappears
  and the footer **Total** drops, because the **API** recalculated it (same side-effect as
  save).

**Save and check:** open an order's detail — the items table shows each line's Amount and a
footer Total. Click a row's **Delete** → the confirm modal opens; **Delete** removes the row
and the Total drops. The **Add Order Item** and **Edit** links now have somewhere to go (the
form routes you add in section 7).

---

## 7. ▶ Code along — Wire the routes and pages, then verify in the browser

Add the two nested routes and the thin create/edit pages, then do the full pass. With your
API running and `npm run dev` up:

1. From an order's detail, click **Add Order Item** → the URL is
   `/orders/detail/{id}/orderitem/create`. Price and Amount read `$0.00`.
2. Pick a menu item — **Price** fills in with that item's price immediately.
3. Change **Quantity** — **Amount** updates on each keystroke (Price × Quantity). Set
   quantity to 0 and try to Save → "Quantity must be at least 1" blocks it.
4. Save a valid item → you return to the order detail, the new row is in the items
   table, and the footer **Total** has increased. Check **Network**: a `POST
   /api/orderitems` and then a `GET /api/orders/{id}` with the recalculated total.
5. **Edit** an item → the form pre-fills (including the selected menu item, so Price
   shows); change the quantity and Save → the Total updates again.
6. Click a row's **Delete** → the confirm modal opens; **Delete** removes the item and the
   Total drops.
7. **Cancel** on the form returns to the order detail, not a list. Console clean.

---

## The General Pattern (what to take away)

- A **nested child form** is scoped to its parent: the parent id comes from a route
  param, the blank child pre-fills `orderId`, and **Cancel returns to the parent
  detail**.
- **`watch("field")`** returns a field's live value and re-renders on change — the
  engine behind derived fields.
- **Derived fields** (Price, Amount) are **read-only display text**, computed from a
  watched value + the selected FK record; format money with `Intl.NumberFormat`.
- The **parent total is recalculated by the API**, not the front end; re-fetch the
  parent to show it.

On PRS, the **RequestLine** form is this form — a Product FK dropdown, a derived Amount
(Price × Quantity via `watch`), and a Request total the API recalculates — **minus the
Notes field**.

---

## Build Steps

1. Create `IOrderItem.ts` and `OrderItemAPI.ts` with `find`/`post`/`put`/`delete` (plain
   `fetch` — Lesson 12 hardens it).
2. Build `OrderItemForm`: read `:id` (order) and `:itemId` from `useParams`; build
   `emptyOrderItem` with `orderId` from the route.
3. In `defaultValues` (async), `loadMenuItems()` then return the blank item (create) or
   `orderItemAPI.find(itemId)` (edit).
4. Register the **Menu Item** FK `<select>` and **Quantity** (required, `min: 1`,
   `valueAsNumber`); add a **Notes** input.
5. `watch("menuItemId")` + a `useEffect([menuItemId])` to set `selectedMenuItem`; render
   **Price** and **Amount** as read-only `Intl.NumberFormat` text (`watch("quantity")`
   for Amount).
6. `save`: POST/PUT by `!id`, then `navigate('/orders/detail/${orderId}')`; make Cancel
   a `Link` back to the parent detail.
7. On `OrderDetailPage`, add the **items table** card (rows from `order.orderItems`, footer
   **Add Order Item** link + **Total**, per-row Edit/trash), and wire the **delete-confirm
   modal** (`orderItemToDelete` state, `removeOrderItem` → `orderItemAPI.delete` → re-fetch).
8. Add the two nested routes and thin `OrderItemCreatePage` / `OrderItemEditPage`.
9. Verify in the browser using section 7 — Price fills on select, Amount recomputes live,
   the parent Total updates after save, and delete removes a row and drops the Total.
