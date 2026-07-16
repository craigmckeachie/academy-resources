# HTML/CSS Concepts — Lesson Materials

This folder contains the lesson materials for the HTML/CSS/Bootstrap pass
(Lessons 1–5). It starts with **hand-written HTML, CSS, the box model, and flexbox in
plain files** — no tooling, no framework — then adds a Vite + `vite-plugin-handlebars`
scaffold and **Bootstrap** to build the TableServe static front end with a
flexbox-only layout.

## File types

**`lesson-{N}-guide-*.md`** — the concept reference (**I do**). Read through this
during the instructor-led session. It explains the concepts being taught with code
examples and a step-by-step build walkthrough. Keep it open as a reference.

**`lesson-{N}-lab-*.md`** — the hands-on exercise (**You do**). Use this to build a
similar page independently. Instructions are intentionally terse — refer back to the
guide and what you built alongside it as your model.

## Schedule

| Lesson | Guide | Lab |
|--------|-------|-----|
| 1 | [Semantic HTML and the box model — raw CSS, plain files](lesson-01-guide-semantic-html-box-model.md) | [Style a Staff card by hand](lesson-01-lab-staff-card.md) |
| 2 | [Flexbox — raw CSS](lesson-02-guide-flexbox.md) | [A card grid, and Flexbox Froggy](lesson-02-lab-card-grid-flexbox-froggy.md) |
| 3 | [The Vite scaffold, partials, and the Bootstrap page shell](lesson-03-guide-vite-scaffold-bootstrap-shell.md) | [Staff page skeleton](lesson-03-lab-page-skeletons.md) |
| 4 | [Bootstrap cards, tables, badges, dropdowns, shared form](lesson-04-guide-bootstrap-cards-tables-forms.md) | [Staff list and form](lesson-04-lab-staff-list-and-form.md) |
| 5 | [Detail pages, modals, nested form, Sign In](lesson-05-guide-forms-modals-detail-signin.md) | [Order form, Order Item edit, delete modals](lesson-05-lab-order-form-and-modals.md) |

**Lessons 1–2 use plain files you write and preview with the VS Code Live Server
extension** — no Vite, no npm, no Bootstrap. The point is to see raw HTML, the box
model, and flexbox before a framework hides them. **The Vite scaffold and Bootstrap
enter in Lesson 3**, and from there you build on the same page shell.

After the HTML/CSS pass you build all the **PRS static pages independently** using
these completed TableServe pages as the direct pattern reference: Sign In, Requests
list, Request Detail (with the Reject modal), Request Create/Edit, Products, Vendors,
Users, and RequestLine Create/Edit.

## Prework — optional head start

Between passes and want to get ahead? Work through
[**HTML/CSS prework**](prework-html-css.md) — a self-guided warm-up on semantic HTML, the
box model, CSS selectors, and flexbox (the Lesson 1–2 material), plus a skim of Bootstrap
and a study of the PRS pages you'll build. Optional and ungraded; the pass teaches it all.

## Stretch challenges

Finished a lab early? Each lab ends with a short **Stretch challenges** section tied to
that lesson's concept. For bigger challenges that span the whole pass — reskinning the
app to your own restaurant, adding a brand-new entity's pages, dark mode, responsive
layout, retheming with CSS variables, and generating or reviewing markup with GitHub
Copilot — see [Stretch challenges](stretch-html-css-challenges.md). None of it is required for the
capstone; it's optional extra practice, tagged **[Reinforce]** (builds on the guide)
or **[Reach]** (goes past it, with a reference link to research).

## Tips

- Every guide and lab uses the **TableServe** domain (Staff, Categories, MenuItems,
  Orders, OrderItems). In the capstone you rebuild the same patterns for **PRS**
  (Users, Vendors, Products, Requests, RequestLines).
- **Lessons 1–2 are plain files** (`.html` + `.css`, previewed with the **Live Server**
  VS Code extension) — you write the CSS by hand so you understand what Bootstrap does for
  you. **Lesson 3 onward uses the Vite scaffold** — run `npm run dev` and open the URL it
  prints so the `{{> header}}` partials expand.
- **Get the scaffold for Lesson 3:** download [`tableserve-design-starter.zip`](https://github.com/craigmckeachie/academy-resources/raw/main/files/tableserve-design-starter.zip),
  unzip it, and run `npm install` — that unzipped folder is the `TableServe.Design`
  starter project the Lesson 3 guide builds on. (See all [Downloads](../downloads.md).)
- **Flexbox for layout — never the Bootstrap `row`/`col` grid, and no CSS Grid.** Use
  `display: flex` (raw) / `d-flex` (Bootstrap), `justify-content-*`, `align-items-*`,
  `gap-*`, `flex-wrap`, and `flex-grow-1` for all layout.
- **Bootstrap classes are the CSS you already wrote, renamed** — `d-flex` is
  `display: flex`, `p-4` is padding, `justify-content-between` is
  `justify-content: space-between`. If a class ever feels like magic, recall the raw
  rule from Lessons 1–2.
- This is a **static** pass: no JavaScript of your own beyond Bootstrap's bundle (which
  drives dropdowns and modals). Forms and Sign In don't really submit — the markup is
  the target React will wire up later.
- The **header** and **nav** partials, `styles.css`, and the icon sprite are provided
  finished — you build the individual pages. The **Categories** list and form are also
  provided as reference.
- The **avatar-circle-with-initials** on Staff cards is left for you to work out (a
  stretch challenge — raw CSS in the Lesson 1 lab, Bootstrap in the Lesson 4 lab) —
  you'll need the same pattern on PRS's Users cards.
- **GitHub Copilot** (TQL's preferred AI assistant) appears in this pass only as optional
  [stretch challenges](stretch-html-css-challenges.md) — generating markup and auditing it
  against the flexbox-and-npm house style. Keep the
  [Copilot quick-start](../reference/copilot-quickstart.md) handy; the required Copilot
  lessons are in the API and React passes.
