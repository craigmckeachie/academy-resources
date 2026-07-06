# Lesson 8 Guide — The Nested Child Form with Derived Fields

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
the parent's total (the side-effect recalculation you built in the API pass).

---

## 1. A form scoped to its parent

The Order Item form is reached from an order's detail page and always belongs to that
order. Two route params carry the context — the parent order `id` and (on edit) the
item's `itemId`:

```tsx
{ path: "orders/detail/:id/orderitem/create", element: <OrderItemCreatePage /> },
{ path: "orders/detail/:id/orderitem/edit/:itemId", element: <OrderItemEditPage /> },
```

```tsx
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

## 2. The FK dropdown, again

Menu Item is an FK dropdown just like Category on the Menu form (Lesson 5) — options
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

## 4. Derived display fields — read-only, not inputs

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

## 5. Saving — and the parent total recalculates

Save POSTs (no id) or PUTs (has id), then returns to the parent detail:

```tsx
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

The items table on the detail page (Lesson 7) shows each line's Amount and the footer
Total, both with `Intl.NumberFormat` — the same currency formatting used here.

---

## 6. Verifying in the browser

Verify in the **browser**. With your API running and `npm run dev` up:

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
6. **Cancel** on the form returns to the order detail, not a list.
7. Console clean.

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

1. Add `find(id)`, `post(item)`, `put(item)`, `delete(id)` to `OrderItemAPI.ts`.
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
7. Add the two nested routes and thin `OrderItemCreatePage` / `OrderItemEditPage`.
8. Verify in the browser using section 6 — Price fills on select, Amount recomputes
   live, the parent Total updates after save.
```
