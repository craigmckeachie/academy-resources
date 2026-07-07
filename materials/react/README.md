# React Concepts — Lesson Materials

This folder contains the lesson materials for the React pass (Lessons 1–15). It **opens
with two JavaScript/TypeScript intro lessons for C# developers** (run in a throwaway
vanilla-ts scratch project), then a **React orientation** — components, JSX, and
rendering lists — before building the TableServe front end one concept at a time (data
fetching, routing, forms, detail pages, modals, auth/context, toasts) and ending with
review lessons and a **capstone bridge** into PRS.

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
| 1 | [JavaScript for C# developers (intro)](lesson-01-guide-javascript-for-csharp-devs.md) | [Translating C# to JavaScript](lesson-01-lab-javascript-for-csharp-devs.md) |
| 2 | [TypeScript for C# developers (intro)](lesson-02-guide-typescript-for-csharp-devs.md) | [Typing a Menu Item](lesson-02-lab-typescript-for-csharp-devs.md) |
| 3 | [Components, JSX, and TypeScript (orientation)](lesson-03-guide-components-jsx-typescript.md) | [A hardcoded Staff list](lesson-03-lab-staff-list-hardcoded.md) |
| 4 | [State, effects, and fetching real data](lesson-04-guide-hooks-data-fetching.md) | [Fetch the Staff list](lesson-04-lab-staff-list-fetch.md) |
| 5 | [Routing, the app shell, and props](lesson-05-guide-routing-layout-props.md) | [Route and navigate to the Staff page](lesson-05-lab-staff-routing.md) |
| 6 | [Conditional rendering, tables, badges, skeletons](lesson-06-guide-conditional-rendering-skeletons.md) | [Staff card grid with conditional rendering](lesson-06-lab-staff-card-grid.md) |
| 7 | [Forms with react-hook-form, shared create/edit](lesson-07-guide-forms-react-hook-form.md) | [The Staff create/edit form](lesson-07-lab-staff-form.md) |
| 8 | [Route params and the detail page](lesson-08-guide-routing-params-detail.md) | [A Category detail view](lesson-08-lab-category-detail.md) |
| 9 | [Status-driven workflow buttons and modals](lesson-09-guide-conditional-buttons-modals.md) | *Worked example — no lab* |
| 10 | [The nested child form with derived fields](lesson-10-guide-nested-child-form.md) | *Worked example — no lab* |
| 11 | [Sign In, localStorage, and Context](lesson-11-guide-auth-context.md) | *Worked example — no lab* |
| 12 | [Toasts and centralized error handling](lesson-12-guide-toasts-error-handling.md) | [Toasts and error handling for Staff CRUD](lesson-12-lab-staff-crud-toasts.md) |
| 13 | [Review/Buffer: the Categories CRUD walkthrough](lesson-13-guide-review-categories-crud.md) | *Review — no lab* |
| 14 | [Review/Buffer: full-app review and PRS gap-check](lesson-14-guide-review-app-gap-check.md) | *Review — no lab* |
| 15 | [Capstone bridge: building the PRS front end](lesson-15-guide-capstone-bridge.md) | *Bridge — no lab* |

**Lessons 1–2 are JavaScript/TypeScript intro lessons** for students coming straight from
the C# API pass — the language mapped onto what they already know, run and verified by
observation in a throwaway **vanilla-ts scratch project**, not against the reference app.
**Lesson 3 is a React orientation** — you render a hardcoded array to learn components,
JSX, interfaces, and `.map()` in the browser. **Real data fetching starts in Lesson 4.**
Lessons 9–11 are **worked examples** (the Order Detail workflow/modals, the nested Order
Item form, and Sign In/Context) — patterns that are *named exceptions* with no second
TableServe entity to repeat them on, so they're built once alongside the instructor.
Lessons 13–15 are review, gap-check, and the capstone bridge.

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
- **Lessons 1–2 use a separate throwaway scratch project** (`npm create vite@latest -- --template vanilla-ts`)
  just to try the language; the real TableServe React app is created in Lesson 3.
- **Verify in the browser** (open the page, check DevTools Console and Network) — not in
  Insomnia. Insomnia was the API pass; here you confirm the front end renders and behaves.
- Your **TableServe Web API must be running with CORS enabled** (you turn it on in Lesson
  4) so the React app can fetch from it. Use the port your API prints.
- This course has **no JWT/token authentication** — login returns the Staff/User object,
  the front end strips the password and stores the rest in `localStorage` + Context, and
  "signed in" means that value isn't null. Don't add tokens or `[Authorize]`.
- All passwords in the seed data use the plaintext: `test1234`.
- Each entity uses the same **feature folder** pattern (interface, API module, page,
  list, card/row, skeleton, shared form, thin create/edit wrappers) — learn it once,
  repeat it per entity, then again across all of PRS.
