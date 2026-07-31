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

The next several snippets are pieces of a new file, `src/orderItems/OrderItemForm.tsx` —
each is shown as a `diff` with the enclosing `function OrderItemForm()` (and `...` for the
code you're not touching) so you can see exactly where it nests. **Section 5 lists the
finished file whole** if you'd rather read it than assemble it.

The Order Item form is reached from an order's detail page and always belongs to that
order. Two route params carry the context — the parent order `id` and (on edit) the
item's `itemId`. The routes themselves you add to the router in section 7; they're shown
here for the two params they carry:

```tsx title="src/main.tsx"
{ path: "orders/detail/:id/orderitem/create", element: <OrderItemCreatePage /> },
{ path: "orders/detail/:id/orderitem/edit/:itemId", element: <OrderItemEditPage /> },
```

Read both params at the top of the component with `useParams`:

```diff title="src/orderItems/OrderItemForm.tsx"
  function OrderItemForm() {
+   let { itemId, id } = useParams<{ itemId: string; id: string }>();
+   const orderItemId = Number(itemId);
+   const orderId = Number(id);
    ...
  }
```

The blank child pre-fills its `orderId` from the route, so a new item knows its parent:

```diff title="src/orderItems/OrderItemForm.tsx"
  function OrderItemForm() {
    ...  // useParams, orderId
+   let emptyOrderItem: IOrderItem = {
+     id: undefined, quantity: 0, notes: undefined,
+     orderId: orderId,          // ← from the parent route param
+     menuItemId: 0, menuItem: undefined, order: undefined,
+   };
    ...
  }
```

Finally, give the component its **`return`** — the `<form>` and **Item** card the fields drop
into (sections 2 and 4), with the **Cancel** and **Save** buttons beneath. **Cancel returns to
the parent detail** — not a top-level list, the signature of a nested form; **Save** is a
submit button whose `onSubmit` you wire up in section 5:

```diff title="src/orderItems/OrderItemForm.tsx"
  function OrderItemForm() {
    ...  // useParams, orderId, emptyOrderItem
+   return (
+     <form className="form w-50">
+       <div className="card p-4">
+         <h5 className="card-title"><strong>Item</strong></h5>
+
+         {/* Menu Item, Price, Quantity, Notes, Amount fields — sections 2 and 4 */}
+
+         <div className="d-flex justify-content-end mt-4">
+           <Link to={`/orders/detail/${orderId}`} className="btn btn-outline-primary me-2">Cancel</Link>
+           <button type="submit" className="btn btn-primary">Save item</button>
+         </div>
+       </div>
+     </form>
+   );
  }
```

---

## 2. ▶ Code along — The FK dropdown, again

Menu Item is an FK dropdown just like Category on the Menu form (Lesson 7) — options
fetched from another entity. Add the `menuItems` state and its loader **inside
`OrderItemForm`, above the `return`** (the loader is called from the form's `defaultValues`,
which you set up in the next step):

```diff title="src/orderItems/OrderItemForm.tsx"
  function OrderItemForm() {
    ...  // useParams, orderId, emptyOrderItem (section 1)
+   const [menuItems, setMenuItems] = useState<IMenuItem[]>([]);
+
+   async function loadMenuItems() {
+     const data = await menuItemAPI.list();
+     setMenuItems(data);
+   }
    ...
  }
```

Next, set up **`useForm`** — the source of the form's fields, validation, and initial values.
Its **async `defaultValues`** loads the menu items, then returns the blank `emptyOrderItem`
(create) or the fetched item (edit) — the same create-vs-edit switch as the other forms. It
has to exist **before** the `<select>` below, which pulls `register` and `errors` from it:

```diff title="src/orderItems/OrderItemForm.tsx"
  function OrderItemForm() {
    ...  // useParams, orderId, emptyOrderItem, menuItems state, loadMenuItems
+   const {
+     register,
+     handleSubmit,
+     formState: { errors },
+   } = useForm<IOrderItem>({
+     defaultValues: async () => {
+       await loadMenuItems();
+       if (!itemId) {
+         return Promise.resolve(emptyOrderItem);          // create: blank child
+       } else {
+         const orderItem = await orderItemAPI.find(orderItemId);
+         return Promise.resolve(orderItem);               // edit: fetch the item
+       }
+     },
+   });
    ...
  }
```

Then the **Menu Item field** — a `<select>` with its label and validation message — drops into
the **Item** card, where the fields placeholder is:

```diff title="src/orderItems/OrderItemForm.tsx"
  function OrderItemForm() {
    ...
    return (
      ...
      <div className="card p-4">
        ...  // Item heading (section 1)
+       <div className="mb-3">
+         <label htmlFor="menuItemId" className="form-label">Menu Item</label>
+         <select
+           {...register("menuItemId", { valueAsNumber: true, required: "Menu item is required" })}
+           className={`form-select ${errors?.menuItemId && "is-invalid"}`}
+         >
+           <option value="0">Select…</option>
+           {menuItems.map((m) => (
+             <option key={m.id} value={m.id}>{m.name}</option>
+           ))}
+         </select>
+         <div className="invalid-feedback">{errors?.menuItemId?.message}</div>
+       </div>
        ...  // Cancel / Save buttons (section 1)
      </div>
    );
  }
```

The new part is what happens *after* you pick one.

---

## 3. `watch` — reacting to a field's current value

react-hook-form's **`watch`** returns a field's current value and **re-renders the
component whenever it changes**. That's how a derived field stays live. Add `watch` to the
`useForm` destructure, then read the two fields you'll derive from:

```diff title="src/orderItems/OrderItemForm.tsx"
  function OrderItemForm() {
    ...
    const {
      register,
      handleSubmit,
+     watch,
      formState: { errors },
    } = useForm<IOrderItem>({ ... });
+
+   let menuItemId = watch("menuItemId");
+   let quantity = watch("quantity");
    ...
  }
```

Now `menuItemId` and `quantity` update on every change to those inputs — and because
`watch` re-renders, anything computed from them re-renders too.

### Deriving Price from the selected menu item

When the chosen `menuItemId` changes, look up that menu item (for its price). Track it
in state via an effect keyed on `menuItemId`:

```diff title="src/orderItems/OrderItemForm.tsx"
  function OrderItemForm() {
    ...
+   const [selectedMenuItem, setSelectedMenuItem] = useState<IMenuItem | undefined>(undefined);
    ...
+   useEffect(() => {
+     let currentMenuItem = menuItems.find((m) => m?.id === menuItemId);
+     setSelectedMenuItem(currentMenuItem);
+   }, [menuItemId]);
    ...
  }
```

This is a **non-empty dependency array** again (like the Orders filter): the effect
re-runs whenever `menuItemId` changes, refreshing which menu item is selected.

---

## 4. ▶ Code along — Derived display fields (read-only, not inputs)

Price and Amount are **computed**, so they render as **text**, not `<input>`s — a user can't
type them; **Notes** is a normal optional input. All three drop into the **Item** card after
the Menu Item field:

```diff title="src/orderItems/OrderItemForm.tsx"
  function OrderItemForm() {
    ...
    return (
      ...
      <div className="card p-4">
        ...  // Item heading + Menu Item field (sections 1–2)
+       {/* Price — from the selected menu item */}
+       <div className="mb-3">
+         <label className="form-label">Price</label>
+         <div className="form-label">
+           {new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })
+             .format(selectedMenuItem?.price ?? 0)}
+         </div>
+       </div>
+
+       {/* Quantity — a real input */}
+       <div className="mb-3">
+         <label htmlFor="quantity" className="form-label">Quantity</label>
+         <input id="quantity" type="number"
+           {...register("quantity", {
+             required: "Quantity is required",
+             min: { value: 1, message: "Quantity must be at least 1" },
+             valueAsNumber: true,
+           })}
+           className={`form-control ${errors?.quantity && "is-invalid"}`} />
+         <div className="invalid-feedback">{errors?.quantity?.message}</div>
+       </div>
+
+       {/* Notes — optional text (TableServe's addition over PRS's RequestLine) */}
+       <div className="mb-3">
+         <label htmlFor="notes" className="form-label">Notes</label>
+         <input id="notes" type="text" {...register("notes")}
+           className="form-control"
+           placeholder="Enter any notes for this item (optional)" />
+       </div>
+
+       {/* Amount — Price × Quantity, recomputed live */}
+       <div className="mb-3">
+         <label className="form-label">Amount</label>
+         <div className="form-label">
+           {new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })
+             .format((selectedMenuItem?.price ?? 0) * quantity)}
+         </div>
+       </div>
        ...  // Cancel / Save buttons (section 1)
      </div>
    );
  }
```

- **Price** shows `selectedMenuItem?.price` — fills in the moment you pick an item.
- **Amount** is `price × quantity`, recomputed on every keystroke in Quantity because
  `watch("quantity")` re-renders. Change the quantity → Amount updates instantly, no
  submit needed.
- `?? 0` guards the pre-selection state (nothing chosen yet → `$0.00`).

This "pick a dropdown value → a related field fills → a third field recomputes from it"
is the dropdown-triggers-derived-field mechanic, and it's the whole reason this lesson
stands alone.

---

## 5. ▶ Code along — Saving, then wire the routes and run the form

Save POSTs (no id) or PUTs (has id), then returns to the parent detail. It's the last
piece added **inside the component, above the `return`**:

```diff title="src/orderItems/OrderItemForm.tsx"
  function OrderItemForm() {
    ...
+   const navigate = useNavigate();
+
+   const save: SubmitHandler<IOrderItem> = async (orderItem) => {
+     try {
+       if (!orderItem.id) {
+         orderItem = await orderItemAPI.post(orderItem);
+       } else {
+         await orderItemAPI.put(orderItem);
+       }
+       toast.success("Successfully saved.");
+       navigate(`/orders/detail/${orderItem.orderId}`);
+     } catch (error: any) {
+       toast.error(error.message);
+     }
+   };
    ...
  }
```

Connect `save` to the form — add `onSubmit={handleSubmit(save)}` to the `<form>` tag you wrote
in section 1:

```diff title="src/orderItems/OrderItemForm.tsx"
    return (
-     <form className="form w-50">
+     <form className="form w-50" onSubmit={handleSubmit(save)}>
        ...
      </form>
    );
```

You don't recompute `Order.Total` in the front end — **the API does it** as a
side-effect of the POST/PUT/DELETE (the recalculation you built in the API pass). When
`navigate` returns to the detail page, it re-fetches the order and shows the new
running total in the items-table footer. The front end computes Amount *for display*;
the back end owns the persisted Total.

The items table on the detail page (built next, in section 6) shows each line's Amount and
the footer Total, both with `Intl.NumberFormat` — the same currency formatting used here.

### The complete `OrderItemForm.tsx`

Sections 1–5 built this file up a piece at a time to explain each new part. Here it is whole —
the params and blank child, the FK dropdown, the two `watch`es and the derived-field effect,
the read-only Price/Amount, and `save`. If you were reading along rather than typing, create the
file with this:

```tsx title="src/orderItems/OrderItemForm.tsx"
import { useEffect, useState } from "react";
import { useForm, SubmitHandler } from "react-hook-form";
import toast from "react-hot-toast";
import { Link, useNavigate, useParams } from "react-router-dom";

import { IOrderItem } from "./IOrderItem";
import { IMenuItem } from "../menuItems/IMenuItem";
import { menuItemAPI } from "../menuItems/MenuItemAPI";
import { orderItemAPI } from "./OrderItemAPI";

function OrderItemForm() {
  let { itemId, id } = useParams<{ itemId: string; id: string }>();
  const orderItemId = Number(itemId);
  const orderId = Number(id);
  const navigate = useNavigate();
  const [menuItems, setMenuItems] = useState<IMenuItem[]>([]);
  const [selectedMenuItem, setSelectedMenuItem] = useState<IMenuItem | undefined>(undefined);

  let emptyOrderItem: IOrderItem = {
    id: undefined,
    quantity: 0,
    notes: undefined,
    orderId: orderId,          // ← from the parent route param
    menuItemId: 0,
    menuItem: undefined,
    order: undefined,
  };

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors },
  } = useForm<IOrderItem>({
    defaultValues: async () => {
      await loadMenuItems();
      if (!itemId) {
        return Promise.resolve(emptyOrderItem);
      } else {
        const orderItem = await orderItemAPI.find(orderItemId);
        return Promise.resolve(orderItem);
      }
    },
  });

  async function loadMenuItems() {
    const data = await menuItemAPI.list();
    setMenuItems(data);
  }

  let menuItemId = watch("menuItemId");
  let quantity = watch("quantity");

  useEffect(() => {
    let currentMenuItem = menuItems.find((m) => m?.id === menuItemId);
    setSelectedMenuItem(currentMenuItem);
  }, [menuItemId]);

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

  return (
    <form className="form w-50" onSubmit={handleSubmit(save)}>
      <div className="card p-4">
        <h5 className="card-title"><strong>Item</strong></h5>

        <div className="mb-3">
          <label htmlFor="menuItemId" className="form-label">Menu Item</label>
          <select
            {...register("menuItemId", { valueAsNumber: true, required: "Menu item is required" })}
            className={`form-select ${errors?.menuItemId && "is-invalid"}`}
          >
            <option value="0">Select…</option>
            {menuItems.map((m) => (
              <option key={m.id} value={m.id}>{m.name}</option>
            ))}
          </select>
          <div className="invalid-feedback">{errors?.menuItemId?.message}</div>
        </div>

        <div className="mb-3">
          <label className="form-label">Price</label>
          <div className="form-label">
            {new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })
              .format(selectedMenuItem?.price ?? 0)}
          </div>
        </div>

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

        <div className="mb-3">
          <label htmlFor="notes" className="form-label">Notes</label>
          <input id="notes" type="text" {...register("notes")}
            className="form-control"
            placeholder="Enter any notes for this item (optional)" />
        </div>

        <div className="mb-3">
          <label className="form-label">Amount</label>
          <div className="form-label">
            {new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })
              .format((selectedMenuItem?.price ?? 0) * quantity)}
          </div>
        </div>

        <div className="d-flex justify-content-end mt-4">
          <Link to={`/orders/detail/${orderId}`} className="btn btn-outline-primary me-2">Cancel</Link>
          <button type="submit" className="btn btn-primary">Save item</button>
        </div>
      </div>
    </form>
  );
}

export default OrderItemForm;
```

With the form built, **wire its two routes so you can run it now** — before building the table.
Two thin page components wrap the form (create and edit), each rendering `<OrderItemForm />`
under a heading (the same create/edit page pattern as Menu Items and Staff):

```tsx title="src/orderItems/OrderItemCreatePage.tsx"
import OrderItemForm from "./OrderItemForm";

function OrderItemCreatePage() {
  return (
    <section className="content container-fluid mx-5 my-2 py-4">
      <div className="d-flex justify-content-between pb-4 mb-5 border-bottom border-2">
        <h2>New Order Item</h2>
      </div>
      <OrderItemForm />
    </section>
  );
}

export default OrderItemCreatePage;
```

```tsx title="src/orderItems/OrderItemEditPage.tsx"
import OrderItemForm from "./OrderItemForm";

function OrderItemEditPage() {
  return (
    <section className="content container-fluid mx-5 my-2 py-4">
      <div className="d-flex justify-content-between pb-4 mb-5 border-bottom border-2">
        <h2>Edit Order Item</h2>
      </div>
      <OrderItemForm />
    </section>
  );
}

export default OrderItemEditPage;
```

Add the two nested routes under `Layout` in the router — the ones previewed in section 1. The
pages exist now, so the `element`s resolve:

```diff title="src/main.tsx"
  ...  // existing routes under Layout
+ { path: "orders/detail/:id/orderitem/create", element: <OrderItemCreatePage /> },
+ { path: "orders/detail/:id/orderitem/edit/:itemId", element: <OrderItemEditPage /> },
  ...
```

**✅ Checkpoint — run the form on its own.** There's no **Add Order Item** link yet (that's
section 6), so reach it by typing the URL. With your API running and `npm run dev` up:

1. Go to **`/orders/detail/1/orderitem/create`** (any real order id) — the form renders; Price
   and Amount read **`$0.00`**.
2. Pick a **menu item** → **Price** fills in immediately (the derived field).
3. Change **Quantity** → **Amount** recomputes on each keystroke (Price × Quantity). Set it to
   0 and Save → **"Quantity must be at least 1"** blocks it.
4. Save a valid item → you land back on the order detail. **Network** shows a `POST
   /api/orderitems`, then a `GET /api/orders/{id}` with the recalculated total. (You won't
   *see* the new row until the items table in section 6 — but the derived fields and the
   round-trip are already working.)
5. Type an edit URL — `/orders/detail/1/orderitem/edit/{itemId}` — the form **pre-fills** (menu
   item selected, so Price shows). Console clean.

---

## 6. ▶ Code along — The items table on the detail page (and the delete modal)

The form works, but so far you reach it by typing URLs — the **items table** on the order
detail lists the order's items and gives the form in-app **Add Order Item** / **Edit** links.
On `OrderDetailPage`, below `<OrderHeader />`, add a
**card holding the items table** — one row per `order.orderItems`, a footer **Add Order Item**
link and running **Total**, and per-row **Edit** / **trash** actions. The trash button opens a
**delete-confirmation modal** — the same state-driven `Modal` you built for Cancel in Lesson 9,
now for a destructive action.

First, the table maps `order.orderItems` and shows `order.total`, but the `IOrder` from Lesson 6
(extended with `cancellationReason` in Lesson 8) has no `orderItems` array yet — add it,
importing the `IOrderItem` you created in §1:

```diff title="src/orders/IOrder.ts"
+ import { IOrderItem } from "../orderItems/IOrderItem";
  ...
  export interface IOrder {
    ...
+   orderItems: IOrderItem[];
  }
```

The rows also format currency three times (Price, Amount, and the footer Total), so lift the
`Intl.NumberFormat` you wrote inline in the form into a small **`money`** helper in
`formatUtilities.ts`, beside `getTextBackgroundByStatus` from Lesson 6:

```diff title="src/utility/formatUtilities.ts"
  ...  // formatPhoneNumber, getTextBackgroundByStatus (Lesson 6)

+ export function money(amount: number) {
+   return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(amount);
+ }
```

Import it at the top of `OrderDetailPage.tsx` so the table can call it:

```tsx title="src/orders/OrderDetailPage.tsx"
import { money } from "../utility/formatUtilities";
```

Now the items-table card — it uses `money(...)` for Price, Amount, and the footer Total:

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

> Swap the plain `Edit`/`Delete` text for the pencil/trash SVG icons from the design if you
> want the finished look (same sprite + `xlinkHref` pattern as Lesson 6).

The table's **trash button** calls `handleShowDeleteItemModal(orderItem)`, which doesn't
exist yet — your editor flags it as *not defined* until you add it now. Add its state,
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
footer Total. Click **Add Order Item** → the create form opens (wired in section 5); Cancel
back. Click a row's **Delete** → the confirm modal opens; **Delete** removes the row and the
Total drops.

---

## 7. Verify in the browser — the full round-trip

You've tested the form on its own (section 5) and the items table (section 6); now the full
end-to-end pass, this time driving it from the **Add Order Item** link instead of typed URLs.
With your API running and `npm run dev` up:

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
7. Add the thin `OrderItemCreatePage` / `OrderItemEditPage` and the two nested routes, then
   **run the form by URL** — Price fills on select, Amount recomputes live, and a valid save
   round-trips to the detail page (Network shows the `POST` + recalculated `GET`).
8. Extend `IOrder` with `orderItems: IOrderItem[]`, then on `OrderDetailPage` add the **items
   table** card (rows from `order.orderItems`, footer **Add Order Item** link + **Total**,
   per-row Edit/trash), and wire the **delete-confirm modal** (`orderItemToDelete` state,
   `removeOrderItem` → `orderItemAPI.delete` → re-fetch).
9. Verify in the browser using section 7 — Price fills on select, Amount recomputes live,
   the parent Total updates after save, and delete removes a row and drops the Total.
