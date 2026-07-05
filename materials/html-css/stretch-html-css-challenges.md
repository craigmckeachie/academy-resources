# HTML/CSS Stretch Challenges

Optional, off-the-critical-path work for when you finish a lab early. **None of this
is required for the PRS capstone** — it's here to keep you sharp and let you push
past what the guides cover.

Each lab also has its own short **Stretch challenges** section tied to that lesson's
concept. The challenges below are the bigger, cross-cutting ones that span the whole
HTML/CSS pass — reach for them once you're comfortably ahead.

## How the challenges are labeled

- **[Reinforce]** — extends something a guide already showed you. No new concept; you
  have everything you need.
- **[Reach]** — goes past the guides. You'll need to do some research on your own; a
  reference link is provided as a starting point. Expect to read and experiment.

Everything you build here is verified the same way the labs are — in the **browser**,
with `npm run dev` running. There's no new tooling to add.

---

## 1. Model your own restaurant — [Reinforce]

The pages ship with hardcoded TableServe data (Loaded Nachos, Ribeye Steak, and so
on). Replace it throughout with **your own favorite restaurant's** menu, categories,
staff, and orders, so the whole app reflects a real place you know.

Rather than hand-editing every card and row, use an AI assistant — and **give it one
of your finished pages as the reference** so the generated markup matches your
structure exactly:

1. Paste your completed `menuitems.html` into the assistant and tell it to **keep the
   markup structure identical** — same `.card` shape, same badge classes, same 3-dots
   dropdown — and only swap the names, prices, and categories.
2. Do the same for `categories.html`, `staff.html`, and the `orders.html` /
   `order-detail.html` rows.
3. **Read what it produced before pasting it back.** Confirm the category badges match
   real categories, the FK dropdown options in the forms line up with your new
   categories/menu items, and the Order totals still equal the sum of their items.
4. Reload each page and confirm it renders cleanly.

The skill here is directing the AI with a good reference — your existing page is the
contract the new markup has to honor. (This mirrors the AI-assisted seed-data
challenge from the API pass.)

---

## 2. A brand-new entity page — [Reinforce]

Add a page for an entity the design doesn't include — **Tables** (the physical dining
tables): a card grid plus a shared Create/Edit form, built entirely from patterns you
already know.

1. `tables.html` — a card grid (Lesson 2) where each card shows a table number, seat
   count, and a 3-dots Edit/Delete menu.
2. `table-create.html` / `table-edit.html` — a shared form (Lesson 2) with Table
   Number and Seats number inputs, Cancel/Save buttons.
3. Add a **Tables** link to a copy of `nav.html`, and add the three pages to
   `vite.config.js`.
4. Wire the delete modal (Lesson 3) on the list page.

If you can stand this up without re-reading the guides, you've internalized the
card-grid + shared-form + modal pipeline you'll run five times on PRS.

---

## 3. Dark mode — [Reach]

Bootstrap 5.3 has a built-in dark mode driven by a single attribute,
`data-bs-theme="dark"`, on the `<html>` element. Add a dark variant of the app.

- Try it first by hand: set `<html lang="en" data-bs-theme="dark">` on one page and
  reload — most components adapt instantly.
- Then add a **toggle**: a header link/button that flips the attribute. This is the
  one place a few lines of your own `<script>` are justified (Bootstrap's own docs do
  the same) — everything else in this pass stays markup-only.
- Check your custom `styles.css` overrides (the orange brand color, the sign-in
  gradient) still look right against the dark background; tweak if needed.

Not covered in the guide — research color modes here:
[Bootstrap color modes](https://getbootstrap.com/docs/5.3/customize/color-modes/).

---

## 4. Responsive layout — [Reach]

The app is built for a wide screen — the fixed 280px nav and wrapping card grids hold
up when narrowed, but the layout isn't truly responsive. Improve it for small screens
**without** reaching for the Bootstrap `row`/`col` grid (still banned).

- Below a breakpoint, stack the nav **above** the content instead of beside it (change
  the `main` from a flex row to a flex column at narrow widths).
- Let the Order table scroll horizontally on small screens (`table-responsive`) rather
  than overflowing.
- Confirm the card grids already re-flow (they do — that's `flex-wrap`), and shrink
  the fixed card widths at narrow widths if they crowd.

Use your browser's device-toolbar (responsive mode) to test. Not covered in the guide
— research media queries:
[Using media queries (MDN)](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_media_queries/Using_media_queries).

---

## 5. Retheme with CSS custom properties — [Reach]

The brand orange (`#FF7A00`) is wired through `styles.css` using **CSS custom
properties** (variables) — that's how `--bs-btn-bg`, `--bs-link-color-rgb`, and the
nav-pill colors are overridden. Re-skin the app to a different brand color of your
choosing by changing the variables, not by hunting down every hardcoded hex.

1. Read the top of `css/styles.css` and find where it sets Bootstrap's `--bs-*`
   variables and the `.btn-primary` / `.badge` / `.progress-bar` overrides.
2. Introduce your **own** variable (e.g. `--brand: #2E7D32;`) on `:root`, then
   reference it with `var(--brand)` in those override rules.
3. Reload and confirm buttons, badges, links, and the sign-in accents all shift to the
   new color from that single source.

Not covered in the guide — research custom properties:
[Using CSS custom properties (MDN)](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties).

---

## 6. Swap and expand the icon set — [Reinforce]

Every icon in the app is an SVG `<use href="/assets/bootstrap-icons.svg#name" />`
pointing at a symbol in the Bootstrap Icons sprite. Explore the full set and improve
the app's iconography:

- Browse the library at [Bootstrap Icons](https://icons.getbootstrap.com/) and find
  the exact symbol names.
- Replace a generic icon with a more fitting one (e.g. a distinct icon per workflow
  action on the Order Detail buttons).
- Add an icon to a place that has none (e.g. a small icon beside each `<dt>` label in
  the detail summary).

Because the sprite is already loaded, this is pure markup — just change the `#name`
in the `<use href>`.

---

You'll reuse every one of these instincts on the PRS capstone: reskinning to your own
data, standing up a new entity's pages, and polishing layout and theming are exactly
the kinds of things you'll reach for once the core PRS pages are in place.
