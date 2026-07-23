# Lesson 5 Guide — Routing, the App Shell, and Props

**Goal:** by the end of this lesson your app has **multiple pages** you navigate
between without full reloads, wrapped in a shared **shell** — a `Header` across the top
and an `AppNav` sidebar — built with **react-router-dom**. You'll convert the static
`header`/`nav` partials from the HTML/CSS pass into JSX components, learn **props** to
pass data into components, and use **`Outlet`** and **nested routes** to place each
page inside the shell.

**The general pattern you're learning:** a router maps **URL paths to components**. A
**layout** component renders the shared chrome once and drops the current page into an
**`Outlet`**. **Props** are how a parent component hands data down to a child. This
shell + routing setup is built once and hosts every page in the app.

---

## 1. From static partials to components

In the HTML/CSS pass, `{{> header}}` and `{{> nav}}` were Handlebars partials Vite
stitched into every page. React has no partials — instead, **a component is the reuse
unit**. The `header.html` markup becomes a `Header.tsx` component; `nav.html` becomes
`AppNav.tsx`. You render `<Header />` and `<AppNav />` from a shared `Layout`, and they
appear on every page — the same idea, expressed as components.

The conversion is mechanical: paste the markup, rename `class` → `className`,
`for` → `htmlFor`, self-close empty tags, and replace `<a href>` links with
react-router `<Link to>` (section 5).

---

## 2. Installing and mounting the router — start flat

`react-router-dom` is already installed (Lesson 3). You define the routes in `main.tsx`
with `createBrowserRouter` and render them with `RouterProvider`. Start with the simplest
thing that works — a **flat** list of routes, one path per page:

```tsx
import ReactDOM from "react-dom/client";
import { RouterProvider, createBrowserRouter } from "react-router-dom";
import OrdersPage from "./orders/OrdersPage";
import MenuItemsPage from "./menuItems/MenuItemsPage";

const router = createBrowserRouter([
  { path: "orders", element: <OrdersPage /> },
  { path: "menuitems", element: <MenuItemsPage /> },
]);

ReactDOM.createRoot(document.getElementById("root")!).render(
  <RouterProvider router={router} />
);
```

- Each route is `{ path, element }` — visiting the path renders that component.
- Visit `/orders` and you get `OrdersPage`; visit `/menuitems` and you get
  `MenuItemsPage`. No shared header or nav yet — one page per URL.

That's a working router. But every page needs the same `Header` and `AppNav` around it,
and pasting them into each page component would be repetitive. That's exactly what nested
routes and `Outlet` are for — next.

---

## 3. `Outlet` and nested routes — one shared shell

To wrap every page in the same chrome, put the shared parts in a **`Layout`** component,
then nest the page routes **inside** a `Layout` route. `<Outlet />` is the placeholder
where the active child route renders:

```tsx
import "bootstrap/dist/css/bootstrap.min.css";
import "./App.css";
import Header from "./Header";
import AppNav from "./AppNav";
import { Outlet } from "react-router-dom";

function Layout() {
  return (
    <>
      <Header />
      <main className="d-flex">
        <AppNav />
        <Outlet />
      </main>
    </>
  );
}
export default Layout;
```

> **Where did the Bootstrap import go?** In Lesson 3 it lived in `App.tsx`. `App` is no
> longer in the route tree — `main.tsx` renders the router directly — so its imports
> wouldn't run. Put the CSS imports in `Layout` for now; Lesson 11 brings `App` back as
> the app-wide wrapper.

Now nest the two page routes as **children** of a `Layout` route:

```tsx
const router = createBrowserRouter([
  {
    element: <Layout />,
    children: [
      { path: "orders", element: <OrdersPage /> },
      { path: "menuitems", element: <MenuItemsPage /> },
    ],
  },
]);
```

- The parent route renders `<Layout />`; whichever child route matches renders **into
  `Layout`'s `<Outlet />`**.
- Visit `/orders` → `Layout` draws `Header` + `AppNav`, and its `Outlet` becomes
  `<OrdersPage />`. Visit `/menuitems` → the same `Header` + `AppNav`, only the `Outlet`
  swaps to `<MenuItemsPage />`.
- **The shell renders once; only the page inside the `Outlet` changes** — that's the SPA
  feel. Add a page by adding one `{ path, element }` under `children`; it gets the shell
  for free.

Right now there's just **one `Outlet`** in the whole app — the one in `Layout`. Hold onto
that: a *second* one appears in Lesson 11, for a specific reason (next).

---

## 4. Catching bad routes with `errorElement`

Attach an `errorElement` to the `Layout` route so a bad URL — or an error thrown while
rendering — shows a friendly page instead of a blank screen:

```tsx
import ErrorPage from "./ErrorPage";

const router = createBrowserRouter([
  {
    element: <Layout />,
    errorElement: <ErrorPage />,
    children: [
      { path: "orders", element: <OrdersPage /> },
      { path: "menuitems", element: <MenuItemsPage /> },
    ],
  },
]);
```

`errorElement` catches routing/render errors under this route — including a URL that
matches no page — and renders `ErrorPage`.

> **What's coming in Lesson 11.** Every page so far lives inside the shell. The **Sign
> In** page (Lesson 11) is the exception — it has *no* header or nav. To make a page
> shell-less, you'll wrap this whole tree in an outer **`App`** route that has **its own**
> `Outlet`, and place Sign In as a sibling of `Layout` (inside `App`, outside `Layout`).
> That's when the **second `Outlet`** appears — introduced exactly when a page needs to
> sit outside the shell. For now: one shell, one `Outlet`.

---

## 5. `Link` — navigating without a reload

Never use a plain `<a href>` for in-app navigation — it triggers a full page reload,
throwing away your React state. Use react-router's **`Link`**:

```tsx
import { Link } from "react-router-dom";

<Link to="/menuitems/create" className="btn btn-primary">Add Item</Link>
```

`to` is the path; `Link` renders an `<a>` but intercepts the click and swaps the route
in place — no reload. Every navigation in the app (nav links, Create buttons, Edit
links, row actions) uses `Link`.

The `AppNav` is a column of `Link`s (using react-bootstrap's `Nav` for the pill
styling):

```tsx
import { Link, useLocation } from "react-router-dom";
import Nav from "react-bootstrap/Nav";

function AppNav() {
  const location = useLocation();
  return (
    <Nav variant="pills" defaultActiveKey={location.pathname} as="ul"
      className="d-flex flex-column flex-shrink-0 p-3 bg-body-tertiary border-end min-vh-100 position-sticky"
      style={{ width: 280 }}>
      <Nav.Item as="li" className="text-secondary fw-bold mb-2">Serve</Nav.Item>
      <Nav.Item as="li">
        <Nav.Link eventKey="/orders" as={Link} to="/orders">Orders</Nav.Link>
      </Nav.Item>
      <Nav.Item as="li">
        <Nav.Link eventKey="/menuitems" as={Link} to="/menuitems">Menu</Nav.Link>
      </Nav.Item>
      {/* Categories, Staff … */}
    </Nav>
  );
}
export default AppNav;
```

`as={Link}` tells the react-bootstrap `Nav.Link` to render as a router `Link` so it
navigates without a reload. `useLocation()` gives the current path so the active pill
highlights. (The icons are SVG `<use>` refs to the Bootstrap Icons sprite — carried
over from the static pass.)

---

## 6. Props — passing data into a component

A **prop** is an argument you pass to a component, written like an HTML attribute — how a
parent hands data to a child. You saw `<Nav.Link to="/orders">`; `to` is a prop. Your own
components take props too, and *receiving* one is where the **destructuring from Lesson 1**
finally pays off. Watch a `MenuItemCard` receive its `menuItem` prop in three phases — the
parent passes it the same way every time:

```tsx
<MenuItemCard menuItem={item} />
```

**Phase 1 — the whole `props` object.** A component receives a single argument: an object
holding all its props. Reach in with dot access:

```tsx
function MenuItemCard(props) {
  return (
    <div className="card p-4">
      <span className="fs-4 fw-medium">{props.menuItem.name}</span>
      <span className="fs-5 fw-light">${props.menuItem.price}</span>
    </div>
  );
}
```

Everything comes through `props.` — repetitive, and it's easy to lose track of what's
inside.

**Phase 2 — destructure in the body.** Pull `menuItem` out of `props` on the first line
(the object destructuring from Lesson 1):

```tsx
function MenuItemCard(props) {
  const { menuItem } = props;
  return (
    <div className="card p-4">
      <span className="fs-4 fw-medium">{menuItem.name}</span>
      <span className="fs-5 fw-light">${menuItem.price}</span>
    </div>
  );
}
```

**Phase 3 — destructure in the parameter list.** Since the argument is just an object, do
the destructuring right where it arrives. This is the form the whole course uses:

```tsx
interface IMenuItemCardProps {
  menuItem: IMenuItem;
}

function MenuItemCard({ menuItem }: IMenuItemCardProps) {
  return (
    <div className="card p-4" style={{ width: "23rem" }}>
      <span className="fs-4 fw-medium">{menuItem.name}</span>
      <span className="fs-5 fw-light">${menuItem.price}</span>
    </div>
  );
}
```

- The parent passes it: `<MenuItemCard menuItem={item} />`.
- The child **destructures** it from its single props argument: `({ menuItem })` — Lesson
  1's destructuring, now in the parameter list.
- We type props with an interface (`IMenuItemCardProps`) so the compiler checks the
  parent passes the right shape.

This lets you split a big list component into a `List` (fetches, maps) and a `Card`
(renders one item) — the exact structure the app uses:

```tsx
{menuItems.map((menuItem) => (
  <MenuItemCard key={menuItem.id} menuItem={menuItem} />
))}
```

Note `key` goes on the element in the `.map()`, and `menuItem` is passed as a prop.
(Props also carry **callbacks** — e.g. an `onRemove` function a child calls to tell the
parent to remove an item. You'll use that pattern in Lesson 12's CRUD.)

### The spread operator

When a component takes many props, `{...obj}` **spreads** an object's properties as
individual props — shorthand you'll see in library code and route definitions:

```tsx
const props = { menuItem: item };
<MenuItemCard {...props} />   // same as <MenuItemCard menuItem={item} />
```

---

## 7. Verifying in the browser

With `npm run dev` running:

1. Open the app at **`/orders`** — you should see the `Header` bar and the `AppNav`
   sidebar with the Orders page beside it. (The bare `/` matches no route yet — it shows
   `ErrorPage` until a home route is added in Lesson 11.)
2. Click a nav link — the URL changes (e.g. to `/menuitems`) and the page content swaps
   **without a full reload** (watch the browser's reload spinner — it shouldn't fire).
   The `Header` and `AppNav` stay put; only the `Outlet` area changes.
3. Use the browser **Back** button — it navigates to the previous route (react-router
   integrates with browser history).
4. Open **DevTools → Console** — clean. A blank page usually means a `path` typo or a
   missing `Outlet` in a parent route.
5. Type a bad URL like `/nope` — the `ErrorPage` (or a "no route matches" message)
   shows, proving `errorElement` is wired.

---

## The General Pattern (what to take away)

- A **router** (`createBrowserRouter` + `RouterProvider`) maps **paths to components**.
- **Nested routes** + **`Outlet`** build a shared **shell**: a `Layout` route
  (`Header` + `AppNav`) wraps the page routes and drops the active page into its single
  `Outlet`. Add a page = add one route child. (Lesson 11 wraps this in an outer `App`
  route so the Sign In page can sit outside the shell.)
- **`Link to=`** navigates in-place — never `<a href>` for internal links.
- **Props** pass data from parent to child; destructure them from the props argument
  and type them with an interface. `{...obj}` spreads an object as props.
- Static partials become **components** rendered from the layout.

On PRS you'll build the identical shell — a `Header`, an `AppNav` with Requests /
Products / Vendors / Users links, a `Layout` with an `Outlet`, and a route per page.

---

## Build Steps

1. Convert `header.html` → `Header.tsx` and `nav.html` → `AppNav.tsx` (rename
   `class`→`className`, `<a href>`→`<Link to>`).
2. In `main.tsx`, start with a **flat** router — `createBrowserRouter` with `orders` and
   `menuitems` as top-level `{ path, element }` routes — rendered by `<RouterProvider>`.
3. Create `Layout.tsx` rendering `<Header />`, a `<main className="d-flex">`, `<AppNav />`,
   and an `<Outlet />` (with the Bootstrap CSS imports moved here from `App.tsx`).
4. Nest the page routes as `children` of a `Layout` route and add
   `errorElement: <ErrorPage />` to it — every page now renders inside the shell's single
   `Outlet`.
5. Make the `AppNav` links `Nav.Link as={Link} to="…"` for Orders and Menu.
6. Split your menu list into `MenuItemList` (fetch + map) and `MenuItemCard` (takes a
   `menuItem` **prop**), passing `key` + `menuItem` in the `.map()`.
7. Verify in the browser using section 7 — nav swaps pages without reload, Back works,
   Console is clean.
```
