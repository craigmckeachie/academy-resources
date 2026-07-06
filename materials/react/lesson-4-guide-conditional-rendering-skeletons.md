# Lesson 4 Guide — Conditional Rendering, Tables, Badges, and Skeletons

**Goal:** by the end of this lesson you have the **Orders list** — a *table* (not a
card grid) with **status badges**, a **status filter**, a **3-dots action menu**, and
**skeleton loading placeholders** while the data fetches. This is your second fetching
page, and its focus is **conditional rendering**: showing different UI depending on the
data's state (loading vs. loaded) and each record's values (status → badge color).

**The general pattern you're learning:** the same JSX can render **different output
based on conditions** — `{loading && <Skeletons />}` for in-flight state,
`{cond ? <A /> : <B />}` to choose between two, and a **lookup function** to map a
value (a status string) to a class (a badge color). A list you *compare row by row*
becomes a **table**; a list of things you *consider individually* stays a card grid.

---

## 1. Card grid vs. table — same choice as the static pass

You met this in the HTML/CSS pass: **card grid** for records you consider on their own
(Menu Items, Staff, Categories); **table** for records you compare field-by-field
(Orders — by status, total, time). Orders is the table. The data still comes from a
`useState` + `useEffect` + fetch (Lesson 2); only the layout differs.

---

## 2. The three shapes of conditional rendering

React has no template `if` — you use JavaScript expressions inside `{ }`:

### `&&` — render something or nothing

```tsx
{loading && <p>Loading…</p>}
```

If `loading` is true, the right side renders; if false, nothing does. Use it for
"show this only when X."

### Ternary — choose between two

```tsx
{orders.length === 0 ? <EmptyState /> : <OrderTable orders={orders} />}
```

Use `cond ? <A /> : <B />` when you must render one *or* the other.

### A lookup function — map a value to output

When the choice has many cases (status → color), don't nest ternaries — write a helper.
This is the badge-color function, in `src/utility/formatUtilities.ts`:

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

Then in JSX:

```tsx
<span className={`badge ${getTextBackgroundByStatus(order.status)}`}>
  {order.status}
</span>
```

The **status → color** mapping is the same convention from the static pass (grey /
yellow / blue / green / red). Keeping it in one function means every place that shows a
status badge stays consistent.

---

## 3. Skeleton loading placeholders

While the fetch is in flight, showing a blank page feels broken. A **skeleton** is a
grey placeholder shaped like the real content, shown *only while loading*:

```tsx
const [loading, setLoading] = useState(false);

const menuItemCardSkeletons = Array.from(Array(12), (_value, index) => (
  <MenuItemCardSkeleton key={index} />
));

// in the JSX:
{loading && menuItemCardSkeletons}
{menuItems.map((menuItem) => (
  <MenuItemCard key={menuItem.id} menuItem={menuItem} onRemove={removeMenuItem} />
))}
```

- `Array.from(Array(12), (_v, index) => …)` builds an array of 12 skeleton elements —
  a quick way to render N copies. (Here the index *is* a valid `key`: skeletons never
  reorder.)
- `{loading && menuItemCardSkeletons}` shows them only during the fetch; `setLoading`
  flips around the `await` (`true` before, `false` in `finally`).
- `MenuItemCardSkeleton` is a copy of the card with the text swapped for grey bars
  (`skeleton skeleton-text` classes from `App.css`). The Categories list ships with a
  ready-made `CategoryCardSkeleton` you can model yours on.

The Orders table can use a simpler `{loading && <p>Loading…</p>}` or skeleton rows —
the skeleton *cards* matter most on the card grids.

---

## 4. The Orders table

The table sits in a `.list` tray with a **status filter** above it. Here's the
structure (in an `OrderTable` component that fetches orders):

```tsx
<section className="list d-flex flex-row flex-wrap bg-body-tertiary gap-5 p-4 rounded-4">
  <table className="table table-hover w-100 rounded-4">
    <thead>
      <tr>
        <th scope="col">Order #</th>
        <th scope="col">Table Number</th>
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
```

Each row is its own `OrderRow` component (props: `order` and an `onRemove` callback):

```tsx
function OrderRow({ order, onRemove }: IOrderRowProps) {
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
          hour: "numeric", minute: "2-digit",
        })}
      </td>
      <td>{/* 3-dots dropdown — section 6 */}</td>
    </tr>
  );
}
```

- `{order.notes || "—"}` — the `||` renders a dash when notes is empty/undefined. A
  tiny but constant conditional-rendering idiom for optional fields.
- `order.staff?.firstName` — optional chaining on the nested `staff` nav property.
- `new Date(order.orderedAt).toLocaleTimeString(...)` formats the ISO timestamp as a
  readable time.

---

## 5. The status filter with `useSearchParams`

The filter's selected value lives in the **URL** (`/orders?status=PREPARING`) so the
list is shareable and survives a refresh. react-router's **`useSearchParams`** reads
and writes the query string:

```tsx
import { useSearchParams } from "react-router-dom";

const [searchParams, setSearchParams] = useSearchParams();

async function loadOrders() {
  const data = await orderAPI.list(searchParams.get("status") ?? undefined);
  setOrders(data);
}

useEffect(() => {
  loadOrders();
}, [searchParams.get("status")]);

function handleStatusChange(event: SyntheticEvent) {
  setSearchParams({ status: (event.target as HTMLSelectElement).value });
}
```

```tsx
<select id="status" className="form-select"
  value={searchParams.get("status") ?? undefined}
  onChange={handleStatusChange}>
  <option value="">All</option>
  <option value="PLACED">Placed</option>
  <option value="PREPARING">Preparing</option>
  <option value="READY">Ready</option>
  <option value="SERVED">Served</option>
  <option value="CANCELLED">Cancelled</option>
</select>
```

The key idea: **the `useEffect` depends on `searchParams.get("status")`** — a
**non-empty dependency array**. When the filter changes the query string, the status
value changes, the effect re-runs, and the list re-fetches for that status. This is the
first time you've used a dependency other than `[]` — the effect now re-runs on demand,
not just on mount. `orderAPI.list(status)` appends `?status=…` to the request when a
status is given.

---

## 6. The 3-dots action menu

Each row's last cell is a react-bootstrap **`Dropdown`** — the JSX form of the static
pass's `data-bs-toggle="dropdown"` menu (react-bootstrap handles the toggle for you):

```tsx
import Dropdown from "react-bootstrap/Dropdown";
import { Link } from "react-router-dom";

<Dropdown className="d-inline">
  <Dropdown.Toggle className="btn btn-light" style={{ background: "none" }}>
    {/* three-dots-vertical icon */}
  </Dropdown.Toggle>
  <Dropdown.Menu>
    <Dropdown.Item as={Link} to={`/orders/detail/${order.id}`}>View</Dropdown.Item>
    <Dropdown.Item as={Link} to={`/orders/edit/${order.id}`}>Edit</Dropdown.Item>
    <Dropdown.Item as="a" href="#" onClick={async (event) => {
      event.preventDefault();
      if (confirm("Are you sure you want to delete this order?")) {
        if (order.id) {
          await orderAPI.delete(order.id);
          onRemove(order);       // tell the parent to drop the row
        }
      }
    }}>Delete</Dropdown.Item>
  </Dropdown.Menu>
</Dropdown>
```

- `as={Link}` makes a menu item navigate (View → detail, Edit → edit form).
- **Delete** calls the API, then calls the `onRemove` **callback prop** so the parent
  list removes the row from state — the pattern where a child asks the parent to update.
  The parent supplies it: `function removeOrder(order) { setOrders(orders.filter(o => o.id !== order.id)); }`.
- A `window.confirm(...)` guards the delete for now (Lesson 7 replaces it with a modal).

---

## 7. Verifying in the browser

Verify in the **browser** (not Insomnia). With your API running and `npm run dev` up:

1. Open `/orders`. While the fetch is in flight you should see the loading state, then
   the table fills with rows — each status in its correct badge color (grey / yellow /
   blue / green / red).
2. Change the **Status** filter — the URL gains `?status=PREPARING`, and the table
   re-fetches to just those orders. Reload the page — the filter *sticks* (it's in the
   URL). Set it back to **All**.
3. Open a row's **⋮** menu → **View** / **Edit** navigate; **Delete** confirms, removes
   the row, and (check **Network**) fires a `DELETE`.
4. For the card grids (Menu/Staff), throttle the network (**DevTools → Network → Slow
   3G**) and reload — the **skeleton cards** show during the fetch, then swap for real
   cards.
5. Console clean throughout.

---

## The General Pattern (what to take away)

- **Conditional rendering** = JS expressions in `{ }`: `cond && <X />` (show or
  nothing), `cond ? <A /> : <B />` (one or the other), and a **lookup function** for
  many cases (status → badge class).
- **Skeletons** are placeholder elements shown `{loading && …}` while a fetch runs;
  flip `loading` around the `await`.
- A **table** (`OrderTable` → `OrderRow`) suits records you compare; each row is a
  component taking `order` + an `onRemove` callback prop.
- **`useSearchParams`** keeps filter state in the URL; make the fetch **effect depend
  on the filter value** so it re-runs when the filter changes.
- A row/card **`Dropdown`** holds per-record actions; **Delete** calls the API then an
  `onRemove` callback so the parent updates its state.

On PRS, the **Requests** list is this exact page — a table with status badges, a status
filter via `useSearchParams`, and a 3-dots menu (Review / Edit / Delete).

---

## Build Steps

1. Add `getTextBackgroundByStatus` to `src/utility/formatUtilities.ts` (status →
   `text-bg-*`).
2. Build `OrderAPI.ts` with `list(status?)` that appends `?status=` when given, plus
   `delete(id)`.
3. Build `OrderTable`: fetch orders in a `useEffect`, render the `<table>` with a
   `<thead>` and `orders.map(...)` of `<OrderRow>`.
4. Build `OrderRow` (props `order`, `onRemove`): cells for id, table #, notes (`|| "—"`),
   a **status badge**, total, staff, time, and a **3-dots `Dropdown`** (View / Edit /
   Delete-with-confirm calling `onRemove`).
5. Add the **status filter** `<select>` wired to **`useSearchParams`**, and make the
   fetch `useEffect` depend on `searchParams.get("status")`.
6. Add skeleton placeholders to a **card** list (Menu Items): a `MenuItemCardSkeleton`
   and `{loading && skeletons}` around the fetch.
7. Verify in the browser using section 7 — badge colors, a sticky URL filter, working
   row actions, and skeletons on slow network.
```
