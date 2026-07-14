# HTML/CSS Prework — Optional Head Start

**Optional. Not required for the capstone.** This packet is for students who finish the
PRS backend capstone early and want a running start on the next pass — HTML/CSS/Bootstrap —
instead of waiting. It's ungraded, and skipping it costs you nothing: the pass teaches all
of it from scratch.

**What it front-loads:** the HTML/CSS pass opens with two **hand-written** lessons —
semantic HTML + the box model (Lesson 1) and flexbox (Lesson 2), both in plain files with
no framework — then adds Bootstrap in Lesson 3 to build the TableServe static pages. This
packet warms up that exact material and ends by studying the **PRS pages you'll build in
the capstone**, so the pass becomes mostly assembly.

**The one big idea:** everything Bootstrap does for you later is CSS you can write by hand
now — and writing it by hand once is what makes the framework classes stop feeling like
magic. `d-flex` is `display: flex`; `p-4` is padding. Learn the raw rules first.

> Deeper treatment lives in the lesson guides in this folder:
> [Semantic HTML & the box model](lesson-01-guide-semantic-html-box-model.md) and
> [Flexbox](lesson-02-guide-flexbox.md). This packet is the short, do-it-yourself version.

---

## Before you start

- **No tooling needed** for Parts 1–2 — just **VS Code** (your editor) and a browser. You
  write the `.html` + `.css` files in VS Code and open them **straight from disk**
  (`file://`), exactly as Lessons 1–2 do. (Bootstrap and Vite don't arrive until Lesson 3.)
- **Use Chrome** so these steps match exactly. (Edge is nearly identical — same engine.)
- **Opening DevTools (Windows).** The reliable way: **right-click anything on the page →
  Inspect**. DevTools opens with that element already selected in the **Elements** panel —
  exactly what you want for this packet. There's also a keyboard shortcut, **F12** — but on
  many **laptops** the top row acts as media keys, so F12 may need **Fn + F12** (if tapping
  F12 changes the volume or brightness instead, hold **Fn** as well). If the shortcut
  fights you, just use **right-click → Inspect** — it always works.
- **Verify by observation** — you'll *see* the layout in DevTools: the **box-model diagram**
  in Part 1 and the **flexbox overlay** in Part 2.

---

## Part 0 — A practice folder (once)

Make a folder to experiment in — call it `css-fundamentals/` (the same name Lesson 1
uses). Inside, create two linked files and open `index.html` in your browser:

```
css-fundamentals/
  index.html      ← structure
  styles.css      ← styling; link it from <head> with <link rel="stylesheet" href="styles.css">
```

Put `* { box-sizing: border-box; }` at the top of `styles.css` and you're ready.

---

## Part 1 — Semantic HTML, selectors, and the box model

Warm up on the Lesson 1 material. Build as you read — type it, open it, poke it in
DevTools.

- [ ] **Semantic tags** name what content *is*: `<header>`, `<nav>`, `<main>` (one per
      page), `<section>`, `<address>`, `<h1>`–`<h6>` (by rank, not size), `<p>`, `<ul>`/`<li>`,
      `<a>`. Reach for `<div>`/`<span>` only when nothing semantic fits.
- [ ] **Selectors**: element (`p`), class (`.price`), id (`#total`). Classes are how you
      style almost everything — and they're exactly what Bootstrap's utility classes are.
- [ ] **The box model** — every element is content → padding → border → margin. Size the
      content with `width`/`height`, space inside with `padding`, outline with `border`,
      space outside with `margin`. Set `box-sizing: border-box` once so `width` means the
      whole box.
- [ ] **`display`**: `block` (stacks, full width), `inline` (flows with text, ignores
      width/height), `inline-block` (flows but takes a size + padding — how a badge pill
      works).

**Build it:** make a **card** by hand — a bordered, rounded, padded box with a bold name,
a lighter line of secondary text, and a small colored **badge** pill (use
`display: inline-block` on the badge). A PRS **Vendor card** is a good target — name + a
code badge + an address — because you'll build the real one in the capstone.

**Verify:** open the page, then **right-click the card → Inspect** (see *Before you start*
for opening DevTools). With the card selected in the **Elements** panel, find the
**box-model diagram** in the Styles/Computed panel and **hover each layer** — content,
padding, border, margin — to watch it highlight on the page. Then delete
`box-sizing: border-box` and reload — the card gets *wider* than you set, because padding is
now added on top. Put it back.

- **Drill selectors** with [CSS Diner](https://flukeout.github.io/) — a quick game for
  element/class/id/attribute selectors.
- Reference: [MDN — Introduction to the CSS box model](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_box_model/Introduction_to_the_CSS_box_model).

---

## Part 2 — Flexbox (the layout engine for the whole pass)

Almost all layout in this course is **flexbox** (never the Bootstrap grid, never CSS
Grid). Warm up on the Lesson 2 material:

- [ ] `display: flex` on a **container** turns its direct children into flex **items** laid
      out along a **main axis** (`flex-direction: row`/`column`) and a perpendicular
      **cross axis**.
- [ ] **`justify-content`** spaces items on the **main** axis (`space-between` pins one
      child to each end); **`align-items`** aligns on the **cross** axis (`center` vertically
      centers a row).
- [ ] **`gap`** spaces children without margins; **`flex-wrap: wrap`** lets them flow onto
      new lines; **`flex-grow: 1`** on one item makes it absorb the leftover space.

**Build two layouts you'll reuse on every page:**

1. **Header row** — a heading hard-left and a button hard-right, vertically centered:
   `display: flex; justify-content: space-between; align-items: center`.
2. **Card grid** — put several of your Part 1 cards in a container with
   `display: flex; flex-wrap: wrap; gap: 1rem` and watch them reflow as you resize the
   window.

**See it in DevTools — the flexbox overlay and editor.** Just like the box model, Chrome
lets you *see* and *tweak* a flex layout live:

1. **Right-click your header row → Inspect** to select the flex container in the
   **Elements** panel.
2. Chrome shows a little **`flex` badge** next to that element in Elements. Click it — an
   **overlay** appears on the page outlining the flex container, with markers for the
   **main axis**, the **cross axis**, and each `gap`.
3. In the **Styles** panel, find the `display: flex` rule and click the small **flexbox
   editor icon** right beside it. A popup of clickable buttons opens for `flex-direction`,
   `flex-wrap`, `align-items`, and `justify-content`. Click through the `justify-content`
   options (`center`, `space-between`, `flex-end`) and watch the button slide around the
   row — the same live-edit trick you used on the box model, but for layout.
4. Do the same on your **card grid** container: toggle `flex-wrap`, change `align-items`,
   and resize the window to watch the cards reflow.

(Live DevTools edits reset on reload — they're just for exploring.)

- **Drill it** with [Flexbox Froggy](https://flexboxfroggy.com/) — the first ~15 levels
  cover exactly `justify-content`, `align-items`, and `flex-direction`. This is the one
  game the pass itself uses.

> **Stop at flexbox.** Froggy links a "Grid Garden" game — **skip it**. CSS Grid is
> deliberately out of scope in this course; every layout is flexbox.

---

## Part 3 — Preview Bootstrap and study the PRS pages

The orientation payoff — you install nothing here, you just *recognize* what's coming.

**Skim Bootstrap** — [Bootstrap 5.3 docs](https://getbootstrap.com/docs/5.3/getting-started/introduction/).
Don't memorize anything; just browse the components the pass uses so the names are
familiar: **cards, tables, badges, buttons, dropdowns, forms, modals**. As you read, map
each class back to the raw CSS from Parts 1–2 — `d-flex` = `display: flex`,
`justify-content-between` = `justify-content: space-between`, `p-4` = padding.

**Study the pages you'll build.** Open the PRS requirements and its screenshots —
[`../specs/prs-requirements.md`](../specs/prs-requirements.md) — and for each page, sketch
or annotate the **repeating components**. You'll notice the whole app is a handful of
patterns reused:

| Pattern | PRS pages that use it |
|---|---|
| Card grid + three-dots action menu | Products, Vendors, Users |
| Table + status badges + status filter + three-dots | Requests list |
| Shared Create/Edit form | Request, Product, Vendor, User forms |
| Detail page + workflow buttons + modal | Request Detail (with the Reject modal) |
| Centered card | Sign In |

Spot those five patterns and Pass 2 becomes mostly assembling shapes you already
recognize.

---

## Part 4 — What this sets you up for

| What you did here | Where it returns |
|---|---|
| Semantic tags, selectors, the box model, a card by hand | Lesson 1 (the Menu Item card, by hand) |
| Flexbox: header row, wrapping card grid, Froggy | Lesson 2 (header row + app frame + card grid) |
| Recognizing Bootstrap components | Lessons 3–5 (the same card / table / form / modal in Bootstrap) |
| Spotting the repeating PRS page patterns | the HTML/CSS capstone (you build every PRS page) |

You do **not** need to install Vite, npm, or Bootstrap — that's Lesson 3. Stay in plain
files opened from disk.

---

## Guardrails

- **Optional and ungraded** — do as much or as little as you like; stop any time.
- **Flexbox only** for layout — no Bootstrap `row`/`col` grid, no CSS Grid.
- **Static pass** — no JavaScript of your own; the markup is what React wires up later.
- Parts 1–2 are **plain files opened from disk** — no server, no build step.
