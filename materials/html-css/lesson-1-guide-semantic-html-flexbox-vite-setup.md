# Lesson 1 Guide — Semantic HTML, the Box Model, Flexbox, and the Vite Scaffold

**Goal:** by the end of this lesson you have the TableServe static-design project
running with `npm run dev`, you understand the page shell every screen shares
(header → nav → content), and you have built the first **page skeleton** — the
Orders page — using semantic HTML and Bootstrap flexbox utility classes. No
Bootstrap components yet (cards, tables, forms come next lesson) — this lesson is
about the layout scaffold that every page sits inside.

**The general pattern you're learning:** every page in this app is the same three
regions — a shared `header`, a shared `nav` sidebar, and a page-specific
`section.content` — laid out with **flexbox utility classes**, never the Bootstrap
`row`/`col` grid. Once you can produce that shell, every other page is just
different content dropped into the same frame.

---

## 1. What this pass is and why it comes before React

You already built the TableServe **Web API**. In this pass you build the **static
front end** — plain HTML and CSS styled with Bootstrap, with **no JavaScript
logic** of your own (only Bootstrap's bundle for dropdowns and modals). There's no
data fetching, no forms that actually submit, no routing.

That sounds limiting, but it's the point. You get the **markup and layout** exactly
right while it's still simple. In the React pass you'll convert this same markup
into components — so the closer this is to final, the less you fight later. Think of
these pages as the visual target React has to reproduce.

```
API pass          →  HTML/CSS pass (you are here)  →  React pass
data + endpoints     the visual target                wire it together
```

---

## 2. The project scaffold (provided)

You're given a starter project — you don't build the tooling from scratch. Open the
`TableServe.Design` folder and you'll find:

```
TableServe.Design/
  package.json          ← dependencies + dev/build scripts
  vite.config.js        ← Vite + handlebars partials config
  index.html            ← redirects to signin.html
  partials/
    header.html         ← finished — the top bar + brand + user menu
    nav.html            ← finished — the left sidebar links
  css/
    styles.css          ← finished — fonts, brand color, layout tweaks
  assets/
    bootstrap-icons.svg  ← the icon sprite used with <use href="...#icon">
  node_modules/         ← after you run npm install
```

The `header.html`, `nav.html`, `styles.css`, and `assets/` are **finished for you**.
Your job this pass is the individual pages.

### package.json

```json
{
  "name": "tableserve-design",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  },
  "dependencies": {
    "bootstrap": "^5.3.3"
  },
  "devDependencies": {
    "vite": "^5.2.0",
    "vite-plugin-handlebars": "^2.0.0"
  }
}
```

Three packages, that's it:
- **bootstrap** — the CSS framework (installed via npm, **not** a CDN `<link>`).
- **vite** — the dev server. It serves your pages with instant reload as you save.
- **vite-plugin-handlebars** — lets you write `{{> header}}` in a page and have the
  contents of `partials/header.html` dropped in. That's how every page shares one
  header and one nav without copy-pasting them.

Run `npm install` once to create `node_modules/`, then `npm run dev`. Vite prints a
local URL (e.g. `http://localhost:5173`). Leave it running — it reloads on save.

---

## 3. Partials — write the header and nav once

Without partials, changing a nav link would mean editing every page. Instead, each
page includes the shared pieces with a Handlebars **partial** tag:

```html
{{> header}}   ← inserts partials/header.html
{{> nav}}      ← inserts partials/nav.html
```

`vite.config.js` wires this up by pointing the plugin at the `partials/` folder:

```js
import { defineConfig } from "vite";
import handlebars from "vite-plugin-handlebars";
import { resolve } from "path";

export default defineConfig({
  plugins: [
    handlebars({
      partialDirectory: resolve(__dirname, "partials"),
    }),
  ],
  build: {
    rollupOptions: {
      input: {
        // one entry per page so `npm run build` produces every page
        orders: resolve(__dirname, "orders.html"),
        // ...one line per .html page you add
      },
    },
  },
});
```

When you add a **new page**, add one line to that `input` object so the production
build knows about it. During `npm run dev` you can open any `.html` file directly
without touching the config, but get in the habit of adding the build entry too.

You don't need to edit `header.html` or `nav.html` — they're done. It's still worth
reading them so you recognize the pieces (the brand SVG logo, the user dropdown, the
nav-pills sidebar links).

---

## 4. Semantic HTML

**Semantic** tags describe what a region *is*, not just how it looks. A screen
reader, a search engine, and the next developer all get meaning for free.

| Instead of | Use | Meaning |
|---|---|---|
| `<div class="header">` | `<header>` | page/section banner |
| `<div class="nav">` | `<nav>` | primary navigation |
| `<div class="main">` | `<main>` | the one main content area of the page |
| `<div class="section">` | `<section>` | a thematic grouping |
| `<div>` for an address block | `<address>` | contact/identity info (used on cards) |

Rules of thumb:
- Exactly **one `<main>`** per page.
- Reach for a `<div>` only when no semantic tag fits — usually for pure layout
  wrappers (a flex row, a spacing wrapper). That's fine; `<div>` isn't banned, it's
  just the fallback, not the default.
- Headings go in order — an `<h2>` for the page title, `<h5>` for a card title
  inside it. Don't pick a heading level for its size; pick it for its rank and let
  CSS size it.

You'll see the TableServe pages use `<address>` for the little identity blocks on
Staff and Menu cards — that's a semantic choice, not a styling one.

---

## 5. The box model

Every element is a box with four layers, from the inside out:

```
┌─────────────────── margin ───────────────────┐
│  ┌──────────────── border ────────────────┐  │
│  │  ┌───────────── padding ────────────┐  │  │
│  │  │            content               │  │  │
│  │  └──────────────────────────────────┘  │  │
│  └────────────────────────────────────────┘  │
└───────────────────────────────────────────────┘
```

- **content** — the text/child elements
- **padding** — space *inside* the border, pushing content away from the edge
- **border** — the line around the padding
- **margin** — space *outside* the border, pushing other elements away

Bootstrap gives you utility classes for padding (`p-*`) and margin (`m-*`) on a
0–5 scale, with direction suffixes:

| Class | Effect |
|---|---|
| `p-4` | padding on all sides, step 4 |
| `py-4` | padding top **and** bottom (`y` axis) |
| `px-4` | padding left **and** right (`x` axis) |
| `mb-4` | margin-bottom only |
| `me-2` | margin-end (right, in left-to-right languages) |
| `gap-5` | space *between* flex children (more in the next section) |

You'll rarely write raw `padding:` / `margin:` CSS — the utilities cover almost
everything. `styles.css` only adds the handful of rules Bootstrap can't express.

---

## 6. Flexbox utility classes (NOT the row/col grid)

This is the one layout rule for the whole course: **we lay out with flexbox utility
classes, never Bootstrap's `row`/`col` grid.** If you catch yourself typing
`class="row"` or `class="col-6"`, stop — that's the wrong tool here.

Flexbox turns a container into a flexible row or column and gives you control over
alignment and spacing of its children. The utility classes map one-to-one to CSS
flexbox properties:

| Class | CSS it applies | Use it to… |
|---|---|---|
| `d-flex` | `display: flex` | make an element a flex container |
| `flex-row` | `flex-direction: row` | lay children left-to-right (default) |
| `flex-column` | `flex-direction: column` | stack children top-to-bottom |
| `flex-wrap` | `flex-wrap: wrap` | let children wrap to the next line |
| `justify-content-between` | `justify-content: space-between` | push children to the two ends |
| `justify-content-end` | `justify-content: flex-end` | push children to the end |
| `align-items-center` | `align-items: center` | center children on the cross axis |
| `gap-4` | `gap` | even spacing between children |
| `flex-grow-1` | `flex-grow: 1` | let a child eat the remaining space |

Two patterns you'll use on nearly every page:

**A header row with a title on the left and a button on the right:**
```html
<div class="d-flex justify-content-between align-items-center">
  <h2>Orders</h2>
  <a href="/order-create.html" class="btn btn-primary">Create Order</a>
</div>
```
`justify-content-between` puts maximum space between the two children, pinning one
to each end.

**A sidebar next to a content area that fills the rest:**
```html
<main class="d-flex">
  {{> nav}}                          <!-- fixed 280px sidebar -->
  <section class="content flex-grow-1">...</section>  <!-- eats the rest -->
</main>
```
`d-flex` makes `main` a row; `flex-grow-1` on the content lets it expand to fill
whatever the fixed-width nav doesn't use. That's the whole app frame.

---

## 7. The page shell every screen shares

Here is the skeleton every TableServe page starts from. Commit it to memory — you'll
type it (or copy it) at the top of every page you build:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>TableServe — Orders</title>
    <link rel="stylesheet" href="/node_modules/bootstrap/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="/css/styles.css" />
  </head>
  <body>
    {{> header}}
    <main class="d-flex">
      {{> nav}}
      <section class="content p-4 flex-grow-1">
        <!-- page-specific content goes here -->
      </section>
    </main>
    <script src="/node_modules/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
  </body>
</html>
```

Notice:
- Bootstrap's CSS is linked from `node_modules` (installed package), then
  `styles.css` **after** it so our overrides win.
- `{{> header}}` sits above `<main>`; `{{> nav}}` is the first child *inside*
  `<main class="d-flex">`, so it becomes the left column.
- `section.content` gets `p-4` (breathing room) and `flex-grow-1` (fill the rest).
- Bootstrap's **JS bundle** is the last line in `<body>`. It powers the dropdowns
  and modals you'll add later. Every page needs it.

---

## 8. The page-heading pattern

Inside `section.content`, every list/detail page opens with the same heading row: a
title on the left, a primary action button on the right, and a bottom border under
both.

```html
<div class="d-flex justify-content-between pb-4 mb-4 border-bottom border-2">
  <h2>Orders</h2>
  <a href="/order-create.html" class="btn btn-primary">
    <svg class="bi pe-none me-2" width="32" height="32" fill="#FFFFFF">
      <use href="/assets/bootstrap-icons.svg#plus" />
    </svg>
    Create Order
  </a>
</div>
```

- `justify-content-between` splits title and button to opposite ends.
- `pb-4 mb-4` — padding then margin below, so the border sits off the text and the
  content below sits off the border.
- `border-bottom border-2` — a 2px rule under the row.
- The **icon** is an SVG `<use>` referencing a symbol in `assets/bootstrap-icons.svg`
  (here `#plus`). `pe-none` makes it ignore pointer events; `me-2` spaces it from the
  label. This same `<svg><use href="...#name" /></svg>` pattern is how every icon in
  the app is drawn.

For this lesson, the content **below** the heading stays empty — a placeholder
comment. Filling it with a card grid or table is next lesson's job. This is a
*skeleton*: shell + heading, nothing more.

---

## 9. Verifying in the browser

There's no Insomnia here — the browser is your verification tool.

1. With `npm run dev` running, open the printed URL and navigate to
   `/orders.html` (or click through from the header brand).
2. You should see: the header bar across the top, the nav sidebar on the left, and
   your "Orders" heading with a "Create Order" button pushed to the right, a rule
   underneath, and empty space below.
3. **Resize the window.** The content area should flex to fill the space beside the
   fixed-width sidebar — that's `flex-grow-1` doing its job.
4. Open the browser **DevTools** (F12) → **Elements**, hover over your `<main>`, and
   confirm it's laid out as a flex row (nav + content side by side). Hover the
   heading `<div>` and watch the box model highlight padding/margin/border in the
   layout overlay.
5. Check the **Console** tab for errors. A 404 on `bootstrap.min.css` or
   `styles.css` means a wrong path in your `<link>` tags — fix the href and save.

If the header or nav doesn't appear, the `{{> header}}` / `{{> nav}}` partial isn't
resolving — confirm the file is named exactly `header.html` / `nav.html` in
`partials/`, and that you started the page from `npm run dev` (partials only expand
through Vite, not by opening the file directly from disk).

---

## The General Pattern (what to take away)

Every page you build this pass is the **same shell**:

1. The standard `<head>` (Bootstrap CSS, then `styles.css`).
2. `{{> header}}` for the top bar.
3. `<main class="d-flex">` with `{{> nav}}` as the first child.
4. `<section class="content p-4 flex-grow-1">` for the page's own content.
5. The Bootstrap JS bundle as the last line of `<body>`.
6. Inside content, the `justify-content-between` heading row (title + action + rule).

You lay it all out with **flexbox utilities** — `d-flex`, `justify-content-*`,
`align-items-*`, `gap-*`, `flex-grow-1` — and **never** `row`/`col`. When you build
the PRS static pages in the capstone, this identical shell is your starting point;
only the page title, the action button, and the content region change.

---

## Build Steps

1. Open the provided `TableServe.Design` scaffold and run `npm install`.
2. Run `npm run dev` and confirm the printed local URL loads (it will land on
   `signin.html` via `index.html`'s redirect — that page is empty for now).
3. Read `partials/header.html` and `partials/nav.html` so you recognize the shared
   pieces. Don't change them.
4. Create `orders.html` in the project root with the full page shell from section 7.
5. Add the page-heading row from section 8 inside `section.content` — an `<h2>`
   "Orders" title and a "Create Order" primary button with the `#plus` icon.
6. Leave the area below the heading empty (a placeholder comment) — components come
   next lesson.
7. Add an `orders` entry to the `input` object in `vite.config.js`.
8. Open `/orders.html` in the browser and verify the shell renders (header, nav,
   heading, rule) using the checks in section 9 — resize to confirm `flex-grow-1`,
   and check the Console for 404s.
