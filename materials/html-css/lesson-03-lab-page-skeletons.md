# Lesson 3 Lab — Staff Page Skeleton

Build the **Staff page skeleton** by hand — the same shell + heading pattern the guide
built for `orders.html`, on a different page. `staff.html` ships **blank** (just the
`<head>`) for exactly this reason: you build its body yourself. Skeleton = the page
shell plus the heading row only — no cards or forms yet (those come in Lesson 4). Refer
back to the guide (sections 6 and 7) for the shell and heading markup.

> **End goal.** You're building the _empty shell_ here — header, nav, and a heading
> row, with nothing below. To see the finished page it grows into over Lessons 4–5,
> browse the [Staff page](screenshots/tableserve/staff.png) in
> `screenshots/tableserve/`. Don't build the cards yet; just the frame.

![Finished TableServe Staff page: a wrapping grid of staff cards, each showing a name, username, phone, email, and role badges, with a three-dots action menu](screenshots/tableserve/staff.png)

---

## Steps

1. **Open `staff.html`** — click its link on the `index.html` page directory in the browser and open
   the file in VS Code for editing. It's **blank** below the `<head>` (the `<head>`, with the
   correct `<title>` and stylesheet links, is already there).
2. Build the **page shell** into the empty `<body>` (guide section 6), in order:
   - `{{> header}}`
   - `<main class="d-flex">` containing `{{> nav}}` and
     `<section class="content p-4 flex-grow-1">`
   - the Bootstrap JS bundle `<script>` as the last line of `<body>`
3. Inside `section.content`, add the **heading row** (guide section 7):
   `<div class="d-flex justify-content-between pb-4 mb-4 border-bottom border-2">` with
   an `<h2>Staff</h2>` and an **Add Staff** primary button linking to
   `/staff-create.html`.
4. For the button icon, reuse the `<svg><use href="/assets/bootstrap-icons.svg#plus" /></svg>`
   pattern from the guide.
5. Leave everything below the heading empty (a placeholder comment) — the staff cards
   come in Lesson 4.
6. `staff.html` is already listed in the `input` object of `vite.config.js` — nothing
   to add there.

---

## Verify in the browser

Browser setup (running `npm run dev`, opening pages, DevTools) is covered in the
guide — section 8. With the dev server running:

1. Open `/staff.html` and confirm the header + nav + heading render, matching the
   `orders.html` you built in the guide.
2. Click the nav links — each should navigate between your pages.
3. Confirm the **Add Staff** button is pinned to the right of the heading row, with
   the rule underneath.
4. **Resize the window** and confirm the content area flexes beside the fixed-width
   nav (`flex-grow-1`).
5. Check the Console (F12) for 404s.

You just stood up the same shell the guide built for Orders, on a second page — this is
exactly what you'll do to stand up every PRS page (Requests, Products, Vendors, Users,
Request Detail) in the capstone.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and
needs some research.

- **Heading rows for the other list pages** — [Reinforce] — the skeletoned
  `menuitems.html` and `categories.html` already ship with the shell but an empty
  content area. Add the same `justify-content-between` heading row to each — Menu /
  **Add Item** → `/menuitem-create.html`, and Categories / **Add Category** →
  `/category-create.html`. It's a head start on Lesson 4.
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
  you used on the Staff skeleton — `.btn-primary`, `.d-flex`, and `.border-bottom`.
  Confirm each is ordinary CSS you could have written yourself, exactly as the guide's
  section 5 says.
- **A print stylesheet** — [Reach] — the box model and CSS you're learning aren't
  Bootstrap-only. Add a `@media print { ... }` block to a page that hides the nav
  when printed. Not covered in the guide — you'll need to research media queries.
  Start here: [Using media queries (MDN)](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_media_queries/Using_media_queries).

Finished these and want more? See
[stretch-html-css-challenges.md](stretch-html-css-challenges.md) for bigger
challenges that span the whole HTML/CSS pass.
