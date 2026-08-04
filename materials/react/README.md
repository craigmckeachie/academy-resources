# React Concepts — Lesson Materials

This folder contains the lesson materials for the React pass (Lessons 1–16). It **opens
with two JavaScript/TypeScript intro lessons for C# developers** (run in a throwaway
vanilla-ts scratch project), then a **React orientation** — components, JSX, and
rendering lists — before building the TableServe front end one concept at a time (data
fetching, routing, forms, detail pages, modals, auth/context, toasts), then review lessons
and a **capstone bridge** into PRS. **Lesson 16 — the tooling lesson on building with GitHub
Copilot — comes *after* the PRS capstone**, not before it: see the
[AI use policy](../reference/ai-policy.md).

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
| 9 | [Status-driven workflow buttons and modals](lesson-09-guide-conditional-buttons-modals.md) | [The Categories list](lesson-09-lab-categories-list.md) |
| 10 | [The nested child form with derived fields](lesson-10-guide-nested-child-form.md) | [The Categories create/edit form](lesson-10-lab-categories-form.md) |
| 11 | [Sign In, localStorage, and Context](lesson-11-guide-auth-context.md) | [The Order create/edit form](lesson-11-lab-order-form.md) |
| 12 | [Toasts and centralized error handling](lesson-12-guide-toasts-error-handling.md) | [Toasts and error handling — Staff, then the rest of the app](lesson-12-lab-staff-crud-toasts.md) |
| 13 | [Review/Buffer: the feature-folder pattern across your app](lesson-13-guide-review-categories-crud.md) | *Review — no lab* |
| 14 | [Review/Buffer: full-app review and PRS gap-check](lesson-14-guide-review-app-gap-check.md) | *Review — no lab* |
| 15 | [Capstone bridge: building the PRS front end](lesson-15-guide-capstone-bridge.md) | *Bridge — no lab* |
| 16 *(after the capstone)* | [Building with GitHub Copilot: autocomplete, Chat, agent mode](lesson-16-guide-building-with-copilot.md) | [Generate a Staff feature and audit it](lesson-16-lab-generate-and-audit-staff.md) |

**Lessons 1–2 are JavaScript/TypeScript intro lessons** for students coming straight from
the C# API pass — the language mapped onto what they already know, run and verified by
observation in a throwaway **vanilla-ts scratch project**, not against the reference app.
**Lesson 3 is a React orientation** — you render a hardcoded array to learn components,
JSX, interfaces, and `.map()` in the browser. **Real data fetching starts in Lesson 4.**
Lessons 9–11 **guides** are **worked examples** (the Order Detail workflow/modals, the nested
Order Item form, and Sign In/Context) — patterns that are *named exceptions* with no second
TableServe entity to repeat them on, so they're built once alongside the instructor. Their
**labs** don't repeat those exact patterns; instead they **build out the rest of the app** so
students finish with a complete TableServe — the **Categories** list (L9) and form (L10), and
the **Order** create/edit form (L11, which applies the Context from the guide).
Lessons 13–15 are review, gap-check, and the capstone bridge — and the capstone follows
them. **Lesson 16 is a tooling lesson** on **GitHub Copilot** (TQL's preferred AI assistant)
— generating React code and auditing it against this project's conventions; verified by
observation in the browser, and building on the API pass's Copilot code-review lesson. It
is taught **after you finish the PRS capstone**, because generating whole features is
exactly what the [AI use policy](../reference/ai-policy.md) holds back until the app has
been built by hand.

## Prework — optional head start

Finished the API capstone early and want a running start? Work through
[**React prework**](prework-react.md) — a self-guided warm-up on JavaScript and TypeScript
for C# developers (the Lesson 1–2 material) that ends by calling **your own PRS API** from
the browser with `fetch`. It's optional and ungraded; the pass teaches all of it from
scratch.

## Stretch challenges

Finished a lab early? Each lab ends with a short **Stretch challenges** section tied to
that lesson's concept. For bigger challenges that span the whole pass — reseeding to your
own restaurant, a brand-new entity's full feature folder, a `useFetch` custom hook, a
dark-mode Context, client-side search, a reusable confirm modal, and consolidated format
utilities — see [Stretch challenges](stretch-react-challenges.md). None of it is required
for the capstone; it's optional extra practice, tagged **[Reinforce]** (builds on the
guide) or **[Reach]** (goes past it, with a reference link to research).

## Optional polish

Small, self-contained improvements to the app you built. None of it is required for the
capstone — pick them up whenever you have time.

- [**The ⋮ menu's orange ring and caret**](polish-dropdown-menus.md) — react-bootstrap's
  `Dropdown.Toggle` adds a `btn-primary` variant and a ▾ caret you never typed, so the
  three-dots menus pick up an orange focus ring and an extra glyph the static design
  doesn't have. A one-line fix per menu, plus one CSS rule. Any time after Lesson 6.
- [**A loading splash while the bundle downloads**](polish-loading-splash.md) — the blank
  white page before React's first render is an empty `<div id="root">`. Fill it with markup
  and inline CSS and it paints immediately, then clears itself when the app mounts. Any
  time after Lesson 3.

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
- **Read the [AI use policy](../reference/ai-policy.md) before the capstone.** During a
  capstone, AI reads code with you; it doesn't write code for you — explaining, researching,
  debugging, and reviewing your own code are allowed; generating components and agent mode
  wait until after.
- **GitHub Copilot** is TQL's preferred AI assistant; Lesson 16 — taught **after** the
  capstone — covers using it to *generate* React code and audit it against this project's
  conventions. Keep the [Copilot quick-start](../reference/copilot-quickstart.md) open for
  the guardrails.
