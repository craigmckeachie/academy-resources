# Lesson 16 Guide — Building with GitHub Copilot: Autocomplete, Chat, and Agent Mode

**Goal:** by the end of this lesson you can use **GitHub Copilot** to *generate* React
code — from a single autocompleted line, to a component scaffolded in Chat, to a
multi-file feature drafted in **agent mode** — and, crucially, hold every line of it to
**this app's house style** before you keep it. In the lab you generate a Staff feature and
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
| **Copilot Chat** | scaffold one thing: a component, a `use…` hook, an API module | Medium — review the whole block against house style |
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
line as it lands, autocomplete rarely drifts off house style — the danger grows as the
generations get bigger.

---

## 3. Copilot Chat — scaffolding one thing

Open Chat, give it context (a **`#` file reference** is best — see the cheat sheet), and
ask for one component or module. For example:

> Generate a `MenuItemCard` component. Match the pattern and conventions of
> `#StaffCard.tsx`.

Referencing a real file from the app is the single biggest thing you can do to get
house-style output — you're handing Copilot the template instead of hoping it guesses.
Even so, **review the result against section 4 before you keep it.** Copilot's default
React is not this app's React.

Two Chat uses beyond generation, both high-value:

- **Explain:** *"Explain what the async `defaultValues` function in `#StaffForm.tsx` does."*
  — Copilot as a tutor for a pattern you're about to reuse.
- **Translate the static page:** paste a finished Bootstrap page from the HTML/CSS pass and
  ask Copilot to convert it to a component — then audit the conversion. (This is literally
  the capstone's job; see the stretch.)

---

## 4. ⚠️ The house-style guardrails Copilot will cross

This app is built a specific way. Copilot, trained on all of GitHub, will confidently
produce the *common* way instead. Every item below is something it's likely to generate
that you must **reject and redo in house style** — the same watch-list idea from the cheat
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
| The feature spread into one big file | the **feature-folder** split (interface, API, page, list, card/row, skeleton, form, thin create/edit wrappers) | everything in a single component |

If a generation trips any "tell," that's Copilot not knowing your app — not a better idea.
Redo it the house way; you know it, you built it eight times.

---

## 5. Agent mode — review it like a pull request

Agent mode is the powerful gear: you describe a change and Copilot proposes edits **across
multiple files** as a **diff you approve or reject, hunk by hunk.** For example:

> Add a `title` field to Staff: update `#IStaff.ts`, the create/edit form, and the API
> payload. Match the existing patterns in those files.

What comes back is exactly a pull request — and you review it exactly like [Lesson 7](../api/lesson-07-guide-copilot-code-review.md):

1. **Read every hunk.** Bucket each: accept (matches house style, correct), reject (crosses
   a section-4 guardrail), or fix-then-accept.
2. **Reject the whole change if you can't review it.** Never "Accept All" on a diff you
   haven't read — that's how `axios` and a `row`/`col` grid quietly enter your codebase.
3. **Verify in the browser.** Approving a diff isn't done — run `npm run dev`, open the
   page, and check the **DevTools Console and Network** tabs. A change that renders wrong or
   throws in the console gets reverted, no matter how confident the agent was.

**Steer it up front.** Naming a reference file and the constraints in the prompt moves most
guardrail violations out of the diff before they appear:

> …match `#StaffForm.tsx`: use **react-hook-form**, **flexbox utilities** (no `row`/`col`),
> our **`fetchUtilities`** helpers, and **react-hot-toast** — no `axios`, no new
> dependencies.

---

## 6. Verifying — how you know a generation is good

There's no test suite here; you verify by **observation and review**, and it scales with how
much Copilot wrote:

- **Every generated line is triaged** — you read it and it either matches house style or you
  fixed it. Nothing was kept just because it appeared.
- **No section-4 guardrail is crossed** in what you keep — no `axios`, no `row`/`col`, no
  inline `fetch`, no `useState`-per-field form, no `data-bs-toggle` modal.
- **It runs clean in the browser** — the page renders, the Console is error-free, and the
  Network tab shows the expected calls to your API (with CORS enabled, as in Lesson 4).

The bigger the generation, the more this matters — a whole agent-mode feature deserves the
same scrutiny you'd give a colleague's PR, because that's what it is.

> **Looking ahead — the capstone.** The PRS front end is the ideal place to use this well:
> you have a finished TableServe app as the template and a static PRS markup pass to convert.
> A **capstone stretch goal** has you build one PRS feature with agent mode against a review
> rubric — see [stretch-react-challenges.md](stretch-react-challenges.md). It's optional and
> never required to finish the capstone.

---

## The General Pattern (what to take away)

- Generation is **triage at scale** — the Lesson 7 habit, applied to code Copilot wrote.
  More generated ⇒ more review.
- **Autocomplete** you eyeball; **Chat** output you review as a block; **agent-mode** diffs
  you review as a pull request — never "Accept All" unread.
- **House style is the yardstick.** Copilot's default React uses `axios`, inline fetches,
  `useState` forms, and the `row`/`col` grid; this app uses fetch helpers + API modules,
  react-hook-form, and flexbox utilities. Redo anything that drifts.
- **Steer with a reference file** (`match #StaffForm.tsx`) and constraints — it's the
  cheapest way to get house-style output.
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
   house style the second attempt is.
5. **Agent mode:** give it a small cross-file task (e.g. add a field through the interface,
   form, and API); **review the diff hunk by hunk**, accepting only what matches house
   style, rejecting or fixing the rest.
6. **Verify in the browser** — `npm run dev`, open the page, and confirm it renders with a
   clean Console and the expected Network calls.
7. Try one **explain** prompt on a pattern you're about to reuse (the async `defaultValues`,
   the `checkStatus`/`parseJSON` chain) — Copilot as tutor, not just generator.
