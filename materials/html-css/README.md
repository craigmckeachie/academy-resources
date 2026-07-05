# HTML/CSS Concepts — Lesson Materials

This folder contains the lesson materials for the HTML/CSS/Bootstrap pass
(Lessons 1–3) — building the TableServe static front end with semantic HTML,
Bootstrap components, and a flexbox-only layout, using a Vite +
`vite-plugin-handlebars` scaffold.

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
| 1 | [Semantic HTML, box model, flexbox, Vite scaffold](lesson-1-guide-semantic-html-flexbox-vite-setup.md) | [Page skeletons](lesson-1-lab-page-skeletons.md) |
| 2 | [Bootstrap cards, tables, badges, dropdowns, shared form](lesson-2-guide-bootstrap-cards-tables-forms.md) | [Staff list and form](lesson-2-lab-staff-list-and-form.md) |
| 3 | [Detail pages, modals, nested form, Sign In](lesson-3-guide-forms-modals-detail-signin.md) | [Order form, Order Item edit, delete modals](lesson-3-lab-order-form-and-modals.md) |

After the HTML/CSS pass you build all the **PRS static pages independently** using
these completed TableServe pages as the direct pattern reference: Sign In, Requests
list, Request Detail (with the Reject modal), Request Create/Edit, Products, Vendors,
Users, and RequestLine Create/Edit.

## Stretch challenges

Finished a lab early? Each of Lessons 1–3 ends with a short **Stretch challenges**
section tied to that lesson's concept. For bigger challenges that span the whole pass
— reskinning the app to your own restaurant, adding a brand-new entity's pages, dark
mode, responsive layout, and retheming with CSS variables — see
[Stretch challenges](stretch-html-css-challenges.md). None of it is required for the
capstone; it's optional extra practice, tagged **[Reinforce]** (builds on the guide)
or **[Reach]** (goes past it, with a reference link to research).

## Tips

- Every guide and lab uses the **TableServe** domain (Staff, Categories, MenuItems,
  Orders, OrderItems). In the capstone you rebuild the same patterns for **PRS**
  (Users, Vendors, Products, Requests, RequestLines).
- **Flexbox utility classes only — never the Bootstrap `row`/`col` grid.** Use
  `d-flex`, `justify-content-*`, `align-items-*`, `gap-*`, `flex-wrap`, and
  `flex-grow-1` for all layout.
- This is a **static** pass: no JavaScript of your own beyond Bootstrap's bundle (which
  drives dropdowns and modals). Forms and Sign In don't really submit — the markup is
  the target React will wire up later.
- The **header** and **nav** partials, `styles.css`, and the icon sprite are provided
  finished — you build the individual pages. The **Categories** list and form are also
  provided as reference.
- The **avatar-circle-with-initials** on Staff cards is left for you to work out
  (Lesson 2 lab stretch) — you'll need the same pattern on PRS's Users cards.
