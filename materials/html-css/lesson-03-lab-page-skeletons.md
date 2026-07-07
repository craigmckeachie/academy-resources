# Lesson 3 Lab — Page Skeletons

Build the page **skeletons** for the rest of the TableServe pages, using the same
shell and heading pattern you saw in the guide's `orders.html`. Skeleton = the page
shell plus the heading row only — no cards, tables, or forms yet (those come in
Lesson 4). Refer back to the guide (sections 6 and 7) for the shell and heading
markup.

> **End goal.** You're building the *empty shells* here — header, nav, and a heading
> row, with nothing below. To see the finished pages these grow into over Lessons 4–5,
> browse the `screenshots/tableserve/` folder — e.g. the finished
> [Menu](screenshots/tableserve/menuitems.png) and
> [Orders](screenshots/tableserve/orders.png) pages. Don't build those yet; just the
> frame.

---

## Pages to skeleton

Create each file in the project root with the standard shell (`{{> header}}`,
`<main class="d-flex">`, `{{> nav}}`, `<section class="content p-4 flex-grow-1">`,
Bootstrap JS bundle) and a `justify-content-between` heading row. Use these titles,
buttons, and `<title>` tags:

| File | `<title>` | Heading `<h2>` | Action button (text + icon) | Button href |
|---|---|---|---|---|
| `menuitems.html` | TableServe — Menu Items | Menu | Add Item (`#plus`) | `/menuitem-create.html` |
| `categories.html` | TableServe — Categories | Categories | Add Category (`#plus`) | `/category-create.html` |
| `staff.html` | TableServe — Staff | Staff | Add Staff (`#plus`) | `/staff-create.html` |

Then two pages that have **no** action button — just a title and the rule:

| File | `<title>` | Heading `<h2>` |
|---|---|---|
| `order-detail.html` | TableServe — Order Detail | Order |
| `menuitem-create.html` | TableServe — New Menu Item | New Menu Item |

---

## Steps

1. Copy the page shell from the guide's section 7 into each new file.
2. Set the correct `<title>` in `<head>` for each page.
3. Add the heading row: `<div class="d-flex justify-content-between pb-4 mb-4 border-bottom border-2">`
   with the `<h2>` and (where listed) the primary button.
4. For the button icon, reuse the SVG `<use href="/assets/bootstrap-icons.svg#plus" />`
   pattern from the guide.
5. For `order-detail.html` and `menuitem-create.html`, include only the `<h2>` in
   the heading row — no button.
6. Leave everything below each heading empty (a placeholder comment).
7. Add an entry for each new page to the `input` object in `vite.config.js`
   (`menuitems`, `categories`, `staff`, `orderDetail`, `menuitemCreate`).

---

## Verify in the browser

Browser setup (running `npm run dev`, opening pages, DevTools) is covered in the
guide — section 9. With the dev server running:

1. Open each new page (`/menuitems.html`, `/categories.html`, `/staff.html`,
   `/order-detail.html`, `/menuitem-create.html`) and confirm the header + nav +
   heading render, matching `orders.html`.
2. Click the nav links — each should navigate between your pages.
3. Confirm the pages with buttons show the button pinned to the right; the two
   without show just the title and rule.
4. Check the Console (F12) for 404s on any page.

You just reproduced the same shell across five pages — this is exactly what you'll
do to stand up every PRS page (Requests, Products, Vendors, Users, Request Detail)
in the capstone.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and
needs some research.

- **Skeleton the whole app** — [Reinforce] — add shells for the remaining pages
  (`category-create.html`, `staff-create.html`, `order-create.html`,
  `order-edit.html`, `menuitem-edit.html`, `orderitem-create.html`) so every page
  in the design has a shell waiting. Add each to `vite.config.js`.
- **Active nav link** — [Reinforce] — Bootstrap's nav-pills style an `active` link
  differently. Add `class="nav-link active"` to the current page's link in a copy of
  the nav and confirm it takes the orange highlight from `styles.css`. (In React
  you'll set this dynamically; here just prove you can see the active state.)
- **Inspect the box model** — [Reinforce] — in DevTools, select your heading row and
  read off the computed `padding`, `margin`, and `border` values the `pb-4 mb-4
  border-bottom border-2` classes produced. Match each number back to a layer of the
  box-model diagram in the guide.
- **Read Bootstrap's source** — [Reinforce] — open the unminified
  `node_modules/bootstrap/dist/css/bootstrap.css` and find the rules for three classes
  you used on the Orders skeleton — `.btn-primary`, `.d-flex`, and `.border-bottom`.
  Confirm each is ordinary CSS you could have written yourself, exactly as the guide's
  section 5 says.
- **A print stylesheet** — [Reach] — the box model and CSS you're learning aren't
  Bootstrap-only. Add a `@media print { ... }` block to a page that hides the nav
  when printed. Not covered in the guide — you'll need to research media queries.
  Start here: [Using media queries (MDN)](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_media_queries/Using_media_queries).

Finished these and want more? See
[stretch-html-css-challenges.md](stretch-html-css-challenges.md) for bigger
challenges that span the whole HTML/CSS pass.
