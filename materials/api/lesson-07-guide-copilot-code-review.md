# Lesson 7 Guide — Reviewing Your Code with GitHub Copilot

**Goal:** by the end of this lesson you can point **GitHub Copilot** at a Web API
controller, ask it to review the code, and — the part that matters — **triage** what it
says: accept the genuine improvements, reject the suggestions that fight this course's
conventions, and know *why* for each. You practice on a TableServe controller here; in
the lab you turn the same skill on the **PRS backend you built in the capstone**.

> **This is a tooling lesson, not a build lesson.** There's no new TableServe feature to
> write and nothing to check in Insomnia for its own sake. You verify by **observation and
> judgment** — reading Copilot's suggestions and deciding which are right for *this*
> codebase. (The one exception: if you *accept* a change, you re-run that controller's
> Insomnia folder to confirm it's still green — see section 5.) A later regeneration
> shouldn't "correct" this into building an entity.

**The general pattern you're learning:** an AI review is a **list of opinions, not a list
of facts.** Some are real bugs you should fix; some are generic "best practices" that
don't apply because this project made a deliberate, different choice. Your job is to sort
them — and you can only do that because you built this code by hand and understand it.
Reviewing code you own is the safest, highest-value way to start using AI: it can't do
the work for you, it can only give you a second opinion to judge.

> **Prerequisite:** skim the [GitHub Copilot quick-start](../reference/copilot-quickstart.md)
> first — especially **The discipline: verify, don't trust**, the **house-style
> watch-list**, and **How to hand Copilot Chat your files**. This lesson puts all three to
> work.

---

## 1. What "review with Copilot" means

You open **Copilot Chat**, give it a controller as context, and ask it to review that
code. It reads the file and returns a list of observations — possible bugs, style notes,
"consider extracting this," and so on.

Two things make a review useful:

- **Give it the whole file, live.** The cleanest way is a **`#` file reference** (type
  `#`, pick the controller) or the **Add Context** button — that hands Copilot the current
  contents of a specific file, even one you don't have open. Pasting works too, but it's a
  snapshot that goes stale the moment you edit. (See the cheat sheet's *How to hand Copilot
  Chat your files*.)
- **Tell it the rules of the house.** Copilot doesn't know this project's conventions, so
  it will suggest the "normal" production version of everything. You can head that off by
  putting the constraints in the prompt (section 4).

A first prompt is as simple as:

> Review `#StaffController.cs` for bugs and correctness issues.

---

## 2. A worked review — triaging the suggestions

Say you ask Copilot to review your `OrdersController`. A typical response comes back as a
numbered list. Here's the skill: sort every item into one of **three buckets.**

### Bucket A — accept: a real improvement

These are genuine correctness issues in *your* code, independent of any convention. Fix
them.

- *"`GetById` will throw / return `null` when the id doesn't exist — return `NotFound()`."*
  → **Accept** if you missed the 404 path. This is a real bug, and the course's HTTP
  conventions call for a `404`.
- *"`Update` sets values without confirming the record exists first."* → **Accept** — the
  course's PUT pattern is *fetch-then-`SetValues`*, and the fetch is also your existence
  check.
- *"The response doesn't include the `Staff` navigation property, so it's `null` in the
  JSON."* → **Accept** — you forgot an `Include(o => o.Staff)`. Real bug.

### Bucket B — reject: a house-style violation

These are the ones that separate a student who understands the material from one who
doesn't. Copilot is confidently recommending the production-grade pattern this course
**deliberately drops** — and you reject it, with a reason.

- *"Introduce an `OrderDto` so callers can't over-post fields."* → **Reject.** This course
  uses EF models directly in controllers — **no DTOs.** One less layer while you learn the
  core flow.
- *"Add `[Authorize]` / JWT bearer authentication to protect these endpoints."* → **Reject.**
  There are **no tokens** in this course; login returns the user object and every endpoint
  is open, on purpose. Auth is taught conceptually, not as production security.
- *"Move data access into a repository/service layer."* → **Reject.** `DbContext` is
  injected straight into controllers here — **no repository pattern.**
- *"Use `_db.Entry(order).State = EntityState.Modified;` for the update."* → **Reject.**
  The course pattern is `_db.Entry(current).CurrentValues.SetValues(updated)` — never
  `EntityState.Modified`.
- *"Tighten CORS to specific origins."* → **Reject.** CORS is intentionally wide open for
  teaching.
- *"Mark navigation properties `virtual` to enable lazy loading."* → **Reject.** Lazy
  loading isn't configured; nav properties are always explicitly `Include()`d so data
  loading stays visible.

Every one of these is Copilot **not knowing your rules** — not a gap in your code. (This is
the whole **house-style watch-list** from the cheat sheet, showing up live.)

### Bucket C — ignore: noise or a misread

Some suggestions are harmless nitpicks, restate something you did on purpose, or
misunderstand the design. Note them and move on.

- *"Consider renaming `GetAll` to `GetAllOrders`."* → **Ignore.** The course convention is
  verb-only method names (`GetAll`), entity never repeated.
- *"This method could be `async`."* → **Judgment call.** Fine to ignore in this course's
  synchronous style unless you've been writing async elsewhere.

---

## 3. The triage discipline

For **every** suggestion, do three things:

1. **Decide the bucket** — accept / reject / ignore.
2. **Say why in one line** — "real 404 bug," or "reject: we use no DTOs." If you can't
   articulate why, that's the signal you don't yet understand that part of your own code —
   go read it before you accept *or* reject.
3. **If you accept, verify.** Make the change, then re-run that controller's Insomnia
   folder (section 5). A suggestion that sounded right but turns a green test red was
   wrong for your code.

The output of a review isn't "Copilot fixed my code." It's **you, having judged each point
and understood your controller better.** That judgment is the transferable skill — it's
identical whether the reviewer is an AI, a senior engineer, or a linter.

---

## 4. Prompts that get a more useful review

The review gets sharper when you hand Copilot the constraints up front, so it stops
suggesting the things you'd only reject:

> Review `#OrdersController.cs` for correctness bugs and missing `404`/`400` handling.
> Conventions for this project, do **not** flag these: no DTOs (models used directly), no
> repository pattern (`DbContext` injected into controllers), no `[Authorize]`/JWT (all
> endpoints open), CORS wide open, and updates use `SetValues`, not `EntityState.Modified`.

That single paragraph moves most of Bucket B out of the response before it appears, leaving
a review that's mostly real bugs. Notice this is the same "give it a reference / give it
the constraints" idea from the cheat sheet — you're teaching Copilot the house style one
prompt at a time.

Two other high-value review prompts:

- **Explain, don't just critique:** *"Explain what `_db.Entry(current).CurrentValues.SetValues(updated)` does here."* — Copilot as a tutor for code you're reading.
- **Consistency across files:** *"Using `#codebase`, do all my controllers return the same status codes for GET/POST/PUT/DELETE?"* — a review question no single-file view can answer.

---

## 5. Verifying — how you know a review session went well

There's no "wall of green" for the review itself; you verify by **observation**:

1. **Every suggestion is triaged.** You can point at each item and say accept / reject /
   ignore **and why.** None were accepted just because Copilot sounded confident.
2. **You rejected the house-style violations** — and could explain the course's reason for
   each (no DTOs, no JWT, `SetValues` not `EntityState.Modified`, …). Catching these is the
   clearest sign you understand the material.
3. **Every change you accepted still passes Insomnia.** For any fix you applied, re-run
   that entity's folder in the collection and confirm it's **green** — the pass's normal
   verification tool is still the source of truth for whether the *code* is correct. A
   change that reds a test gets reverted or fixed.

If Copilot found a real bug you'd missed, that's a win — you fixed it *and* you now know
what to watch for. If it found nothing but house-style "improvements," that's also a win —
you correctly rejected all of them.

---

## The General Pattern (what to take away)

- An AI review is **opinions to judge, not fixes to apply.** You own every accept/reject.
- Sort every suggestion into **accept** (real bug), **reject** (house-style violation), or
  **ignore** (noise) — **with a one-line reason each.**
- The rejects are the tell: Copilot will push DTOs, repositories, JWT, `EntityState.Modified`,
  tighter CORS, `virtual` nav properties — the exact simplifications this course made on
  purpose. Rejecting them *with the reason* proves you understand the code.
- **Feed it the constraints** in the prompt so the review is mostly real bugs.
- **Verify accepted changes** the normal way — Insomnia green — because Copilot's
  confidence is not evidence.

You'll use this on every codebase you ever touch, AI-assisted or not: a review is only as
good as the engineer triaging it.

---

## Build Steps

1. Open your TableServe API in the editor with **Copilot Chat** available, and open the
   [Copilot quick-start](../reference/copilot-quickstart.md) alongside for the house-style
   watch-list.
2. In Chat, attach a controller with a **`#` file reference** (e.g. `#StaffController.cs`)
   and ask for a review of bugs and correctness issues.
3. Read the response and **sort every item** into accept / reject / ignore, writing a
   one-line reason for each.
4. Confirm at least the obvious house-style suggestions land in **reject**, and that you
   can state the course's reason (no DTOs, no `[Authorize]`, `SetValues` not
   `EntityState.Modified`, etc.).
5. Re-run the review with the **constraints paragraph** from section 4 and notice how many
   Bucket-B items disappear.
6. Apply any **real** fix Copilot surfaced, then **re-run that controller's Insomnia
   folder** to confirm it's still green.
7. Try one **explain** prompt on a line you're unsure about (e.g. `SetValues`, or an
   `Include()`), using Copilot as a tutor rather than a generator.
