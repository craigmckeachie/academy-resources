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
    anatomy-of-a-class.md
    anatomy-of-a-class-quiz.md
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
  quickstarts, `csharp-naming-conventions.md`, `anatomy-of-a-class.md`, and its
  companion `anatomy-of-a-class-quiz.md` support the API pass. Evergreen; linked
  from lessons and the `reference/README.md` manifest.

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
