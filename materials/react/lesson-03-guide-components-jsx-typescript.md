# Lesson 3 Guide — Components, JSX, and TypeScript (React Orientation)

**This is an intro / overview lesson.** It's the big picture: what a React
single-page app is, how the Vite project is laid out, and the three ideas every
React file is built from — **components**, **JSX**, and **typed data**. There's no
API and no database yet. You render **one hardcoded menu-item card**, then a whole
**list** of them, so you see components and JSX working on their own — before data
fetching, routing, or forms. You verify everything **by observation in the browser** —
not against the finished reference app, not in Insomnia.

> **This lesson builds on the JavaScript and TypeScript intro (Lessons 1–2).** `.map()`,
> `interface`, and `import`/`export` are used here as tools you already met — this lesson
> is about putting them together into your first React components, not re-teaching the
> language. If any of those feel shaky, revisit Lessons 1–2 first.

**Goal:** by the end of this lesson you can create a React project with Vite, write a
**component** that returns **JSX**, describe the shape of your data with a **TypeScript
interface**, render **one** card from that data, and then render a **whole list** by
calling **`.map()`** over a hardcoded array. You'll have a Menu Items page showing a grid
of cards built entirely from local data.

**The general pattern you're learning:** a React UI is a tree of **components** —
functions that return **JSX**. Data is just JavaScript values (typed with an
**interface**), and you turn an array of data into a list of elements with
**`.map()`**. Everything for the rest of this pass — fetching, routing, forms — hangs
off these three ideas.

> **How to use this guide.** Sections headed **▶ Code along** are ones you **build into
> your project** — type them as you go. Unmarked sections are concept or orientation:
> read them (or watch the instructor), but there's nothing to type. Each code block names
> the file it belongs in on its first line (e.g. `// src/menuItems/IMenuItem.ts`). The
> **Build Steps** at the end recap every ▶ Code along action in order, so you can catch up
> on your own.

> **Why hardcoded data here?** This lesson comes *before* the build of the real
> TableServe front end. Its job is to establish mental models, so it deliberately
> uses local data instead of the API. You confirm it works by looking at the page in the
> browser. Real data fetching arrives in Lesson 4.

---

## 1. What is a single-page app (and where React fits)

*(Read this — nothing to type yet.)*

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

## 2. ▶ Code along — Create the project

*(One-time setup. You run these commands once; the rest of the pass builds inside this
project.)*

**Vite** is the build tool and dev server (you met it in the HTML/CSS pass for the
static scaffold — same tool, now driving a React app). Create the project:

```bash
npm create vite@latest TableServe.Web -- --template react-ts
cd TableServe.Web
npm install
npm run dev
```

- `--template react-ts` gives you **React + TypeScript**.
- Vite may prompt for a **package name** (npm names can't contain capitals or dots) —
  accept its suggested `tableserve.web`; the folder still keeps the `TableServe.Web` name.
- `npm run dev` starts the dev server and prints a URL (usually
  `http://localhost:5173`). Open it — you get Vite's starter page.
- Vite has **hot module replacement (HMR)**: save a file and the browser updates
  instantly, no manual refresh. Leave `npm run dev` running for the whole lesson.

**One tsconfig tweak (do this now).** Current Vite scaffolds `tsconfig.app.json` with
`"verbatimModuleSyntax": true`, which forces a special `import type { … }` form when you
import an interface (a *type-only* import). To keep every import simple and consistent — a
plain `import { … }` whether you're importing a component, a function, or an interface —
open **`tsconfig.app.json`** and set that option to `false` (or delete the line):

```jsonc title="tsconfig.app.json"
"verbatimModuleSyntax": false,
```

Now `import { IMenuItem } from "./IMenuItem"` works exactly like importing anything else — no
special `type` keyword needed. (Leaving the flag on isn't wrong; it just adds `import type`
noise this course doesn't need.)

Install the libraries this pass uses (you'll wire them in over the coming lessons):

```bash
npm install bootstrap react-bootstrap react-router-dom react-hook-form react-hot-toast
```

**Save and check:** the dev server is running and the browser shows Vite's default starter
page (a spinning logo + a counter button) at the printed URL — proof the project scaffolded.
You'll replace that starter content in section 5.

---

## 3. How the project is laid out and boots

*(Read this to get oriented — **you won't edit `main.tsx` in this lesson**.)*

The important files:

```
TableServe.Web/
  index.html          ← the single HTML shell; has <div id="root"></div>
  src/
    main.tsx          ← entry point — mounts React into #root
    index.css         ← global styles (Vite ships demo CSS here)
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

**How the app boots:** `index.html` contains one meaningful line, `<div id="root"></div>`.
`src/main.tsx` (already generated by Vite) finds that `div` and tells React to render your
app into it:

```tsx title="src/main.tsx"
ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

- `createRoot(...).render(...)` mounts the React tree into `#root`.
- `<App />` is your root **component** (next section).
- `<React.StrictMode>` is a development helper that surfaces bugs — leave it.

You don't touch `main.tsx` in this lesson. (In Lesson 5 you'll add the router here.)

---

## 4. Components & JSX — the two ideas

*(Read this. You'll put both to work in section 5.)*

**A component** is a JavaScript function whose name starts with a **capital letter** and
returns **JSX** (markup). That's the whole definition:

```tsx
function App() {
  return <h1>TableServe</h1>;
}

export default App;
```

- The capital `A` is required — React treats lowercase names as HTML tags (`<div>`) and
  capitalized names as components (`<App />`).
- `export default App` makes the component importable — the **default export** from
  Lesson 1. You **use** a component by writing it as a tag: `<App />`. Components nest: a
  page renders smaller components, a tree rooted at `<App />`.

> **Default vs named exports (Lesson 1), made concrete.** `App` is a **default** export —
> imported with no braces, and the importer can name it anything: `import App from "./App"`.
> The `IMenuItem` interface you write next is a **named** export — imported in braces that
> must match its exact name: `import { IMenuItem } from "./IMenuItem"`. That pairing *is*
> the convention: **default exports for components** (one per file), **named exports for
> helpers, interfaces, and hooks**. The tell from Lesson 1 holds: **braces in an import
> mean a named export.**

**JSX** is the HTML-like syntax you return from a component. It looks like HTML, but it's
JavaScript, so a few things differ:

- **`className`, not `class`** — `class` is a reserved word in JavaScript.
- **`{ }` embeds JavaScript** — `{heading}` drops the value of `heading` into the markup.
  Anything in braces is a JS expression: `{2 + 2}`, `{item.name}`, `{items.map(...)}`.
- **One root element** — a component returns a *single* top-level element. Wrap siblings
  in one parent, or an empty **fragment** `<>...</>` if you don't want an extra `<div>`.
- **Self-close empty tags** — `<br />`, `<img />`, `<input />`.
- **`htmlFor`, not `for`** on labels (another reserved word).

If this feels familiar it should — it's the Bootstrap markup from the HTML/CSS pass with
`class` renamed to `className`.

---

## 5. ▶ Code along — Your first component: an interface and one card

Start with a single card so you can *see* a component render typed data, before any loop.

**Describe the data with an interface.** You met **interfaces** in Lesson 2 — a named set
of properties and their types, the front-end echo of your C# model. Create the feature
folder `src/menuItems/`, then the interface:

```ts title="src/menuItems/IMenuItem.ts"
export interface IMenuItem {
  id: number | undefined;
  name: string;
  price: number | undefined;
}
```

The `I` prefix is our convention; `number | undefined` is a **union** (an id doesn't
exist until the server assigns one). The real model has more fields (`categoryId`,
`category`) — you'll add them when they're needed; `id`, `name`, `price` is enough to
start.

**Render one card.** Write a component that holds one hardcoded item and returns plain
JSX for it — no styling yet, just the React shape:

```tsx title="src/menuItems/MenuItemsPage.tsx"
import { IMenuItem } from "./IMenuItem";

const nachos: IMenuItem = { id: 1, name: "Loaded Nachos", price: 9.99 };

function MenuItemsPage() {
  return (
    <section>
      <h2>Menu</h2>
      <div>
        <span>{nachos.name}</span>
        <span>${nachos.price}</span>
      </div>
    </section>
  );
}

export default MenuItemsPage;
```

`{nachos.name}` and `{nachos.price}` are the `{ }` embed from section 4 — pulling values
out of your typed object into the markup.

**Clear out Vite's starter content.** The scaffold filled a few files with a demo app —
a counter, the Vite/React logos, and demo styles (a centered, max-width `#root`, and even
a `.card` rule that would fight Bootstrap later). Wipe all of it so you start from a blank
slate:

- **`src/App.tsx`** — **delete the entire file's contents and replace them** with the
  snippet below. That removes the logo `import`s, the `useState` counter, and the starter
  JSX in one move (a full replace is cleaner here than editing line by line).
- **`src/App.css`** and **`src/index.css`** — **select all and delete** so each file is
  empty. You don't need Vite's demo styles; Bootstrap provides the look in section 8. Leave
  the (now-empty) files in place — they're still imported elsewhere, and that's fine.

**Show it on screen.** Point the root component at your page. For now `App` just renders
`<MenuItemsPage />`:

```tsx title="src/App.tsx"
import MenuItemsPage from "./menuItems/MenuItemsPage";

function App() {
  return <MenuItemsPage />;
}

export default App;
```

Save. With `npm run dev` running, the browser shows the **Menu** heading and **one**
plain card — the name and price of your one item, with **no Vite logos or counter**.

> **✅ Checkpoint.** One card on screen means a **component** is rendering **typed data**
> through **JSX** — the whole core of React, working. If you're following along live,
> this is a natural place to pause before the next part.

---

## 6. Two arrow shapes: `=> ( … )` vs `=> { … }`

*(Read this — it's the one syntax gotcha in the next section.)*

In a moment you'll pass an arrow function to `.map()`, and which **shape** you use
matters. From Lesson 1, an arrow function has two forms:

- **`item => ( … )`** — the parentheses hold a **single expression** that is **returned
  automatically**. The parens are just grouping so the JSX can span several lines. This is
  the form you use to return JSX from `.map()`.
- **`item => { … }`** — the curly braces are a **block body**; a block runs statements and
  **returns nothing unless you write `return`**.

So these two are equivalent:

```tsx
menuItem => ( <div>{menuItem.name}</div> )          // implicit return of the JSX
menuItem => { return <div>{menuItem.name}</div>; }  // block body, explicit return
```

…but this one is the classic first bug — a block body with **no `return`**, which renders
**nothing**:

```tsx
menuItem => { <div>{menuItem.name}</div> }          // ⚠ returns undefined — blank output
```

Rule of thumb for `.map()`: reach for `=> ( … )` so the JSX is returned for you.

---

## 7. ▶ Code along — Render the list with `.map()`

One card is good; a real page renders *many*. In Lesson 1 you walked
`for → forEach → map` to transform an array of **numbers**; rendering a list is that
**same transform**, only the output is JSX instead of numbers — so go straight to
`.map()`.

Swap your single item for a hardcoded **array**, and `.map()` it into one card per item
(still plain — styling is the next section):

```tsx title="src/menuItems/MenuItemsPage.tsx"
import { IMenuItem } from "./IMenuItem";

const menuItems: IMenuItem[] = [
  { id: 1, name: "Loaded Nachos", price: 9.99 },
  { id: 2, name: "Mozzarella Sticks", price: 7.99 },
  { id: 3, name: "Ribeye Steak", price: 24.99 },
];

function MenuItemsPage() {
  return (
    <section>
      <h2>Menu</h2>
      {menuItems.map((menuItem) => (
        <div key={menuItem.id}>
          <span>{menuItem.name}</span>
          <span>${menuItem.price}</span>
        </div>
      ))}
    </section>
  );
}

export default MenuItemsPage;
```

**Save and check:** three plain cards appear. Three things to understand:

- **`menuItems.map((menuItem) => ( … ))`** runs the arrow once per element (the `=> ( … )`
  form from section 6), producing one `<div>` per item. The array of elements renders in
  order. **This is how React renders every list.**
- **`key={menuItem.id}`** — every element in a `.map()` needs a unique **`key`** so React
  can track items when the list changes. Use the record's `id`. Never use the array index
  if the list can reorder, and never `Math.random()`.
- **`const menuItems: IMenuItem[]`** types the array — TypeScript checks each object has
  the right shape, and your editor autocompletes `menuItem.name`.

---

## 8. ▶ Code along — Make it look like a card

The mechanics work; now make it *look* like the design. These are **the same Bootstrap
classes you put on the menu-items card in the HTML/CSS pass** — `card`, the `d-flex` tray,
the `fs-*` type utilities — so this is mostly recognition, not new material. (The finished
markup lives in the [TableServe design repo](https://github.com/craigmckeachie/tableserve-design),
`menuitems.html`.) Add the classes, plus a `.list` tray around the cards, and import
Bootstrap's CSS so the classes take effect:

```tsx title="src/menuItems/MenuItemsPage.tsx"
import { IMenuItem } from "./IMenuItem";

const menuItems: IMenuItem[] = [
  { id: 1, name: "Loaded Nachos", price: 9.99 },
  { id: 2, name: "Mozzarella Sticks", price: 7.99 },
  { id: 3, name: "Ribeye Steak", price: 24.99 },
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

```diff title="src/App.tsx"
+ import "bootstrap/dist/css/bootstrap.min.css";
+ import "./App.css";
  import MenuItemsPage from "./menuItems/MenuItemsPage";

  function App() {
    return <MenuItemsPage />;
  }

  export default App;
```

**Save and check:** the plain cards become a wrapping grid of styled cards. Notice the **only** things
that changed from section 7 are `className`s and the CSS import; the React logic (the
component, the `.map()`, the `key`) is identical. That's the point of doing styling as a
separate pass — the mechanics and the look are two different jobs. (`App.css` is still the
empty file from section 5 — that's fine; it's just where app-wide styles would go. Here,
Bootstrap's CSS is doing the work.)

> **New JSX syntax — `style={{ … }}`.** Those are **two** sets of braces doing two things.
> The **outer `{ }`** drops into a JavaScript expression (the embed from section 4); the
> **inner `{ }`** is a JavaScript **object** — the style object. So
> `style={{ width: "23rem" }}` reads as "*the `style` prop equals this object.*" Two things
> differ from CSS: property names are **camelCase**, not kebab-case (`backgroundColor`, not
> `background-color`; `width` is one word so it happens to look the same), and the values
> are **strings** (`"23rem"`). Prefer classes for styling — reach for `style` only for a
> one-off value like this fixed card width.

> **Styling note:** the `card`, `d-flex flex-wrap`, `gap-5` classes are the same Bootstrap
> classes as the HTML/CSS pass. This lesson keeps the JSX minimal on purpose; the polished
> `MenuItemCard` component (its own file, a `Card` from react-bootstrap) comes in Lesson 6.

---

## 9. Verifying in the browser

There's no Insomnia and no API here — you verify **by looking at the page and the
DevTools**. You've checked each piece as you built it; this is the full pass. With
`npm run dev` running:

1. Open the printed URL (e.g. `http://localhost:5173`). You should see the **Menu**
   heading and one styled card per item in your hardcoded array.
2. Open **DevTools → Console** (F12). It should be clean. The most common first error is
   **"Each child in a list should have a unique key"** — that means a `.map()` is missing
   its `key={...}`. Add it and the warning clears.
3. Edit an item's `name` in the array and save — the card updates immediately (that's HMR
   and React re-rendering).
4. Add a fourth object to the `menuItems` array and save — a fourth card appears without
   you writing any more JSX. That's the payoff of `.map()`: the markup is written once;
   the data drives how many render.
5. **Install React DevTools** (browser extension) if you can — the **Components** tab
   shows your component tree (`App → MenuItemsPage`), the clearest way to *see* that a
   React app is a tree of components.

---

## The General Pattern (what to take away)

- A **component** is a capitalized function that returns **JSX**; you export it
  (`export default`) and use it as a tag (`<MenuItemsPage />`).
- **JSX** is HTML-like markup in JavaScript: `className` not `class`, `{ }` to embed
  values, one root element (or a `<>` fragment).
- A **TypeScript interface** (`IMenuItem`) names the shape of your data — the front-end
  echo of your C# model.
- Render **one** first, then **many**: **`.map()`** turns an array of data into a list of
  elements, each with a unique **`key`**. Use `=> ( … )` in the callback so the JSX
  returns.
- Build the **mechanics first, styling second** — the same component just gains
  `className`s.
- Everything else in this pass builds on these: Lesson 4 swaps the hardcoded array for a
  real fetch; Lesson 5 adds routing between pages; Lesson 7 adds forms.

On PRS you'll write the same things first — an `IProduct` interface, a `ProductsPage`
component, one card, then a `.map()` over products — before any data loads.

---

## Build Steps

1. Scaffold the project: `npm create vite@latest TableServe.Web -- --template react-ts`,
   then `cd` in and `npm install`. In **`tsconfig.app.json`**, set
   `"verbatimModuleSyntax": false` (so plain `import { IMenuItem }` works for interfaces).
2. Install the pass's libraries (`bootstrap react-bootstrap react-router-dom
   react-hook-form react-hot-toast`) and start `npm run dev`.
3. Create the `src/menuItems/` feature folder and `src/menuItems/IMenuItem.ts` with the
   `IMenuItem` **interface** (`id`, `name`, `price`).
4. In `src/menuItems/MenuItemsPage.tsx`, render **one** hardcoded item as a plain card.
5. **Clear Vite's boilerplate:** replace all of `App.tsx` with a render of
   `<MenuItemsPage />`, and empty `App.css` and `index.css`. Confirm the one card shows
   (**checkpoint**).
6. Swap the single item for a hardcoded `IMenuItem[]` array and **`.map()`** it into cards,
   each with a **`key`** — still plain.
7. Add the Bootstrap `className`s and import `bootstrap/dist/css/bootstrap.min.css` in
   `App.tsx` to style the cards.
8. Verify in the browser using section 9 — cards render, the Console is clean, adding an
   array item adds a card.
