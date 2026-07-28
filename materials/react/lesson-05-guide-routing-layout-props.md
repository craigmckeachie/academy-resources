# Lesson 5 Guide — Routing, the App Shell, and Props

**Goal:** by the end of this lesson your app has **multiple pages** you navigate between
without full reloads, wrapped in a shared **shell** — a `Header` across the top and an
`AppNav` sidebar — built with **react-router-dom**. You'll convert the static
`header`/`nav` partials from the HTML/CSS pass into JSX components, learn **props** to pass
data into components, and use **`Outlet`** and **nested routes** to place each page inside
the shell.

**The general pattern you're learning:** a router maps **URL paths to components**. A
**layout** component renders the shared chrome once and drops the current page into an
**`Outlet`**. **Props** are how a parent component hands data down to a child. This shell +
routing setup is built once and hosts every page in the app.

> **How to use this guide.** Sections headed **▶ Code along** are ones you **build into your
> project** — type them as you go. Unmarked sections are concept: read them (or watch the
> instructor), nothing to type. Each code block carries its file name as a title bar. The
> **Build Steps** at the end recap every ▶ Code along action in order.

---

## 1. From static partials to provided components

*(Read this.)*

In the HTML/CSS pass, `{{> header}}` and `{{> nav}}` were Handlebars partials Vite stitched
into every page — and you were **handed** finished `header.html` / `nav.html`. React has no
partials; **a component is the reuse unit**, so `header.html` becomes a `Header.tsx`
component, `nav.html` becomes an `AppNav.tsx`, and a shared `Layout` renders `<Header />` +
`<AppNav />` on every page.

**We hand you both again — finished `Header.tsx` and `AppNav.tsx` (section 3).** Converting
the shell's markup to JSX is fiddly (the logo and nav icons are SVG, which doesn't paste
cleanly — section 3 shows what's involved) and it's beside the point of a routing lesson, so
it's done for you. You *will* convert markup yourself later — when you turn your **PRS**
static pages into JSX during the capstone — so read the provided files now to see the shape.

---

## 2. ▶ Code along — Mount the router (start flat)

`react-router-dom` is already installed (Lesson 3). In Lesson 3, `main.tsx` rendered
`<App />` inside `<React.StrictMode>`; now **swap that `<App />` for a router** (`App.tsx` then
sits unused until Lesson 11 brings it back). Define the routes with `createBrowserRouter` and
hand them to `RouterProvider` — start with the simplest thing that works, a **flat** list of
routes, one path per page:

```diff title="src/main.tsx"
  import React from "react";
  import ReactDOM from "react-dom/client";
+ import { RouterProvider, createBrowserRouter } from "react-router-dom";
+ import MenuItemsPage from "./menuItems/MenuItemsPage";
+ import OrdersPage from "./orders/OrdersPage";
- import App from "./App.tsx";

+ const router = createBrowserRouter([
+   { path: "menuitems", element: <MenuItemsPage /> },
+   { path: "orders", element: <OrdersPage /> },
+ ]);

  ReactDOM.createRoot(document.getElementById("root")!).render(
    <React.StrictMode>
-     <App />
+     <RouterProvider router={router} />
    </React.StrictMode>
  );
```

- Each route is `{ path, element }` — visiting the path renders that component.
- Visit `/menuitems` and you get the page you built in Lessons 3–4. `OrdersPage` is built in
  Lesson 6 — for now a one-line stub is enough to route to:

  ```tsx title="src/orders/OrdersPage.tsx"
  function OrdersPage() {
    return <h2>Orders</h2>;
  }
  export default OrdersPage;
  ```

- No shared header or nav yet — one page per URL. Every page needs the same `Header` and
  `AppNav` around it, and pasting them into each page would be repetitive — that's what
  `Link`, nested routes, and `Outlet` are for next.

**Save and check:** open **`/menuitems`** in the browser — your Menu page renders (no shell
yet), and `/orders` shows the stub heading. There's no nav to click yet; type the paths in
the address bar.

---

## 3. ▶ Code along — Drop in the provided shell (`Header` + `AppNav`)

Both files are **handed to you** — copy them in as-is, then read the notes so you understand
what's inside (you'll write plenty of `Link`s and react-bootstrap components yourself from
here on).

**Navigate with `Link`, never `<a href>`.** A plain `<a href>` triggers a full page reload,
throwing away your React state. react-router's **`Link`** renders an `<a>` but intercepts the
click and swaps the route in place — no reload; `to` is the path. Every in-app navigation
(nav links, Create buttons, Edit links, row actions) uses it — including each `Nav.Link`
below.

Here's the provided **`AppNav`** — a column of `Link`s on react-bootstrap's `Nav`, with the
Bootstrap Icons already wired up:

```tsx title="src/AppNav.tsx"
import { Link, useLocation } from "react-router-dom";
import Nav from "react-bootstrap/Nav";
import bootstrapIcons from "./assets/bootstrap-icons.svg";

function AppNav() {
  const location = useLocation();
  return (
    <Nav variant="pills" defaultActiveKey={location.pathname} as="ul"
      className="d-flex flex-column flex-shrink-0 p-3 bg-body-tertiary border-end min-vh-100 position-sticky"
      style={{ width: 280 }}>
      <Nav.Item as="li" className="text-secondary fw-bold mb-2">Serve</Nav.Item>
      <Nav.Item as="li">
        <Nav.Link eventKey="/orders" as={Link} to="/orders">
          <svg className="bi pe-none me-2" width={16} height={16} fill="currentColor">
            <use xlinkHref={`${bootstrapIcons}#cart`} />
          </svg>
          Orders
        </Nav.Link>
      </Nav.Item>
      <Nav.Item as="li">
        <Nav.Link eventKey="/menuitems" as={Link} to="/menuitems">
          <svg className="bi pe-none me-2" width={16} height={16} fill="currentColor">
            <use xlinkHref={`${bootstrapIcons}#journal-text`} />
          </svg>
          Menu
        </Nav.Link>
      </Nav.Item>
      {/* Categories, Staff — add these Nav.Items as those pages get built */}
    </Nav>
  );
}
export default AppNav;
```

> Copy the **`bootstrap-icons.svg`** sprite from your HTML/CSS project's `assets/` into
> `src/assets/` so that `import` resolves.

- **`variant="pills"`** — the `Nav` style: rounded "pill" links with a filled background on
  the active one (Bootstrap's `.nav-pills`). The other built-in option is `variant="tabs"`.
- **`as="ul"` / `as="li"`** — react-bootstrap's **`as` prop** renders a component as a
  *different* element. `Nav` and `Nav.Item` render as `<div>`s by default; `as="ul"` and
  `as="li"` make them a proper semantic `<ul>` / `<li>` list. It's the same prop as
  **`as={Link}`** on `Nav.Link`, which renders each link as a router `Link` so it navigates
  without a reload — `as` takes either an HTML tag name (`"ul"`) *or* a component (`Link`).
- **`eventKey` + `defaultActiveKey`** — react-bootstrap highlights one link as **active** by
  matching keys. Each `Nav.Link` has an `eventKey` set to its path (`"/orders"`), and
  `defaultActiveKey={location.pathname}` seeds the active one from the **current URL**
  (`useLocation()` gives that path) — so the pill for the page you're on is highlighted.
- **The icons** are SVG `<use>` refs to the Bootstrap Icons sprite — the fiddly SVG-in-JSX
  bit (import the sprite, `xlinkHref`), and the main reason `AppNav` is handed to you. See
  **SVGs in JSX** below.

> **Why `react-bootstrap`, not just Bootstrap?** You've used **Bootstrap's CSS classes**
> (`card`, `d-flex`, `badge`) directly since Lesson 3 — those are just class names, and they
> stay. But Bootstrap's *interactive* widgets — dropdowns, modals, nav pills that track the
> active tab — are normally driven by **Bootstrap's own JavaScript** through
> `data-bs-toggle` attributes that reach into the page and toggle things themselves. That
> fights React, which already owns the DOM (it renders from state); two libraries poking at
> the same DOM leads to bugs. **`react-bootstrap`** fixes this: it reimplements those widgets
> as **React components** (`<Nav>`, `<Dropdown>`, `<Modal>`) that look identical (same
> Bootstrap CSS) but manage their behavior with **React state**, not `data-bs-toggle` — so we
> don't load Bootstrap's JS bundle at all. The rule for this course: **Bootstrap classes for
> styling/layout; `react-bootstrap` components for anything interactive** (the nav here,
> dropdowns in Lesson 6, modals in Lesson 9).

And the provided **`Header`** — the logo + title bar. It's just the logo and title for now:
the signed-in **`Dropdown`** and the **Sign in** button need the Staff context, which arrives
in **Lesson 11**, so they're added there.

```tsx title="src/Header.tsx"
import { Link } from "react-router-dom";

function Header() {
  return (
    <header>
      <div className="navbar bg-body-tertiary py-4 border-bottom">
        <div className="container-fluid">
          <Link to="/" className="d-flex align-items-center link-body-emphasis text-decoration-none">
            <svg width={52} height={21} viewBox="0 0 78 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M55.5 0H77.5L58.5 32H36.5L55.5 0Z" fill="#FF7A00" />
              <path d="M35.5 0H51.5L32.5 32H16.5L35.5 0Z" fill="#FF9736" />
              <path d="M19.5 0H31.5L12.5 32H0.5L19.5 0Z" fill="#FFBC7D" />
            </svg>
            <span className="small mx-2 fw-semibold" style={{ color: "#FF7A00" }}>
              TableServe
            </span>
          </Link>
        </div>
      </div>
    </header>
  );
}

export default Header;
```

> **SVGs in JSX — what we converted for you.** The logo above and the nav icons are SVG, and
> SVG doesn't paste from HTML into JSX cleanly — the main reason the shell is handed to you.
> Two things happen in the conversion, worth **recognizing** for when you turn your PRS pages
> into JSX in the capstone:
> - **Attribute names go camelCase** — `class` → `className`, and hyphenated SVG attributes
>   (`stroke-width` → `strokeWidth`, `fill-rule` → `fillRule`). React warns in the console
>   about any that slip through.
> - **The Bootstrap Icons sprite is `import`ed, not path-referenced.** The static pass wrote
>   `<use href="/assets/bootstrap-icons.svg#cart" />`; in Vite you `import` the sprite for its
>   bundled URL and write `<use xlinkHref={`${bootstrapIcons}#cart`} />` (as in `AppNav`
>   above). (`xlinkHref` is React's name for SVG's `xlink:href`; plain `href` also works in
>   React 18.)

**Check:** nothing new on screen yet — `AppNav` and `Header` don't render until `Layout`
wraps them (next section). For now confirm the editor shows **no red import/type errors**,
and that `src/assets/bootstrap-icons.svg` exists so the `AppNav` import resolves.

---

## 4. ▶ Code along — `Outlet` and nested routes (one shared shell)

To wrap every page in the same chrome, put the shared parts in a **`Layout`** component,
then nest the page routes **inside** a `Layout` route. `<Outlet />` is the placeholder where
the active child route renders:

```tsx title="src/Layout.tsx"
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
> wouldn't run. Put the CSS imports in `Layout` for now; Lesson 11 brings `App` back as the
> app-wide wrapper.

Now nest the page routes as **children** of a `Layout` route:

```diff title="src/main.tsx"
+ import Layout from "./Layout";
  ...
  const router = createBrowserRouter([
-   { path: "menuitems", element: <MenuItemsPage /> },
-   { path: "orders", element: <OrdersPage /> },
+   {
+     element: <Layout />,
+     children: [
+       { path: "menuitems", element: <MenuItemsPage /> },
+       { path: "orders", element: <OrdersPage /> },
+     ],
+   },
  ]);
```

- The parent route renders `<Layout />`; whichever child route matches renders **into
  `Layout`'s `<Outlet />`**.
- Visit `/menuitems` → `Layout` draws `Header` + `AppNav`, and its `Outlet` becomes
  `<MenuItemsPage />`. Visit `/orders` → the same `Header` + `AppNav`, only the `Outlet`
  swaps.
- **The shell renders once; only the page inside the `Outlet` changes** — that's the SPA
  feel. Add a page by adding one `{ path, element }` under `children`; it gets the shell for
  free.

Right now there's just **one `Outlet`** in the whole app — the one in `Layout`. Hold onto
that: a *second* one appears in Lesson 11, for a specific reason (below).

**Save and check:** open **`/menuitems`** — now the `Header` bar and `AppNav` sidebar wrap
the page, and clicking **Menu** / **Orders** swaps the content **without a full reload** (the
shell stays put).

---

## 5. ▶ Code along — Catch bad routes with `errorElement`

A bad URL — or an error thrown while rendering — should show a friendly page, not a blank
screen. **First create that page.** react-router hands the caught error to it via
**`useRouteError()`**:

```tsx title="src/ErrorPage.tsx"
import { useRouteError } from "react-router-dom";

export default function ErrorPage() {
  const error = useRouteError() as Error;
  console.error(error);

  return (
    <div id="error-page">
      <h1>Oops!</h1>
      <p>Sorry, an unexpected error has occurred.</p>
      <p>
        <i>{error.message}</i>
      </p>
    </div>
  );
}
```

Now attach it to the `Layout` route as its **`errorElement`**:

```diff title="src/main.tsx"
+ import ErrorPage from "./ErrorPage";
  ...
  const router = createBrowserRouter([
    {
      element: <Layout />,
+     errorElement: <ErrorPage />,
      children: [
        { path: "menuitems", element: <MenuItemsPage /> },
        { path: "orders", element: <OrdersPage /> },
      ],
    },
  ]);
```

`errorElement` catches routing/render errors under this route — including a URL that matches
no page — and renders `ErrorPage`.

> **✅ Checkpoint.** Open `/menuitems`: the `Header` and `AppNav` **shell** render with your
> page beside it; click a nav pill and the page swaps **without a full reload**; and **type a
> bad URL like `/nope` in the address bar** — you get the `ErrorPage` ("Oops!") instead of a
> blank screen. That's the whole shell working — a natural place to pause before props.

> **What's coming in Lesson 11.** Every page so far lives inside the shell. The **Sign In**
> page (Lesson 11) is the exception — it has *no* header or nav. To make a page shell-less,
> you'll wrap this whole tree in an outer **`App`** route that has **its own** `Outlet`, and
> place Sign In as a sibling of `Layout`. That's when the **second `Outlet`** appears —
> introduced exactly when a page needs to sit outside the shell.

---

## 6. ▶ Code along — Props: extract a `MenuItemCard`

A **prop** is an argument you pass to a component, written like an HTML attribute — how a
parent hands data to a child. You saw `<Nav.Link to="/orders">`; `to` is a prop. Your own
components take props too, and *receiving* one is where the **destructuring from Lesson 1**
finally pays off. Watch a `MenuItemCard` receive its `menuItem` prop in three phases — the
parent passes it the same way every time:

```tsx
<MenuItemCard menuItem={item} />
```

**Phases 1–2 show the evolution so the final form makes sense — you only *type* phase 3.**

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

Everything comes through `props.` — repetitive, and it's easy to lose track of what's inside.

**Phase 2 — destructure in the body.** Pull `menuItem` out of `props` on the first line (the
object destructuring from Lesson 1):

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
the destructuring right where it arrives. **This is the form to type** — the whole course
uses it:

```tsx title="src/menuItems/MenuItemCard.tsx"
import { IMenuItem } from "./IMenuItem";

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

export default MenuItemCard;
```

- The parent passes it: `<MenuItemCard menuItem={item} />`.
- The child **destructures** it from its single props argument: `({ menuItem })` — Lesson
  1's destructuring, now in the parameter list.
- We type props with an interface (`IMenuItemCardProps`) so the compiler checks the parent
  passes the right shape.

Now **pull the per-item card out of `MenuItemsPage`** into that `MenuItemCard` —
`MenuItemsPage` still fetches and maps; `MenuItemCard` renders one item:

```diff title="src/menuItems/MenuItemsPage.tsx"
+ import MenuItemCard from "./MenuItemCard";
  ...
  function MenuItemsPage() {
    ...
    return (
      ...
      {menuItems.map((menuItem) => (
-       <div className="card p-4" style={{ width: "23rem" }} key={menuItem.id}>
-         <span className="fs-4 fw-medium">{menuItem.name}</span>
-         <span className="fs-5 fw-light">${menuItem.price}</span>
-       </div>
+       <MenuItemCard key={menuItem.id} menuItem={menuItem} />
      ))}
      ...
    );
  }
```

Note `key` goes on the element in the `.map()`, and `menuItem` is passed as a prop. (Props
also carry **callbacks** — e.g. an `onRemove` function a child calls to tell the parent to
remove an item. You'll use that pattern in Lesson 12's CRUD.)

### The spread operator

When a component takes many props, `{...obj}` **spreads** an object's properties as
individual props — shorthand you'll see in library code and route definitions. With two or
more props it earns its keep: one `{...cardProps}` instead of listing each by hand:

```tsx
const cardProps = { menuItem: item, onRemove: removeMenuItem };
<MenuItemCard {...cardProps} />
// same as: <MenuItemCard menuItem={item} onRemove={removeMenuItem} />
```

That `onRemove` is the callback prop noted just above — the real `MenuItemCard` takes both a
`menuItem` and an `onRemove`, so spreading a two-key object hands over both at once.

**Save and check:** the menu cards look **exactly the same** as before — each is now a
`<MenuItemCard>`. An unchanged page is the win: you moved the rendering into a reusable
component without changing the output.

---

## 7. Verifying in the browser

You've checked each piece as you built it; this is the full end-to-end pass. With
`npm run dev` running:

1. Open the app at **`/menuitems`** — you should see the `Header` bar and the `AppNav`
   sidebar with the Menu page beside it. (The bare `/` matches no route yet — it shows
   `ErrorPage` until a home route is added in Lesson 11.)
2. Click a nav link — the URL changes (e.g. to `/orders`) and the page content swaps
   **without a full reload** (watch the browser's reload spinner — it shouldn't fire). The
   `Header` and `AppNav` stay put; only the `Outlet` area changes.
3. Use the browser **Back** button — it navigates to the previous route (react-router
   integrates with browser history).
4. Open **DevTools → Console** — clean. A blank page usually means a `path` typo or a
   missing `Outlet` in a parent route.
5. Type a bad URL like `/nope` — the `ErrorPage` (or a "no route matches" message) shows,
   proving `errorElement` is wired.

---

## The General Pattern (what to take away)

- A **router** (`createBrowserRouter` + `RouterProvider`) maps **paths to components**.
- **Nested routes** + **`Outlet`** build a shared **shell**: a `Layout` route (`Header` +
  `AppNav`) wraps the page routes and drops the active page into its single `Outlet`. Add a
  page = add one route child. (Lesson 11 wraps this in an outer `App` route so the Sign In
  page can sit outside the shell.)
- **`Link to=`** navigates in-place — never `<a href>` for internal links.
- **Props** pass data from parent to child; destructure them from the props argument and
  type them with an interface. `{...obj}` spreads an object as props.
- Static partials become **components** rendered from the layout.

On PRS you'll build the identical shell — a `Header`, an `AppNav` with Requests / Products /
Vendors / Users links, a `Layout` with an `Outlet`, and a route per page.

---

## Build Steps

1. In `main.tsx`, mount a **flat** router — `createBrowserRouter` with a `menuitems` route
   (your Lessons 3–4 page) and an `orders` route (a one-line `OrdersPage` stub until Lesson
   6) — rendered by `<RouterProvider>`.
2. **Drop in the provided `AppNav.tsx` and `Header.tsx`** (section 3), and copy the
   `bootstrap-icons.svg` sprite into `src/assets/`.
3. Create `Layout.tsx` (`<Header />`, `<main className="d-flex">`, `<AppNav />`, `<Outlet />`;
   move the Bootstrap CSS import here from `App.tsx`), and **nest** the page routes as
   `children` of a `Layout` route.
4. Create `ErrorPage.tsx` (uses `useRouteError()`) and add `errorElement: <ErrorPage />` to
   the `Layout` route. **✅ Checkpoint** — shell renders, nav swaps pages without reload, and
   typing a bad URL like `/nope` shows `ErrorPage`.
5. **Props:** extract a `MenuItemCard` (takes a `menuItem` prop, typed with an interface)
   from `MenuItemsPage`, and render `<MenuItemCard key={…} menuItem={…} />` inside the
   `.map()`.
6. Verify in the browser using section 7 — nav swaps pages without reload, Back works,
   Console is clean.
