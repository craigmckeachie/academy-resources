# Lesson 2 Lab — A Card Grid, and Flexbox Froggy

Reinforce flexbox two ways: **build a wrapping card grid** from the cards you styled in
Lesson 1, and **drill the core properties with Flexbox Froggy**. Same plain-file setup
as the guide — no framework. Refer back to the guide for the flexbox properties.

---

## Part A — a wrapping card grid

In Lesson 1 you built a single card. A real list page shows *many* cards that wrap
across the page as it narrows — a flex container with `flex-wrap`.

1. In `css-fundamentals/`, create `card-grid.html` + `card-grid.css` (linked), with
   `* { box-sizing: border-box; }` at the top.
2. Bring over your Menu Item card CSS from Lesson 1 (the `.card`, `.name`, `.price`,
   `.badge` rules).
3. In the HTML, wrap **several** cards (4–6, different menu items) in a container:
   `<section class="grid"> …cards… </section>`.
4. Make the container a wrapping flex row:
   ```css
   .grid {
     display: flex;
     flex-wrap: wrap;
     gap: 1.5rem;
   }
   ```
5. Open it and **resize the window** — the cards should reflow onto fewer/more per row
   as the width changes. That reflow is `flex-wrap` doing the work of a grid, with no
   `row`/`col` anywhere.

## Part B — a header row above the grid

6. Above the grid, add the **header row** from the guide (section 4): an `<h2>` "Menu"
   on the left and a "Add Item" button on the right, using
   `display: flex; justify-content: space-between; align-items: center`.

## Part C — Flexbox Froggy

7. Play **Flexbox Froggy** and complete roughly the **first 12–15 levels**:
   [flexboxfroggy.com](https://flexboxfroggy.com). Those levels drill
   `justify-content`, `align-items`, and `flex-direction` — the exact properties from
   the guide. Stop once the later levels move past what we've covered; you don't need
   the whole game.

---

## Verify in the browser

Browser checks work the same as the guide — section 7. Open `card-grid.html`:

1. Confirm the cards sit in a wrapping row with even `gap` spacing, and that they
   **reflow** when you resize the window.
2. Confirm the header row has the title left and the button right, vertically aligned.
3. Open **DevTools** (F12), select `.grid`, click its **`flex` overlay** badge, and
   confirm the main axis runs across and items wrap to new lines.
4. Check the **Console** for a failed stylesheet load if nothing is styled.

A wrapping card grid and a header row are the two layouts you'll build on every list
page this pass — next lesson you'll make them with Bootstrap's flex utilities instead
of hand-written CSS, but the layout is identical.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and
needs some research.

- **Center a lonely card** — [Reinforce] — in a container with a single card, use
  `justify-content: center` and `align-items: center` (give the container a `height`)
  to center it both ways — the Sign In page centering you'll meet later.
- **Column on narrow, row on wide** — [Reinforce] — build a small two-box layout and
  switch its `flex-direction` from `row` to `column` by hand; watch the main axis flip
  and `justify-content` / `align-items` swap which way they push.
- **Nudge one item** — [Reach] — give one flex item `align-self` to override the
  container's `align-items` for just that child. Not covered in the guide — research
  it: [align-self (MDN)](https://developer.mozilla.org/en-US/docs/Web/CSS/align-self).
- **Push the last item away** — [Reach] — in a row of items, give one item
  `margin-left: auto` and watch it (and everything after it) shove to the far end — a
  handy flexbox trick. Research: [Aligning items in a flex container →
  auto margins (MDN)](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_flexible_box_layout/Aligning_items_in_a_flex_container).

> Layout in this course is **flexbox only** — we deliberately don't use CSS Grid. You
> may meet Grid on the job; here, everything you need for a card grid is `flex-wrap` +
> `gap`.

Finished these and want more? See
[stretch-html-css-challenges.md](stretch-html-css-challenges.md) for bigger
challenges that span the whole HTML/CSS pass.
