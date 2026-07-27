# Lesson 8 Guide — Route Params and the Detail Page

**Goal:** by the end of this lesson you have the **Order Detail** page — a read-only view of
one order, reached by its id in the URL (`/orders/detail/5`). You'll learn **`useParams`** to
read the id from the route, **`useNavigate`** to move between pages in code, and the
**definition-list** summary layout. This lesson builds the *summary only*; the workflow
buttons and modals come in Lesson 9.

**The general pattern you're learning:** a **detail page** reads a **route param** (`:id`),
fetches that one record, and renders its fields — commonly as a **definition list**
(`<dl>`/`<dt>`/`<dd>`). `useParams` gets the id from the URL; `useNavigate` programmatically
navigates (after a save, or on a button click).

> **How to use this guide.** Sections headed **▶ Code along** are ones you build into your
> project (each ends with a quick **Save and check**); unmarked sections are concept. Code
> blocks name their file on the first line.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`), and
> you have the Orders list from Lesson 6 (its **⋮ → View** item links here).

---

## 1. Route params — a placeholder in the path

*(Read this.)*

A **route param** is a named slot in a path, written with a colon. You already added one for
edit forms:

```tsx
{ path: "orders/detail/:id", element: <OrderDetailPage /> },
```

`:id` matches whatever segment is there — `/orders/detail/5` sets `id` to `"5"`. The
component reads it with **`useParams`**:

```tsx
import { useParams } from "react-router-dom";

const { id } = useParams<{ id: string }>();
```

- `useParams()` returns an object of the route's params; destructure the one you want.
- **Params are always strings** — convert to a number for API calls: `Number(id)`.

---

## 2. ▶ Code along — Fetch the one record

With the id in hand, fetch that single order into state and render it. Because the record is
one object (not a list), initialize state as `undefined` and guard the render until it
arrives. First add `find(id)` to the API module:

```ts
// src/orders/OrderAPI.ts — add find
find(id: number): Promise<IOrder> {
  return fetch(`${url}/${id}`).then((response) => response.json());
},
```

```tsx
// src/orders/OrderDetailPage.tsx
import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import toast from "react-hot-toast";
import { IOrder } from "./IOrder";
import { orderAPI } from "./OrderAPI";
import OrderHeader from "./OrderHeader";

function OrderDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [loading, setLoading] = useState(false);
  const [order, setOrder] = useState<IOrder | undefined>(undefined);

  async function loadOrder() {
    setLoading(true);
    try {
      setOrder(await orderAPI.find(Number(id)));
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
      {order && <OrderHeader order={order} />}
    </section>
  );
}

export default OrderDetailPage;
```

- **`{order && <OrderHeader … />}`** guards the first render, when `order` is still
  `undefined` (the fetch hasn't returned). Conditional rendering (Lesson 6) again.
- `orderAPI.find(id)` GETs `/api/orders/{id}`, which returns the order with its nested
  `staff` and `orderItems`.

**Check:** the page imports `OrderHeader`, which you build next — so it won't render until
section 3. For now confirm the editor shows no *other* errors.

---

## 3. ▶ Code along — The definition-list summary

The order's fields render as a **definition list** — the right semantic element for
label/value pairs. Three `<dl>` columns sit in a flex row:

```tsx
// src/orders/OrderHeader.tsx
import { IOrder } from "./IOrder";
import { getTextBackgroundByStatus } from "../utility/formatUtilities";

interface IOrderHeaderProps {
  order: IOrder;
}

function OrderHeader({ order }: IOrderHeaderProps) {
  return (
    <section className="d-flex flex-wrap gap-4 justify-content-between pe-5">
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
        <dd>{order.staff?.firstName} {order.staff?.lastName}</dd>
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

export default OrderHeader;
```

- `<dt>` is the label, `<dd>` the value — semantic and screen-reader friendly.
- **Status** reuses `getTextBackgroundByStatus` from Lesson 6 — one badge-color source, used
  on the list *and* the detail page.
- **Total** is formatted with `Intl.NumberFormat` as USD currency — the standard money format
  in this app (you'll reuse it on the items table and OrderItem form).
- The **Cancellation Reason** pair renders only when status is `CANCELLED` — a `<>` fragment
  inside `{cond && …}` so two elements are conditional together.
- The columns lay out with **flex utilities** (`d-flex flex-wrap gap-4`) — no custom CSS
  needed (recall `App.css` is empty; Bootstrap does the layout).

> **Note:** `IOrder` needs a `cancellationReason?: string` field for the last pair. If your
> `IOrder` from Lesson 6 doesn't have it yet, add it now (optional string).

**Save and check:** from `/orders`, open a row's **⋮ → View** → `/orders/detail/{id}` shows
the three `<dl>` columns for *that* order, with the right status badge color and a
currency-formatted total.

---

## 4. `useNavigate` — navigating in code

*(Read this.)*

`Link` handles navigation the user clicks. **`useNavigate`** navigates from *code* — after a
save, or when a handler decides to move:

```tsx
import { useNavigate } from "react-router-dom";

const navigate = useNavigate();
// …later, in a handler:
navigate("/orders");                        // go to a path
navigate(`/orders/detail/${newOrder.id}`);  // go to a computed path
```

You've already seen it in the form's `save` (Lesson 7) — after POST/PUT it calls
`navigate("/menuitems")`. A row's **⋮ → View** uses a `Link` (the user clicks to go to the
detail page), while Lesson 9's workflow buttons will `navigate` after their API calls.
**`Link` for what the user clicks to go somewhere; `useNavigate` for going somewhere as a
result of an action.**

---

## 5. Verifying in the browser

You've checked each piece as you built it; this is the full pass. With your API running and
`npm run dev` up:

1. From `/orders`, open a row's **⋮ → View** → the URL becomes `/orders/detail/{id}` and the
   summary renders for *that* order — three `<dl>` columns, the right status badge color, a
   currency-formatted total.
2. Change the id in the URL by hand (`/orders/detail/2`) and reload — a *different* order
   loads. That's `useParams` reading the id and the fetch keying off it.
3. Open a **cancelled** order — the **Cancellation Reason** pair appears; open a
   non-cancelled one — it's absent.
4. Console clean; **Network** shows `GET /api/orders/{id}` returning the order with nested
   `staff`.

---

## The General Pattern (what to take away)

- A **detail page** reads `:id` with **`useParams`** (params are strings — `Number(id)` for
  the API), fetches that one record into `undefined`-initialized state, and guards the render
  with `{record && …}`.
- The summary is a **definition list** (`<dl>`/`<dt>`/`<dd>`) in a flex row; reuse the
  **status-badge** helper and `Intl.NumberFormat` for money.
- Conditionally show a field pair with `{cond && <> … </>}`.
- **`useNavigate`** navigates from code (after actions); **`Link`** for user clicks.

On PRS, the **Request Detail** page is this page — `useParams` for the request id, a
definition-list summary with a status badge, and (Lesson 9) workflow buttons.

---

## Build Steps

1. Add `find(id)` to `OrderAPI.ts` (GET `/api/orders/{id}`).
2. Build `OrderDetailPage`: read `:id` with `useParams`, fetch the order into
   `useState<IOrder | undefined>(undefined)` via a `useEffect`, guard with `{order && …}`.
3. Build `OrderHeader` (prop `order`): three `<dl>` columns in a `d-flex flex-wrap gap-4`
   row, with a **status badge**, an `Intl.NumberFormat` **Total**, and a
   `{status === "CANCELLED" && <>…</>}` reason pair (add `cancellationReason?` to `IOrder` if
   needed). **Check** a View link renders the summary.
4. Confirm the `orders/detail/:id` route exists under `Layout`, and the **⋮ → View** item
   from Lesson 6 reaches it.
5. Verify using section 5 — a different id loads a different order; the cancelled-only field
   toggles; Network shows the GET.
