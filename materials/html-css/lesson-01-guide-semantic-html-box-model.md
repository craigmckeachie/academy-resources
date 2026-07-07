# Lesson 1 Guide — Semantic HTML and the Box Model (by hand)

**Goal:** by the end of this lesson you have written your first HTML page and CSS
stylesheet **by hand** — two plain files, no tooling and no framework — and used the
**box model** to style a TableServe **Menu Item card**. You'll finish able to
structure content with semantic tags and space/size any element with content,
padding, border, and margin.

**The general pattern you're learning:** an **HTML file** structures content with
**semantic tags**; a **linked CSS file** styles it; and **every element on the page
is a box** you size and space with the box model. Everything a framework like
Bootstrap does for you later, you can do by hand right now — and doing it by hand
once is what makes the framework make sense later. Later this pass you'll rebuild
this exact card with Bootstrap in a handful of classes; today you build it the long
way so you know what those classes are doing.

> **No tooling this lesson.** No Vite, no npm, no Bootstrap. Just two files you write
> and open straight in the browser. The scaffold and Bootstrap arrive in Lesson 3 —
> on purpose, *after* you've seen the raw mechanics.

---

## 1. Two plain files, opened in the browser

Make a folder to practice in — call it `css-fundamentals/`. Inside it, create two
files:

```
css-fundamentals/
  index.html
  styles.css
```

`index.html` is the structure; `styles.css` is the styling. The HTML **links** the
CSS in its `<head>`:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>CSS Fundamentals</title>
    <link rel="stylesheet" href="styles.css" />
  </head>
  <body>
    <!-- your content goes here -->
  </body>
</html>
```

- `<!doctype html>` tells the browser to use modern standards mode. Always first.
- `<head>` holds page metadata — the title, the character set, and the
  `<link>` to your stylesheet. Nothing in `<head>` is drawn on the page.
- `<body>` holds everything the user actually sees.
- `<link rel="stylesheet" href="styles.css" />` connects the two files. The `href` is
  the path to your CSS relative to the HTML file.

**To view it:** double-click `index.html`, or right-click → open with your browser.
It loads straight from disk — the address bar shows a `file://` path. That's all you
need this lesson; there's no server to run.

---

## 2. Semantic HTML — tags that mean something

**Semantic** tags describe what a region *is*, not just how it looks. A screen
reader, a search engine, and the next developer all get meaning for free. Reach for
the tag that names the content:

| Tag | Use it for |
|---|---|
| `<header>` | a page or section banner |
| `<nav>` | primary navigation |
| `<main>` | the one main content area of the page |
| `<section>` | a thematic grouping of content |
| `<address>` | contact/identity info (a person, a place) |
| `<h1>`–`<h6>` | headings, in rank order |
| `<p>` | a paragraph of text |
| `<ul>` / `<li>` | a list and its items |
| `<a href="...">` | a link |
| `<span>` | an inline piece of text with no other meaning |
| `<div>` | a generic block wrapper with no other meaning |

Rules of thumb:
- Exactly **one `<main>`** per page.
- Pick heading levels by **rank, not size** — `<h1>` for the page title, `<h2>` for a
  major section — and let CSS decide how big they look.
- Reach for `<div>` (block) or `<span>` (inline) only when **no semantic tag fits** —
  usually a pure layout or styling wrapper. They're the fallback, not the default.

You'll use `<address>` in this lesson's card because a Menu Item card is an identity
block — the same semantic choice the finished TableServe cards make.

---

## 3. How CSS applies — selectors and the ruleset

A CSS file is a list of **rulesets**. Each one points at some elements with a
**selector** and sets one or more **property: value** declarations:

```css
selector {
  property: value;
  property: value;
}
```

The three selectors you need this lesson:

| Selector | Matches | Example |
|---|---|---|
| **element** | every tag of that type | `p { color: gray; }` |
| **class** (`.name`) | every element with `class="name"` | `.price { font-weight: 300; }` |
| **id** (`#name`) | the one element with `id="name"` | `#total { font-size: 2rem; }` |

You attach a class in the HTML with the `class` attribute — and one element can carry
several classes separated by spaces:

```html
<span class="price muted">$9.99</span>
```

**Classes are how you'll style almost everything** — they're reusable (many elements
can share one) and they're exactly what Bootstrap's utility classes are, later. When
two rules target the same element, the more specific selector wins (id beats class
beats element), and when two rules tie, the **last one wins** — that's the "cascade"
in Cascading Style Sheets.

---

## 4. The box model — the heart of CSS layout

**Every element is a rectangular box** with four layers, from the inside out:

```
┌─────────────────── margin ───────────────────┐
│  ┌──────────────── border ────────────────┐  │
│  │  ┌───────────── padding ────────────┐  │  │
│  │  │            content               │  │  │
│  │  └──────────────────────────────────┘  │  │
│  └────────────────────────────────────────┘  │
└───────────────────────────────────────────────┘
```

- **content** — the text or child elements; sized with `width` / `height`.
- **padding** — space *inside* the border, pushing content away from the edge.
- **border** — the line around the padding.
- **margin** — space *outside* the border, pushing other elements away.

In raw CSS you set each layer directly:

```css
.box {
  width: 20rem;              /* content width */
  padding: 1.5rem;           /* space inside the border */
  border: 1px solid #dee2e6; /* the border line */
  margin-bottom: 1rem;       /* space below, outside the border */
}
```

Each of padding, border, and margin can be set on one side
(`padding-top`, `margin-bottom`, `border-left`) or all four at once (`padding`).

### box-sizing — the one gotcha

By default, `width` sets the **content** width, and padding + border are *added on
top* — so a `20rem` box with `1.5rem` padding is actually wider than `20rem`. Fix it
once, at the top of every stylesheet, so `width` means the **whole** box:

```css
* {
  box-sizing: border-box;
}
```

The `*` selector matches every element. With `border-box`, padding and border are
drawn *inside* the width you set — far more predictable. Set it and forget it.

### display — block vs. inline

Elements come in two default flavors, and it controls how boxes stack:

- **block** (`<div>`, `<p>`, `<section>`, headings) — takes the full width available
  and starts on a new line. Respects `width`, `height`, and all margins.
- **inline** (`<span>`, `<a>`) — flows along with text, only as wide as its content,
  and **ignores** `width`/`height` and top/bottom margins.

When you need an inline thing (like a badge) to take padding and a set size, promote
it with **`display: inline-block`** — it flows inline but behaves like a box:

```css
.badge {
  display: inline-block;   /* now padding + a size actually apply */
  padding: 0.35em 0.65em;
}
```

---

## 5. Build a Menu Item card by hand

Now put it together. A TableServe **Menu Item card** shows a name, a price, and a
category "badge." Here's the markup — an `<address>` (identity block) holding three
spans:

```html
<body>
  <address class="card">
    <span class="name">Loaded Nachos</span>
    <span class="price">$9.99</span>
    <span class="badge">Appetizers</span>
  </address>
</body>
```

And the CSS that turns it into a card, using only the box model and display:

```css
* {
  box-sizing: border-box;
}

body {
  font-family: system-ui, sans-serif;
  padding: 2rem;
}

.card {
  width: 23rem;                       /* fixed width */
  padding: 1.5rem;                    /* space inside */
  border: 1px solid #dee2e6;          /* light border */
  border-radius: 0.75rem;             /* rounded corners */
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  font-style: normal;                 /* <address> defaults to italic — undo it */
}

.name {
  display: block;                     /* each span on its own line */
  font-size: 1.5rem;
  font-weight: 500;
}

.price {
  display: block;
  font-size: 1.25rem;
  font-weight: 300;
  color: #6c757d;
  margin-bottom: 1rem;                /* gap before the badge */
}

.badge {
  display: inline-block;              /* so padding + radius apply */
  padding: 0.35em 0.65em;
  font-size: 0.85rem;
  color: #0d6efd;
  background-color: #cfe2ff;
  border-radius: 0.375rem;
}
```

Read it against the box model:
- `.card` is a box: `width` (content), `padding` (inside), `border`, `border-radius`
  for rounded corners, and a soft `box-shadow`.
- `.name` and `.price` are spans (normally inline) promoted to **block** so they stack
  vertically; `.price` adds `margin-bottom` to separate itself from the badge.
- `.badge` is a span promoted to **inline-block** so its padding and rounded
  background actually render — a little pill.

That's a real card, built from nothing but the box model and `display`. Hold onto it:
in Lesson 4 you'll rebuild this same card with Bootstrap, and every class you write
there maps back to a line you wrote here.

---

## 6. Verifying in the browser

The browser is your verification tool this whole pass — start the habit now.

1. Double-click `index.html` to open it. You should see the card: a bordered,
   rounded, padded box with the name on top, a lighter price, and a colored badge
   pill.
2. Open **DevTools** (F12) → **Elements**. Click your `.card` element.
3. Find the **box-model diagram** in the Styles/Computed panel — the nested
   content / padding / border / margin rectangle. Hover each layer and watch it
   highlight on the page. Confirm the numbers match your CSS (`padding: 24px` for
   `1.5rem`, etc.).
4. In the Styles panel, try changing a value live — bump `.card` `padding` to `3rem`
   and watch the box grow. (Live edits reset on reload; it's just for exploring.)
5. Temporarily delete `box-sizing: border-box` and reload — notice the card gets
   *wider* than `23rem` because padding is now added on top. Put it back.

If the styles don't apply at all, the `<link href="styles.css">` path is wrong, or
the file isn't named exactly `styles.css` — check the **Console** and **Network**
tabs for a failed stylesheet load.

---

## The General Pattern (what to take away)

- An **HTML file** holds semantic structure; a **linked CSS file** styles it; you
  connect them with `<link rel="stylesheet">`.
- **Semantic tags** (`<header>`, `<main>`, `<section>`, `<address>`, headings) name
  what content *is*. Use `<div>`/`<span>` only when nothing semantic fits.
- **CSS selectors** target elements (`tag`), classes (`.class`), or ids (`#id`); the
  more specific one — and, on a tie, the later one — wins.
- **The box model** is content → padding → border → margin. You size the content with
  `width`/`height`, space inside with `padding`, outline with `border`, and space
  outside with `margin`. Set `box-sizing: border-box` once so `width` means the whole
  box.
- **`display`** decides how boxes flow: `block` stacks and takes full width, `inline`
  flows with text, `inline-block` flows but takes a size and padding.

Everything you just did by hand is what Bootstrap's utility classes will do for you
in Lesson 3 onward — you'll recognize every one of them because you wrote the CSS
underneath it first.

---

## Build Steps

1. Create a `css-fundamentals/` folder with `index.html` and `styles.css`.
2. In `index.html`, write the document skeleton (section 1) and `<link>` the
   stylesheet.
3. At the top of `styles.css`, add `* { box-sizing: border-box; }` and a little
   `body` padding.
4. Add the Menu Item card markup — an `<address class="card">` with `.name`,
   `.price`, and `.badge` spans (section 5).
5. Style `.card` as a box: `width`, `padding`, `border`, `border-radius`, a
   `box-shadow`, and `font-style: normal`.
6. Style `.name` and `.price` as **block** spans; give `.price` a `margin-bottom`.
7. Style `.badge` as **inline-block** with padding, a background color, and
   `border-radius` so it renders as a pill.
8. Open `index.html` in the browser and verify with the box-model overlay in DevTools
   (section 6); try the `box-sizing` experiment.
