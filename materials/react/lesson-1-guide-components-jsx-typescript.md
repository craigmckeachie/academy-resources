# Lesson 1 Guide — Components, JSX, and TypeScript (React Orientation)

**This is an intro / overview lesson.** It's the big picture: what a React
single-page app is, how the Vite project is laid out, and the three ideas every
React file is built from — **components**, **JSX**, and **typed data**. There's no
API and no database yet. You render a **hardcoded** array of menu items so you can
see components and JSX working on their own, before data fetching, routing, or forms
enter the picture. You verify everything **by observation in the browser** — not
against the finished reference app, not in Insomnia.

**Goal:** by the end of this lesson you can create a React project with Vite,
understand how `main.tsx` boots the app, write a **component** that returns **JSX**,
describe the shape of your data with a **TypeScript interface**, and render a list by
calling **`.map()`** over a hardcoded array. You'll have a Menu Items page showing a
grid of cards built entirely from local data.

**The general pattern you're learning:** a React UI is a tree of **components** —
functions that return **JSX**. Data is just JavaScript values (typed with an
**interface**), and you turn an array of data into a list of elements with
**`.map()`**. Everything for the rest of this pass — fetching, routing, forms — hangs
off these three ideas.

> **Why hardcoded data here?** This lesson comes *before* the build of the real
> TableServe front end. Its job is to establish mental models, so it deliberately
> uses a local array instead of the API. You confirm it works by looking at the page
> in the browser. Real data fetching arrives in Lesson 2.

---

## 1. What is a single-page app (and where React fits)

In the API pass you built a Web API that returns JSON. In the HTML/CSS pass you built
static pages. **React is what ties them together**: it runs in the browser, fetches
JSON from your Web API, and renders it as HTML — updating the page in place instead of
loading a new one from the server each time. That's a **single-page application
(SPA)**: one HTML shell, and JavaScript swaps the content as the user navigates.

```
Browser (React app)  ──fetch──▶  Web API  ──▶  SQL Server
        │  renders JSON as HTML          ◀── JSON
        ▼
   updates the page in place — no full reload
```

You already saw the request/response half of this in the API pass. React is the piece
that turns the response into what the user sees.

---

## 2. Creating the project with Vite

**Vite** is the build tool and dev server (you met it in the HTML/CSS pass for the
static scaffold — same tool, now driving a React app). Create a project:

```bash
npm create vite@latest tableserve-web -- --template react-ts
cd tableserve-web
npm install
npm run dev
```

- `--template react-ts` gives you **React + TypeScript**.
- `npm run dev` starts the dev server and prints a URL (usually
  `http://localhost:5173`). Open it — you get Vite's starter page.
- Vite has **hot module replacement (HMR)**: save a file and the browser updates
  instantly, no manual refresh.

Install the libraries this pass uses (you'll wire them in over the coming lessons):

```bash
npm install bootstrap react-bootstrap react-router-dom react-hook-form react-hot-toast
```

---

## 3. The project structure

The important files:

```
tableserve-web/
  index.html          ← the single HTML shell; has <div id="root"></div>
  src/
    main.tsx          ← entry point — mounts React into #root
    App.tsx           ← the root component
    App.css           ← app-wide styles
    menuItems/        ← a feature folder (you'll create these per entity)
      IMenuItem.ts     ← the TypeScript interface
      MenuItemsPage.tsx
  package.json        ← scripts and dependencies
  vite.config.ts
```

We organize by **feature folder** — one folder per entity (`menuItems/`, `staff/`,
`orders/`, …), each holding that entity's interface, components, and (later) its API
calls. This is the exact structure the finished app uses and the structure you'll
mirror on PRS.

### How the app boots

`index.html` contains one meaningful line:

```html
<div id="root"></div>
```

`src/main.tsx` finds that `div` and tells React to render your app into it:

```tsx
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.tsx";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

- `createRoot(...).render(...)` mounts the React tree into `#root`.
- `<App />` is your root **component** (next section).
- `<React.StrictMode>` is a development helper that surfaces bugs — leave it.

You rarely touch `main.tsx` in this lesson; it's shown so you know where the app
starts. (In Lesson 3 you'll add the router here.)

---

## 4. Components — functions that return JSX

A **component** is a JavaScript function whose name starts with a **capital letter**
and returns **JSX** (markup). That's the whole definition.

```tsx
function App() {
  return <h1>TableServe</h1>;
}

export default App;
```

- The capital `A` in `App` is required — React treats lowercase names as HTML tags
  (`<div>`) and capitalized names as components (`<App />`).
- `export default App` makes the component importable from other files — this is an
  **ES module** export. `main.tsx` did `import App from "./App.tsx"` to get it. One
  default export per file is our convention.
- You **use** a component by writing it as a tag: `<App />`.

Components nest. A page component renders smaller components, which render smaller ones
still — a tree, rooted at `<App />`.

---

## 5. JSX — markup inside JavaScript

**JSX** is the HTML-like syntax you return from a component. It looks like HTML but
it's JavaScript, so a few things differ:

```tsx
function MenuItemsPage() {
  const heading = "Menu";
  return (
    <section className="content">
      <h2>{heading}</h2>
      <p>Our items are listed below.</p>
    </section>
  );
}
```

The rules that trip people up coming from HTML:

- **`className`, not `class`** — `class` is a reserved word in JavaScript.
- **`{ }` embeds JavaScript** — `{heading}` drops the value of the `heading` variable
  into the markup. Anything inside braces is a JS expression: `{2 + 2}`,
  `{item.name}`, `{items.map(...)}`.
- **One root element** — a component must return a *single* top-level element. Wrap
  siblings in one parent, or an empty **fragment** `<>...</>` if you don't want an
  extra `<div>`:

  ```tsx
  return (
    <>
      <h2>Menu</h2>
      <p>Subtitle</p>
    </>
  );
  ```

- **Self-close empty tags** — `<br />`, `<img />`, `<input />`.
- **`htmlFor`, not `for`** on labels (another reserved word).

If this feels familiar it should — it's the Bootstrap markup from the HTML/CSS pass
with `class` renamed to `className`. The `d-flex`, `card`, `badge` classes all carry
straight over.

---

## 6. Typing your data with an interface

TypeScript lets you describe the **shape** of your data with an **interface**. This is
the same idea as the C# model class from the API pass — a named set of properties and
their types. Create `src/menuItems/IMenuItem.ts`:

```ts
export interface IMenuItem {
  id: number | undefined;
  name: string;
  price: number | undefined;
  categoryId: number | undefined;
  category?: ICategory;
}
```

- We prefix interfaces with `I` (`IMenuItem`, `IStaff`, `IOrder`) — a convention that
  makes them easy to spot.
- `number | undefined` is a **union type**: the value is a number *or* `undefined`
  (an id doesn't exist until the server assigns one).
- `category?: ICategory` — the `?` marks the property **optional**; it may be absent.
- This mirrors the C# `MenuItem` model exactly (`Id`, `Name`, `Price`, `CategoryId`,
  `Category` nav property). The interface is how the front end knows what the API
  returns.

For this lesson, `category` isn't needed — you'll display just `name` and `price` — so
a minimal `IMenuItem` with `id`, `name`, and `price` is enough to start.

---

## 7. Rendering a list with `.map()`

Real UIs render *lists*. In React you turn an **array of data** into an **array of
JSX elements** by calling **`.map()`**. Here's the whole page with a hardcoded array:

```tsx
import { IMenuItem } from "./IMenuItem";

const menuItems: IMenuItem[] = [
  { id: 1, name: "Loaded Nachos", price: 9.99, categoryId: 1 },
  { id: 2, name: "Mozzarella Sticks", price: 7.99, categoryId: 1 },
  { id: 3, name: "Ribeye Steak", price: 24.99, categoryId: 2 },
];

function MenuItemsPage() {
  return (
    <section className="content container-fluid mx-5 my-2 py-4">
      <h2 className="pb-4 mb-4 border-bottom border-2">Menu</h2>
      <section className="list d-flex flex-row flex-wrap bg-light gap-5 p-4 rounded-4">
        {menuItems.map((menuItem) => (
          <div className="card p-4" style={{ width: "23rem" }} key={menuItem.id}>
            <span className="fs-4 fw-medium">{menuItem.name}</span>
            <span className="fs-5 fw-light">${menuItem.price}</span>
          </div>
        ))}
      </section>
    </section>
  );
}

export default MenuItemsPage;
```

The three things to understand:

- **`menuItems.map((menuItem) => (...))`** runs the arrow function once per array
  element, producing one `<div className="card">` per menu item. The resulting array
  of elements renders in order.
- **`{menuItem.name}` / `{menuItem.price}`** pull values out of each item with the
  `{ }` embed from section 5.
- **`key={menuItem.id}`** — every element in a `.map()` needs a unique **`key`** so
  React can track items efficiently when the list changes. Use the record's `id`.
  Never use the array index if the list can reorder, and never `Math.random()`.

`const menuItems: IMenuItem[]` types the array — `IMenuItem[]` means "an array of
`IMenuItem`." TypeScript now checks that each object has the right properties, and your
editor autocompletes `menuItem.name`.

> **Styling note:** the `card`, `d-flex flex-wrap`, `gap-5`, `badge` classes are the
> same Bootstrap classes from the HTML/CSS pass. Import Bootstrap's CSS once (in
> `App.tsx`, shown next lesson) and every class works. This lesson focuses on the
> React mechanics; the polished `MenuItemCard` component comes in Lesson 4.

---

## 8. Wiring the page into `App`

Render your page from the root component so it shows up:

```tsx
import "bootstrap/dist/css/bootstrap.min.css";
import "./App.css";
import MenuItemsPage from "./menuItems/MenuItemsPage";

function App() {
  return <MenuItemsPage />;
}

export default App;
```

Save, and the browser (still running `npm run dev`) updates instantly — a wrapping grid
of hardcoded menu cards.

---

## 9. Verifying in the browser

There's no Insomnia and no API here — you verify **by looking at the page and the
DevTools**. With `npm run dev` running:

1. Open the printed URL (e.g. `http://localhost:5173`). You should see the **Menu**
   heading and one card per item in your hardcoded array.
2. Open **DevTools → Console** (F12). It should be clean. The most common first error
   is **"Each child in a list should have a unique key"** — that means a `.map()` is
   missing its `key={...}`. Add it and the warning clears.
3. Edit an item's `name` in the array and save — the card updates immediately (that's
   HMR + React re-rendering).
4. Add a fourth object to the `menuItems` array and save — a fourth card appears
   without you writing any more JSX. That's the payoff of `.map()`: the markup is
   written once; the data drives how many render.
5. **Install React DevTools** (browser extension) if you can — the **Components** tab
   shows your component tree (`App → MenuItemsPage`), which is the clearest way to
   *see* that a React app is a tree of components.

---

## The General Pattern (what to take away)

- A **component** is a capitalized function that returns **JSX**; you export it
  (`export default`) and use it as a tag (`<MenuItemsPage />`).
- **JSX** is HTML-like markup in JavaScript: `className` not `class`, `{ }` to embed
  values, one root element (or a `<>` fragment).
- A **TypeScript interface** (`IMenuItem`) names the shape of your data — the front-end
  echo of your C# model.
- **`.map()`** turns an array of data into a list of elements; each needs a unique
  **`key`**.
- Everything else in this pass builds on these: Lesson 2 swaps the hardcoded array for
  a real fetch; Lesson 3 adds routing between pages; Lesson 5 adds forms.

On PRS you'll write the same three things first — an `IProduct` interface, a
`ProductsPage` component, and a `.map()` over products — before any data loads.

---

## Build Steps

1. Scaffold the project: `npm create vite@latest tableserve-web -- --template react-ts`,
   then `cd` in and `npm install`.
2. Install the pass's libraries (`bootstrap react-bootstrap react-router-dom
   react-hook-form react-hot-toast`) and start `npm run dev`.
3. Create the `src/menuItems/` feature folder.
4. In `src/menuItems/IMenuItem.ts`, define the `IMenuItem` **interface** (start with
   `id`, `name`, `price`).
5. In `src/menuItems/MenuItemsPage.tsx`, declare a hardcoded `IMenuItem[]` array and a
   `MenuItemsPage` **component** that **`.map()`s** it into cards, each with a **`key`**.
6. In `App.tsx`, import Bootstrap's CSS and render `<MenuItemsPage />`.
7. Verify in the browser using section 9 — cards render, the Console is clean, adding an
   array item adds a card.
```
