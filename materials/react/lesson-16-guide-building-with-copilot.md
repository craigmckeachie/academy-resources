# Lesson 16 Guide — Building with GitHub Copilot: Autocomplete, Chat, and Agent Mode

**Goal:** by the end of this lesson you can use **GitHub Copilot** to *generate* React
code — from a single autocompleted line, to a component scaffolded in Chat, to a
multi-file feature drafted in **agent mode** — and, crucially, hold every line of it to
**this project's conventions** before you keep it. In the lab you generate a Staff feature and
audit it against the version you already built by hand.

> **This is a tooling lesson, not a build lesson.** There's no new TableServe feature to
> add. You re-generate patterns you already built by hand precisely *so you have a
> ground-truth version to judge Copilot's against*. Verify by **observation** — run it in
> the browser, read every line — the same way the rest of the React pass verifies. A later
> regeneration shouldn't "correct" this into building an entity.

**The general pattern you're learning:** in [Lesson 7 (API)](../api/lesson-07-guide-copilot-code-review.md)
you learned to **triage** an AI review — accept / reject / ignore, with a reason. Generation
raises the stakes of that exact skill: **the more Copilot writes, the more you must
review.** A one-line autocomplete you can eyeball; a whole feature from agent mode is a
pull request you have to review before merging. The yardstick is always the same — **does
it match how this app is already built?**

> **Prerequisites:** the [GitHub Copilot quick-start](../reference/copilot-quickstart.md)
> (the three surfaces, and *How to hand Copilot Chat your files*) and the triage habit from
> [API Lesson 7](../api/lesson-07-guide-copilot-code-review.md). This lesson is that habit,
> applied to code Copilot *wrote* instead of code you wrote.

---

## 1. The three surfaces, in a React workflow

| Surface | In React, use it to… | How much review it needs |
|---|---|---|
| **Inline autocomplete** | finish a `.map()`, a repetitive form field, an import, the next line of a hook | Low — you read each line as it appears |
| **Copilot Chat** | scaffold one thing: a component, a `use…` hook, an API module | Medium — review the whole block against our conventions |
| **Agent mode** | draft a change across several files (a new field through the interface, form, and API) | High — review it like a teammate's pull request |

You've met autocomplete since Lesson 3. Chat and agent mode are the new gears — and the
review discipline scales up with each.

---

## 2. Autocomplete — the low-stakes gear

With a component file open, autocomplete reads the surrounding code and offers the next
line or two as grey ghost text. It's at its best **once you've established a pattern** —
type the first `<div className="mb-3 w-50">…</div>` field and it will offer the next one
correctly, because your own file is its context.

```tsx
{menuItems.map((menuItem) => (
  // ⌁ ghost text offers the rest, modeled on your imports and IMenuItem
))}
```

Press **Tab** to accept, **Esc** to dismiss, keep typing to ignore. Because you read each
line as it lands, autocomplete rarely drifts away from our conventions — the danger grows as the
generations get bigger.

---

## 3. Copilot Chat — scaffolding one thing

Open Chat, give it context (a **`#` file reference** is best — see the cheat sheet), and
ask for one component or module. For example:

> Generate a `MenuItemCard` component. Match the pattern and conventions of
> `#StaffCard.tsx`.

Referencing a real file from the app is the single biggest thing you can do to get
convention-matching output — you're handing Copilot the template instead of hoping it guesses.
Even so, **review the result against section 4 before you keep it.** Copilot's default
React is not this app's React.

Two Chat uses beyond generation, both high-value:

- **Explain:** *"Explain what the async `defaultValues` function in `#StaffForm.tsx` does."*
  — Copilot as a tutor for a pattern you're about to reuse.
- **Translate the static page:** paste a finished Bootstrap page from the HTML/CSS pass and
  ask Copilot to convert it to a component — then audit the conversion. (This is literally
  the capstone's job; see the stretch.)

    **Which tool, though?** [Lesson 15](lesson-15-guide-capstone-bridge.md) points you at the
    **HTML to JSX extension** for this, and that's still the right first pass: it's
    deterministic, so `class`→`className` and the camelCased SVG attributes come out the same
    way every time, with nothing to audit. Copilot earns its keep on the part the extension
    *can't* do — wiring the converted markup to props, state, `Link`s, and react-hook-form,
    and rebuilding `data-bs-toggle` widgets as react-bootstrap. **Mechanical renames → the
    extension; judgment → Copilot, audited.**

---

## 4. ⚠️ The conventions Copilot will break

Generated code goes wrong in **two different ways**, and they need different eyes.

**Convention-wrong** is code that works perfectly and doesn't belong here — `axios` instead of
our fetch helpers, a `row`/`col` grid instead of flexbox. Nothing fails. It runs, it renders,
and it quietly makes the codebase two codebases. That's this section, and it's the kind you
can only catch because you built the app by hand.

**Just-wrong** is code that doesn't work: an invented prop, a stale API, a dependency array
missing an entry. The compiler catches some of it and running it catches the rest — see
*Where it goes wrong* in the
[Copilot quick-start](../reference/copilot-quickstart.md) for the four shapes it takes.

This app is built a specific way. Copilot, trained on all of GitHub, will confidently
produce the *common* way instead. Every item below is something it's likely to generate
that you must **reject and redo to our conventions** — the same watch-list idea from the cheat
sheet, now for React:

| Copilot tends to generate… | This app uses… | Tell |
|---|---|---|
| `axios`, or `fetch` inline in the component | `fetch(...).then(checkStatus).then(parseJSON)` via the **`utility/fetchUtilities`** helpers | an `import axios` or a raw `fetch` in a `.tsx` |
| Data calls scattered in components | An **API module object** per entity (`staffAPI.list/find/post/put/delete` in `StaffAPI.ts`) | no `*API.ts` file in the feature folder |
| A hand-rolled form with `useState` per field + `onChange` | **react-hook-form** (`useForm`, `register`, `handleSubmit`, async `defaultValues`) | `value={…} onChange={…}` on every input |
| Bootstrap **`row`/`col`** grid, or CSS **Grid** | **flexbox utilities only** (`d-flex flex-wrap gap-*`, `w-50`) | any `className="row"` / `col-*` / `display:grid` |
| A Bootstrap **CDN `<link>`**, or ad-hoc `react-bootstrap` | Bootstrap installed via **npm**, styled with utility classes | a CDN URL, or an unplanned dependency |
| Modals via `data-bs-toggle` / jQuery-style | **modals driven by React state** (`show={!!state}`) | `data-bs-toggle="modal"` in JSX |
| `alert()` / inline error text | **toasts** via `react-hot-toast` (`toast.success` / `toast.error`) | `alert(` or bespoke error banners |
| Loose or `any` typing | a typed **interface** per entity (`IStaff`), used everywhere | missing `I{Entity}` import, stray `any` |
| The feature spread into one big file | the **feature-folder** split (interface, API, page, card/row, skeleton, form, thin create/edit wrappers — the **page** owns the fetch, state, and `.map()`; there's no separate `List` file in this app) | everything in a single component |

If a generation trips any "tell," that's Copilot not knowing your app — not a better idea.
Redo it the way this project does it; you know it, you built it five times.

---

## 5. Teach it your conventions once — `.github/copilot-instructions.md`

Look at that table again and notice what it really is: a list of things you would otherwise
have to say **in every single prompt**. You don't have to. Copilot reads a file at the root of
your repository and applies it to every Chat and agent-mode request in that project:

```
tableserve/
  .github/
    copilot-instructions.md     ← plain markdown, no special syntax
  TableServe.Web/
  TableServe.Api/
```

It's just prose, and **short and specific beats long and aspirational** — the file is sent
along with your request, so a rambling one spends context and dilutes the rules that matter.
Section 4's table, compressed:

```markdown
# Project conventions

React 18 + TypeScript + Vite. Bootstrap 5 via npm. ASP.NET Core 8 Web API, EF Core.

## Always
- Fetch through `utility/fetchUtilities` — `fetch(...).then(checkStatus).then(parseJSON)`
- One API module object per entity, in that entity's feature folder (`StaffAPI.ts`)
- Forms with react-hook-form: `useForm`, `register`, `handleSubmit`, async `defaultValues`
- Layout with Bootstrap flexbox utilities — `d-flex`, `flex-wrap`, `gap-*`, `w-50`
- A typed interface per entity (`IStaff`), imported as `import { IStaff }`
- Success and error feedback with react-hot-toast
- Models used directly in controllers; `DbContext` injected into the controller

## Never
- `axios`, or a raw `fetch` inside a component
- Bootstrap `row`/`col` grid classes, or CSS Grid
- A `useState` per form field
- `data-bs-toggle` modals — modals are driven by React state
- `alert()` for feedback
- `import type` for interfaces
- DTOs, a repository layer, `[Authorize]`, or JWT
- New dependencies without being asked
```

Three things worth knowing:

- **It shapes Chat and agent mode.** Inline autocomplete is driven mostly by the file you're
  sitting in, which is why section 2's advice — establish the pattern first — still holds.
- **It is not a guarantee.** It moves *most* violations out of the diff before they appear. It
  does not remove the audit; section 4 is still the checklist you read the output against.
- **It's a living file.** The moment you find yourself correcting the same thing twice, that
  correction belongs in here rather than in a third prompt.

For finer control you can scope rules to particular files with `.github/instructions/*.instructions.md`
— worth knowing exists, and covered in the
[Copilot documentation](https://docs.github.com/en/copilot). One repo-root file is plenty for a
project this size.

!!! tip "This is a team artifact, not a personal one"

    The value compounds the moment you're not working alone. In the **team development block**
    you share a repository, and the charter names the real constraint there: not how fast anyone
    can generate code, but **how much code three people can honestly review.**

    A conventions file in the shared repo attacks that directly — every violation it prevents is
    one a reviewer never has to catch. When a teammate flags the same drift twice in review, the
    fix isn't a third review comment. It's one line in this file, and now it's fixed for all
    three of you.

---

## 6. Writing the request — and what to do when it comes back wrong

The conventions file handles the rules that never change. The *request* is everything else,
and it's where most of the quality difference lives. A good one has **four ingredients**:

| | | Example |
|---|---|---|
| **The task** | One thing, stated as an outcome | *Generate a `MenuItemCard` that renders name, price, and category, with the ⋮ dropdown.* |
| **The reference** | The file that already solves something similar | *Match `#StaffCard.tsx`.* |
| **The scope** | Which files may change | *Only `menuItems/MenuItemCard.tsx`.* |
| **The constraints** | The rules this particular job is likely to break | *No new dependencies. The card is presentational — the page owns the fetch.* |

The **reference** is the one people skip and it's the highest-value of the four. Describing
your conventions in prose asks Copilot to imagine them; naming a file *shows* it. And the two
steering tools do different jobs — the conventions file says what the rules **are**,
`#StaffCard.tsx` shows what they **look like**. Use both.

Compare:

> ❌ Write a card component for menu items.

> ✅ Generate a `MenuItemCard` component that renders the menu item's name, price, and
> category name, plus the ⋮ dropdown with Edit and Delete. Match `#StaffCard.tsx` — same
> structure, same Bootstrap utilities, same props shape. Only create
> `menuItems/MenuItemCard.tsx`. It's presentational; the page owns the fetch and the state.

The second one takes twenty seconds longer to type and saves the ten minutes you'd have spent
undoing the first one's answer.

### Ask small

One component, review it, then the next. A 200-line generation you have to untangle is slower
than three 40-line ones you accepted in sequence — and if something's wrong in the middle of
the big one, you often can't tell which part to keep.

### The repair loop

Most generations come back roughly right and specifically wrong. Don't start over and don't
hand-fix silently — **correct it in the same conversation**, where it still has the context:

1. **One correction at a time.** Bundled corrections get partially applied and you lose track
   of which stuck.
2. **Name the rule, not the symptom.** *"Use our `fetchUtilities` helpers — `fetch(...)
   .then(checkStatus).then(parseJSON)`"* works. *"That's not how we do it"* doesn't.
3. **Re-point at the reference** if it drifted: *"`#StaffCard.tsx` doesn't do it that way —
   look again at how it renders the dropdown."*
4. **Ask it to explain itself** when a line surprises you: *"why did you use a `useEffect`
   there?"* Sometimes there's a good reason; sometimes the question is enough to make the
   problem obvious.

And two exit conditions, both of them fine:

- **On the fourth correction, restart.** Four rounds means the *prompt* was wrong, not the
  output. Write a new one with all four corrections folded into it — you'll get there faster
  than continuing to negotiate.
- **When editing its code is slower than writing yours, write yours.** That's a judgement,
  not a defeat, and the team block's Lesson 3 treats it as a named skill rather than a
  fallback.

---

## 7. Agent mode — review it like a pull request

Agent mode is the powerful gear: you describe a change and Copilot proposes edits **across
multiple files** as a **diff you approve or reject, hunk by hunk.** For example:

> Add a `title` field to Staff: update `#IStaff.ts`, the create/edit form, and the API
> payload. Match the existing patterns in those files.

What comes back is exactly a pull request — and you review it exactly like [Lesson 7](../api/lesson-07-guide-copilot-code-review.md):

1. **Read every hunk.** Bucket each: accept (matches our conventions, correct), reject (crosses
   a section-4 guardrail), or fix-then-accept.
2. **Reject the whole change if you can't review it.** Never "Accept All" on a diff you
   haven't read — that's how `axios` and a `row`/`col` grid quietly enter your codebase.
3. **Verify in the browser.** Approving a diff isn't done — run `npm run dev`, open the
   page, and check the **DevTools Console and Network** tabs. A change that renders wrong or
   throws in the console gets reverted, no matter how confident the agent was.

**Section 6's four ingredients matter more here than anywhere else**, because the cost of a
vague prompt scales with how many files the answer touches. **Scope** in particular stops
being optional — *"only `#IStaff.ts`, `#StaffForm.tsx`, and `#StaffAPI.ts`"* is the difference
between a diff you can review and one you'll approve out of fatigue.

---

## 8. Verifying — how you know a generation is good

There's no test suite here; you verify by **observation and review**, and it scales with how
much Copilot wrote:

- **Every generated line is triaged** — you read it and it either matches our conventions or you
  fixed it. Nothing was kept just because it appeared.
- **No section-4 guardrail is crossed** in what you keep — no `axios`, no `row`/`col`, no
  inline `fetch`, no `useState`-per-field form, no `data-bs-toggle` modal.
- **It runs clean in the browser** — the page renders, the Console is error-free, and the
  Network tab shows the expected calls to your API (with CORS enabled, as in Lesson 4).
- **You exercised the case that isn't the happy path** — the empty list, the missing field,
  the form submitted blank. Plausible-but-wrong logic survives every check above this one.

The bigger the generation, the more this matters — a whole agent-mode feature deserves the
same scrutiny you'd give a colleague's PR, because that's what it is.

!!! warning "Reading the diff is not verification"

    Two of the four failure modes — the expensive two — produce code that reads perfectly.
    Generated code is *unusually* convincing to read: consistent naming, no typos, a comment
    on every block. **Polish is not correctness.** The only thing that separates a good
    generation from a plausible one is running it, on the input you didn't want to try.

> **Why this lesson is here and not earlier.** You've now built two full front ends by
> hand — TableServe across this pass, PRS in the capstone. That's deliberate: the
> [AI use policy](../reference/ai-policy.md) holds generation back until the capstone is
> done, because **you can't review code you never understood.** Everything in this lesson
> was off-limits a week ago; it isn't now, and the reason it isn't is the two apps behind
> you.
>
> **What to do with it next.** Challenge #8 in
> [stretch-react-challenges.md](stretch-react-challenges.md) has you build one more PRS
> feature with agent mode against a review rubric — optional, and now unlocked. Beyond
> that, the **team development block** puts agent mode in a shared repository where every
> generated line passes a teammate's pull-request review before it merges.

---

## The General Pattern (what to take away)

- Generation is **triage at scale** — the Lesson 7 habit, applied to code Copilot wrote.
  More generated ⇒ more review.
- **Autocomplete** you eyeball; **Chat** output you review as a block; **agent-mode** diffs
  you review as a pull request — never "Accept All" unread.
- **Our conventions are the yardstick.** Copilot's default React uses `axios`, inline fetches,
  `useState` forms, and the `row`/`col` grid; this app uses fetch helpers + API modules,
  react-hook-form, and flexbox utilities. Redo anything that drifts.
- **Steer with a reference file** (`match #StaffForm.tsx`) and constraints — it's the
  cheapest way to get convention-matching output.
- **Write the rules down once**, in `.github/copilot-instructions.md`, instead of retyping
  them every prompt. The conventions file says what the rules *are*; a reference file shows
  what they *look like*. Use both.
- **Four ingredients in every request:** task, reference, scope, constraints. Ask small, and
  correct **in the same conversation** — one thing at a time, naming the rule rather than the
  symptom. On the fourth correction the prompt was wrong; restart with them folded in.
- **Two kinds of wrong.** *Convention-wrong* runs perfectly and doesn't belong here — only
  you can catch it. *Just-wrong* doesn't work — and the half of it that still compiles is
  found by running the code, never by reading the diff.
- **Verify in the browser**, every time — a clean-looking diff that errors in the Console is
  still wrong.

You'll lean on this through the PRS capstone and for the rest of your career: AI can write a
lot of code fast, and the value you add is being the engineer who can tell which of it to
keep.

---

## Build Steps

1. Open your TableServe React app with **Copilot Chat** available and the
   [Copilot quick-start](../reference/copilot-quickstart.md) alongside for the guardrails.
2. **Autocomplete:** in an existing list component, start a `.map()` and let autocomplete
   finish a card/row; accept it line by line, reading each.
3. **Chat:** ask Copilot to generate one component (e.g. `MenuItemCard`) **referencing a
   real file** (`#StaffCard.tsx`); review the output against the section-4 table and note
   every guardrail it crossed.
4. Re-ask with a **reference file + constraints** in the prompt and see how much closer to
   project conventions the second attempt is.
5. **Write `.github/copilot-instructions.md`** at the root of your TableServe repo, from the
   section-4 table and the violations you just watched Copilot commit. Keep it to an
   *Always* list and a *Never* list.
6. Re-run step 3's prompt **with the file in place** and count the violations again. That
   drop is what you bought.
7. Practise the **repair loop** on one generation that came back nearly right: correct it in
   the same conversation, one rule at a time, and notice how many rounds it takes.
8. **Agent mode:** give it a small cross-file task (e.g. add a field through the interface,
   form, and API), **with the files it may change named in the prompt**; **review the diff
   hunk by hunk**, accepting only what matches our conventions, rejecting or fixing the rest.
8. **Verify in the browser** — `npm run dev`, open the page, and confirm it renders with a
   clean Console and the expected Network calls.
9. Try one **explain** prompt on a pattern you're about to reuse (the async `defaultValues`,
   the `checkStatus`/`parseJSON` chain) — Copilot as tutor, not just generator.
