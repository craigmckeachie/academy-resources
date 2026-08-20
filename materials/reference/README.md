# Reference — Evergreen Cheat Sheets

Cross-cutting reference material that isn't tied to a single lesson. Guides and labs
link here; students keep these open while they work. Unlike the lesson folders, nothing
here is a step-by-step build — these are lookups.

## Cheat sheets

- [HTTP, REST, JSON & Status Codes](http-rest-status-codes.md) — request/response
  anatomy, the CRUD-to-HTTP mapping, JSON, and the status-code families + this course's
  conventions. First taught in **API Lesson 1**.
- [Insomnia quick-start](insomnia-quickstart.md) — what Insomnia is, importing the
  TableServe collection, setting `baseUrl`, and reading responses. First taught in
  **API Lesson 1**.
- [AI use policy](ai-policy.md) — **read this before every capstone.** During a capstone,
  AI reads code with you; it doesn't write code for you. Explaining, researching, debugging,
  and reviewing your own code are allowed; generating components and agent mode wait until
  after. Includes the allowed/deferred table and the one test that settles most cases.
- [Git collaboration quick-start](git-collaboration-quickstart.md) — working in a shared
  repository: the branch → pull request → review → merge loop, staying current with `main`,
  resolving conflicts, and Git **worktrees** (including why an autonomous agent needs its
  own). Used throughout the **team development block**.
- [Git flow — animated walkthrough](git-flow-animation.html){ target="_blank" rel="noopener" } —
  an 18-step animation of the same workflow: two developers take features from `git clone`
  through branches, pull requests, a merge conflict, and back into `main`. **Opens full screen
  in a new tab.** Arrow keys or click to step, `1`/`2` jump between phases, `F` for fullscreen.
  Pairs with the quick-start above; used throughout the **team development block**.
- [GitHub Copilot quick-start](copilot-quickstart.md) — TQL's preferred AI assistant:
  the three surfaces (autocomplete, Chat, agent), set-up per editor, the verify-don't-trust
  discipline, and the conventions watch-list. Backs the Copilot lessons and stretch
  challenges across all three passes.
- [Anatomy of C# Code](anatomy-of-csharp-code.md) — an annotated model and controller that
  name every part: class, object, method, parameter, field, local variable, property, and
  the distinctions students trip on. Has a blank [quiz version](anatomy-of-csharp-code-quiz.md).
  Useful from **API Lesson 2** and throughout the capstone.
- [Anatomy of TypeScript Code](anatomy-of-typescript-code.md) — the TypeScript/React companion:
  an annotated interface, API module, and list component that name every part — interface,
  property, type, object, method, function, hook, parameter, argument, and the distinctions
  students trip on. Has a blank [quiz version](anatomy-of-typescript-code-quiz.md). Useful from
  **React Lesson 3–4** and throughout the capstone.
- [Unit testing and mocking in C#](csharp-testing-examples.md) — **optional.** A small
  clone-and-read example (xUnit + Moq) showing test doubles on C# code that has real
  decisions and real external collaborators. The C# counterpart to the Vitest testing in
  **React Lessons 17–20**, with a Vitest-to-xUnit translation table. Two branches: the
  library alone, and the same code inside a Web API.
- [C# naming conventions](csharp-naming-conventions.md) — the PascalCase / camelCase /
  `_field` rules, and how casing hints at what a token is. Pairs with Anatomy of C# Code.
- [TypeScript / React naming conventions](typescript-naming-conventions.md) — the
  PascalCase / camelCase / `I`-prefix / `use`-hook / `on`-prop rules, casing-as-a-clue, and
  the **three flips from C#** (methods and properties go camelCase; interfaces keep `I`).
  Pairs with Anatomy of TypeScript Code; useful from **React Lesson 3** and the capstone.

## Assessment reviews

Study guides for the multiple-choice assessments: a checklist to work through first, then an
example and a reference link for every item. They revise material you've already built with
— nothing here is new.

- [HTML, CSS & JavaScript](html-css-js-assessment-review.md) — global vs. element-specific
  attributes, void elements, `display` and the ways to put elements side-by-side, `==` vs.
  `===`, the four kinds of loop, anonymous functions, and reading an `<input>` with `.value`.
- [React](react-assessment-review.md) — what a component is and why it's PascalCase, props,
  the `useState` shape, `useEffect`'s dependency array, conditional rendering, `key`,
  controlled vs. uncontrolled inputs, and what React Hook Form's `useForm` returns.

## images/

Diagrams and infographics embedded by the cheat sheets and lesson guides. See
`images/README.md` for the exact filenames each document expects.
