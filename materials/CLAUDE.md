# Concept Materials — Claude Code Context

This directory contains the lesson materials for the back half of the
TQL Software Development Academy bootcamp. Read this before creating,
editing, or extending any guide or lab file.

## Key documents
- **Curriculum plan**: `code-academy/planning/full-curriculum-plan.md` —
  authoritative source for lesson-by-lesson topics, TableServe→PRS pattern mapping,
  named exceptions, and the overall teaching model. Read this before writing
  any new guide or lab to ensure the content matches the planned sequence.
- **Root CLAUDE.md**: `code-academy/CLAUDE.md` — repo-wide conventions
  including file naming (guide vs. lab prefixes, lesson numbering, kebab-case
  filenames).

---

## README.md conventions

Every concept subdirectory (`api/`, `html-css/`, `react/`) must have a
`README.md` that acts as a navigation hub for students. Update the README
every time a new guide or lab file is added.

### README structure
Each README should follow this exact shape (see `api/README.md` as the
canonical example):

```markdown
# {Pass Name} Concepts — Lesson Materials

This folder contains the lesson materials for the {pass description}.

## File types

**`lesson-{N}-guide-*.md`** — concept reference (I do)...

**`lesson-{N}-lab-*.md`** — hands-on exercise (You do)...

## Schedule

| Lesson | Guide | Lab |
|--------|-------|-----|
| 1 | [Topic description](lesson-01-guide-*.md) | [Lab description](lesson-01-lab-*.md) |
| 2 | ... | ... |

## Stretch challenges

Short blurb: each lab ends with a stretch section; link the standalone
[Stretch challenges](stretch-{pass}-challenges.md) file for cross-cutting work.

## Tips

- Domain reminder (TableServe for api/html-css, TableServe→PRS for react)
- Password reminder if relevant
```

### Rules for README maintenance
- Link text in the schedule table should be the topic description, not the
  filename — e.g. `[Project setup, controllers, EF DbContext](lesson-01-guide-...)`,
  not `[lesson-01-guide-project-setup-crud.md](lesson-01-guide-...)`
- If a lab slot has no file yet (e.g. Lesson 6 API where capstone begins),
  use plain text in the Lab column, not a broken link
- Future guide/lab files that don't exist yet should appear as plain text
  in the table (no link) — add the link when the file is created
- The Tips section should remind students which domain they're working in
  and any other session-wide conventions (e.g. seed data password)
- The README must include a **Stretch challenges** section linking the folder's
  `stretch-{pass}-challenges.md` file (see **Stretch challenges** below); add the
  link when that file is created

---

## Terminology — no day- or time-based references

Materials are deliberately **decoupled from days, dates, and time-of-day**. The
academy's calendar shifts between cohorts, so nothing in a guide, lab, README, or
the curriculum plan should assume a specific day, a calendar date, or a part of
the day.

- **The unit of instruction is a "lesson."** Files are named
  `lesson-{NN}-guide-*.md` and `lesson-{NN}-lab-*.md`, where `{NN}` is the lesson
  number **zero-padded to two digits** (`lesson-01` … `lesson-15`) so files sort
  numerically; the schedule column in both the README and the curriculum plan is
  **Lesson**; cross-references read "Lesson N," never "Day N."
- **Guide ↔ lab is I do / You do**, never morning/afternoon. The guide is the
  I-do concept reference; the lab is the You-do independent exercise.
- **Banned words** (and their replacements):

  | Don't write | Write instead |
  |---|---|
  | today, in class | in this lesson |
  | Goal for today | Goal |
  | by the end of class / today | by the end of this lesson |
  | Today's Build Steps | Build Steps |
  | (what to take away today / this week) | (what to take away) |
  | this morning, the morning session | this lesson's guide / the guide |
  | this afternoon | this lesson's lab / the lab |
  | yesterday / yesterday's X | in the previous lesson / the previous lesson's X |
  | tomorrow | in the next lesson |
  | this week (the teaching pass) | this pass |
  | next week, next class (the applied PRS work) | in the capstone / during the capstone |
  | daily direction | regular instructor direction |
  | any calendar date (7/8, 8/25, "Wed 7/8 – Tue 7/21") | omit entirely |

- **Applied/capstone sections may state an estimated day count** (e.g.
  "(5 days, estimate)", "estimated 4 days") — but never a fixed date or date
  range. Concept-teaching sections count **lessons**, not days.

---

## Markdown formatting — wrapped list items

When a list item or a numbered build/verify step **wraps** onto a second line, make sure the
continuation line does **not start with `+ `, `- `, or `* `** (or `N. `). Markdown parses a
line beginning with one of those as a **new bullet**, so the tail of your sentence renders as
a stray sub-item instead of continuing the line. This bites most often with a `+` used as
"and": e.g. `(that's HMR\n   + React re-rendering)` renders "React re-rendering)" as its own
bullet. **Fix by rewording so the marker isn't at a line start** — `HMR + React` →
`HMR and React`; separate list-y items with commas/`and` rather than `+`.

---

## Directory structure

```
materials/
  index.md                             # docs-site landing page (front-matter title; links the 3 passes + capstone)
  downloads.md                         # docs-site downloads page (seed SQL, Insomnia collections, starter zips — GitHub links)
  api/
    README.md
    lesson-01-guide-web-architecture-http-insomnia.md   # intro/overview — no reference-app build
    lesson-01-lab-devtools-insomnia-exploration.md
    lesson-02-guide-project-setup-crud.md
    lesson-02-lab-categories-controller.md
    ...
    stretch-api-challenges.md          # cross-cutting stretch challenges (sorts last)
  html-css/
    README.md
    prework-html-css.md                # optional head-start packet for fast finishers (see Other materials below)
    lesson-01-guide-semantic-html-box-model.md          # intro/overview — raw HTML/CSS, plain files
    lesson-01-lab-staff-card.md
    lesson-02-guide-flexbox.md
    lesson-02-lab-card-grid-flexbox-froggy.md
    ...
    stretch-html-css-challenges.md
  react/
    README.md
    prework-react.md                   # optional head-start packet for fast finishers (see Other materials below)
    lesson-01-guide-javascript-for-csharp-devs.md
    lesson-01-lab-...
    ...
    stretch-react-challenges.md
  reference/                           # evergreen cheat sheets + shared images (cross-pass)
    README.md
    http-rest-status-codes.md
    insomnia-quickstart.md
    copilot-quickstart.md
    csharp-naming-conventions.md
    anatomy-of-csharp-code.md
    anatomy-of-csharp-code-quiz.md
    anatomy-of-typescript-code.md
    anatomy-of-typescript-code-quiz.md
    images/                            # diagrams/infographics; manifest in images/README.md
```

## Other materials (beyond guides and labs)

Alongside the per-lesson guides and labs, the materials tree carries a few
supporting files. They follow the same terminology rules (no day/time references)
but are **not** part of the guide→lab generation flow — a bulk "generate a pass"
run neither creates nor overwrites them. Maintain them by hand.

- **Docs-site pages** (`materials/` root) — `index.md` (site landing page) and
  `downloads.md` (the single place listing every seed SQL script, Insomnia
  collection, and starter zip, with GitHub links). Both carry YAML front-matter
  (`title:`) for the docs site. Update `index.md`'s pass/lesson table and
  `downloads.md`'s file list whenever passes or downloadable assets change.
- **Prework packets** — `html-css/prework-html-css.md` and
  `react/prework-react.md`: optional, ungraded head-start packets for students who
  finish the previous pass's capstone early. Each front-loads that pass's
  intro/overview lessons and ends with a mini-exercise against the student's own
  PRS work. There is intentionally **no API prework** (the API pass is first). Keep
  each in sync with the intro lessons it previews.
- **Extra reference cheat sheets** (`reference/`) — beyond the three cross-pass
  quickstarts, `csharp-naming-conventions.md`, `anatomy-of-csharp-code.md`, and its
  companion `anatomy-of-csharp-code-quiz.md` support the API pass; the parallel
  `anatomy-of-typescript-code.md` and `anatomy-of-typescript-code-quiz.md` support the
  React pass (same "name every token" exercise, on an interface / API module / component).
  Evergreen; linked from lessons and the `reference/README.md` manifest.

---

## File types and their purpose

### Guides (`lesson-{N}-guide-*.md`)
Concept reference (I do). Written for students to read alongside the
instructor-led session. Should include:
- A goal statement ("by the end of this lesson you will have...")
- A general pattern callout ("the general pattern you're learning is...")
- Numbered concept sections with code examples
- Seed data SQL where relevant so students have real data to verify against
- A detailed Insomnia/verification walkthrough (guides only, not labs)
- A "Build Steps" numbered list at the end — one step per discrete action
- A "The General Pattern" section before the build steps explicitly naming
  the transferable principle, not just the TableServe-specific mechanics

Guides serve both students who code along live AND students who watch and
catch up independently — the build steps section enables independent catch-up.

### Labs (`lesson-{N}-lab-*.md`)
Hands-on exercise (You do). Written to be terse — students have just seen
the concept in the guide and the I-do session. Should include:
- The entity/model being built (C# class with properties)
- Terse numbered steps (no explanatory prose)
- Seed SQL for that entity so Insomnia returns real data
- A brief Insomnia verification section referencing the specific folder name
  in the collection and expected responses
- A pointer back to the guide for Insomnia setup details (don't repeat them)
- A closing line reminding students this is the same pattern they'll repeat
  on PRS in the capstone
- A `## Stretch challenges` section at the very end (see **Stretch challenges**
  below) — only on lessons that actually have a lab

Labs do NOT repeat concept explanations from the guide. They are action lists.

---

## Teaching flow (I do / We do / You do)

```
Guide (I do):    Instructor builds a TableServe feature live
                 Students watch or code along — the guide supports both

Lab (You do):    Students build an analogous TableServe feature independently
                 Terse instructions, same pattern, different entity

Capstone (PRS):  Students build the PRS equivalent independently
                 TableServe serves as their reference — no new concepts introduced
```

The lab is always a simpler or parallel entity to what was demonstrated in the
guide. The entity should be different enough that students can't just
copy-paste, but close enough structurally that the same pattern applies.

---

## Intro / overview lessons (before the build)

A pass does **not** have to jump straight into building the TableServe reference app.
Each pass may open with **1–3 intro / overview / big-picture lessons** that establish
context and mental models first — architecture, fundamentals, tooling, the big picture —
before any reference-app code or markup is written. Going straight to the reference app
is *not* required.

Where each pass currently does this:

- **API** — Lesson 1: web app architecture (SPA/CSR), HTTP, REST/JSON, status codes, and
  an Insomnia tutorial — taught by observing real traffic before the first controller.
- **HTML/CSS** — Lessons 1–2: semantic HTML, the box model, and flexbox written **by
  hand** in plain files, before the Vite scaffold and Bootstrap.
- **React** — Lessons 1–2: **JavaScript, then TypeScript, for C# developers** — the
  language mapped onto what students already know from the API pass (`.map()`/LINQ, arrow
  functions, destructuring, spread, modules; then the C#→TS type system) — written and run
  in a throwaway **vanilla-ts Vite scratch project** and verified by observation (browser
  console / type errors), before the React build starts in Lesson 3.

Conventions for these lessons:

- They are the deliberate **exception** to "teach from the finished reference
  implementation" (next section) — there is usually no TableServe reference code or
  markup for them, so don't force one. State this in the guide so a later regeneration
  doesn't "correct" them back into building the app.
- **Verify by observation**, matched to the pass — browser DevTools, Insomnia against a
  public API, or hand-written throwaway files — rather than against `tableserve/`.
- They **may still have a lab** (a hands-on exploration or fundamentals exercise) or be
  guide-only; otherwise they follow the same guide/lab, README, and stretch conventions.
- They're still **lessons** — same `lesson-{N}-guide/lab-*.md` naming and "lesson"
  terminology (no "chapter," no day/time references).
- Supporting reference material (cheat sheets, diagrams) lives in `reference/` and
  `reference/images/`, linked from the lesson and the folder README.

---

## Reference implementations and verification

Each pass has a **finished reference implementation** — this is the ground truth for
the code or markup you teach. Read the actual files you're building and teach *those*
real patterns; never invent plausible-but-wrong code, markup, or class names.

| Pass | Reference implementation (ground truth) | Verify guides/labs in |
|---|---|---|
| API | `tableserve/TableServe.Api` (controllers, models, DbContext) | Insomnia |
| HTML/CSS | `tableserve/TableServe.Design` (finished `.html` pages, `partials/`, `css/styles.css`) | the browser (DevTools / console) |
| React | `tableserve/TableServe.Web` (components, hooks, routes) | the browser (DevTools / console) |

- **Match the verification tool to the pass.** A guide's verification section uses
  Insomnia for the API pass and the **browser** (open the page, check DevTools and the
  console) for the HTML/CSS and React passes. Don't carry Insomnia steps into the
  static or React passes.
- **The spec describes; the implementation shows.** For HTML/CSS especially, the spec
  (`spec/tableserve-design.md`) tells you *which* pages exist and defers exact
  markup to "the analogous page." The real markup lives only in
  `tableserve/TableServe.Design/` — read the specific page you're teaching before
  writing its guide.
- **Intro/overview lessons are the exception.** The 1–3 big-picture lessons that open a
  pass (see **Intro / overview lessons** above) have no reference-app code or markup to
  teach from — they precede the build on purpose. Verify them by observation, not
  against `tableserve/`.
- **Intentional guide/lab divergences from the reference — don't "correct" these back.**
  A few teaching choices deliberately differ from `tableserve/`:
  - **Card wrappers are `<div>` in guides and labs**, even though the reference
    implementations (`TableServe.Design`, `TableServe.Web`) wrap card identity blocks in
    `<address>`. A menu/staff card isn't contact info, so guides and labs teach `<div>`;
    `<address>` is reserved for a *real* address block (a stretch). The reference apps
    keep `<address>` and are **not** being changed to match.
  - **`OrderHeader` (React Lesson 8) takes a single `order` prop** — the guide's version reads
    `order.staff?.firstName` off the passed order. The reference `orders/OrderHeader.tsx` adds
    a redundant second `staff?: IStaff` prop and is called `<OrderHeader order={order}
    staff={order.staff} />`. The one-prop form is cleaner and self-consistent; teach it and
    **don't** "correct" it toward the reference's two-prop shape.
  - **`money(amount)` helper (React Lesson 10 §6)** — the guide lifts the repeated
    `Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(...)` into a
    `money` helper in `utility/formatUtilities.ts`, imported into `OrderDetailPage`. The
    reference **inlines** that call everywhere. The helper is a deliberate DRY teaching step
    (the Order Item form teaches the inline call first in §4; §6 refactors it into `money`) —
    keep it; don't "correct" it back to inline to match the reference.

### HTML/CSS by-hand lessons (Lessons 1–2) — workflow conventions

The pre-Bootstrap "by hand" lessons follow a specific teaching workflow; keep it when
editing or regenerating them:

- **Preview with VS Code's Live Server extension**, not a `file://` double-click, so saves
  auto-reload.
- **Give Emmet hints for markup** — `!` / `html:5` for the HTML5 boilerplate, `link:css`
  for the stylesheet link, and `tag.class` / `tag#id` (e.g. `div.card`) for elements. Note
  that you type the tag name without angle brackets and press Tab, and link the
  [Emmet cheat sheet](https://docs.emmet.io/cheat-sheet/).
- **Hand out CSS incrementally**, not as one paste-the-whole-file block: build the example
  up in small "add this, save, look" passes (a `▶ Save and look` cue) so students see each
  rule take effect.

### HTML/CSS guides (all lessons) — the `▶ Code along` convention

Every guide in the HTML/CSS pass (Lessons 1–5, hand-written and Bootstrap alike) uses one
signposting convention so students know when to type versus when to just read:

- A **"How to use this guide"** blockquote near the top (after the goal + general pattern)
  explaining the marker.
- **`▶ Code along`** prefixed on the `## N. …` header of any section whose body the student
  builds into their files — e.g. `## 6. ▶ Code along — the page shell`. Concept, decision,
  reference-table, and verification sections stay unmarked. Build-heavy lessons (4–5) mark
  most sections; concept-heavy ones (1–2) mark only their one or two build sections.
- **Each `▶ Code along` section ends with a quick check** — a one-line "save and you should
  see X" so a mistake surfaces immediately, not only at the end. When a piece isn't visible
  on its own yet (a component not wired in until later), say so honestly. The lesson's final
  *Verifying …* section still does the full pass. (Full rationale and examples: **React pass
  — authoring lessons** → principle 7, below. The bulleted **`Save and check`** format defined
  there is **React-pass-only for now** — html-css guides keep their one-line checks until
  that pass is swept.)

> **Also piloted in React Lesson 3.** `react/lesson-03-guide-components-jsx-typescript.md`
> now uses this same `▶ Code along` convention and the "How to use this guide" blockquote,
> and additionally **labels each code block with its target file as a code-block `title=`**
> (`` ```tsx title="src/menuItems/IMenuItem.ts" ``). It also teaches **mechanics first, styling second**
> (plain JSX, then a Bootstrap pass) and renders **one card before the `.map()` list**,
> with a ✅ checkpoint at the single-card stage. **Decision:** these are now adopted across
> the React **build** lessons (Lessons 3+) — don't strip them on a regeneration. The full
> set is in **React pass — authoring lessons (from delivering Lesson 3)** below.

## React pass — authoring lessons (from delivering Lesson 3)

Surfaced by teaching **React Lesson 3** live and reworking its guide + lab. They apply to
**every remaining React build lesson (3–16)** — carry them through when writing or reworking
any React guide/lab. Several generalize to the other passes too; treat them as React-first,
not React-only.

### Code-block checklist — run this on EVERY code block before finalizing

Guide reviews keep surfacing the **same handful of misses**. Before a guide code block is
done, verify all of these (principles 1–9 below give the full rationale and worked examples —
this is the fast pre-flight):

1. **Title.** The fence carries `title="src/…"`. *Exception:* a cross-file **concept** snippet
   that illustrates an idea rather than "add this here now" stays plain — no title, no diff.
   Never a `// path` comment inside the fence.
2. **Create → full block; modify → `diff`.** A file is *existing* (→ diff) if it was created in
   an earlier section, an earlier lesson, **or handed over as provided scaffold**
   (`Header`/`AppNav` from Lesson 5). If you're about to reprint a whole existing file to change
   a few lines, stop and write a diff.
3. **Placement is unambiguous.** A diff shows the enclosing `function`/object/`return` with
   `...` for untouched code. JSX fields diff into a `return` **that already exists** — if the
   component has no shell yet, an *earlier* block must build the `<form>`/card/table first.
4. **Nothing the student must type is missing.** Show every **import** (new file: the full
   list; modify: `+` the added ones), every **field/element** (no "…other inputs", no "see the
   static page" hand-off for react-wired markup), and every **sibling** a step introduces (all
   three of `startPreparing`/`markReady`/`markServed`, not one + prose). `...` is only ever code
   shown elsewhere or genuinely unchanged — **never** code the reader still has to write.
5. **Dependencies exist first.** Everything the block references is already defined: the API
   method before the handler that calls it, `useForm` before JSX using `register`, a helper
   before its first use, a component before the route that renders it, and **an interface
   property before code reads it off the typed object** (`order.orderItems` needs `orderItems`
   on `IOrder`; `menuItem.category` needs it on `IMenuItem`) — extend the interface in a diff
   *before* the usage. An unavoidable forward reference (view-first) must be **flagged in the
   Save-and-check** ("your editor flags X as *not defined* until section N"). If the missing
   piece stops the **whole app compiling** (e.g. the router imports a page you build two
   sections later), never leave a can't-happen "open the page and…" check. **Prefer a one-line
   placeholder/stub** for the missing file so the section stays runnable (replace it for real
   in the later section); or, if a stub doesn't fit, say plainly "the app won't compile until
   §N" and move the *runnable* check to the section where it can actually run. (Lesson 11 §2
   stubs `SignInPage` so its router change runs; §3 replaces it with the real form.)
6. **Identifiers are current.** Every name matches the latest decision (`openCancel`, not a
   since-renamed `handleShowCancelModal`). After any rename, grep the whole pass.

Two section-level checks belong here too:

7. **A new concept gets a "read this" explanation before its first code-along** (principle 4).
8. **Verification isn't hoarded at the end** — every ▶ section ends with a **`Save and check`**
   (bulleted when there's more than one observable, inline when there's one — see principle 7),
   and a feature is made runnable as soon as its dependencies allow, not only in a final section.

---

1. **Signpost code-along vs. read.** Every React build lesson (3+) marks build-section
   headers with **`▶ Code along`**, leaves concept/orientation/verification sections
   unmarked, opens with a "How to use this guide" blockquote, and **labels each code block
   with its target file as a code-block `title=`** (`` ```tsx title="src/menuItems/IMenuItem.ts" ``
   — see principle 8; **not** a `// path` comment inside the fence). (Intro Lessons 1–2 keep
   their `▶ Try it` scratch-project convention.) See the ▶ Code along note under *Reference
   implementations and verification*.

2. **Code-along steps are literal and complete — assume nothing.** Spell out every action a
   live coder takes: creating files, **deleting scaffold boilerplate** (Vite's demo
   `App.tsx`; emptying `App.css`/`index.css`), and every import that changes. When a snippet
   replaces a whole file, say "replace the whole file with this." A student coding along
   can't fill gaps you leave implicit.

3. **Minimize Bootstrap up front; borrow the design's classes when you add them.** Teach the
   React mechanics on plain (or barely-classed) markup first, then a **separate styling
   pass**. When you add classes, frame them as the ones students already wrote in the
   HTML/CSS pass and point at the finished design
   (`github.com/craigmckeachie/tableserve-design`) so they read as recognition, not new
   material. The React **teaching** lessons hand students finished components — **Lesson 5
   provides `Header.tsx`/`AppNav.tsx`** (like the static pass handed over the partials), so
   there's no HTML→JSX conversion there. The real "convert HTML → JSX (with a helper)" moment
   is the **PRS capstone** (students convert their own static pages); introduce the tool at
   the capstone bridge, not the teaching lessons (see the `html-to-jsx-at-capstone` memory).
   Interactive Bootstrap (dropdowns, modals) is rebuilt as react-bootstrap by hand, not
   machine-converted. **Flag the SVG-icon gotcha wherever icons
   convert** (Lesson 5's logo/nav icons, the 3-dots dropdowns from Lesson 6 on): SVG
   attributes go camelCase (`class`→`className`, `stroke-width`→`strokeWidth`), and the
   Bootstrap Icons sprite must be **imported**
   (`import bootstrapIcons from "./assets/bootstrap-icons.svg"`) and referenced with
   **`xlinkHref`** on `<use>` (the imported URL + `#icon-id`) — *not* the design's
   `<use href="/assets/…">`. The html-to-jsx tool handles the attribute camelCasing but
   **not** the sprite `import` (a module/build step) — that part is always by hand.

4. **Explain every new React concept at first use.** The instant new syntax/idiom appears,
   stop and explain it — e.g. the `.map()` arrow shapes `=> ( )` vs `=> { }`, the
   `style={{ }}` double-brace + camelCase-vs-CSS, `key`, default vs named exports,
   `useState`/`useEffect`. Don't let a new concept ride unremarked inside a bigger snippet.

5. **Split freely — don't cram; there's schedule slack.** If a lesson conflates too much
   (setup + concepts + build), split it or add a lab rather than overload one guide. Cohorts
   have been moving roughly **one lesson (guide+lab) per half-day** and finishing the
   capstones **well ahead**, so extra, smaller lessons are affordable. **Prefer splitting
   content into clearly-marked parts with a ✅ checkpoint over renumbering** — lesson numbers
   are referenced across guides, the curriculum plan, and the Kahoot quizzes
   (`tooling/quizzes/`), so a renumber has wide blast radius. Renumber only if a true split
   is unavoidable. (Specific cohort dates/pacing live in session memory, not here — they
   shift per cohort.)

6. **Labs mirror the guide's build arc, and hand over data that isn't the point.** A lab is
   the *You do* of the guide's *I do* — give it the **same sequence and ✅ checkpoint** on a
   **parallel entity** (Staff for Menu Items), not a different shape. And provide any
   **starter data as a ready snippet** (a hardcoded `IStaff[]`, seed rows) when typing it
   out isn't the skill being practiced — students should spend effort on the concept
   (`.map()`, the badges, the fetch), not on inventing data. (The Lesson 3 lab hands over a
   5-member `IStaff[]` and is built one-card → list → badges → styling, matching the guide.)

7. **Each ▶ Code along section ends with a `Save and check`.** After a build step, tell
   students what to do and see to confirm it worked, so a mistake surfaces immediately rather
   than only at the end. When a piece isn't visible on its own yet (a component not wired in
   until a later section), say so honestly ("nothing on screen yet — it renders once `Layout`
   wraps it; confirm no editor errors"). The final **Verifying in the browser** section still
   does the full pass; the per-section checks are the incremental confirmations along the way.

   **Format — never a run-on sentence.** Multiple checks chained with semicolons and arrows
   are unreadable at the keyboard. So:
   - **Two or more observables → a bulleted list.** The bold label **`Save and check`** sits on
     its own line (no colon), followed by a blank line and **2–5 bullets**. Each bullet is
     **one action — one observable**, phrased *do this — see that*, em dash between, with the
     thing to look for in **bold**. Never chain two actions into one bullet.
   - **A single observable → stays inline** as `**Save and check:** …`. A one-bullet list is
     noise, and these often run straight into teaching prose that explains what was just seen.
   - **Deferred verification goes in one trailing italic line**, after a blank line, not in the
     bullets: *"Not yet: the signed-**in** → `/orders` redirect — you'll see that in §3."*
     This is also where a **flagged transient error** goes when a section teaches view-first
     (principle 9).
   - The label is always **`Save and check`** — not "Check", not "Quick check".

   **Lesson 11 is the worked example**; Lessons 5–10 and 12 follow it.

8. **Label every code block with a `title=`, and show *where* edited code goes — full block to
   create, `diff` to modify.** The file name goes in a **Material for MkDocs code-block title**
   on the fence line — `` ```tsx title="src/menuItems/IMenuItem.ts" `` — which renders as a
   header bar fused to the top of the block. **Not** a `// path` comment inside the fence (the
   old style; don't reintroduce it). `title=` works via `pymdownx.superfences` (in
   `mkdocs.yml`) and, unlike a `####` heading, doesn't pollute the right-rail TOC. A code block
   that **creates a new file** is shown whole under its `title=`. A code block that **modifies
   an existing file** — adds a method to an API object, a handler/state to a component, JSX to a
   `return` — is shown as a **`diff` fence** (`` ```diff title="…" ``) so a student coding along
   knows exactly where the new lines nest, without re-printing the whole file. Every such diff:
   - **shows the enclosing function or object** you're editing — `function OrderDetailPage() {`,
     `export const orderAPI = {` — so "what am I inside of?" is never a guess (for a
     module-scope addition like an `interface`, show the neighbouring `...  // imports` and the
     component instead, since it isn't inside a function);
   - **elides untouched code with `...`** — a short `// what's here` note is fine in JS/TS
     statement positions; use a bare `...` inside JSX;
   - marks **added lines with `+`** (removed with `-`), indented to their real nesting.

   Two clarifications that keep getting missed. **(a) A file is "existing" — modify it with a
   diff, don't reprint it whole — if it was built in an earlier section, an earlier lesson, or
   handed over as provided scaffold** (`Header`/`AppNav` from Lesson 5). Adding three lines to a
   provided component is a `diff`, not a fresh full block. **(b) A block that adds JSX
   fields/elements needs the component's `return` shell to already exist** — build the
   `<form>`/card/table in an earlier block so each field diffs into a real place; never nest a
   field into a `return ( ... )` that hasn't been created yet. (Lesson 10 §1 builds the
   `OrderItemForm` shell before §2–§4 drop fields in; Lesson 11 §4's `Header` is a diff over the
   Lesson-5 provided component.)

   Genuine *code* comments (`// plain string, not { reason: … }`) stay; only the file-path
   banner moves to the `title=`. Concept/"(Read this.)" snippets that illustrate an idea across
   files (not "add this to one file now") stay plain — no `title=`, don't diff them.
   **Temporary / throwaway code** the student will remove later (a debug `<pre>`, a scratch
   `console.log`, a swapped-in `useForm` for a demo) is shown NOT as a diff but by **commenting
   out the original and pasting the replacement below it** — with `// added:` notes on the new
   pieces and `...` for the enclosing context — so reverting is just "delete this, uncomment
   that." (Worked example: the L7 §3 *optional debug-view* step.)
   **Lesson 9 is the worked example** of the diff shape — every build block in §2–§4 uses it;
   match it when reworking other lessons.

9. **Order code blocks so each compiles when added — dependency before dependent.** A student
   pastes snippets top to bottom, so every step should type-check on its own. Put the thing
   being *called* before the code that calls it: the **API method before the handler** that
   invokes it, the **interface before the `useForm<T>`** that uses it, a **helper before its
   first use**. Don't show a handler that references `orderAPI.cancel` and only add `cancel` to
   the module three blocks later — that's a "property does not exist" error while typing along.
   Also **show every sibling a step introduces** — if a section adds `startPreparing`,
   `markReady`, and `markServed`, show all three, not one with the others described in prose.
   **Exception — deliberate view-first teaching:** a lesson may show the JSX (buttons, a table)
   that wires up handlers *before* the handlers exist when that wiring is the concept being
   taught (Lesson 9 §2's status-driven buttons; Lesson 10 §6's items table). When you do,
   **flag the transient error in the Save-and-check** ("your editor will flag these as *not
   defined* until section 3") so it reads as expected, not a mistake. **Lesson 9 §3–§4 are the
   worked examples:** the `OrderAPI` workflow methods come before the handlers that call them,
   and the `cancel` method before the `saveCancel` that calls it.

The reworked **Lesson 3–5 guides** (and the L3/L4 labs) are the worked examples of principles
1–7; **Lesson 9** is the worked example of principles 8 and 9 (the diff shape, and
dependency-first code-block ordering) — use them as the template when writing new React
material. **All React lessons
1–16 have now been reworked to these principles** (guides + labs, plus the L13–15 review/
bridge lessons and the L16 Copilot tooling lesson), so any React guide/lab is a valid model;
match whichever is closest in shape to what you're writing. A few lesson-specific decisions
worth preserving on regeneration: the **items table + delete-confirm modal live entirely in
Lesson 10** (the OrderItem child-collection unit) — **Lesson 9 builds only the status buttons +
Cancel modal** and merely notes that the delete modal comes in L10 (it does not preview it);
L10 reuses L9's state-driven `Modal` *pattern* for the delete confirmation. Every API module
uses **plain `fetch` until
Lesson 12**, which introduces the shared `fetchUtilities` (`checkStatus`/`parseJSON`) and
retrofits all modules at once (Lesson 11's `findByAccount` uses an inline
`if (!response.ok) throw` guard in the interim). The **html-to-jsx tool** intro lives in the
**Lesson 15 capstone bridge**, not the teaching lessons.

**Categories is student-built, not provided** (the whole app is built from a blank project — no
shared completed code beyond the guides/labs). Its module grows **incrementally**: `list` (L7
guide, for the Menu Item FK dropdown) → `find` (L8 lab) → `delete` (L9 lab) → `post`/`put` (L10
lab); L7 also extends `IMenuItem` with `categoryId` + `category` (deferred in L3), so create
`ICategory` + `CategoryAPI` **before** editing `IMenuItem` (it imports `ICategory`). **Lessons
9–11 guides are worked examples but each now has a lab that builds out the rest of TableServe**
so students finish with a complete reference app: **Categories list** (L9), **Categories
create/edit form** (L10), and the **Order create/edit form** (L11 — applies the guide's Context
to pre-fill + disable the Staff dropdown; also re-adds the order Add/Edit affordances). The
Categories labs are deliberately **terse** (students transfer their Menu Items / Staff code).
**Role-gating** maintenance behind `isAdmin` is an **L11-lab stretch**. **Lesson 13** is a
feature-folder *review of the app students built* (not a walkthrough of provided code). **L15**'s
PRS "Request Create/Edit" reference points at the **Order form**.

**`verbatimModuleSyntax` is turned OFF (Lesson 3 setup).** Current Vite's `react-ts` template
scaffolds `tsconfig.app.json` with `"verbatimModuleSyntax": true`, which would force
`import type { … }` for every interface import. The L3 setup step sets it to **`false`** so all
guides/labs use a **plain `import { IMenuItem }`** for interfaces — matching the reference app
(`TableServe.Web`, which predates the flag and uses plain imports). **Do not** rewrite the
guide/lab imports to `import type`, and don't drop the tsconfig step — keeping the flag off is
the intentional choice (minimize incidental complexity; one config line beats `import type`
noise on ~40 imports). Copilot/agent-mode output will use `import type`; that's a fine triage
example, not a house-style correction to adopt.

---

## Generating a whole pass (bulk runs)

When asked to generate every guide/lab for a pass at once, **begin by stating the
per-lesson guide→lab entity mapping** you'll use — which TableServe entity each lab
builds — and explicitly call out any lab where the curriculum lists **no "We do"**
(e.g. HTML/CSS Lesson 5, or React worked-example lessons), since you must choose a
parallel entity there. Ask before generating only if a mapping is genuinely
ambiguous; otherwise proceed. This surfaces the biggest judgment call before you
commit many files to it. Also account for the pass's **intro/overview lessons** (see
**Intro / overview lessons** above): they don't build a TableServe entity, so they have
no guide→lab entity mapping — flag them as intro/overview (verified by observation),
not as a build lesson missing a mapping.

---

## Stretch challenges

Fast finishers get optional, off-the-critical-path work so they stay engaged
without pulling the rest of the cohort forward. Stretch challenges live in two
places, and **both are produced as part of the normal guide/lab generation task**:

1. **Per-lab section** — every lab that exists ends with a `## Stretch challenges`
   section of 2–4 short bullets tied to that lesson's concept. Lessons with **no
   lab** (e.g. API Lesson 6 where the capstone begins, or React worked-example-only
   lessons) get **no** stretch section.
2. **One standalone file per concept folder** — `stretch-{pass}-challenges.md`
   (`stretch-api-challenges.md`, `stretch-html-css-challenges.md`,
   `stretch-react-challenges.md`). It holds the bigger, cross-cutting challenges
   that span the whole pass — an extra controller/entity, pagination, AI-assisted
   seed data, and so on. Generate or refresh it when building a whole pass, link it
   from the folder README, and point to it from each lab's stretch section. The
   `stretch-` prefix makes it sort below the `lesson-*` files.

### Conventions for both

- **Not required for the capstone.** Say so plainly at the top of the standalone
  file and in each lab section ("Optional — for when you finish early. Not needed
  for the capstone.").
- **Tag every item** `[Reinforce]` or `[Reach]`:
  - `[Reinforce]` extends something a guide already showed — no new concept.
  - `[Reach]` goes past the guides — say so explicitly ("not covered in the
    guide — you'll need to research it") and give **one reference link**.
- **Reach links must be verified.** Fetch the URL and confirm it resolves before
  including it. Prefer official docs (Microsoft Learn for the API pass; MDN and
  official library docs for html-css and react). If no clean built-in or
  annotation exists for what you're asking (e.g. EF Core ignores `[DefaultValue]`
  for schema defaults), say so and lead students to the real approach rather than
  inventing one.
- **Verified the same way as the pass** — API challenges are confirmed in Insomnia
  (add a request, hit the endpoint); html-css and react challenges are confirmed in
  the browser. Don't introduce a new verification mechanism.
- **Migrations reminder** — any API challenge that adds or changes a model property
  must remind students to `Add-Migration` and `Update-Database`, and to set a
  sensible column default when adding a non-nullable column to a table that already
  has rows.
- **Respect the intentional simplifications** — a stretch challenge must never push
  students toward `[Authorize]`, JWT, DTOs, the repository pattern, or a tighter
  CORS policy (see **Known intentional simplifications**).
- **Same terminology rules apply** — no day/time references; "lesson," "guide,"
  "lab," and "capstone" only.

---

## AI-assisted development (GitHub Copilot)

GitHub Copilot — **TQL's preferred AI assistant** — is woven through the curriculum, not
bolted on. Keep these facts straight when editing or regenerating any Copilot material:

- **Cheat sheet.** `reference/copilot-quickstart.md` is the evergreen, cross-pass reference
  (the three surfaces, set-up per editor, the verify-don't-trust discipline, the house-style
  watch-list, and how to hand Copilot files). Every Copilot lesson/stretch links to it; keep
  it editor-neutral except where it deliberately contrasts Visual Studio vs. VS Code.
- **Two required lessons, sequenced review-before-generate:**
  - **API Lesson 7** (`api/lesson-07-guide-copilot-code-review.md` + lab) — code **review**:
    attach a controller to Copilot Chat and *triage* its suggestions (accept real bugs /
    reject house-style violations / ignore noise). Guide demos on TableServe; lab reviews the
    student's **PRS backend capstone**.
  - **React Lesson 16** (`react/lesson-16-guide-building-with-copilot.md` + lab) — code
    **generation**: autocomplete → Chat → agent mode, audited against house style. Lab
    generates a Staff feature; a capstone stretch (challenge #8 in
    `stretch-react-challenges.md`) builds a PRS feature with agent mode against a rubric.
- **Pass 2 (HTML/CSS) is intentionally stretch-only** — no required Copilot lesson (it would
  undercut the hand-building focus). Copilot appears there as challenges #7–#8 in
  `stretch-html-css-challenges.md` (generate-and-audit markup; review your markup).
- **These are intro/overview-style tooling lessons** — verified by **observation and
  judgment** (reading/triaging Copilot's output), matched to each pass's tool for any code
  actually changed (Insomnia for API, browser/DevTools for HTML/CSS and React). They are not
  built against `tableserve/`; state this so a regeneration doesn't turn them into entity
  builds.
- **Carve-out to the "respect the intentional simplifications" stretch rule:** Copilot
  materials deliberately *surface* the banned patterns (DTOs, `[Authorize]`/JWT, the
  repository pattern, `EntityState.Modified`, the Bootstrap `row`/`col` grid, CDN links) **so
  students reject them with a reason.** That is the opposite of *pushing students toward*
  them and is allowed — do not "correct" a Copilot challenge for naming these. A Copilot
  challenge must still never tell a student to *adopt* one.

---

## TableServe → PRS pattern mapping

Every concept taught on TableServe maps directly to a PRS equivalent. When
writing guides and labs, make these connections explicit so students understand
what they're rehearsing.

| TableServe (taught) | PRS (applied independently) | Pattern rehearsed |
|---|---|---|
| Staff | Users | Simple CRUD, no FK, bcrypt password, role flags |
| Categories | Vendors | Simple reference entity, own CRUD screen |
| MenuItems | Products | CRUD with FK dropdown (CategoryId → VendorId) |
| Orders | Requests | Workflow entity, status, computed total, FK to user |
| OrderItems | RequestLines | Child-collection CRUD, computed Amount, parent total recalculation |
| Order Cancel (branch + reason) | Request Reject (branch + reason) | Non-CRUD endpoint, plain string body |
| Order status advance endpoints | Request review/approve endpoints | Custom workflow endpoints |
| Staff IsManager / IsAdmin | User IsReviewer / IsAdmin | Role-based conditional UI |

### Named exceptions (NOT rehearsed in TableServe — taught directly on PRS)
These patterns have no TableServe equivalent and should be called out explicitly
when they appear in PRS guides or capstone directions:

1. **Dual-role FK** — PRS Request has both a submitter (`UserId`) and an implied
   reviewer role via `IsReviewer`. No TableServe equivalent.
2. **$50 auto-approve rule** — Review endpoint auto-approves if `Total <= 50`.
   No TableServe equivalent.
3. **Avatar-circle-with-initials** — User card UI pattern. Left for students
   to solve independently during the PRS capstone. This applies to the TableServe
   teaching materials too: even though the reference `staff.html` shows the avatar,
   **don't spell out its markup** in a Staff guide or lab — present it as a
   self-discovery **stretch challenge** instead.

---

## Auth and security decisions

### How authentication actually works

**There is no JWT in this application.** The login endpoint returns the full
User object as JSON. The front end parses it, strips the password field, and
stores the remaining user object in `localStorage`. A user is considered
signed in if the user object in context is not null. That's the entire auth
model.

```
POST /api/users/login  →  { id, username, firstName, lastName, ... }
                          (password field stripped before storing)
Front end stores in localStorage → sets UserContext
Signed in = user object is not null
Signed out = user object is null / cleared from localStorage
```

Role-based permissions are enforced **client-side only** using boolean flags
on the User object:
- `IsReviewer` — Approve and Reject buttons are shown/enabled only for
  reviewers. Additionally, a reviewer may not approve/reject their own request
  — buttons are disabled when `request.userId === currentUser.id`
- `IsAdmin` — CRUD maintenance pages (Vendors, Products, Users) are accessible
  only to admins

**There is no server-side authorization enforcement.** This is a deliberate
teaching simplification — the API endpoints are wide open. Do not add
`[Authorize]` attributes, JWT middleware, or token validation. The learning
objective is understanding the auth flow at a conceptual level, not
implementing production-grade security.

### ⚠️ Do NOT add any of the following
- `[Authorize]` attributes on controllers or actions
- JWT bearer token middleware in `Program.cs`
- Token storage or validation of any kind on the back end
- Tighter CORS policy

These omissions are intentional. Do not "fix" them.

### BCrypt password hashing
Passwords ARE hashed with BCrypt (`BCrypt.Net-Next` package). This is the one
security practice that IS taught because:
- It's simple to use (one method call)
- The consequences of skipping it are easy to demonstrate (plain text in the DB)
- The login endpoint uses it to verify the entered password against the stored hash

All seed data uses the same BCrypt hash — plaintext is `test1234`. Students
are told this explicitly so they can log in during testing.

---

## Code conventions for guide/lab examples

When writing C# code examples in guides and labs, follow these conventions
from the established PRS.Api patterns. Consistency across examples matters
because students will use earlier guides as models when writing later code.

### Naming
- Controller action methods: `GetAll`, `GetById`, `Create`, `Update`, `Delete`
  — verb-based, RCUD order, entity name never repeated in the method name
- DbContext field: `_db` of type `TableServeDbContext` (or `PrsDbContext`)
- Lambda parameters: descriptive, not `x` — e.g. `staff`, `order`, `menuItem`
- PUT parameter naming:
  - Incoming body: `updatedStaff`, `updatedOrder` etc.
  - Database-fetched entity: `currentStaff`, `currentOrder` etc.
- POST parameter naming: `newStaff`, `newOrder` etc.
- Re-fetched entity with nav properties: `staffWithOrders`, `orderWithItems` etc.

### Models
- Required strings: `string PropertyName { get; set; } = string.Empty;`
- Optional strings: `string? PropertyName { get; set; }`
- No `virtual` on navigation properties — lazy loading is not configured
- Navigation properties always explicitly `Include()`d — never assumed

### Controllers
- PUT pattern: fetch-then-set using `_db.Entry(current).CurrentValues.SetValues(updated)`
- Never use `EntityState.Modified`
- Existence confirmed by fetch before save — no `EntityExists()` helper methods
- POST and PUT return the full entity with navigation properties (200/201 with body)
- Status constants in a static class, never magic strings:
  - TableServe: `OrderStatus.Placed`, `OrderStatus.Cancelled` etc.
  - PRS: `RequestStatus.New`, `RequestStatus.Approved` etc.

### HTTP response conventions
| Verb | Success | Not Found | Bad Request |
|------|---------|-----------|-------------|
| GET | 200 OK | 404 | — |
| POST | 201 Created | — | — |
| PUT | 200 OK + body | 404 | 400 |
| DELETE | 204 No Content | 404 | — |

### Known intentional simplifications (do not "fix" these)
- No DTOs — models used directly in controllers
- No repository pattern — DbContext injected directly
- CORS wide open
- No `[Authorize]` on controllers
- No JWT — login returns a User object, stored in localStorage, null-check
  determines signed-in state, role flags on User object for conditional UI

---

## Insomnia collection conventions

The TableServe Insomnia collection (`tableserve-insomnia.json`) has:
- An **Auth** folder with a Login request that verifies credentials and returns
  the full Staff object. There is no token — nothing is stored or carried
  forward, and no other request depends on having logged in.
- One folder per entity matching the guide/lab structure
- After-response tests on every request checking status codes and response
  structure — never specific field values or row counts
- `baseUrl` environment variable (no `authToken` — there is no JWT)
- Login is **optional**: because every endpoint is open, students never need to
  log in before calling other requests. It's only there to confirm credentials
  and show the Staff object shape.

When writing guide verification sections, always:
- Reference the specific **folder name** in the collection (e.g. "expand the
  **Staff** folder") rather than describing raw HTTP requests
- Reference the specific **request name** (e.g. "run **Get All Staff**")
- Remind students to check the **Tests** tab for green/red pass/fail indicators
- Do NOT tell students to "run Login first" as a prerequisite — the endpoints are
  open. Note that no login is required when introducing the verification steps.
- Include troubleshooting notes for connection errors (there is no auth, so no
  401 Unauthorized to worry about)
- Put full Insomnia setup instructions (import, baseUrl) in the guide only —
  labs reference back to the guide rather than repeating setup steps
