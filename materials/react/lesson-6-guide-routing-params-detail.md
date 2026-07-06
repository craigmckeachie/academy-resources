# Lesson 6 Guide — Route Params and the Detail Page

**Goal:** by the end of this lesson you have the **Order Detail** page — a read-only
view of one order, reached by its id in the URL (`/orders/detail/5`). You'll learn
**`useParams`** to read the id from the route, **`useNavigate`** to move between pages
in code, and the **definition-list** summary layout. This lesson builds the *summary
only*; the workflow buttons and modals come in Lesson 7.

**The general pattern you're learning:** a **detail page** reads a **route param**
(`:id`), fetches that one record, and renders its fields — commonly as a **definition
list** (`<dl>`/`<dt>`/`<dd>`). `useParams` gets the id from the URL; `useNavigate`
programmatically navigates (after a save, or on a button click).

---

## 1. Route params — a placeholder in the path

A **route param** is a named slot in a path, written with a colon. You already added
one for edit forms:

```tsx
{ path: "orders/detail/:id", element: <OrderDetailPage /> },
```

`:id` matches whatever segment is there — `/orders/detail/5` sets `id` to `"5"`,
`/orders/detail/42` sets it to `"42"`. The component reads it with **`useParams`**:

```tsx
import { useParams } from "react-router-dom";

let { id } = useParams<{ id: string }>();
```

- `useParams()` returns an object of the route's params; destructure the one you want.
- **Params are always strings** — convert to a number for API calls: `Number(id)`.

---

## 2. Fetching the one record

With the id in hand, fetch that single order into state and render it. Because the
record is one object (not a list), initialize state as `undefined` and guard the render
until it arrives:

```tsx
import { useEffect, useState } from "react";
import { orderAPI } from "./OrderAPI";
import { IOrder } from "./IOrder";

function OrderDetailPage() {
  let { id } = useParams<{ id: string }>();
  const [loading, setLoading] = useState(false);
  const [order, setOrder] = useState<IOrder | undefined>(undefined);

  async function loadOrder() {
    let orderId = Number(id);
    setLoading(true);
    try {
      const order = await orderAPI.find(orderId);
      setOrder(order);
    } catch (error: any) {
      toast.error(error.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadOrder();
  }, []);

  return (
    <section className="content container-fluid mx-5 my-2 py-4">
      <div className="d-flex justify-content-between pb-4 mb-4 border-bottom border-2">
        <h2>Order</h2>
      </div>
      {loading && <p>Loading…</p>}
      {order && <OrderHeader order={order} staff={order.staff} />}
    </section>
  );
}
```

`{order && <OrderHeader … />}` is conditional rendering guarding against the first
render, when `order` is still `undefined`. `orderAPI.find(id)` GETs `/api/orders/{id}`,
which returns the order with its nested `staff` and `orderItems`.

---

## 3. The definition-list summary

The order's own fields render as a **definition list** — the right semantic element for
label/value pairs. Three `<dl>` columns sit in a `.detail-header` flex row
(`OrderHeader` component, props `order` + `staff`):

```tsx
function OrderHeader({ order, staff }: IOrderHeaderProps) {
  return (
    <section className="detail-header justify-content-between pe-5">
      <dl>
        <dt>Table Number</dt>
        <dd>{order.tableNumber}</dd>
        <dt>Notes</dt>
        <dd>{order.notes || "—"}</dd>
      </dl>
      <dl>
        <dt>Status</dt>
        <dd>
          <span className={`badge ${getTextBackgroundByStatus(order.status)}`}>
            {order.status}
          </span>
        </dd>
        <dt>Total</dt>
        <dd>
          {new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })
            .format(order.total)}
        </dd>
      </dl>
      <dl>
        <dt>Staff</dt>
        <dd>{staff?.firstName} {staff?.lastName}</dd>
        <dt>Ordered At</dt>
        <dd>
          {new Date(order.orderedAt).toLocaleTimeString([], {
            hour: "numeric", minute: "2-digit",
          })}
        </dd>
        {order.status === "CANCELLED" && (
          <>
            <dt>Cancellation Reason</dt>
            <dd>{order.cancellationReason}</dd>
          </>
        )}
      </dl>
    </section>
  );
}
```

- `<dt>` is the label, `<dd>` the value — semantic and screen-reader friendly.
- **Status** reuses `getTextBackgroundByStatus` from Lesson 4 — one badge-color source,
  used on the list *and* the detail page.
- **Total** is formatted with `Intl.NumberFormat` as USD currency — the standard way to
  render money in this app (you'll reuse it on the items table and the OrderItem form).
- The **Cancellation Reason** pair renders only when status is `CANCELLED` — a `<>`
  fragment inside a `{cond && …}` so two elements can be conditional together.

`.detail-header` is a small custom class (`display:flex; flex-wrap:wrap; gap:1rem`) in
`App.css` — the one named layout class the design keeps, since this two/three-column
detail layout recurs on every detail and form page.

---

## 4. `useNavigate` — navigating in code

`Link` handles navigation the user clicks. **`useNavigate`** navigates from *code* —
after a save, or when a handler decides to move:

```tsx
import { useNavigate } from "react-router-dom";

const navigate = useNavigate();
// …later, in a handler:
navigate("/orders");                       // go to a path
navigate(`/orders/detail/${newOrder.id}`); // go to a computed path
```

You've already seen it in the form's `save` (Lesson 5) — after POST/PUT it calls
`navigate("/menuitems")`. On this detail page the Edit link uses a `Link`
(`to={/orders/edit/${order.id}}`), while Lesson 7's workflow buttons will `navigate`
after their API calls. **`Link` for what the user clicks to go somewhere; `useNavigate`
for going somewhere as a result of an action.**

---

## 5. Verifying in the browser

Verify in the **browser**. With your API running and `npm run dev` up:

1. From `/orders`, open a row's **⋮ → View** → the URL becomes `/orders/detail/{id}`
   and the summary renders for *that* order — the three `<dl>` columns with the right
   status badge color and a currency-formatted total.
2. Change the id in the URL by hand (`/orders/detail/2`) and reload — a *different*
   order loads. That's `useParams` reading the id and the fetch keying off it.
3. Open a **cancelled** order — confirm the **Cancellation Reason** pair appears; open a
   non-cancelled one — it's absent.
4. Click the Edit (pencil) link — it navigates to the edit form for that order.
5. Console clean; **Network** shows a `GET /api/orders/{id}` returning the order with
   nested `staff` and `orderItems`.

---

## The General Pattern (what to take away)

- A **detail page** reads `:id` with **`useParams`** (params are strings — `Number(id)`
  for the API), fetches that one record into `undefined`-initialized state, and guards
  the render with `{record && …}`.
- The summary is a **definition list** (`<dl>`/`<dt>`/`<dd>`) in a `.detail-header`;
  reuse the **status-badge** helper and `Intl.NumberFormat` for money.
- Conditionally show a field pair with `{cond && <> … </>}`.
- **`useNavigate`** navigates from code (after actions); **`Link`** for user clicks.

On PRS, the **Request Detail** page is this page — `useParams` for the request id, a
definition-list summary with a status badge, and (Lesson 7) workflow buttons.

---

## Build Steps

1. Add `find(id)` to `OrderAPI.ts` (GET `/api/orders/{id}`).
2. Build `OrderDetailPage`: read `:id` with `useParams`, fetch the order into
   `useState<IOrder | undefined>(undefined)` via a `useEffect`, guard with
   `{order && …}`.
3. Build `OrderHeader` (props `order`, `staff`): three `<dl>` columns in a
   `.detail-header`, with a **status badge**, an `Intl.NumberFormat` **Total**, and a
   `{status === "CANCELLED" && <>…</>}` reason pair.
4. Add an Edit (pencil) `Link` to `/orders/edit/:id` in the heading row.
5. Ensure the `orders/detail/:id` route exists under `Layout`.
6. Verify in the browser using section 5 — a different id loads a different order, the
   cancelled-only field toggles, Network shows the GET.
```
