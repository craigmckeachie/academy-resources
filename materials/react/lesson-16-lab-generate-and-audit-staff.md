# Lesson 16 Lab — Generate a Staff Feature with Copilot, Then Audit It

Use Copilot to **generate** parts of the Staff feature, then **audit** what it produced against
your working version and this project's conventions. Because you built Staff across Lessons
3–12, you have a ground-truth reference to judge Copilot's output against — that's the whole
point.

Three parts, and they build: **A** shows you what unsteered generation does, **B** turns that
into a conventions file, and **C** puts agent mode to work on a real gap in your app and holds
the result to a written rubric.

Keep the [Copilot quick-start](../reference/copilot-quickstart.md) open for the guardrails,
and refer back to the guide's **section 4** (the conventions table), **section 5** (the
conventions file), **section 6** (the four ingredients and the repair loop), and **section 7**
(reviewing an agent-mode diff).

---

## Part A — Chat: generate a component and diff it against yours

1. Pick a Staff file you built — `StaffCard.tsx`, `StaffPage.tsx`, or the `StaffAPI.ts`
   module.
2. In Chat, ask Copilot to generate that piece **from a description** — first with **no
   reference file** (e.g. *"Write a StaffAPI module with list, find, post, put, and delete
   for a `/staff` endpoint"*).
3. **Diff it against your real file.** List every difference, and bucket each: convention
   match, or **guardrail crossed**. Expect at least some of:
   - `axios` (or a raw `fetch`) instead of `fetch(...).then(checkStatus).then(parseJSON)`
   - fetch calls inline in a component instead of an **API module object**
   - a `useState`-per-field form instead of **react-hook-form**
   - a Bootstrap **`row`/`col`** grid instead of **flexbox utilities**
   - `alert()`/inline errors instead of **react-hot-toast**
   - missing the `IStaff` **interface** / stray `any`
4. Now re-ask **with a reference file and constraints**: *"…match `#MenuItemAPI.ts`; use our
   `fetchUtilities` helpers, no axios."* Diff again and note how many guardrail violations
   disappeared. That difference is the value of steering.
5. **Repair, don't restart.** Take whichever attempt came back closest and correct it **in the
   same conversation** — one rule at a time, naming the rule rather than the symptom (guide
   section 6). Count the rounds it takes. If you reach four, stop and write one fresh prompt
   with all four corrections folded in; compare that against where the negotiation had got to.
6. **Try one input that isn't the happy path** on whatever you kept — an empty list, a missing
   optional field. Every check up to here is a reading check, and the failure mode this catches
   survives all of them.

---

## Part B — Write the conventions file

You've just watched Copilot break the same handful of rules on purpose. Stop retyping them.

1. Create **`.github/copilot-instructions.md`** at the root of your TableServe repository.
2. Write it from **two sources**: the guide's section-4 table, and the violations you actually
   collected in Part A. Two headings — **Always** and **Never** — and keep it tight. Short and
   specific beats long and aspirational; it's sent with every request.
3. **Re-run your Part A prompt with the file in place** — same wording, no reference file, no
   constraints paragraph. Count the guardrail violations again.
4. Compare the three counts you now have:

    | Attempt | Violations |
    |---|---|
    | No context at all (Part A step 2) | |
    | Reference file + constraints in the prompt (Part A step 4) | |
    | Conventions file, plain prompt (just now) | |

    Note which rules the file fixed and which it didn't. Anything still getting through is
    either worded too vaguely to act on, or buried — tighten that line.

> The file is a living document, not homework. Every time you correct the same thing twice,
> that correction belongs in here instead of in a third prompt.

---

## Part C — Agent mode: review a cross-file change like a PR

**The ticket.** Your Menu Items list shows skeleton cards while it fetches. Your Staff list
shows nothing — it renders empty, then pops. Close that gap.

It's a real gap in your app, it spans a new file and a rewritten one, and the version you're
matching is two folders away — which is exactly the situation agent mode is for, and exactly
the situation where an unscoped one goes shopping.

*(If your Staff list already has a skeleton, target the **Orders** list instead — it has no
loading state either, and a table skeleton is a slightly harder shape.)*

1. **Write the prompt with all four ingredients** (guide section 6). Yours should name:

    - **task** — a `StaffCardSkeleton`, and `StaffList` showing a grid of them while loading
    - **reference** — `#MenuItemCardSkeleton.tsx` and `#MenuItemList.tsx`, which already do
      exactly this
    - **scope** — only the `staff/` folder
    - **constraints** — no new dependencies; reuse the existing `skeleton` classes

2. **Watch the file list as it works.** The moment it opens something outside `staff/`, that's
   the conversation to have — not after it's finished. If your project is in Git,
   `git status` is the fastest check; otherwise read the list of files the agent says it
   touched, and trust that over its summary.
3. **Review the diff hunk by hunk** (guide section 7). Accept only what matches project
   conventions; reject or fix the rest. **Do not "Accept All" unread.** Your conventions file
   from Part B is in force here too — notice whether this diff needed less correcting than
   Part A's output did.

### The rubric — every row must pass before you'd merge this

| # | Check | Pass |
|---|---|---|
| 1 | **Scope:** only files inside `staff/` changed. `menuItems/` is untouched | |
| 2 | The new component is `staff/StaffCardSkeleton.tsx` — in the feature folder, not a shared `components/` directory | |
| 3 | It reuses the **`skeleton` / `skeleton-text` classes already in `App.css`** — it didn't invent a spinner or a new animation | |
| 4 | **No new dependency.** A skeleton library is the obvious reach here, and it's a rejection | |
| 5 | The skeleton is the **same outer shape** as a real `StaffCard`, so the grid doesn't jump when data arrives | |
| 6 | `loading` is cleared in a **`finally`**, so a failed fetch doesn't leave skeletons on screen forever | |
| 7 | The existing **error toast** still fires on a failed load | |
| 8 | **Flexbox utilities only** — no `row`/`col` crept into the new markup | |
| 9 | Nothing else in `StaffList` changed behaviour — the `.map()`, the `key`, and `removeStaff` still do what they did | |
| 10 | You can **explain every line** you kept | |

**Rubric rows 4 and 6** are the ones generated code most often fails, and note that **row 6 is
invisible in the browser unless you make the fetch fail.** **Row 1** is the one that's
invisible in the diff view, if you only read the hunks it chose to show you.

4. **Verify in the browser** — `npm run dev`, open the Staff page, and confirm a clean
    DevTools **Console** and the expected **Network** calls.
5. **Actually see the skeleton.** It's gone in 80ms on localhost. In DevTools → **Network**,
    set throttling to **Slow 3G** and reload. If you never see it, you haven't verified it.
6. **Then make the fetch fail** — stop your API and reload. The error toast should appear and
    the skeletons should go away. That's rubric row 6, and it's the only way to check it.

> You don't have to *keep* the change — reviewing and rejecting a bad diff is a complete,
> correct outcome, and saying *why* in one sentence is the whole skill. In the team block
> you'll do this against a rubric a teammate applies to your pull request; here you're both
> the author and the reviewer.

---

## What to hand in

**1. Your "guardrails Copilot crossed" list.** A short list (aim for 3–5) of convention
violations Copilot introduced when you didn't steer it, each with the convention-matching fix:

- *Generated `import axios` — replaced with `fetch(...).then(checkStatus).then(parseJSON)`.*
- *Built the form with a `useState` per field — this app uses react-hook-form (`register`/`handleSubmit`).*
- *Laid the fields out with `className="row"` / `col-6` — redone with `d-flex flex-row gap-4` + `w-50`.*

**2. Your `.github/copilot-instructions.md`**, plus the three violation counts from Part B.

**3. Part C's rubric, filled in** — and if any row failed, one sentence on what you did about
it. "Row 4 failed — it added `react-loading-skeleton`; rejected and pointed it at the existing
`skeleton` classes" is a complete answer. So is "rows 4 and 6 failed, the diff was further from
our patterns than it was worth repairing, and I threw it away."

Together they're the evidence for the three things this lesson is actually about: you can
generate *fast* and still ship only what fits this codebase; you can make the tool stop
fighting you in the first place instead of catching it every time; and you can judge a
generated change against a written standard rather than against whether it looks finished.

---

## Verify anything you kept from Parts A and B

Part C has its own verification steps and rubric. For whatever you kept out of the earlier
parts — browser setup (`npm run dev`, your API up with CORS, DevTools) is covered in the guide
and Lesson 4 — confirm:

1. Anything you **kept** renders correctly and the **Console** is error-free.
2. The **Network** tab shows calls hitting your API (not a stray `axios` default or wrong
   base URL).
3. Any form you touched still validates and saves via react-hook-form + toasts.

---

## Stretch challenges

Optional — for when you finish early. Not required.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs some
research.

- **Steer vs. unsteered, measured** — [Reinforce] — regenerate the same component four ways:
  no context, with a `#` reference file, with a reference file **plus** the constraints
  paragraph, and with your conventions file doing the work instead. Count the guardrail
  violations in each. Prove to yourself which lever is worth pulling and when.
- **Tighten a rule that isn't landing** — [Reinforce] — take one rule from Part B that
  Copilot still broke, and rewrite it. Vague rules get ignored: *"follow our fetch
  conventions"* is unactionable, *"fetch through `utility/fetchUtilities` —
  `fetch(...).then(checkStatus).then(parseJSON)`; never `axios`"* is not. Re-test it.
- **Convert a static page** — [Reinforce] — take one finished Bootstrap page from the
  HTML/CSS pass and ask Copilot to convert it into a component, then audit the conversion for
  flexbox-only layout and the feature-folder split. (You did exactly this by hand in the
  capstone — compare.)
- **Agent-mode a whole feature folder** — [Reach] — have agent mode scaffold a small new
  entity's feature folder (interface, API, page, list, card, form) end to end, then review
  the entire diff against our conventions before keeping any of it. **Write the rubric
  first**, before you look at what it produced — a standard you set afterwards is a standard
  you fit to the output. Research agent mode:
  [Copilot Chat in VS Code](https://code.visualstudio.com/docs/copilot/overview).
- **Copilot as tutor** — [Reinforce] — ask Copilot to **explain** a generated hook or the
  async `defaultValues` pattern, and confirm its explanation matches what the code does.

For the bigger challenge — building a whole PRS feature with agent mode against a review
rubric — see challenge #8 in [stretch-react-challenges.md](stretch-react-challenges.md).
It's unlocked now that the capstone is behind you.

> **Next lesson closes the door again, briefly.**
> [Lesson 17](lesson-17-guide-first-unit-tests.md) is hand-written only — you can't judge a
> generated test if you've never written one. Generation comes back in Lesson 18, aimed at
> tests, along with the specific way they go wrong.

---

Same generate-then-triage discipline, now on code an AI wrote. You built TableServe and PRS
by hand first, and that's the whole reason you can judge this output at all — from here you
can lean on Copilot to move fast, as long as *you* remain the engineer who decides what's
good enough to keep.
