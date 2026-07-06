# Lesson 2 Guide — Flexbox (by hand)

**Goal:** by the end of this lesson you can lay elements out with **flexbox** in raw
CSS — turn a container into a flexible row or column, control how its children align
and space out, and build the two layouts every page in this app uses: a **header row**
(title left, action right) and the **app frame** (a fixed sidebar beside a content
area that fills the rest). Still plain files, still no framework.

**The general pattern you're learning:** put `display: flex` on a **container** and
its direct **children** become flexible items you arrange along a **main axis** and a
**cross axis**. Almost all page layout in this course is flexbox — and in Lesson 3
you'll find that Bootstrap's `d-flex`, `justify-content-*`, and `flex-grow-1` classes
are exactly the flexbox properties you write here, just renamed.

> **Still no tooling.** Keep working in your `css-fundamentals/` folder with plain
> `.html` + `.css` files opened from disk. Bootstrap arrives next lesson.

---

## 1. The problem flexbox solves

Laying boxes *side by side* and controlling the space between them used to be genuinely
painful in CSS. Flexbox replaced all of that with a simple idea: **you make one
element a flex container, and its children arrange themselves** according to a few
properties you set on the container.

```css
.container {
  display: flex;   /* this element is now a flex container */
}
```

The moment you write that, the container's **direct children** become **flex items**
and line up in a row. Everything else — direction, alignment, spacing, wrapping — is a
property you add on top.

---

## 2. Container vs. items, and the two axes

Flexbox has two levels of control:

- Properties on the **container** (`display: flex`, `flex-direction`,
  `justify-content`, `align-items`, `gap`, `flex-wrap`) — these arrange *all* the
  children.
- Properties on an **item** (`flex-grow`, `align-self`) — these adjust *one* child.

And it works along **two axes**:

```
flex-direction: row  (default)          flex-direction: column
                                        
main axis  ──────────────▶              cross axis ──────────▶
┌────┐ ┌────┐ ┌────┐                    ┌───────────────┐   │
│ A  │ │ B  │ │ C  │   cross            │       A       │   │ main
└────┘ └────┘ └────┘   axis            └───────────────┘   │ axis
                       │                ┌───────────────┐   │
                       ▼                │       B       │   ▼
                                        └───────────────┘
```

- The **main axis** runs in the `flex-direction` (row = horizontal, column =
  vertical).
- The **cross axis** is perpendicular to it.
- `justify-content` aligns items **along the main axis**; `align-items` aligns them
  **along the cross axis**. Getting these two straight is 80% of flexbox.

---

## 3. The core properties

All on the **container** unless noted:

### `flex-direction` — which way is the main axis

```css
flex-direction: row;     /* default — children left to right */
flex-direction: column;  /* children top to bottom */
```

### `justify-content` — spacing along the main axis

```css
justify-content: flex-start;    /* default — packed at the start */
justify-content: center;        /* packed in the center */
justify-content: flex-end;      /* packed at the end */
justify-content: space-between; /* first & last at the edges, gaps even between */
justify-content: space-around;  /* equal space around each item */
```

`space-between` is the one you'll use most — it's how a title goes left and a button
goes right in the same row.

### `align-items` — alignment along the cross axis

```css
align-items: stretch;     /* default — items fill the cross axis */
align-items: center;      /* centered on the cross axis */
align-items: flex-start;  /* packed at the cross-start */
align-items: flex-end;    /* packed at the cross-end */
```

In a `row`, `align-items: center` **vertically** centers items of different heights —
the cleanest way to line up a heading and a button.

### `gap` — space between items

```css
gap: 1.5rem;   /* even spacing between every child, no margins needed */
```

`gap` is the modern way to space flex children — no more `margin-right` on every item
but the last.

### `flex-wrap` — let items flow onto new lines

```css
flex-wrap: wrap;   /* when items run out of room, wrap to the next line */
```

By default flex items all cram onto one line. `flex-wrap: wrap` lets them flow onto
the next — that's how a grid of cards reflows as the window narrows (you'll build that
in the lab).

### `flex-grow` — let an item eat the leftover space (on the *item*)

```css
.content {
  flex-grow: 1;   /* this child expands to fill remaining space */
}
```

Put `flex-grow: 1` on **one child** and it stretches to absorb whatever space the
other children don't use. This is the trick behind a fixed sidebar next to a
fills-the-rest content area.

---

## 4. Pattern 1 — the header row (title left, action right)

The single most common row in the app: a heading pinned to the left, a button pinned
to the right, both vertically centered.

```html
<div class="header-row">
  <h2>Orders</h2>
  <a href="#" class="button">Create Order</a>
</div>
```

```css
.header-row {
  display: flex;
  justify-content: space-between;  /* title left, button right */
  align-items: center;             /* both centered vertically */
}
```

`space-between` throws maximum space between the two children, pinning one to each
end; `align-items: center` lines them up despite their different heights. That's the
whole pattern — you'll reuse it on every list and detail page.

---

## 5. Pattern 2 — the app frame (sidebar + growing content)

Every page in TableServe is a **fixed-width sidebar** next to a **content area that
fills the rest** of the width. That's a flex row with `flex-grow` on the content:

```html
<main class="frame">
  <nav class="sidebar">…nav links…</nav>
  <section class="content">…page content…</section>
</main>
```

```css
.frame {
  display: flex;              /* sidebar and content sit in a row */
}

.sidebar {
  width: 280px;              /* fixed width — does not grow */
  flex-shrink: 0;            /* never let it get squeezed narrower */
}

.content {
  flex-grow: 1;             /* eats all the remaining width */
  padding: 2rem;
}
```

The sidebar keeps its `280px`; the content's `flex-grow: 1` makes it expand to fill
whatever's left, at any window width. Resize the window and the content flexes while
the sidebar holds steady. **This is the exact frame** the Bootstrap scaffold gives you
next lesson — you're building it by hand first so the scaffold isn't a mystery.

---

## 6. Practice with Flexbox Froggy

The fastest way to make `justify-content` and `align-items` stick is to drill them.
In the lab you'll play **Flexbox Froggy** — a small game where you write
`justify-content`, `align-items`, and `flex-direction` to move frogs onto lilypads.
The first dozen-or-so levels cover exactly the properties in this guide. It's the one
external tool this pass — everything else you build yourself.

---

## 7. Verifying in the browser

Open your practice page and use DevTools to *see* the flex layout:

1. Confirm the header row shows the title hard-left and the button hard-right, aligned
   vertically.
2. Confirm the frame shows the sidebar at a fixed width with the content filling the
   rest. **Resize the window** — the content should flex while the sidebar stays put.
3. Open **DevTools** (F12) → **Elements**, select a flex container, and click the
   little **`flex` badge** next to it — the browser overlays the main/cross axes and
   the gaps. Toggle `justify-content` values in the Styles panel and watch the items
   move.
4. Temporarily set the frame's `.content` `flex-grow` to `0` and reload — the content
   collapses to its natural width, proving what `flex-grow: 1` was doing.

---

## The General Pattern (what to take away)

- **`display: flex`** on a container turns its direct children into flex items laid
  out along a **main axis** (set by `flex-direction`) and a perpendicular **cross
  axis**.
- **`justify-content`** spaces items along the **main** axis (`space-between` pins one
  child to each end); **`align-items`** aligns them on the **cross** axis
  (`center` for vertical centering in a row).
- **`gap`** spaces children without margins; **`flex-wrap: wrap`** lets them flow onto
  new lines; **`flex-grow: 1`** on one item makes it absorb the leftover space.
- The **header row** = `display: flex; justify-content: space-between; align-items:
  center`. The **app frame** = a flex row with a fixed sidebar and `flex-grow: 1`
  content.

In Lesson 3 you'll meet Bootstrap's `d-flex`, `justify-content-between`,
`align-items-center`, `gap-*`, `flex-wrap`, and `flex-grow-1` — every one is a flexbox
property from this guide, renamed. You already know what they do.

---

## Build Steps

1. In your `css-fundamentals/` folder, create a `flexbox.html` + `flexbox.css`
   (linked), with `* { box-sizing: border-box; }` at the top of the CSS.
2. Build the **header row** (section 4): a container with an `<h2>` and a button,
   styled `display: flex; justify-content: space-between; align-items: center`.
3. Build the **app frame** (section 5): a `<main>` flex row with a fixed-width
   `<nav class="sidebar">` and a `<section class="content">` set to `flex-grow: 1`.
4. Add a couple of nav links in the sidebar and a heading in the content so you can
   see the two regions.
5. Open it in the browser, **resize the window**, and confirm the content flexes while
   the sidebar holds its width (section 7).
6. In DevTools, toggle the flex overlay and experiment with `justify-content` and
   `align-items` values to see each one move the items.
