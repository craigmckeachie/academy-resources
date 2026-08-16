---
title: "Lesson 3 Guide — Supervising an agent in a worktree"
---

# Lesson 3 Guide — Supervising an Agent in a Worktree

**Goal:** by the end of this lesson you can take a bounded ticket, hand it to Copilot agent
mode working in its own Git **worktree**, keep the diff inside the ticket's scope, audit it
against this codebase's conventions, and open a pull request you can defend line by line.

**The general pattern you're learning:** the skill here is not prompting. It's **being the
reviewer of a contributor who is fast, confident, tireless, and has never read your team's
conventions.** Everything else follows from that. You scope the ticket before you start
because an unscoped ticket produces an unreviewable diff. You isolate the work in a worktree
because you keep building while it works. You audit because the assistant doesn't know your
rules. And you write down what you *rejected*, because that's the only durable evidence that
anyone reviewed anything.

> **This is a tooling lesson, not a build lesson.** There's no feature of your own to add —
> the practice is your assigned agentic ticket, which you'll start during this lesson. Verify
> by **observation**: the diff, the running app, the pull request.

<!-- Authoring note (not student-facing): this lesson deliberately has no entity build — there's
     no feature of the student's own to construct. The lab is a Sprint 3 runbook (worktree setup,
     agent handoff, the two audit passes, the rubric), not a second walked example. This lesson
     also owns the Git worktree material, moved here out of Lesson 1. Don't "correct" either of
     those on a regeneration.
     See materials/CLAUDE.md → Team project (team-project/) for the reasoning. -->


> **How to use this guide.** Sections marked **▶ Code along** are ones you run on your own
> machine, on your **real assigned ticket** — not on a throwaway drill. Unmarked sections are
> concepts; read them, don't type them. Each ▶ section ends with a **Save and check** so a
> mistake surfaces immediately.

[React Lesson 16](../react/lesson-16-guide-building-with-copilot.md) is the prerequisite: it
covered the three Copilot surfaces, agent mode itself, and the conventions watch-list. This
lesson is about everything that happens **after** the generation — which is where the work
actually is. Keep the [Copilot quick-start](../reference/copilot-quickstart.md) open for the
watch-list, and the [team charter](team-charter.md) open for what your pull request is held to.

---

## 1. What changes when you're not the author

The charter says the limit on this block isn't how fast anyone can generate code — it's how
much code three people can honestly review. An agent removes the typing constraint and leaves
the review constraint exactly where it was. Generating without a plan for the review doesn't
speed the team up; it just moves the queue.

Three things are different when you didn't write the diff:

**You can't rely on having thought about it.** Normally, writing the code *is* how you come to
understand the problem — you discover the tricky part by hitting it. Hand the work off and
that discovery doesn't happen, so you have to do the understanding separately, and up front.
That's section 2.

**Your reviewer is reviewing you, not the agent.** *"The agent wrote it"* is not an answer to
a review question. You are the author of that pull request in every sense that matters.

**A long diff is now a worse diff.** Length used to be evidence of effort. It's free to
produce now, and it costs your teammate exactly as much to read as it always did.

!!! note "This is a different skill from Lesson 16"

    Lesson 16 was *can I get it to produce something useful?* This is *can I be accountable
    for what it produced?* The second one is what a job actually asks of you, and it's mostly
    reading, not prompting.

---

## 2. Scope the ticket before you start it

**Before you open the agent, write the list of files you expect the change to touch.** Read
the issue, open the app, click through the screen, find the code. Five minutes, by hand.

This is the highest-value thing you'll do in the whole exercise, and it isn't about planning
— it's about **evidence**. Once the list exists, "is this change in scope?" stops being an
argument and becomes a comparison: your list, against `git diff --stat`. Without it, every
extra file the agent touched has a plausible-sounding justification and you have no ground to
stand on.

The ticket we'll walk through together in this lesson:

> **AG-0 — Filter the products list by vendor.** The Products page shows all fifty products
> with no way to narrow them. Add a vendor filter above the card grid.

!!! note "You've built this before — that's the point"

    By now you've written a server-side filter three times: the requester filter on the requests
    list, then search and sort, then "Anyone else". You know what good looks like here, cold.

    That's deliberate. This lesson isn't about learning the pattern — it's about **judging
    somebody else's attempt at it**. Most of the findings in section 6 are only visible to
    someone who already knows the right answer, and for once that's you. Auditing generated code
    is easy on ground you know and nearly impossible on ground you don't, which is the whole
    reason the AI policy made you build things by hand first.

The first real decision is **where the filtering happens**, and it's a design call before it's a
file list. Fifty products would filter perfectly well in the browser — the page already fetches
all of them. But a product catalogue only grows, and this app already answers that question
elsewhere: the requests list filters **server-side**, by passing the status through to the API.
Follow the app. Filter in the database, not in the browser.

That makes this a **vertical slice** — an endpoint and the page that calls it — which is one
branch, one pull request, and one reviewer who sees the whole change. Read the code and you'd
write down:

- `Prs.Api/Controllers/ProductsController.cs` — `GetAll` takes an optional vendor id
- `src/products/ProductAPI.ts` — `list()` passes it through
- `src/products/ProductList.tsx` — the filter control, and re-fetching when it changes
- `src/products/ProductsPage.tsx` — *maybe*, depending on where the control belongs
- `src/vendors/VendorAPI.ts` — **read only**; `vendorAPI.list()` already exists, so nothing to
  add

And the file that's **not** in scope: `ProductCard.tsx`. That's somebody else's ticket, and the
card doesn't change just because fewer of them are on screen.

### Find the precedent, and name it in the prompt

This codebase **already has exactly this feature**, on a different entity — the status filter on
the requests list. Both halves of it are worth reading before you write a word of prompt.

**The front end, `src/requests/RequestTable.tsx`:**

- the `<select>` sits **above** the panel `section`, not inside it
- the selection lives in the **URL** via `useSearchParams`, not in local `useState` — which is
  why the status filter survives a page refresh
- changing it **re-fetches** rather than filtering an array already in memory

**The back end, `RequestsController.GetAll`:**

```csharp
public async Task<ActionResult<IEnumerable<Request>>> GetAll([FromQuery] string? status = null) {
    var query = _db.Requests
                   .Include(request => request.User)
                   .AsQueryable();

    if (status != null) {
        query = query.Where(request => request.Status == status);
    }

    return await query.ToListAsync();
}
```

Three things to copy from that, and they're all easy to get wrong: the parameter is
**optional with a default**, so the existing no-parameter call still works; the filter is applied
conditionally to an `AsQueryable()`; and the `Include` comes **before** the filter, so the
navigation property survives it. `ProductsController.GetAll` already has
`.Include(product => product.Vendor)` — the cards need it for the vendor name.

*"Match the existing filter pattern in `RequestTable.tsx` and `RequestsController.GetAll`"* is a
constraint an assistant can actually follow, and it's worth more than three sentences of
description. Finding the precedent is your job, not the agent's — it has no way to know which of
the twenty plausible approaches is the one your team already chose.

---

## 3. ▶ Code along — a worktree of its own

Normally, switching branches swaps every file in your folder. A **worktree** gives you a
second folder, on a different branch, sharing the same repository — two branches checked out
at once.

Run this **from the repository root**:

```bash
git switch main && git pull origin main
git worktree add ../prs-agent-<slug> -b feature/<issue>-<slug>
git worktree list
```

Look at the folder next to your repo. It's a complete checkout on a different branch, and your
original folder hasn't moved.

!!! warning "Where you run `git worktree add` decides where the folder lands"

    The `../` is relative to your **current directory**, not to the repository. Run it from
    the repo root and you get a sibling folder, which is what you want. Run it from inside
    `Prs.Web` and `../` means the repo root — so the worktree gets created *inside* your
    repository, where it'll show up as untracked clutter in every `git status`.

    `git worktree list` works from anywhere in the repo and prints **absolute** paths, which
    is the quickest way to confirm the new folder really is a sibling. Simplest habit: **run
    all worktree commands from the repo root.**

Two things bite everyone, both because a worktree is a *fresh folder* containing only the files
Git tracks:

- **Dependencies aren't installed.** Run `npm install` in the worktree's own `Prs.Web`.
- **Anything in `.gitignore` isn't there either** — including `appsettings.Development.json`
  and your connection string. Copy it across by hand.

!!! warning "Run one copy of the app at a time"

    Two branches on disk is not two running apps. `Prs.Api`'s **http** profile binds a fixed
    `http://localhost:5555`, so starting it in the worktree while your own copy is running just
    fails to bind the port.

    The quieter version of this is worse. `Prs.Web` has the API address hard-coded
    (`BASE_URL` in `src/utility/fetchUtilities.ts`), and Vite silently picks the next free port
    for a second dev server — so a front end started in the worktree still calls **whatever is
    on 5555**, which may well be the API from your *other* checkout. Everything looks like it
    works, and you're testing the agent's front end against your own branch's back end.

    So: stop your API before you run the worktree's, and remember which one is up. The worktree
    isolates the **files**, not the ports.

**This is what makes an autonomous agent workable.** An agent edits files as it goes. Point one
at the folder you're working in and you are both writing to the same files, with no way to tell
your changes from its. Point it at its own worktree and it physically cannot touch your work —
you keep building in the foreground, and each stream lands as its own branch and its own pull
request.

**Save and check**

- `git worktree list` shows **two entries**, on two different branches
- The sibling folder exists on disk and holds a **full copy of the project**
- With your other API **stopped**, `npm install` done and your config copied in, the app **runs
  from inside the worktree**
- Your original folder is **still on the branch you left it on**, files untouched

*Leave the worktree in place — you'll remove it once the pull request merges, in section 10.*

---

## 4. ▶ Code along — handing the ticket over

Open the worktree as **its own VS Code window**, so the agent's context is that folder and
nothing else:

```bash
code ../prs-agent-<slug>
```

Or *File → Open Folder* and pick the worktree. You now have two windows: your own work in one,
the agent's branch in the other. Start Copilot Chat in the **worktree window** and switch it to
**agent mode** there.

The prompt is where your section-2 homework gets spent. Give it four things: the ticket, the
file list, the precedent, and the constraints. **Adapt this — don't paste it verbatim:**

```text
Implement this ticket:

  Add a vendor filter above the products card grid on the Products page. Selecting a
  vendor narrows the grid to that vendor's products. An "All vendors" option clears it.

Filter server-side, matching the existing status filter on requests — front end
src/requests/RequestTable.tsx, back end RequestsController.GetAll.

Specifically:
  - ProductsController.GetAll takes [FromQuery] int? vendorId = null and applies it
    conditionally, exactly like GetAll's status parameter on RequestsController
  - keep the existing .Include(product => product.Vendor) — the cards show vendor name
  - GET /api/products with no vendorId must behave exactly as it does today
  - the selection lives in the URL via useSearchParams, so it survives a refresh

Change only these files:
  Prs.Api/Controllers/ProductsController.cs
  src/products/ProductAPI.ts
  src/products/ProductList.tsx
  src/products/ProductsPage.tsx

Read src/vendors/VendorAPI.ts but do not change it — vendorAPI.list() already exists.

Conventions: no DTOs, no [Authorize]. Bootstrap flexbox utilities only, never row/col grid
classes. Plain `import { IProduct }`, never `import type`. No new dependencies.
```

Then stop typing and read what it does.

!!! warning "What not to put in a prompt"

    *"Add any improvements you see,"* *"clean this up while you're in there,"* *"make it
    nice."* Open-ended invitations are exactly how a three-file ticket becomes an eleven-file
    diff, and every one of those extra files is yours to explain in review. Scope is a
    kindness to your reviewer.

**Save and check**

- The agent is working in the **worktree window**, and `git status` in your **original** folder
  is still clean
- Its first response names files that are **on your list** — if it opens with a file you didn't
  expect, that's the moment to ask why, not after it's finished

---

## 5. ▶ Code along — supervising the diff while it works

Don't wait until it announces that it's done. Check the shape of the change while it's still
forming.

In the worktree, periodically:

```bash
git diff --stat main...HEAD
```

That's the whole technique. One line per file, one number per file — everything the branch has
changed so far, compared against the list you wrote in section 2. Three seconds, and it's the
difference between catching scope creep and discovering it in review.

**Commit checkpoints yourself as it goes.** Small commits on the branch cost nothing — they're
about to be squashed — and they buy you two things: you can `git diff` between checkpoints to
see what the last step actually changed, and you can back out *one* step instead of all of them.

!!! note "Why `main...HEAD`, and not just `git diff --stat`"

    Plain `git diff --stat` shows only what's **uncommitted**. So the moment you make a
    checkpoint commit, those files drop out of it — and your scope check quietly reports less
    and less as the branch grows, which is the opposite of what you want. Comparing against
    `main` keeps the whole branch in view, committed or not.

    Both are useful: `main...HEAD` for *what has this branch done*, plain `git diff --stat` for
    *what has it done since my last checkpoint*.

When a file appears that isn't on your list, stop and work out which of two things happened:

- **The ticket genuinely needed it.** Fine — add it to your list and say so in the pull request
  description. A scope change you noticed and documented is a good sign, not a bad one.
- **It decided to improve something.** Revert that one file and move on.

Reverting a single file, leaving the rest of the change alone:

```bash
git restore src/products/ProductCard.tsx
```

Read its summary of what it did, but **verify with `git`, not with the summary.** Agent mode
edits files, creates files, and runs commands; its own account of that is usually accurate and
occasionally isn't. `git diff` is not an opinion.

**Save and check**

- `git diff --stat main...HEAD` lists **only files on your scope list** — or you know exactly
  why each extra one is there
- The app **runs in the worktree** and the filter does what the ticket asked
- Your original folder is **still untouched** — `git status` there is clean

---

## 6. The audit pass, before you open the pull request

Two passes, in this order. Don't skip to running it — a change can work perfectly and still be
wrong for this codebase.

**Pass one — conventions.** The full list is in the
[Copilot quick-start](../reference/copilot-quickstart.md); these are the ones that actually
show up in PRS:

| It will reach for | We use |
|---|---|
| DTOs / view models | The model, straight into the controller |
| `[Authorize]`, JWT middleware | Nothing — there is no server-side auth in this app |
| A repository / service layer | `PrsDbContext` injected into the controller |
| `EntityState.Modified` on PUT | `_db.Entry(current).CurrentValues.SetValues(updated)` |
| `"APPROVED"` as a literal | `RequestStatus.Approved` |
| `virtual` navigation properties | Plain properties, explicitly `Include()`d |
| Bootstrap `row` / `col` grid | Flexbox utilities — `d-flex`, `gap-*`, `flex-wrap` |
| Bootstrap from a CDN | The npm package, already installed |
| `import type { IProduct }` | `import { IProduct }` |
| `axios`, or `fetch` inline in a component | The `{entity}API` object, with `checkStatus` and `parseJSON` |

**Pass two — consistency, which no watch-list can cover.** This is the more interesting half,
because it needs someone who has read the codebase. For AG-0, in order of how much damage each
one does:

- **Is `.Include(product => product.Vendor)` still there?** If the agent rewrote the query and
  dropped it, every card silently loses its vendor name — and the filter itself works perfectly,
  so nothing looks broken until you notice a blank line on fifty cards. This is the one to check
  first.
- **Does `GET /api/products` with no `vendorId` still return all fifty?** Extending an endpoint
  without breaking its existing contract is the actual skill; a parameter that isn't optional, or
  a filter applied unconditionally, breaks every other caller.
- **Does "All vendors" clear the filter, or match nothing?** An empty `<option value="">` handed
  straight to the API can arrive as a value that filters everything out.
- Did it put the selection in the **URL** like the status filter does, or in local `useState`?
  Both work. Only one survives a refresh, and only one matches the app.
- Where did the filter control land? `ProductsPage.tsx` and `ProductList.tsx` both render the
  same `section.list` panel wrapper — the markup is genuinely confusing there, and an assistant
  will pick one at random.
- Did it add a dependency you don't need?

Notice what the first three have in common: **the feature works in the happy path in all three
cases.** Running it proves less than you'd think, which is why the audit is a separate pass and
not just "does it do the thing."

**Then the comprehension check.** Pick the three least obvious lines in the diff and explain
each one out loud. Not "it filters the products" — *why that hook, why that dependency array,
why that guard.* If you can't, you have two honest options: read until you can, or delete those
lines and write them yourself. Opening a pull request you can't explain is the one thing this
block asks you not to do.

**Then run it.** The definition of done hasn't changed: verified in the browser, and in Insomnia
if an endpoint changed — which here it did. For AG-0 that's `GET /api/products` (still all fifty,
each with its vendor) and `GET /api/products?vendorId=3` (only that vendor's), plus the page
itself.

---

## 7. Writing the AI-use section

Your pull request template has three parts, and the third one is the assessment:

```markdown
## AI use

<!-- Which parts were AI-assisted (autocomplete / Chat / agent mode), and what you
     changed or rejected in what it produced. Write "none" if none. -->
```

*"Used agent mode, accepted everything"* gets sent back — not as a punishment, but because it's
indistinguishable from not having looked. What you **rejected** is the evidence. A good one
reads like this:

```markdown
## AI use

Copilot agent mode, in a worktree, from the ticket plus a pointer at RequestTable.tsx
and RequestsController.GetAll.

Accepted: the `int? vendorId` parameter on ProductsController.GetAll and the filter
select in ProductList — both match the status-filter pattern closely.
Changed: it rebuilt the products query and dropped `.Include(product => product.Vendor)`,
so every card lost its vendor name while the filter itself worked fine. Restored it.
Also moved the selected vendor from local `useState` into `useSearchParams` so the
filter survives a refresh, like the status filter does.
Rejected: a `ProductFilterDto` wrapping the query parameter (we don't use DTOs), and
`row`/`col` grid classes on the filter bar (flexbox utilities only).
```

Four lines, and none of them flattering to the agent. It tells your reviewer where to look
hardest, and it's the only lasting record that a person was in the loop.

---

## 8. Reviewing an agent's pull request

When the pull request in front of you was generated, add five checks to your normal review:

| Check | Looking for |
|---|---|
| Diff is limited to the files the ticket names | Scope creep, or an undocumented scope change |
| No convention violations from the table in section 6 | The watch-list, applied |
| The author explained the change in their own words | Not a restatement of the ticket |
| The change was actually run, not just read | "How I verified it" is specific |
| The diff is small enough to review honestly | If it isn't, say so — that's a real finding |

Then do the one thing that makes the gate real: **ask the author why one specific line is the
way it is.** Not to catch anyone out. It's the question that separates a diff someone owns from
a diff someone accepted, and it takes twenty seconds.

!!! warning "Approving code you didn't understand is the failure mode"

    It's worse than requesting changes on code you did understand, and it's much easier to do
    on a generated diff, because generated code *reads* as finished — consistent naming, no
    typos, a comment on every block. Polish is not correctness. If you don't follow it, say
    so in the review; "I can't follow this, walk me through it" is a completely legitimate
    review comment and a useful one.

---

## 9. When to throw it away

Three signals that the honest move is to delete the branch and do the ticket by hand:

- The diff is bigger than the ticket and you can't account for the difference.
- You're spending longer editing its code than you'd have spent writing yours.
- You can't explain it, and reading it again isn't helping.

None of those is a failure. Recognising them **is** the skill this lesson is teaching — the
whole point of scoping and auditing is to reach that judgement early instead of at the review.

From your **original** folder — not from inside the worktree you're deleting:

```bash
git worktree remove --force ../prs-agent-<slug>
git branch -D feature/<issue>-<slug>
```

`--force` because the worktree has uncommitted changes you've decided to abandon, and
`branch -D` because the branch was never merged. Then start the ticket again by hand.

!!! note "Generated code sets a sunk-cost trap that hand-written code doesn't"

    Something you wrote yourself, you can feel the cost of. Something that arrived in ten
    seconds looking finished feels free to keep and expensive to throw away — which is exactly
    backwards. The ten seconds are already spent either way; the only cost still ahead of you
    is your teammate's time reading it.

---

## 10. Cleaning up after a merge

The usual ending. Once a teammate has approved and you've squash-merged, GitHub deletes the
branch on **its** side — the worktree is still sitting on your disk, on a branch that no longer
exists upstream. Again from your original folder:

```bash
git worktree remove ../prs-agent-<slug>
git switch main && git pull origin main
git fetch --prune
```

No `--force` this time: the work is merged, so there's nothing to lose. The `git pull` is the
line that matters — it brings your merged ticket into your local `main` so your next branch
starts from it.

---

## The General Pattern (what to take away)

- **Generation is cheap; review is not.** An assistant removes the typing constraint and
  leaves the reviewing constraint exactly where it was. Generate at the rate your team can
  read.
- **Scope before you start — the file list is the contract.** Written afterwards it's an
  opinion; written first it's evidence.
- **Name the precedent.** Pointing at the code that already solves a similar problem beats any
  amount of describing what you want.
- **Isolation is what makes parallelism safe** — the same primitive, for the same reason,
  whether it's three developers on three branches or one developer supervising an agent.
- **You own the diff.** If you can't explain a line, it isn't yours yet — read it or replace
  it, but don't ship it.
- **What you rejected is the deliverable.** It's the only durable proof that review happened.
- **Deleting a generated branch is a legitimate outcome**, and recognising when to is the
  judgement being assessed.

---

## Build Steps

1. Read your assigned agentic ticket, then **write down the files you expect to change** —
    before opening the agent.

2. Find the **precedent** in the codebase: the place that already solves a similar problem. For
    a filter above a list, that's `src/requests/RequestTable.tsx` **and**
    `RequestsController.GetAll` — read both halves, and decide where the work belongs before you
    prompt anything.

3. **From the repository root:** `git switch main && git pull origin main`, then
    `git worktree add ../prs-agent-<slug> -b feature/<issue>-<slug>`, then `git worktree list`
    to confirm the folder is a **sibling** of your repo.

4. In the worktree: `npm install` in `Prs.Web`, and copy in any gitignored local config
    (`appsettings.Development.json`). Confirm the app runs from there.

5. Open the worktree as its own VS Code window (`code ../prs-agent-<slug>`) and start Copilot
    **agent mode** in that window.

6. Prompt it with the ticket, your file list, the precedent, and the conventions. No
    open-ended invitations to improve things.

7. While it works: `git diff --stat main...HEAD` periodically against your file list, and commit
    checkpoints as it goes. `git restore <file>` anything out of scope.

8. **Audit in two passes** — the conventions table, then consistency with the existing app.
9. **Explain the three least obvious lines out loud.** If you can't, read or rewrite them
    before going further.

10. Run it: the browser, plus Insomnia if an endpoint changed.
11. Push, open the pull request, and write an **AI-use section that says what you rejected**.
12. Review a teammate's generated pull request against the five checks, and **ask them why one
    specific line is the way it is**.

13. Once it merges: `git worktree remove ../prs-agent-<slug>`, then
    `git switch main && git pull origin main` and `git fetch --prune`.

There's no lab for this lesson — your assigned agentic ticket is the lab, and you started it in
section 3.
