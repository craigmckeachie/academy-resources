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
this exact card with Bootstrap in a handful of classes; here you build it the long
way so you know what those classes are doing.

> **No framework or build tooling this lesson.** No Vite, no npm, no Bootstrap —
> just two files you write and preview in the browser. You *will* use **VS Code** and
> its **Live Server** extension to view your page (section 1). The scaffold and
> Bootstrap arrive later this pass — on purpose, *after* you've seen the raw mechanics.

> **How to use this guide.** Sections marked **▶ Code along** are hands-on — type them
> into your practice files as you read. The other sections are concepts to **read and
> understand**; you'll put them to work when you build the card in section 8 and in the
> lab. When you see an Emmet hint (💡), it's a keystroke shortcut, explained in section 1.

---

## 1. ▶ Code along — two plain files, previewed with Live Server

Open **VS Code** and make a folder to practice in — call it `css-fundamentals/`.
Inside it, create two files:

```
css-fundamentals/
  index.html
  styles.css
```

`index.html` is the structure; `styles.css` is the styling.

### Emmet — type abbreviations, not angle brackets

VS Code has **Emmet** built in: you type a short abbreviation and press **Tab**, and it
expands into full HTML. You type the **tag name without the angle brackets** — plus, if
you want, a `.class` or `#id` — and Emmet writes the tags for you.

💡 In the empty `index.html`, type `!` and press **Tab** — Emmet expands the entire
HTML5 boilerplate (`<!doctype html>`, `<html>`, `<head>`, `<body>`). Don't hand-type
it. (`html:5` does the same thing.)

Then, on a blank line **inside `<head>`**, type `link:css` and press **Tab** — Emmet
writes the stylesheet link for you:

```html
<link rel="stylesheet" href="style.css" />
```

Change the `href` to `styles.css` to match your filename. Your `<head>` should end up
like this:

```html
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>CSS Fundamentals</title>
  <link rel="stylesheet" href="styles.css" />
</head>
```

- `<!doctype html>` tells the browser to use modern standards mode. Always first.
- `<head>` holds page metadata — nothing in it is drawn on the page.
- `<body>` holds everything the user actually sees.
- `<link rel="stylesheet" href="styles.css" />` connects the two files; the `href` is
  the path to your CSS relative to the HTML file.

Keep the [Emmet cheat sheet](https://docs.emmet.io/cheat-sheet/) open in a browser tab —
you'll lean on it all pass.

### Preview with Live Server (not the file system)

Don't open the page by double-clicking the file — you'd get a stale `file://` page you
have to manually refresh. Instead use **Live Server**, which serves your page and
**auto-reloads it every time you save**:

1. In VS Code, open the **Extensions** view (the squares icon in the left bar, or
   `Ctrl+Shift+X`).
2. Search **Live Server** (by Ritwick Dey) and click **Install**.
3. **Right-click `index.html`** in the file explorer → **Open with Live Server**.

Your browser opens at a `http://127.0.0.1:5500/…` address. Leave it open — every time
you save a file, the page refreshes itself. That's the loop you'll use the whole pass:
edit, save, glance at the browser.

---

## 2. Semantic HTML — tags that mean something

**Semantic** tags describe what a region *is*, not just how it looks. A screen reader, a
search engine, and the next developer all get meaning for free. Reach for the tag that
names the content:

| Tag | Use it for |
|---|---|
| `<header>` | a page or section banner |
| `<nav>` | primary navigation |
| `<main>` | the one main content area of the page |
| `<section>` | a thematic grouping of content |
| `<h1>`–`<h6>` | headings, in rank order |
| `<p>` | a paragraph of text |
| `<ul>` / `<li>` | a list and its items |
| `<a href="...">` | a link |
| `<address>` | real contact info — a physical address, phone, or email |
| `<span>` | an inline piece of text with no other meaning |
| `<div>` | a generic block wrapper with no other meaning |

Rules of thumb:
- Exactly **one `<main>`** per page.
- Pick heading levels by **rank, not size** — `<h1>` for the page title, `<h2>` for a
  major section — and let CSS decide how big they look.
- Reach for `<div>` (block) or `<span>` (inline) when **no semantic tag fits** — usually
  a pure layout or styling wrapper. A card that groups a name, a price, and a category
  isn't a heading or an address — it's a generic grouping — so its container is a
  **`<div>`**. (`<address>` is specifically for *actual* contact details; using it for
  something that isn't an address is a common mistake. Marking up a real address block is
  a stretch challenge, not this card.)

### HTML attributes: global vs. element-specific

Tags carry **attributes** — `name="value"` pairs inside the opening tag. Some are
**global** (allowed on *every* element); others are **specific** to one kind of element.

- **Global attributes** — work on any tag. The three you'll use constantly:
  - `id="..."` — a unique name for one element
  - `class="..."` — a reusable label you style with CSS (section 3)
  - `style="..."` — inline CSS on that one element (used sparingly)
- **Element-specific attributes** — only make sense on certain tags:
  - `href` on `<a>` and `<link>` (the destination / file)
  - `src` and `alt` on `<img>` (the image file and its text description)
  - `type`, `value`, `placeholder` on `<input>`
  - `for` on `<label>` (which field it labels)

If you ever wonder whether an attribute belongs on a tag, that's the split: `id` /
`class` / `style` go anywhere; `href`, `src`, `type`, and friends belong to specific
elements.

---

## 3. How CSS applies — selectors and the ruleset

A CSS file is a list of **rulesets**. Each one points at some elements with a
**selector** and sets one or more `property: value` **declarations**:

```css
selector {
  property: value;
  property: value;
}
```

There are three selectors you need this lesson. Here's each one with **the HTML it
targets** right beside **the CSS that styles it**:

**Element selector** — matches every tag of that type:

```html
<p>Sold out</p>
```
```css
p { color: gray; }
```

**Class selector (`.name`)** — matches every element carrying that `class`:

```html
<span class="price">$9.99</span>
```
```css
.price { font-weight: 300; }
```

**Id selector (`#name`)** — matches the one element with that `id`:

```html
<div id="total">$42.95</div>
```
```css
#total { font-size: 2rem; }
```

Notice the connection to section 2's global attributes: `class` and `id` are the global
attributes you attach in the HTML, and `.` / `#` are how you select them in CSS.

### Lean on classes

One element can carry **several classes**, separated by spaces:

```html
<span class="price muted">$9.99</span>
```
```css
.price { font-weight: 300; }
.muted { color: #6c757d; }
```

**Classes are how you'll style almost everything.** They're reusable (many elements can
share one), and they're exactly what Bootstrap's utility classes are, later — a class
like `.badge` you write today is the same idea as a `badge` class Bootstrap ships. Prefer
classes over ids for styling; save ids for the rare truly-one-of-a-kind element.

When two rules target the same element, the more specific selector wins (**id beats class
beats element**), and when two rules tie, the **last one wins** — that's the "cascade" in
Cascading Style Sheets.

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

Each of padding, border, and margin can be set on one side (`padding-top`,
`margin-bottom`, `border-left`) or all four at once (`padding`).

### box-sizing — the one gotcha

By default, `width` sets the **content** width, and padding + border are *added on top* —
so a `20rem` box with `1.5rem` padding is actually wider than `20rem`. Fix it once, at the
top of every stylesheet, so `width` means the **whole** box:

```css
* {
  box-sizing: border-box;
}
```

The `*` selector matches every element. With `border-box`, padding and border are drawn
*inside* the width you set — far more predictable. Set it and forget it.

---

## 5. `display` — block vs. inline vs. inline-block

Every box has a default **display** that controls how it flows next to other boxes. There
are three you must know, so here's an example of each and what you'd see.

### block — starts on a new line, takes the full width

Block elements (`<div>`, `<p>`, `<section>`, headings) each **begin on their own line** and
stretch to the full width available. They respect `width`, `height`, and all margins.

```html
<div class="row">One</div>
<div class="row">Two</div>
```

You see **two stacked lines** — "One" then "Two" — each spanning the full width, even
though the text is short. That "each on a new line" behavior is the defining trait of
block.

### inline — flows along with the text

Inline elements (`<span>`, `<a>`) sit **in the flow of text**, only as wide as their
content, and **ignore** `width`/`height` and top/bottom margins.

```html
<span class="tag">One</span>
<span class="tag">Two</span>
```

You see **"One Two" on a single line**, side by side, because inline boxes don't break
onto new lines and only take the space their text needs.

### inline-block — flows inline, but behaves like a box

Sometimes you want an inline thing (like a badge) to sit in the text flow **and** take
padding and a size. Promote it with `display: inline-block`:

```html
<span class="pill">One</span>
<span class="pill">Two</span>
```
```css
.pill {
  display: inline-block;   /* flows inline, but padding + size now apply */
  padding: 0.35em 0.65em;
  background-color: #cfe2ff;
}
```

Now the two pills sit **side by side (inline)** but each has real padding and a background
box around it — which a plain inline span would ignore. This is exactly how a badge works.

Summary: **block** = new line + full width; **inline** = in the text flow, no box sizing;
**inline-block** = in the flow *and* a real box.

---

## 6. Styling text — weight, style, size, color

You'll set a few text properties on almost every element. These are worth knowing cold:

| Property | What it does | Common values |
|---|---|---|
| `font-size` | text size | `1rem`, `1.5rem`, `0.85rem` |
| `font-weight` | thickness | `normal` (400), `bold` (700), or `100`–`900` (e.g. `300` light, `500` medium) |
| `font-style` | upright or slanted | `normal`, `italic` |
| `color` | text color | `#6c757d`, `gray`, `#0d6efd` |
| `text-align` | horizontal alignment | `left`, `center`, `right` |

```css
.name  { font-size: 1.5rem; font-weight: 500; }   /* larger, medium weight */
.price { font-weight: 300;  color: #6c757d; }      /* light weight, muted gray */
.note  { font-style: italic; }                     /* slanted text */
```

`font-weight` takes a **word** (`normal`, `bold`) *or* a **number** in hundreds
(`100`–`900`); `400` is normal and `700` is bold, so `300` is lighter than normal and
`500` a touch heavier. `font-style: italic` slants the text; `font-style: normal`
un-slants it (useful when an element defaults to italic).

---

## 7. Units — `rem` vs. `em` (and `px`)

You'll mostly size things in `rem`, but you'll see `em` on things like badge padding.
Here's the difference:

- **`rem`** — "root em" — relative to the **root** font size (`<html>`, `16px` by
  default). `1rem` = 16px, `1.5rem` = 24px, everywhere on the page, no matter how deeply
  nested. Predictable — **use `rem` for most sizes** (widths, font sizes, margins).
- **`em`** — relative to **the element's own font size**. If a badge's `font-size` is
  `0.85rem`, then `padding: 0.35em 0.65em` is `0.35 × 0.85rem` and `0.65 × 0.85rem` —
  the padding **scales with the badge's text**. Make the badge's font bigger and its
  padding grows in proportion, so the pill stays balanced. That's why the badge uses `em`
  for padding but `rem` for its font size: the padding should track the text; the text
  size shouldn't track anything.
- **`px`** — absolute pixels. Reserve it for hairline details that shouldn't scale, like
  a `1px` border.

Rule of thumb: **`rem` for sizes you set directly; `em` when you want a value to scale
with the element's own text** (padding on a pill, spacing around an icon).

---

## 8. ▶ Code along — build a Menu Item card, one piece at a time

Now put it together. A TableServe **Menu Item card** shows a name, a price, and a category
"badge." You'll build it in **four small steps**, saving and glancing at Live Server after
each so you see every piece appear. Type the CSS as you go — don't paste the whole thing at
once.

First, at the very top of `styles.css`, add the two setup rules from section 4 and a little
body padding:

```css
* {
  box-sizing: border-box;
}

body {
  font-family: system-ui, sans-serif;
  padding: 2rem;
}
```

### Step A — the card container

💡 In `<body>`, type `div.card` and press **Tab** → Emmet writes `<div class="card"></div>`.

```html
<body>
  <div class="card"></div>
</body>
```

Style it as a box — width, padding, border, rounded corners, a soft shadow:

```css
.card {
  width: 23rem;                        /* fixed width */
  padding: 1.5rem;                     /* space inside */
  border: 1px solid #dee2e6;           /* light border */
  border-radius: 0.75rem;              /* rounded corners */
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}
```

**▶ Save and look:** an empty rounded, bordered, padded box. That's the box model —
`width` is the content, `padding` is the space inside, `border` outlines it.

### Step B — the name

💡 Inside the card, type `span.name` + **Tab**, then type the text:

```html
<div class="card">
  <span class="name">Loaded Nachos</span>
</div>
```
```css
.name {
  display: block;                      /* its own line (section 5) */
  font-size: 1.5rem;
  font-weight: 500;
}
```

**▶ Save and look:** the name sits at the top of the card. `display: block` makes the span
take its own line so the next piece will stack under it.

### Step C — the price

💡 After the name, type `span.price` + **Tab**:

```html
<span class="price">$9.99</span>
```
```css
.price {
  display: block;                      /* stacks under the name */
  font-size: 1.25rem;
  font-weight: 300;                    /* light weight (section 6) */
  color: #6c757d;                      /* muted gray */
  margin-bottom: 1rem;                 /* gap before the badge */
}
```

**▶ Save and look:** a lighter, gray price under the name, with a gap below it (the
`margin-bottom`, pushing the badge away).

### Step D — the badge

💡 After the price, type `span.badge` + **Tab**:

```html
<span class="badge">Appetizers</span>
```
```css
.badge {
  display: inline-block;               /* flows inline but takes a box (section 5) */
  padding: 0.35em 0.65em;              /* em so it scales with the text (section 7) */
  font-size: 0.85rem;
  color: #0d6efd;
  background-color: #cfe2ff;
  border-radius: 0.375rem;
}
```

**▶ Save and look:** a little blue pill. Because it's `inline-block`, the padding and
rounded background actually render — a plain inline span would have ignored them.

You've now got a real card, built from nothing but the box model, `display`, and a few
text properties. Hold onto it: later this pass you'll rebuild this same card with
Bootstrap, and every class you write there maps back to a line you wrote here.

---

## 9. Verifying in the browser

The browser is your verification tool this whole pass — start the habit now. With the page
open in **Live Server**:

1. You should see the finished card: a bordered, rounded, padded box with the name on top,
   a lighter gray price, and a blue badge pill.
2. Open **DevTools** (F12) → **Elements**. Click your `.card` element.
3. Find the **box-model diagram** in the Styles/Computed panel — the nested content /
   padding / border / margin rectangle. Hover each layer and watch it highlight on the
   page. Confirm the numbers match your CSS (`padding: 24px` for `1.5rem`, etc.).
4. In the Styles panel, change a value live — bump `.card` `padding` to `3rem` and watch
   the box grow. (Live edits reset on reload; it's just for exploring.)
5. Temporarily delete `box-sizing: border-box` from `styles.css` and **save** — with Live
   Server the page reloads and the card gets *wider* than `23rem`, because padding is now
   added on top of the width. Put it back.

If the styles don't apply at all, the `<link href="styles.css">` path is wrong or the file
isn't named exactly `styles.css` — check the **Console** and **Network** tabs for a failed
stylesheet load.

---

## The General Pattern (what to take away)

- An **HTML file** holds semantic structure; a **linked CSS file** styles it; you connect
  them with `<link rel="stylesheet">`, and preview with **Live Server** so saves reload
  automatically.
- **Semantic tags** (`<header>`, `<main>`, `<section>`, headings) name what content *is*.
  Use `<div>`/`<span>` when nothing semantic fits — a card is a `<div>`.
- **Attributes** are `name="value"` pairs: `id`/`class`/`style` are **global** (any
  element); `href`/`src`/`type` are **element-specific**.
- **CSS selectors** target elements (`tag`), classes (`.class`), or ids (`#id`); the more
  specific one — and, on a tie, the later one — wins. **Style with classes.**
- **The box model** is content → padding → border → margin. Size content with
  `width`/`height`, space inside with `padding`, outline with `border`, space outside with
  `margin`. Set `box-sizing: border-box` once so `width` means the whole box.
- **`display`** decides flow: `block` stacks on new lines and takes full width, `inline`
  flows with text, `inline-block` flows but takes a size and padding.
- **Text**: `font-size`, `font-weight` (word or 100–900), `font-style` (`italic`), `color`.
- **Units**: `rem` for most sizes; `em` when a value should scale with the element's own
  text (badge padding); `px` for hairline details.

Everything you just did by hand is what Bootstrap's utility classes will do for you later
this pass — you'll recognize every one of them because you wrote the CSS underneath first.

---

## Build Steps

1. In VS Code, create a `css-fundamentals/` folder with `index.html` and `styles.css`.
2. In `index.html`, expand the boilerplate with Emmet (`!` + Tab) and add the stylesheet
   link (`link:css` + Tab), fixing the `href` to `styles.css` (section 1).
3. Install the **Live Server** extension and open `index.html` with it (right-click → Open
   with Live Server).
4. At the top of `styles.css`, add `* { box-sizing: border-box; }` and a little `body`
   padding.
5. **Step A:** add `<div class="card">` (Emmet `div.card`) and style it as a box — `width`,
   `padding`, `border`, `border-radius`, `box-shadow`. Save and check.
6. **Step B:** add the `.name` span; style it `display: block` with a size and weight. Save
   and check.
7. **Step C:** add the `.price` span; style it block, light weight, muted color, with a
   `margin-bottom`. Save and check.
8. **Step D:** add the `.badge` span; style it `inline-block` with `em` padding, a
   background color, and `border-radius` so it renders as a pill. Save and check.
9. Verify with the box-model overlay in DevTools and try the `box-sizing` experiment
   (section 9).
