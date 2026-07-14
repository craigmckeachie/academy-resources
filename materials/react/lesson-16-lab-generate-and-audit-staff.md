# Lesson 16 Lab — Generate a Staff Feature with Copilot, Then Audit It

Use Copilot to **generate** a piece of the Staff feature you already built by hand, then
**audit** what it produced against your working version and this app's house style. Because
you built Staff across Lessons 3–12, you have a ground-truth reference to judge Copilot's
output against — that's the whole point.

Keep the [Copilot quick-start](../reference/copilot-quickstart.md) open for the guardrails,
and refer back to the guide's section 4 (the house-style table) and section 5 (reviewing an
agent-mode diff).

---

## Part A — Chat: generate a component and diff it against yours

1. Pick a Staff file you built — `StaffCard.tsx`, `StaffList.tsx`, or the `StaffAPI.ts`
   module.
2. In Chat, ask Copilot to generate that piece **from a description** — first with **no
   reference file** (e.g. *"Write a StaffAPI module with list, find, post, put, and delete
   for a `/staff` endpoint"*).
3. **Diff it against your real file.** List every difference, and bucket each: house-style
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

---

## Part B — Agent mode: review a cross-file change like a PR

5. Use **agent mode** to make a small change across the Staff feature folder — for example:
   *"Add a `title` field to Staff: update `#IStaff.ts`, `#StaffForm.tsx`, and the API
   payload. Match the existing patterns."*
6. **Review the proposed diff hunk by hunk** (guide section 5). Accept only hunks that match
   house style; reject or fix the rest. **Do not "Accept All" unread.**
7. **Verify in the browser** — `npm run dev`, open the Staff pages, and confirm they render
   with a clean DevTools **Console** and the expected **Network** calls. Revert anything that
   errors or drifts.

> You don't have to *keep* the change — reviewing and rejecting a bad diff is a complete,
> correct outcome. The skill is the review, not the code.

---

## The one thing to hand in — your "guardrails Copilot crossed" list

Write a short list (aim for 3–5) of house-style violations Copilot introduced when you
didn't steer it, each with the house-style fix. For example:

- *Generated `import axios` — replaced with `fetch(...).then(checkStatus).then(parseJSON)`.*
- *Built the form with a `useState` per field — this app uses react-hook-form (`register`/`handleSubmit`).*
- *Laid the fields out with `className="row"` / `col-6` — redone with `d-flex flex-row gap-4` + `w-50`.*

That list is the deliverable — it's the evidence you can generate *fast* with Copilot and
still ship only what fits this codebase.

---

## Verify in the browser

Browser setup (running `npm run dev`, your API up with CORS, DevTools) is covered in the
guide and Lesson 4. Confirm:

1. Anything you **kept** renders correctly and the **Console** is error-free.
2. The **Network** tab shows calls hitting your API (not a stray `axios` default or wrong
   base URL).
3. Any form you touched still validates and saves via react-hook-form + toasts.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs some
research.

- **Steer vs. unsteered, measured** — [Reinforce] — regenerate the same component three
  ways: no context, with a `#` reference file, and with a reference file **plus** the
  constraints paragraph. Count the guardrail violations in each. Prove to yourself that
  context is the lever.
- **Convert a static page** — [Reinforce] — take one finished Bootstrap page from the
  HTML/CSS pass and ask Copilot to convert it into a component, then audit the conversion for
  flexbox-only layout and the feature-folder split. (This is exactly the capstone's job.)
- **Agent-mode a whole feature folder** — [Reach] — have agent mode scaffold a small new
  entity's feature folder (interface, API, page, list, card, form) end to end, then review
  the entire diff against house style before keeping any of it. Research agent mode:
  [Copilot Chat in VS Code](https://code.visualstudio.com/docs/copilot/overview).
- **Copilot as tutor** — [Reinforce] — ask Copilot to **explain** a generated hook or the
  async `defaultValues` pattern, and confirm its explanation matches what the code does.

For the bigger, capstone-facing challenge — building a whole PRS feature with agent mode
against a review rubric — see [stretch-react-challenges.md](stretch-react-challenges.md).

---

Same generate-then-triage discipline, now on code an AI wrote: on the PRS capstone you can
lean on Copilot to move fast, as long as *you* remain the engineer who decides what's good
enough to keep.
