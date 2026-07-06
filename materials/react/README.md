# React Concepts — Lesson Materials

This folder contains the lesson materials for the React pass (Lessons 1–13). It starts
with a **React orientation** — components, JSX, TypeScript, and rendering lists — then
builds the TableServe front end one concept at a time (data fetching, routing, forms,
detail pages, modals, auth/context, toasts) and ends with review lessons and a
**capstone bridge** into PRS.

## File types

**`lesson-{N}-guide-*.md`** — the concept reference (**I do**). Read through this during
the instructor-led session. It explains the concepts being taught with code examples
and a step-by-step build walkthrough. Keep it open as a reference.

**`lesson-{N}-lab-*.md`** — the hands-on exercise (**You do**). Use this to build a
similar feature independently. Instructions are intentionally terse — refer back to the
guide and what you built alongside it as your model.

## Schedule

| Lesson | Guide | Lab |
|--------|-------|-----|
| 1 | [Components, JSX, and TypeScript (orientation)](lesson-1-guide-components-jsx-typescript.md) | [A hardcoded Staff list](lesson-1-lab-staff-list-hardcoded.md) |
| 2 | [State, effects, and fetching real data](lesson-2-guide-hooks-data-fetching.md) | [Fetch the Staff list](lesson-2-lab-staff-list-fetch.md) |
| 3 | [Routing, the app shell, and props](lesson-3-guide-routing-layout-props.md) | [Route and navigate to the Staff page](lesson-3-lab-staff-routing.md) |
| 4 | [Conditional rendering, tables, badges, skeletons](lesson-4-guide-conditional-rendering-skeletons.md) | [Staff card grid with conditional rendering](lesson-4-lab-staff-card-grid.md) |
| 5 | [Forms with react-hook-form, shared create/edit](lesson-5-guide-forms-react-hook-form.md) | [The Staff create/edit form](lesson-5-lab-staff-form.md) |
| 6 | [Route params and the detail page](lesson-6-guide-routing-params-detail.md) | [A Category detail view](lesson-6-lab-category-detail.md) |
| 7 | [Status-driven workflow buttons and modals](lesson-7-guide-conditional-buttons-modals.md) | *Worked example — no lab* |
| 8 | [The nested child form with derived fields](lesson-8-guide-nested-child-form.md) | *Worked example — no lab* |
| 9 | [Sign In, localStorage, and Context](lesson-9-guide-auth-context.md) | *Worked example — no lab* |
| 10 | [Toasts and centralized error handling](lesson-10-guide-toasts-error-handling.md) | [Toasts and error handling for Staff CRUD](lesson-10-lab-staff-crud-toasts.md) |
| 11 | [Review/Buffer: the Categories CRUD walkthrough](lesson-11-guide-review-categories-crud.md) | *Review — no lab* |
| 12 | [Review/Buffer: full-app review and PRS gap-check](lesson-12-guide-review-app-gap-check.md) | *Review — no lab* |
| 13 | [Capstone bridge: building the PRS front end](lesson-13-guide-capstone-bridge.md) | *Bridge — no lab* |

**Lesson 1 is a React orientation** — you render a hardcoded array to learn components,
JSX, TypeScript interfaces, and `.map()`, verified by observation in the browser. **Real
data fetching starts in Lesson 2.** Lessons 7–9 are **worked examples** (the Order
Detail workflow/modals, the nested Order Item form, and Sign In/Context) — patterns that
are *named exceptions* with no second TableServe entity to repeat them on, so they're
built once alongside the instructor. Lessons 11–13 are review, gap-check, and the
capstone bridge.

## Stretch challenges

Finished a lab early? Each lab ends with a short **Stretch challenges** section tied to
that lesson's concept. For bigger challenges that span the whole pass — reseeding to your
own restaurant, a brand-new entity's full feature folder, a `useFetch` custom hook, a
dark-mode Context, client-side search, a reusable confirm modal, and consolidated format
utilities — see [Stretch challenges](stretch-react-challenges.md). None of it is required
for the capstone; it's optional extra practice, tagged **[Reinforce]** (builds on the
guide) or **[Reach]** (goes past it, with a reference link to research).

## Tips

- Every guide and lab uses the **TableServe** domain (Staff, Categories, MenuItems,
  Orders, OrderItems). In the capstone you rebuild the same patterns for **PRS** (Users,
  Vendors, Products, Requests, RequestLines) — this pass's capstone block **is** the
  course's final project.
- **Verify in the browser** (open the page, check DevTools Console and Network) — not in
  Insomnia. Insomnia was the API pass; here you confirm the front end renders and behaves.
- Your **TableServe Web API must be running with CORS enabled** (you turn it on in Lesson
  2) so the React app can fetch from it. Use the port your API prints.
- This course has **no JWT/token authentication** — login returns the Staff/User object,
  the front end strips the password and stores the rest in `localStorage` + Context, and
  "signed in" means that value isn't null. Don't add tokens or `[Authorize]`.
- All passwords in the seed data use the plaintext: `test1234`.
- Each entity uses the same **feature folder** pattern (interface, API module, page,
  list, card/row, skeleton, shared form, thin create/edit wrappers) — learn it once,
  repeat it per entity, then again across all of PRS.
