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

- **The ban targets *scheduling* language, not every use of the words.** What it exists to
  prevent is a lesson assuming the academy calendar — "we'll cover this tomorrow," "by the end of
  today." Three uses in `team-project/` are deliberate and **reviewed as keepers**; don't
  "correct" them:

  | Where | Text | Why it stays |
  |---|---|---|
  | `team-charter.md` | "Stand up for five minutes **each morning**" | A daily standup is a real practice with a real time of day — it's describing the team's ritual, not the course schedule |
  | `lesson-01-guide-…` | "break everyone else's **afternoon**" | Figurative — the cost of breaking `main`, not a session reference |
  | `lesson-01-guide-…` | "a team stalls on the first **morning**" | Describing when a real failure bites, in the repo-owner setup box |

  The test to apply: **is it telling a student when something happens in the course?** If yes,
  reword it. If it's idiom, or a description of the team's own working rhythm, leave it.

---

## Markdown rendering — what the docs site supports, and two gotchas

The site is Material for MkDocs, so guides can use more than plain Markdown. Extensions
already enabled in `academy-resources/mkdocs.yml` — use them, don't hand-roll substitutes:

- **`admonition`** — `!!! warning "Title"` / `!!! note` / `!!! tip` callout boxes. **The body
  must be indented 4 spaces**, blank line after the title. This is how "Your turn" repeat-work
  instructions are marked (React principle 10).
- **`pymdownx.tasklist`** (with `custom_checkbox`) — `- [ ]` renders as a real checkbox. Used
  for the "Your turn" file lists, the L13 review checklist, and the prework packets. The
  unchecked box is restyled in `materials/stylesheets/extra.css`; Material's default is 7%
  black and effectively invisible, especially inside a tinted admonition.
- **`pymdownx.details`** (`??? note` collapsibles), **`pymdownx.tabbed`**, **`attr_list`**,
  **`tables`**, and **`pymdownx.superfences`** (which is what makes code-block `title=` work).

**Gotcha 1 — a list needs a blank line before it.** Python-Markdown swallows a list that
follows a paragraph line directly:

```markdown
Settings to choose:          ← no blank line…
- Framework: .NET 8          ← …so this renders as literal text in that paragraph
```

It renders as one run-on paragraph with visible `- ` characters, and it is invisible in the
source — you only see it on the built site. Always leave a blank line between a lead-in
sentence (or a bold `**Label**`) and the list under it. This had silently broken eight lists
across the API, HTML/CSS, and reference pages before it was caught.

**Gotcha 2 — see the wrapped-list rule below.**

**Gotcha 3 — inside a list item, indent EVERYTHING 4 spaces, not 3.** A numbered item's
marker (`1. `) is three characters wide, so it's natural to indent its continuation content
three spaces. Python-Markdown wants **four**, and mixing the two silently breaks admonitions
nested in list items — they render as a literal `!!! tip "…"` paragraph, or worse, get
swallowed into a code block with no visible error at all. Verified by rendering each variant:

| Inside a `1. ` item | Result |
|---|---|
| `!!!` at 3 spaces, body at 7 | **fails** — renders as literal text |
| `!!!` at 4, body at 8, plain text before it | works |
| `!!!` at 4, body at 8, but the item's other content at 3 | **fails** — silently becomes a code block |
| Everything in the item at 4 (text, fences, `!!!`), body at 8 | works |

So the rule is **consistency, not just the admonition**: every continuation paragraph,
fenced code block, and admonition inside a list item sits at **4 spaces**, and admonition
bodies at **8**. `team-project/configuring-git.md` is the pattern to copy — it has six
admonitions inside one numbered list.

To check a page actually rendered, build and grep the output rather than trusting the
source: `grep -c '<div class="admonition' <built-page>` should match
`grep -c '^ *!!! ' <source>`. A literal `<p>!!!` in the built HTML means it failed loudly;
equal counts of neither means it failed silently.

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
    lesson-16-guide-building-with-copilot.md            # post-capstone (see AI section)
    lesson-17-guide-*.md / lesson-17-lab-*.md           # PLANNED — first unit tests (Vitest, pure functions)
    lesson-18-guide-*.md / lesson-18-lab-*.md           # PLANNED — edge cases, throw, async
    lesson-19-guide-*.md / lesson-19-lab-*.md           # PLANNED — React Testing Library (OPTIONAL lesson)
    stretch-react-challenges.md
  team-project/                        # post-capstone team development block (see below)
    README.md
    configuring-git.md                 # one-time global Git setup — script file + chmod, not paste
    team-charter.md                    # student-facing working agreement
    lesson-01-guide-collaborating-in-a-shared-repo.md
    lesson-01-lab-first-pull-request.md
    lesson-02-guide-*.md / lesson-02-lab-*.md   # PLANNED — depth in a shared codebase (Sprint 2)
    lesson-03-guide-*.md               # supervising an agent in a worktree (Sprint 3) — RENAME from 02
    lesson-03-lab-*.md                 # PLANNED — Sprint 3 runbook
    lesson-04-guide-*.md               # working a bug ticket (Sprint 4) — RENAME from 03
    lesson-04-lab-*.md                 # PLANNED — Sprint 4 runbook
  reference/                           # evergreen cheat sheets + shared images (cross-pass)
    README.md
    http-rest-status-codes.md
    insomnia-quickstart.md
    copilot-quickstart.md
    ai-policy.md                       # reads-not-writes during capstones; allowed/deferred table
    git-collaboration-quickstart.md    # branches, PRs, review, conflicts, worktrees
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
- **Team project** (`team-project/`) — the **post-capstone team development block**: teams
  of three work a ticket backlog in a shared GitHub repository seeded from the PRS reference
  implementation. See the dedicated section below.
- **Extra reference cheat sheets** (`reference/`) — beyond the three cross-pass
  quickstarts, `csharp-naming-conventions.md`, `anatomy-of-csharp-code.md`, and its
  companion `anatomy-of-csharp-code-quiz.md` support the API pass; the parallel
  `anatomy-of-typescript-code.md` and `anatomy-of-typescript-code-quiz.md` support the
  React pass (same "name every token" exercise, on an interface / API module / component).
  Evergreen; linked from lessons and the `reference/README.md` manifest.

---

## Team project (`team-project/`) — the post-capstone block

Teams of three work a ticket backlog in a shared GitHub repository seeded from the PRS
reference implementation. It runs **after** the React capstone and after React Lesson 16.

**It is not a pass.** No TableServe entity mapping, no reference implementation to teach
from, no `stretch-team-project-challenges.md` — the backlog *is* the stretch work, and it's
deliberately larger than any team can finish. Verified by **observation**: branches, pull
requests, reviews, and merges on GitHub.

### Where it sits in the sequence

```
React L1–15 → PRS React capstone → React L16 → team-project block
                AI: reads, not writes    ↑ generation + agent mode unlock here
```

React **Lesson 16** is the prerequisite: it's where generation and agent mode become
permitted at all (see `reference/ai-policy.md`). The block then applies that under review.

**The block uses AI in two distinct modes, and only one of them is L16's.** The agentic
tickets are L16 applied directly — generate a feature, audit it against conventions. The
**bug work is the opposite skill**: using AI to *comprehend* code you didn't write, then
verifying its explanation against the running app. L16 doesn't teach that, and it's arguably
the more valuable of the two for a first job. Don't collapse them into one thing.

### Lesson plan — four lessons, guide + lab each

| Lesson | Shape | Status | Why |
|---|---|---|---|
| **1 — Collaborating in a shared repo** | guide + lab | **built** | Repo setup, branches, PRs, review, conflicts |
| **2 — Depth in a shared codebase** | guide + lab | guide **built**, lab **to write** | Schema owner and migrations in a team; a conflict where "keep both" isn't obvious; extending an endpoint without breaking its contract; reviewing a vertical slice |
| **3 — Supervising an agent in a worktree** | guide + lab | guide **built**, lab **to write** | Worktrees, scoping a ticket for handoff, the audit passes, the review rubric, keeping the diff reviewable |
| **4 — Working a bug ticket** | guide + lab | guide **built**, lab **to write** | Reproduce before diagnosing, narrow before fixing, failing test first, root cause before the PR |

**Worktrees belong to Lesson 3, not Lesson 1** — moved deliberately. L1's own framing names
*three* things that change in a shared repo (protected `main`, branches, review) and worktrees
aren't one of them; nothing between L1 and L3 uses one (Sprints 1 and 2 are hand-built,
one branch each); and L1 could only motivate them hypothetically, since agent mode isn't in use
yet. L1 keeps a one-line forward pointer and the *isolation makes parallelism safe* takeaway.
Don't move them back.

**Each lesson is a briefing placed immediately before the work it describes:**

```
L1 → Sprint 1 → L2 → Sprint 2 → L3 → Sprint 3 → L4 → Sprint 4 → cross-team review
```

**One agentic ticket and two defects are reserved for the guides to walk through** — planted in
the starter, but never filed as issues, because walking a ticket you also assigned hands a
student their work. **This file ships to the public `academy-resources` repo, so the specific
IDs live only in the instructor-side planning docs** — see *Instructor-side companions* below.
Two authoring rules follow from it: a reserved item must be **invisible unless you go looking**
and must sit in **files no other ticket touches** (otherwise a sprint student finds or fixes it
first), and a guide must never name which items are reserved.

**Every lesson is a guide plus a lab, and Lesson N briefs Sprint N.** Four lessons, four sprints,
no exceptions. **Four lessons is the ceiling** — don't invent Lesson 5.

!!! warning "This reverses an earlier decision — don't reinstate it"

    An earlier version had only **three** lessons, the last two **guide-only on purpose**, "because the practice
    *is* the ticket work, so a lab would duplicate the backlog." That reasoning was wrong in a
    specific way: **the backlog is instructor-only.** Students never see it. So it justified the
    absence of student-facing directions by pointing at a document students can't read — leaving
    them, for three of four sprints, with a GitHub issue and nothing else.

    The labs are **sprint runbooks**, not re-teaches of the loop: take your ticket → the work
    specific to this sprint → verify → the pull request's three sections → review a teammate's.
    They point at the charter for the definition of done and at their guide for the reasoning, so
    they duplicate neither.

    Full plan and remaining TODO: `planning/team-project/README.md` → *Lesson plan*.

**Labs in this block carry no stretch-challenge section.** Every other pass's labs end with one;
here the backlog *is* the stretch work, which is why there's no `stretch-team-project-challenges.md`.
Each lab says so in a closing line.

**One deliberate exception: the L1 lab ends with `## Git drills`** — force a harder conflict, read
the history, recover a bad merge, measure branch drift. It survives the rule for a reason specific
to its position: L1 is the only lab whose students **have no backlog yet** (Part 4 is where they
take their first ticket), and the drills are Git mechanics rather than invented app features, so
they compete with nothing. The section explains its own exception in-place. **Don't rename it back
to "Stretch challenges" and don't delete it** — and don't add one to L2, L3 or L4.

**Testing is deliberately NOT taught here.** It's **React Lessons 17–18**, which run before
the block, so the backlog's TEST tickets assume the skill rather than teach it. That ordering
is also what lets the bug bash ask for a **failing test first** on any defect that's a pure
function, rather than retrofitting a test onto a fix already made. The starter repo still
needs Vitest installed with one finished reference test committed — see the backlog's seed-contents
table.

### Instructor-side companions — never publish these

Everything instructor-side lives in **`planning/team-project/`** — start at its `README.md`, which
maps the four sprints and links every file. The pieces: `sprint-1-the-loop.md` …
`sprint-4-bugs.md` (the tickets), `defects.md` (the seventeen planted defects with plant
instructions and answers), `tests.md`, `alternates.md`, `starter-repo.md` (the one-time build),
`running-the-block.md` (assignment grid, merge order, auditing), and `proposal.md` (management
summary). The whole folder lives outside `materials/` precisely so a publish step can't sweep it up.

**The block is four sprints**, renamed from an earlier scheme where the last two were called the
"agentic exercise" and the "bug bash": **Sprint 1** learn the loop, **Sprint 2** depth, **Sprint 3**
agentic work, **Sprint 4** bugs. **Lesson N briefs Sprint N** — four lessons, four sprints, one
to one.

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
  markup for them, so don't force one. Record this in the guide so a later regeneration
  doesn't "correct" them back into building the app — but **in an HTML comment, not in
  student-facing prose** (see below).

!!! warning "Authoring notes go in HTML comments, never in the lesson text"

    Instructions aimed at a *future author* — "don't turn this into an entity build on a
    regeneration," "this lesson is guide-only on purpose," "don't move this section back" —
    are meaningless to a student and make the guide read like internal scaffolding. They were
    leaking into the student-facing blockquotes of every tooling lesson.

    Put the student-facing half in the prose (*"this is a tooling lesson; verify by
    observation"*) and the authoring half in an `<!-- Authoring note (not student-facing): … -->`
    comment immediately after it. The three `team-project/` guides are the pattern to copy.

    **Verified: MkDocs does *not* strip HTML comments — they pass through into the built page's
    source.** A reader never sees one on the page, but *View Source* on the published site shows
    it verbatim. So a comment is the right home for **authoring/shape** instructions ("guide-only
    on purpose," "don't turn this into an entity build") and the **wrong** home for anything
    instructor-only: no answers, no planted-defect IDs, no paths into `planning/`. Those belong
    in the planning docs, which are never published. Same caution applies to this file — it's
    excluded from the built site by `exclude_docs` in `mkdocs.yml`, but it is still copied to the
    **public** `academy-resources` repo.
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
  — authoring lessons** → principle 7, below — the bulleted **`Save and check`** format
  applies here too.)

**Two cues, and the line between them.** This pass uses both:

- **`▶ Save and look`** — the *mid-build micro-cue*, used only where CSS/markup is handed out
  **incrementally** (L1 §8 builds a card rule by rule; L2 §4–5; L6 §2's toggle-it-by-hand
  experiment). One thing to see, narrative, often followed by *why* it changed. This is the
  by-hand workflow described above; don't replace it with a checklist.
- **`Save and check`** — the *section-closing verification*, same bulleted format as the React
  pass. Used at the end of every ▶ Code along section in **Lessons 3–6**, where the section
  builds a whole component rather than one rule at a time.

Roughly: Lessons 1–2 (hand-written CSS) close their sections with `▶ Save and look`;
Lessons 3–6 (Bootstrap and the validation script) close with `Save and check`.

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
done, verify all of these (principles 1–9 below give the full rationale and examples —
this is the fast pre-flight):

1. **Title.** The fence carries `title="src/…"`. *Exception:* a cross-file **concept** snippet
   that illustrates an idea rather than "add this here now" stays plain — no title, no diff.
   Never a `// path` comment inside the fence. **Inside a ▶ Code along section, an untitled
   snippet must say in words that it isn't a step** — "an illustration to read, not a step",
   "already in your `main.tsx` — nothing to add", "you only *type* phase 3". In a section whose
   whole premise is "type this," a bare fence reads as an instruction; the missing `title=` is
   far too subtle a signal on its own. Same for an inline code span offering a variation
   (`toast.success("Saved.", { duration: 6000 })`) — either name it as an example or cut it.
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
9. **Work the student must repeat across the app is a `!!! warning "Your turn — …"` callout
   with a file checklist** — never a bold sentence in a paragraph (principle 10).

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
   - The label is always **`Save and check`** — not "Check", not "Quick check". (The
     html-css pass additionally keeps **`▶ Save and look`** for mid-build micro-cues — see
     the HTML/CSS section above.)

   **Lesson 11 is the pattern to copy**; React Lessons 5–10 and 12 follow it, as do
   html-css Lessons 3–6.

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
   that." (Pattern to copy: the L7 §3 *optional debug-view* step.)
   **Lesson 9 is the pattern to copy** for the diff shape — every build block in §2–§4 uses it;
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
   pattern to copy:** the `OrderAPI` workflow methods come before the handlers that call them,
   and the `cancel` method before the `saveCancel` that calls it.

10. **Sweep work lives in the lab; the guide shows one example and points at it.** When a
    change has to be repeated across the app — retrofit five API modules, add a `catch` to
    every list page — the guide walks **one** instance and the **lab does the rest**. That's
    the I do / You do split applied to mechanical repetition: instructor-led time goes to the
    idea, not to the fourth identical edit, and the lab is already an action list, which is the
    right shape for a checklist of files. A guide may therefore end with the app **deliberately
    half-converted** — say so plainly, so a student doesn't read the inconsistency as their own
    mistake (**L12 §3** does this in one line). Never instruct the same sweep in both files:
    L12 briefly had `StaffAPI` in the guide's checklist *and* in the lab's steps.

    **Neither half may be prose** — students skim, the sentence gets missed, and the app stays
    half-converted in a way that only surfaces lessons later. Each half has its own shape:
    in a **guide**, a short `!!! warning` pointer (a guide is mostly prose, so the callout is
    what breaks the page); in a **lab**, its own `## Part N` heading with the `- [ ]` file
    checklists (a lab is already an action list, so an admonition inside it is redundant
    packaging). The admonition form — `admonition` is enabled in `mkdocs.yml`, body indented
    **4 spaces**:

    ```markdown
    !!! warning "Your turn — every API module, not just Menu Items"

        <one line of stakes — what stays broken until they do it>

        - [ ] `OrderAPI.ts`
        - [ ] `StaffAPI.ts`

        1. <the steps, in words — no code; they just watched the code>
    ```

    Four things make it work:

    - **A checklist of the actual files** (`- [ ]`; `pymdownx.tasklist` is enabled, so these
      render as real checkboxes) — a student can track what's left. Name every file; "and the
      others" is what gets skipped.
    - **Steps in words, not code.** They just typed the identical change in the walked example;
      re-printing it invites paste-without-reading and buries the one case that differs.
    - **State the stakes in the first line** — "these stay broken until you convert them",
      "any screen without a `catch` now fails silently". A checklist with no consequence reads
      as optional.
    - **List what's already done and what to leave alone.** A conscientious student will
      otherwise re-edit files that are already correct, or "fix" something that was
      deliberate (L12 §4 protects `ErrorPage`'s `console.error` this way). Both lists are as
      much a part of the callout as the to-do.

    **Placement — decided by what the section's `Save and check` actually verifies:**

    - **Check first, then the callout** when the check confirms the *walked example*. Never
      strand a build from its own verification: finish it, prove it works, then extend. Bridge
      the two with a line like "That's Menu Items finished, end to end. Now carry it across the
      app:" so the callout reads as the next step, not a topic change. (**L12 §4** — the check
      is about Menu Items saving and deleting.)
    - **Callout first, then the check** when the check only means something *after* the sweep.
      (**L12 §3** — "every page still fetches and saves" passes trivially before the retrofit,
      since the unconverted modules work fine on the happy path.)

    Either way, **the swept files need a check too** — usually one line inside the callout
    reusing what they just did ("check each the same way: with the API stopped, load `/orders`
    and `/categories`"). Sweep work that's never verified is sweep work that silently didn't
    happen.

    **Build Steps get a one-line pointer** to the callout, not a copy of it — and if the sweep
    is the lab's, the guide's Build Steps **omit it entirely** rather than carry a placeholder
    step; close the list with a sentence handing off to the lab.

    **Pattern to copy: Lesson 12.** The guide converts `MenuItemAPI` + the Menu Items screens
    and carries two short "the lab takes the rest" callouts; the **lab** is in two parts —
    *Part 1 Staff* (the parallel-entity You do) then *Part 2 the rest of the app* (the file
    checklists, the already-correct list, and the `ErrorPage` exclusion), each part with its own
    ✅ checkpoint.

The reworked **Lesson 3–5 guides** (and the L3/L4 labs) are the pattern to copy for principles
1–7; **Lesson 9** for principles 8 and 9 (the diff shape, and dependency-first code-block
ordering) — use them as the template when writing new React material. **All React lessons
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
example, not a convention correction to adopt.

---

## Testing lessons — React 17–19 (planned)

Three lessons at the **end of the React pass, after the capstone**, alongside Lesson 16.
Added at the end deliberately: purely additive, so no existing lesson number moves.

| Lesson | Topic | I do (TableServe) | Lab |
|---|---|---|---|
| **17** *(required)* | First unit tests: Vitest setup, `describe`/`it`/`expect`, watch mode, **red before green** — **built** | `getTextBackgroundByStatus` in `utility/formatUtilities.ts` | `formatPhoneNumber` |
| **18** *(required)* | Edge cases; a function that **throws**; async tests; `await expect(...).rejects.toThrow()`; a fake `new Response("", { status: 404 })`; **generating tests and what that gets wrong** — **built** | `translateStatusToErrorMessage` + `checkStatus` in `utility/fetchUtilities.ts` | `parseJSON` + `formatPhoneNumber` edge cases |
| **19** *(**optional**)* | React Testing Library: `render`, `screen.getByRole` vs `getByText`, `user-event`, assert what the **user sees** — **built** | `MenuItemCard` (props, then a ⋮ click revealing Edit/Delete) | `StaffCard` |
| **20** *(**optional**)* | A fake API with **MSW**: handlers, `setupServer`, the listen/reset/close lifecycle, `findBy…` for data that hasn't arrived, `server.use()` for a 500, `vi.spyOn` for `confirm` — **built** | `MenuItemList` (list, loading skeletons, error toast) | `StaffList` + the delete flow |

Conventions specific to these — carry them through on any regeneration:

- **Verification is the terminal, not the browser.** These are the only React lessons where
  that's true; the whole pass otherwise verifies in DevTools. State it in the guides so a
  regeneration doesn't "correct" them back. The observable is **red → green**, not a page.
- **Lesson 19 carries its own setup, and that's what makes "optional" real.** L17 installs
  plain `vitest` in the default node environment — all a pure function needs. jsdom,
  `vitest.setup.ts`, `@testing-library/react`, `@testing-library/user-event` and
  `@testing-library/jest-dom` arrive **only in L19**. A cohort that skips it never installs
  them and 17–18 still pass.
- **L19 opts into jsdom PER FILE**, with the `@vitest-environment jsdom` docblock, and
  `vite.config.ts` gets only `setupFiles`. **Do not "simplify" this to a global
  `environment: "jsdom"`** — L18's tests build real `new Response(...)` objects, which are
  Node's, and a global switch puts that at risk. The guide teaches the per-file choice as
  *pay for what you use*, which also keeps the utility tests fast.
- **L19's two components both render a `<Link>`**, so every `render()` is wrapped in
  `MemoryRouter`. The guide makes the general point from it — *a component that throws in a
  test but works in the app is usually missing context it normally gets from a parent.*
- **The L19 lab's payoff is the trailing space returning, and passing.** Testing Library
  normalizes whitespace, so `getByText("(800) 555-1234")` matches output that really ends in a
  space — the same reason it was never visible in the browser. The lab draws the conclusion
  explicitly (unit tests assert what a function returns; component tests assert what a user
  reads; when two tests disagree, check whether they're asking different questions). Don't cut
  that note — it's what ties L17, L18 and L19 together.
- **L19 stops at props-in/DOM-out plus a local interaction; L20 crosses that line.** L19 §6 is
  the hand-off and links forward — keep the two in sync if either is regenerated.
- **L20 teaches MSW, not `vi.mock`, and the reasoning is course-specific**: mocking the API
  module would skip `checkStatus` and `parseJSON`, the two functions L18 unit-tested, whereas
  intercepting the network runs them for real — so a 500 handler exercises the actual throw
  path and the actual `translateStatusToErrorMessage`. `vi.spyOn` is taught alongside for the
  non-HTTP case (`window.confirm` in the delete flow). Rule as stated: **network → MSW,
  everything else → `vi.mock`/`vi.spyOn`.** Don't swap L20 to module mocking.
- **MSW v2 API only** — `http` + `HttpResponse` from `msw`, `setupServer` from `msw/node`.
  Never `rest.get` / `res(ctx.json())`, which is v1.
- **L20's handler URLs use `http://localhost:5556/api`** — TableServe's `BASE_URL`. 5555 is
  PRS. And `menuItemAPI.list()`'s `.then(delay(200))` is what makes the loading-state
  assertion possible; don't remove it from the reference app.
- **Use the targets' real quirks rather than tidying them.** TableServe's `formatPhoneNumber`
  returns a **trailing space** (`` `…-${last3Digits} ` ``), so a student's first assertion
  fails on whitespace — a genuine lesson in asserting exactly. Its `last3Digits` variable
  takes **four** digits; the name was wrong long before a test existed. Don't fix either in
  the reference app. **The L17 lab is built on both**: Parts 1–2 are the trailing-space
  discovery (including *why* nobody saw it — `StaffCard` is the only caller and HTML collapses
  trailing whitespace), and the misnamed variable is its first stretch, used to show that a
  green suite is what lets you refactor without being brave.
- **L17 runs red-before-green on correct code, so it inverts the drill**: you can't reproduce
  a bug that isn't there, so the guide has students *break the assertion on purpose* to prove
  the test executes at all, and to teach reading Vitest's Expected/Received output. The real
  red-before-green-on-a-defect version is team-project L4. Don't "fix" L17 by planting a bug
  in `formatUtilities.ts`.
- **AI is explicitly off in L17 and comes back in L18.** L17 says so in a callout, with the
  reason: you cannot see how generated tests fail if you've never written one or watched one
  go red. L18's **§7 owns the generated-tests material** — its thesis is *generated tests
  **describe** current behaviour; hand-written tests **specify** intended behaviour*, demoed
  on Copilot faithfully asserting `formatPhoneNumber`'s trailing space, plus the
  you-decide/it-drafts split and *a generated test you've never seen red is unverified*.
  Don't move that section into L17 and don't drop L17's callout — it's the one lesson after
  L16 that closes the door again, so it has to justify itself.
- **Coverage is taught once, in L18 §6, and kept deliberately short** — run it, read the
  uncovered line numbers, open `coverage/index.html`, gitignore the folder, one caveat. It was
  trimmed from a much longer version on purpose (these are first-time testers); **don't let a
  regeneration grow it back** into branch-vs-statement coverage, thresholds, or CI gates.
  Placed immediately before the generated-tests section because the two share one warning —
  *executed ≠ verified* — and §7 calls back to it. The concrete finding is real and verified:
  after L17 + L18, `fetchUtilities.ts` is short of 100% because **`delay` is exported, used by
  `MenuItemAPI` and `CategoryAPI`, and never tested**. Re-check that if those files change.
- **🔒 `translateStatusToErrorMessage` differs between the two apps ON PURPOSE.** TableServe
  says `"Please sign in again."` (**correct**); PRS says `"Please sigin again."` (**the
  typo**). L18 teaches this function on TableServe, so the typo stays undiscovered until the
  team block's **TEST-04**, where a student writing the obvious assertion finds a real bug
  nobody knew about. **Never sync these two `fetchUtilities.ts` files in either direction**,
  and never mention the typo in React materials. L18's authoring comment repeats this
  warning in-file. See `planning/team-project/tests.md`.
- **No C# tests anywhere in the program.** There's no pure C# logic in PRS or TableServe to
  unit test — every behaviour lives in a controller with an injected `DbContext`. Deliberate;
  don't add an xUnit project.

These feed the **team-project** block: its TEST tickets assume this skill and don't teach it.

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
  (the three surfaces, set-up per editor, the verify-don't-trust discipline, the convention
  watch-list, and how to hand Copilot files). Every Copilot lesson/stretch links to it; keep
  it editor-neutral except where it deliberately contrasts Visual Studio vs. VS Code.
- **AI use policy.** `reference/ai-policy.md` is the evergreen, cross-pass rulebook:
  **during a capstone, AI reads code with you; it doesn't write code for you.** Explaining,
  researching, debugging, and reviewing your own code are allowed; generating
  components/features and agent mode are deferred until after the capstone. The governing
  test is *"did I already know what I wanted to write?"* — which is why autocomplete
  finishing a decided-on line is allowed and autocomplete writing an unplanned block is not.
  The rationale is that **you can't review code you never understood**, so the hand-built
  reps must come first. Don't soften this into "use AI responsibly"; the allowed/deferred
  table is the point.
- **Two required lessons, sequenced review-before-generate:**
  - **API Lesson 7** (`api/lesson-07-guide-copilot-code-review.md` + lab) — code **review**:
    attach a controller to Copilot Chat and *triage* its suggestions (accept real bugs /
    reject convention violations / ignore noise). Guide demos on TableServe; lab reviews the
    student's **PRS backend capstone**.
  - **React Lesson 16** (`react/lesson-16-guide-building-with-copilot.md` + lab) — code
    **generation**: autocomplete → Chat → **the conventions file** → agent mode, audited
    against our conventions. Lab generates a Staff feature. **Taught *after* the PRS React
    capstone, not at the capstone bridge** — it keeps the number 16 but opens the
    post-capstone period, because agent mode and whole-feature generation are exactly what the
    AI policy defers. A future regeneration must not move it back before the capstone.
  - **§5 of that guide owns `.github/copilot-instructions.md`** and the lab's Part B has
    students write one from the violations they just collected, then re-measure. Don't drop
    it on a regeneration and don't relocate it: it sits immediately after the conventions
    table because that table *is* the file, and the payoff is stated in team-project terms —
    a shared conventions file is the one thing in the block that makes review **cheaper**
    rather than merely more careful. The team starter repo ships the PRS equivalent
    (`planning/team-project/starter-repo.md`) and the charter asks teams to maintain it.
  - **§6 owns prompting** — the four ingredients (task, reference, scope, constraints), *ask
    small*, and the **repair loop** with its two exit conditions (restart on the fourth
    correction; hand-write when editing is slower than writing). The four ingredients are the
    same four the team-project L3 guide uses for an agentic ticket; L16 teaches them, L3
    applies them at ticket scale. Keep them worded consistently across the two.
  - **The L16 lab's Part C targets a real, verified gap** — `MenuItemList` renders
    `MenuItemCardSkeleton`s while loading; `StaffList` has no `loading` state and no
    `StaffCardSkeleton` exists. Don't swap the target for an invented one: the value is that
    the thing being matched is real code two folders away, and the ten-row rubric is written
    against it (rows 4 and 6 — no new dependency, `loading` cleared in a `finally` — are the
    ones generated code actually fails). Orders is the documented fallback; it has no loading
    state either. **Deliberately not the products/vendors filter shape**, which is team-project
    AG-0's reserved walked example.
  - **Two kinds of wrong, and they're split across two files on purpose.**
    *Convention-wrong* (runs fine, doesn't belong here) is L16 §4, because it's
    app-specific. *Just-wrong* is the four failure modes in `reference/copilot-quickstart.md`
    → **Where it goes wrong** — evergreen and cross-pass, so the API and HTML/CSS passes can
    point at it too. The ordering there is by **cost**: invention and stale patterns are
    caught by the tooling; plausible-but-wrong logic and confident wrong diagnosis are the
    expensive pair, because the code runs and the answer reads well. Don't merge the two
    tables — the distinction is the teaching point.
  - Challenge #8 in `stretch-react-challenges.md` (build a PRS feature with agent mode
    against a rubric) is therefore a **post-capstone** challenge, not a capstone stretch.
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

1. **Dual-role user on Request** — one `User` is both the submitter (the `UserId` FK) and,
   via the `IsReviewer` flag, a potential reviewer of the same record. **One FK only — there
   is no `ReviewerId` column**; don't let a regeneration invent one. No TableServe equivalent
   (an Order has a single `staffId` and no second role).
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
- **Constant names are PascalCase; constant VALUES are UPPERCASE.** `public const string
  Placed = "PLACED";` — never `"Placed"`. The value crosses C# → SQL Server → JSON → the
  React app, and every comparison on that path is case-sensitive, so a single mixed-case
  value produces a filter that matches nothing and a badge with no colour, silently. Holds
  in both apps, the seed scripts, the Insomnia collections, and the front end
  (`order.status === "PLACED"`). **Casing is a display decision made at the point of display,
  and the reference app is deliberately not uniform about it:** the filter `<select>` uses
  `<option value="PLACED">Placed</option>` (uppercase value, Title Case label), while the
  status **badge prints the raw `{order.status}`** — caps, because a caps chip reads as a
  state. Don't "fix" the badge to Title Case and don't add a display-mapping helper; the rule
  is *never re-case the value*, not *always Title Case the label*. Rationale for students is
  in **API Lesson 4's lab** and **React Lesson 2's guide**.

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
