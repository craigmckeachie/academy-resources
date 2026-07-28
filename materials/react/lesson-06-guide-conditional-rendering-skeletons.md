# Lesson 6 Guide — Conditional Rendering, Tables, Badges, and Skeletons

**Goal:** by the end of this lesson you have the **Orders list** — a *table* (not a card
grid) with **status badges**, a **status filter**, and a **3-dots action menu** — plus
**skeleton loading placeholders** on your card grids. This is your second fetching page,
and its focus is **conditional rendering**: showing different UI depending on the data's
state (loading vs. loaded) and each record's values (status → badge color).

**The general pattern you're learning:** the same JSX can render **different output based on
conditions** — `{loading && <Skeletons />}` for in-flight state, `{cond ? <A /> : <B />}` to
choose between two, and a **lookup function** to map a value (a status string) to a class (a
badge color). A list you *compare row by row* becomes a **table**; a list of things you
*consider individually* stays a card grid.

> **How to use this guide.** Sections headed **▶ Code along** are ones you **build into your
> project** — type them as you go, and each ends with a quick **Save and check**. Unmarked
> sections are concept: read them (or watch), nothing to type. Each code block carries its
> file name as a title bar. The **Build Steps** at the end recap every ▶ Code along action.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`) with
> **Orders seed data** loaded, and the app has the shell + routing from Lesson 5. You'll
> flesh out the `OrdersPage` you stubbed in Lesson 5 into the real Orders list.

---

## 1. Card grid vs. table — same choice as the static pass

*(Read this.)*

You met this in the HTML/CSS pass: **card grid** for records you consider on their own (Menu
Items, Staff, Categories); **table** for records you compare field-by-field (Orders — by
status, total, time). Orders is the table. The data still comes from a `useState` +
`useEffect` + fetch (Lesson 4); only the layout differs.

---

## 2. The three shapes of conditional rendering

*(Read this — you'll use all three in the build below.)*

React has no template `if` — you use JavaScript expressions inside `{ }`:

### `&&` — render something or nothing

```tsx
{loading && <p>Loading…</p>}
```

If `loading` is true, the right side renders; if false, nothing does. This is
**truthy/falsy from Lesson 1** doing real work — `&&` yields its right side only when the
left is truthy, so a `false` flag (or an empty list, since `items.length` is `0` and falsy)
renders nothing. Use it for "show this only when X."

### Ternary — choose between two

```tsx
{orders.length === 0 ? <p>No orders yet.</p> : <OrdersTable />}
```

Use `cond ? <A /> : <B />` when you must render one *or* the other.

### A lookup function — map a value to output

When the choice has many cases (status → color), don't nest ternaries — write a helper. This
is the badge-color function; you'll add it to `formatUtilities.ts` in section 3:

```ts
export function getTextBackgroundByStatus(status: string) {
  switch (status) {
    case "PLACED":    return "text-bg-secondary";
    case "PREPARING": return "text-bg-warning";
    case "READY":     return "text-bg-info";
    case "SERVED":    return "text-bg-success";
    case "CANCELLED": return "text-bg-danger";
    default:          return "";
  }
}
```

Those five status values are a **closed set** — the kind of value Lesson 2's
**literal-string union** describes — though, like the rest of the app, `order.status` is
typed as a plain `string`. The **status → color** mapping is the same convention from the
static pass (grey / yellow / blue / green / red); keeping it in one function means every
status badge stays consistent.

---

## 3. ▶ Code along — Fetch the orders into a table

Flesh out the `OrdersPage` stub from Lesson 5 into the real list. Four small files/edits:

**1 — the interface.** `src/orders/IOrder.ts` describes an order (enough fields for the
table):

```ts title="src/orders/IOrder.ts"
import { IStaff } from "../staff/IStaff";

export interface IOrder {
  id: number | undefined;
  tableNumber: number | undefined;
  notes: string | undefined;
  status: string;
  total: number;
  orderedAt: string;
  staffId: number | undefined;
  staff?: IStaff;
}
```

**2 — the API module** (same plain shape as `MenuItemAPI` from Lesson 4; `list` takes an
optional status you'll use in section 4):

```ts title="src/orders/OrderAPI.ts"
import { IOrder } from "./IOrder";

const url = "http://localhost:5556/api/orders";

export const orderAPI = {
  list(status?: string): Promise<IOrder[]> {
    const query = status ? `?status=${status}` : "";
    return fetch(`${url}${query}`).then((response) => response.json());
  },
  delete(id: number) {
    return fetch(`${url}/${id}`, { method: "DELETE" });
  },
};
```

**3 — the badge-color helper** — add the `getTextBackgroundByStatus` from section 2 to
`src/utility/formatUtilities.ts`.

**4 — the page and the row.** Replace the `OrdersPage` stub with a fetch + a `<table>` that
maps an `OrderRow` per order:

```tsx title="src/orders/OrdersPage.tsx"
import { useEffect, useState } from "react";
import { IOrder } from "./IOrder";
import { orderAPI } from "./OrderAPI";
import OrderRow from "./OrderRow";

function OrdersPage() {
  const [orders, setOrders] = useState<IOrder[]>([]);

  async function loadOrders() {
    const data = await orderAPI.list();
    setOrders(data);
  }

  function removeOrder(order: IOrder) {
    setOrders(orders.filter((o) => o.id !== order.id));
  }

  useEffect(() => {
    loadOrders();
  }, []);

  return (
    <section className="content container-fluid mx-5 my-2 py-4">
      <h2 className="pb-4 mb-4 border-bottom border-2">Orders</h2>
      <section className="list bg-body-tertiary p-4 rounded-4">
        <table className="table table-hover w-100 rounded-4">
          <thead>
            <tr>
              <th scope="col">Order #</th>
              <th scope="col">Table</th>
              <th scope="col">Notes</th>
              <th scope="col">Status</th>
              <th scope="col">Total</th>
              <th scope="col">Staff</th>
              <th scope="col">Ordered At</th>
              <th />
            </tr>
          </thead>
          <tbody>
            {orders.map((order) => (
              <OrderRow key={order.id} order={order} onRemove={removeOrder} />
            ))}
          </tbody>
        </table>
      </section>
    </section>
  );
}

export default OrdersPage;
```

```tsx title="src/orders/OrderRow.tsx"
import { IOrder } from "./IOrder";
import { getTextBackgroundByStatus } from "../utility/formatUtilities";

interface IOrderRowProps {
  order: IOrder;
  onRemove: (order: IOrder) => void;
}

function OrderRow({ order }: IOrderRowProps) {
  return (
    <tr>
      <th scope="row">{order.id}</th>
      <td>{order.tableNumber}</td>
      <td className="text-body-secondary small text-wrap">{order.notes || "—"}</td>
      <td>
        <span className={`badge ${getTextBackgroundByStatus(order.status)}`}>
          {order.status}
        </span>
      </td>
      <td>${order.total}</td>
      <td>{order.staff?.firstName} {order.staff?.lastName}</td>
      <td>
        {new Date(order.orderedAt).toLocaleTimeString([], {
          hour: "numeric",
          minute: "2-digit",
        })}
      </td>
      <td>{/* 3-dots dropdown — section 5 */}</td>
    </tr>
  );
}

export default OrderRow;
```

Three small conditional-rendering idioms in `OrderRow`:

- **`{order.notes || "—"}`** — `||` renders a dash when notes is empty/undefined (a constant
  idiom for optional fields).
- **`order.staff?.firstName`** — **optional chaining** on the nested `staff` nav property
  (from Lesson 1's stretch); yields `undefined` instead of crashing if `staff` is missing.
- **`getTextBackgroundByStatus(order.status)`** — the lookup function turning the status into
  a badge color.

(`onRemove` is declared in the props but not used yet — the delete action arrives with the
dropdown in section 5.)

**Save and check:** open `/orders` — the table fills with rows, and each **Status** shows in
its badge color (grey / yellow / blue / green / red). Check **DevTools → Network** for a
**200** on `orders`.

---

## 4. ▶ Code along — The status filter with `useSearchParams`

Put the filter's selected value in the **URL** (`/orders?status=PREPARING`) so the list is
shareable and survives a refresh. react-router's **`useSearchParams`** reads and writes the
query string. Update `OrdersPage`:

```diff title="src/orders/OrdersPage.tsx"
- import { useEffect, useState } from "react";
+ import { useEffect, useState, SyntheticEvent } from "react";
+ import { useSearchParams } from "react-router-dom";
  ...
  function OrdersPage() {
    const [orders, setOrders] = useState<IOrder[]>([]);
+   const [searchParams, setSearchParams] = useSearchParams();

    async function loadOrders() {
-     const data = await orderAPI.list();
+     const data = await orderAPI.list(searchParams.get("status") ?? undefined);
      setOrders(data);
    }
    ...
    useEffect(() => {
      loadOrders();
-   }, []);
+   }, [searchParams.get("status")]);   // ← re-runs when the filter changes

+   function handleStatusChange(event: SyntheticEvent) {
+     setSearchParams({ status: (event.target as HTMLSelectElement).value });
+   }

    return (
      <section className="content container-fluid mx-5 my-2 py-4">
        <h2 className="pb-4 mb-4 border-bottom border-2">Orders</h2>
        <section className="list bg-body-tertiary p-4 rounded-4">
+         <select id="status" className="form-select w-auto mb-3"
+           value={searchParams.get("status") ?? ""}
+           onChange={handleStatusChange}>
+           <option value="">All</option>
+           <option value="PLACED">Placed</option>
+           <option value="PREPARING">Preparing</option>
+           <option value="READY">Ready</option>
+           <option value="SERVED">Served</option>
+           <option value="CANCELLED">Cancelled</option>
+         </select>
          <table className="table table-hover w-100 rounded-4">
            ...
          </table>
        </section>
      </section>
    );
  }
```

> **Why `?? ""` on the value?** This is a *controlled* `<select>` (it has a `value` prop), so
> `value` must always be a **string**. But `searchParams.get("status")` returns `null` when
> there's no `?status=…` in the URL (the default, unfiltered state), and React treats
> `value={null}` as an *uncontrolled* input — you'd get a "changing an uncontrolled input to
> controlled" warning and the select would stop tracking state. `?? ""` swaps that `null` for
> `""`, which both keeps it controlled **and** matches `<option value="">All</option>`, so an
> empty filter shows **All** selected.

The key idea: **the `useEffect` now depends on `searchParams.get("status")`** — a
**non-empty dependency array**. This is the first time you've used a dependency other than
`[]`: when the filter changes the query string, the status value changes, the effect
re-runs, and the list re-fetches. `orderAPI.list(status)` appends `?status=…` when a status
is given.

**Save and check:** pick a status — the URL gains `?status=PREPARING`, and the table
re-fetches to just those orders. **Reload** the page — the filter *sticks* (it's in the
URL). Set it back to **All**.

---

## 5. ▶ Code along — The 3-dots action menu

Fill the last cell of `OrderRow` with a per-row action menu. As promised in Lesson 5,
**interactive widgets use react-bootstrap** — its **`Dropdown`** is the JSX form of the
static pass's `data-bs-toggle="dropdown"` menu, managing open/close with React state (no
Bootstrap JS). Add the imports, destructure `onRemove`, and replace the placeholder cell:

```diff title="src/orders/OrderRow.tsx"
+ import Dropdown from "react-bootstrap/Dropdown";
+ import { Link } from "react-router-dom";
+ import bootstrapIcons from "../assets/bootstrap-icons.svg";
+ import { orderAPI } from "./OrderAPI";
  ...
- function OrderRow({ order }: IOrderRowProps) {
+ function OrderRow({ order, onRemove }: IOrderRowProps) {
    return (
      <tr>
        ...
-       <td>{/* 3-dots dropdown — section 5 */}</td>
+       <td>
+         <Dropdown className="d-inline">
+           <Dropdown.Toggle className="btn btn-light" style={{ background: "none" }}>
+             <svg className="bi pe-none" width={20} height={20} fill="#007AFF">
+               <use xlinkHref={`${bootstrapIcons}#three-dots-vertical`} />
+             </svg>
+           </Dropdown.Toggle>
+           <Dropdown.Menu>
+             <Dropdown.Item as={Link} to={`/orders/detail/${order.id}`}>View</Dropdown.Item>
+             <Dropdown.Item as="a" href="#" onClick={async (event) => {
+               event.preventDefault();
+               if (confirm("Are you sure you want to delete this order?")) {
+                 if (order.id) {
+                   await orderAPI.delete(order.id);
+                   onRemove(order);   // tell the parent to drop the row
+                 }
+               }
+             }}>
+               Delete
+             </Dropdown.Item>
+           </Dropdown.Menu>
+         </Dropdown>
+       </td>
      </tr>
    );
  }
```

- The toggle's icon is the same **SVG sprite** pattern as Lesson 5's `AppNav` — `import` the
  sprite, reference it with `xlinkHref` (see *SVGs in JSX* in the Lesson 5 guide).
- `as={Link}` makes **View** navigate to the detail route (built in Lesson 8 — it'll 404
  until then).
- **Delete** calls the API, then calls the **`onRemove` callback prop** so the parent drops
  the row from state — the pattern where a child asks the parent to update. `OrdersPage`
  supplies it as `removeOrder`. A `window.confirm(...)` guards it for now; **Lesson 9**
  replaces that with a modal.

**Save and check:** open a row's **⋮** menu → **View** navigates (or 404 for now);
**Delete** confirms, removes the row, and **Network** shows a `DELETE`.

---

## 6. ▶ Code along — Skeleton placeholders (on the card grid)

While a fetch is in flight, a blank page feels broken. A **skeleton** is a grey placeholder
shaped like the real content, shown *only while loading*. Skeletons matter most on the
**card grids** — add them to your **Menu Items** page.

**First, create the skeleton component.** It's a copy of your `MenuItemCard` (from Lesson 5)
with the real text swapped for grey bars — same `card` wrapper and sizing so the placeholder
occupies the same space:

```tsx title="src/menuItems/MenuItemCardSkeleton.tsx"
function MenuItemCardSkeleton() {
  return (
    <div className="card p-4" style={{ width: "23rem" }}>
      <span className="fs-4 fw-medium skeleton skeleton-text"></span>
      <span className="fs-5 fw-light skeleton skeleton-text"></span>
    </div>
  );
}

export default MenuItemCardSkeleton;
```

The empty `<span>`s carry no text — the **`skeleton skeleton-text`** classes give them a fixed
size and the shimmering grey animation. Those classes aren't Bootstrap; add them to
**`App.css`** (which you emptied in Lesson 3 — this is the one bit of custom CSS the pass
needs):

```css title="src/App.css"
.skeleton {
  animation: skeleton-loading 1s linear infinite alternate;
}

@keyframes skeleton-loading {
  0%   { background-color: hsl(200, 20%, 80%); }
  100% { background-color: hsl(200, 20%, 95%); }
}

.skeleton-text {
  width: 18ch;
  height: 0.8rem;
  display: block;
  border-radius: 0.25rem;
  margin: 0.2rem;
}
```

**Now render the skeletons while loading**, in `MenuItemsPage`:

```diff title="src/menuItems/MenuItemsPage.tsx"
+ import MenuItemCardSkeleton from "./MenuItemCardSkeleton";
  ...
  function MenuItemsPage() {
    const [loading, setLoading] = useState(false);   // already added in Lesson 4
    const [menuItems, setMenuItems] = useState<IMenuItem[]>([]);
+   const menuItemCardSkeletons = Array.from(Array(12), (_value, index) => (
+     <MenuItemCardSkeleton key={index} />
+   ));
    ...
    return (
      ...
      <section className="list d-flex flex-row flex-wrap bg-light gap-5 p-4 rounded-4">
-       {loading && <p>Loading…</p>}
+       {loading && menuItemCardSkeletons}
        {menuItems.map((menuItem) => (
          <MenuItemCard key={menuItem.id} menuItem={menuItem} />
        ))}
      </section>
      ...
    );
  }
```

- `Array.from(Array(12), (_v, index) => …)` builds 12 skeleton elements — a quick way to
  render N copies. (Here the array **index is a valid `key`** — skeletons never reorder.)
- `{loading && menuItemCardSkeletons}` shows them only during the fetch; set `loading` `true`
  before the `await` and `false` in a `finally` (the loading flag from Lesson 4).

The Orders **table** can use a simpler `{loading && <p>Loading…</p>}`; the skeleton *cards*
are what matter on the grids.

**Save and check:** throttle the network (**DevTools → Network → Slow 3G**) and reload
`/menuitems` — the **skeleton cards** show during the fetch, then swap for the real cards.

---

## 7. Verifying in the browser

You've checked each piece as you built it; this is the full pass. With your API running and
`npm run dev` up:

1. Open `/orders` — the table loads, each status in its correct badge color (grey / yellow /
   blue / green / red).
2. Change the **Status** filter — the URL gains `?status=PREPARING`, the table re-fetches;
   **reload** and the filter sticks. Set it back to **All**.
3. Open a row's **⋮** → **View** / **Edit** navigate; **Delete** confirms, removes the row,
   and **Network** shows a `DELETE`.
4. Throttle to **Slow 3G** and reload `/menuitems` — skeleton cards show, then swap for real
   cards.
5. **Console** clean throughout.

---

## The General Pattern (what to take away)

- **Conditional rendering** = JS expressions in `{ }`: `cond && <X />` (show or nothing),
  `cond ? <A /> : <B />` (one or the other), and a **lookup function** for many cases
  (status → badge class).
- A **table** (`OrdersPage` → `OrderRow`) suits records you compare; each row is a component
  taking `order` + an `onRemove` callback prop.
- **`useSearchParams`** keeps filter state in the URL; make the fetch **effect depend on the
  filter value** so it re-runs when the filter changes (your first non-`[]` dependency).
- A row/card **`Dropdown`** (react-bootstrap) holds per-record actions; **Delete** calls the
  API then an `onRemove` callback so the parent updates its state.
- **Skeletons** are placeholder elements shown `{loading && …}` while a fetch runs.

On PRS, the **Requests** list is this exact page — a table with status badges, a status
filter via `useSearchParams`, and a 3-dots menu (Review / Edit / Delete).

---

## Build Steps

1. Create `src/orders/IOrder.ts` and `src/orders/OrderAPI.ts` (`list(status?)` + `delete(id)`),
   and add `getTextBackgroundByStatus` to `src/utility/formatUtilities.ts`.
2. Replace the Lesson-5 `OrdersPage` stub with a `useState`/`useEffect` fetch and a `<table>`
   that maps an `OrderRow`; build `OrderRow` (cells for id, table, notes `|| "—"`, a **status
   badge**, total, staff, time, and an empty action cell). **Check** `/orders` renders with
   badge colors.
3. Add the status `<select>` wired to **`useSearchParams`**, and make the fetch `useEffect`
   depend on `searchParams.get("status")`. **Check** the filter changes the URL and sticks on
   reload.
4. Fill the 3-dots **`Dropdown`** in `OrderRow` (View/Edit `Link`s + Delete-with-confirm
   calling `onRemove`; sprite icon via `xlinkHref`). **Check** the row actions work.
5. Add skeletons to the **Menu Items** card grid: create `MenuItemCardSkeleton.tsx` (a copy of
   `MenuItemCard` with `skeleton skeleton-text` bars), add the `.skeleton`/`.skeleton-text` CSS
   to `App.css`, then render `{loading && skeletons}` behind a `loading` flag. **Check**
   skeletons show on Slow 3G.
6. Verify in the browser using section 7.
