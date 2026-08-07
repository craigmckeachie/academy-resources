---
title: "Lesson 3 Lab — Handing off a ticket, and owning the result"
---

# Lesson 3 Lab — Handing Off a Ticket, and Owning the Result

You watched a ticket go out to an agent and come back. Now do yours — in a worktree, audited
before it's pushed, and defensible line by line in review.

Read your issue first. Then work the parts in order. **Part 1 happens before you open the
agent**, and it's the part that decides how the rest goes.

<!-- Authoring note (not student-facing): TICKET-AGNOSTIC, same as the L2 lab — AG-1, AG-2 and
     AG-3 go to three different students and the backlog is instructor-only, so never restate
     acceptance criteria or branch per ticket. Part 4's table is keyed on the SHAPE of the change
     (one component · new endpoint), not on ticket IDs.
     Do NOT reproduce the guide's example prompt (§4) or its worked AI-use section (§7) here — the
     lab names the ingredients and points back. Sprint 3's tickets are chosen to share no files,
     so there is deliberately no conflict part; that's Sprint 2's lesson, not this one.
     No stretch-challenge section anywhere in this block — the backlog is the stretch work. -->

Keep the [Lesson 3 guide](lesson-03-guide-supervising-an-agent-in-a-worktree.md), the
[Copilot quick-start](../reference/copilot-quickstart.md), and the
[team charter](team-charter.md) open.

---

## Part 1 — Scope it, before the agent exists

1. **Read the issue, then go look at the running app.** Click through the screen it's about and
    find the code behind it. Five minutes, by hand.
2. **Write down the files you expect to change.** A list, on paper or in a scratch file. Mark any
    file you expect the agent to *read but not modify*.

    This list is the whole exercise's foundation. Written first it's evidence; written afterwards
    it's an opinion you formed by looking at what the agent did —
    [guide §2](lesson-03-guide-supervising-an-agent-in-a-worktree.md#2-scope-the-ticket-before-you-start-it)
    makes that case at length.
3. **Find the precedent** — the place in this codebase that already solves a similar problem, and
    read it. A filter, a formatting helper, an endpoint that returns something unusual: whatever
    your ticket needs, something near it probably exists.
4. **If your ticket could reasonably be built two ways, decide now**, and decide it the way the
    app already does it. That's a design call, and it isn't the agent's to make — it has no way to
    know which of the plausible approaches your team already chose.

✅ **Checkpoint:** you have a written file list and a named precedent — file and function — and
you have not opened Copilot yet.

---

## Part 2 — A worktree of its own

5. **From the repository root** — not from inside `Prs.Web`, or the worktree lands inside your
    repo:

    ```bash
    git switch main && git pull origin main
    git worktree add ../prs-agent-<slug> -b feature/<issue>-<slug>
    git worktree list
    ```

    `git worktree list` prints absolute paths. Read them and confirm the new folder is a
    **sibling** of your repo, not a child.
6. A worktree contains only the files Git tracks, so two things are missing. In the worktree:

    - `npm install` in its `Prs.Web`
    - copy in your gitignored local config — `appsettings.Development.json` and its connection
      string

7. **Stop the API in your original checkout before you start the one in the worktree.** Both bind
    `http://localhost:5555`, and `Prs.Web` has that address hard-coded. Two branches on disk is
    not two running apps — see the guide's §3 warning for the failure mode where everything
    *looks* fine and you're testing the agent's front end against your own back end.
8. Open the worktree as **its own VS Code window**, so the agent's context is that folder and
    nothing else:

    ```bash
    code ../prs-agent-<slug>
    ```

    Start Copilot Chat in that window and switch it to **agent mode** there.

✅ **Checkpoint:** `git worktree list` shows two entries on two branches, the app runs from inside
the worktree, and `git status` in your original folder is clean.

---

## Part 3 — Hand it over, and watch

9. Prompt it with **four things** —
    [guide §4](lesson-03-guide-supervising-an-agent-in-a-worktree.md#4-code-along-handing-the-ticket-over)
    has a worked example to adapt:

    - the ticket
    - your file list, as an explicit *change only these files*
    - the precedent, named by file and function
    - the conventions it's likely to break

    **No open-ended invitations.** "Add any improvements you see" is how a three-file ticket
    becomes an eleven-file diff, and every extra file is yours to explain.
10. **Read its first response before it gets going.** If it opens by naming a file you didn't
    expect, ask why *now* — not after it's finished.
11. While it works, periodically, in the worktree:

    ```bash
    git diff --stat main...HEAD
    ```

    One line per file. Compare against your list. Three seconds, and it's the difference between
    catching scope creep and discovering it in review.
12. **Commit checkpoints as it goes.** They're about to be squashed, so they cost nothing, and
    they let you back out one step instead of all of them.
13. When a file appears that isn't on your list, decide which happened:

    - **The ticket genuinely needed it** — add it to your list and say so in the pull request. A
      documented scope change is a good sign.
    - **It decided to improve something** — revert that one file and carry on:

        ```bash
        git restore <path/to/file>
        ```

14. Read its summary of what it did, then **verify with `git`, not with the summary.**

✅ **Checkpoint:** `git diff --stat main...HEAD` lists only files on your list — or you can say
out loud why each extra one is there.

---

## Part 4 — Audit, then run

Two passes, in this order, **before** you run anything. A change can work perfectly and still be
wrong for this codebase.

15. **Pass one — conventions.** Work the table in
    [guide §6](lesson-03-guide-supervising-an-agent-in-a-worktree.md#6-the-audit-pass-before-you-open-the-pull-request)
    against the diff: DTOs, `[Authorize]`,
    a repository layer, `EntityState.Modified`, status string literals, `virtual` navigation
    properties, `row`/`col` grid classes, Bootstrap by CDN, `import type`, `axios` or an inline
    `fetch`. Each one is a mechanical check.
16. **Pass two — consistency.** No watch-list covers this; it needs someone who has read the app.
    Start with your ticket's shape:

    | If your ticket… | Check first | Then | The criterion an agent skips |
    |---|---|---|---|
    | **changes how one component renders** | it still renders everything it rendered before — no field quietly dropped | it matches its sibling components rather than inventing a new style | the **empty or missing value** — most seeded rows are the happy path |
    | **adds a parameter to an existing endpoint** | the parameter is optional **with a default**, applied inside an `if` | every existing `Include` survived the rewrite | the call with **no parameter at all**, unchanged |
    | **adds a new endpoint** | it follows the conventions of the ones beside it — route shape, status codes | the front end and controller spell the same thing the same way | the **awkward input** your criteria name — agents write the happy path |

    Whatever your row, ask the question the whole audit exists for: **which of these failures
    would still leave the feature working when I click it?** Those are the ones running it won't
    find.
17. **The comprehension check.** Pick the three least obvious lines in the diff and explain each
    one out loud — not *"it filters the products"*, but why that hook, why that dependency array,
    why that guard. If you can't, you have two honest options: read until you can, or delete those
    lines and write them yourself.
18. **Now run it.** The definition of done hasn't changed: verified in the browser, and in
    Insomnia if an endpoint changed. Work your issue's acceptance criteria one at a time,
    including the one your row above says gets skipped.
19. **Consider throwing it away.** Three signals, from
    [guide §9](lesson-03-guide-supervising-an-agent-in-a-worktree.md#9-when-to-throw-it-away) — the diff is bigger than the
    ticket and you can't account for the difference; you're spending longer editing its code than
    writing your own would have taken; you can't explain it and re-reading isn't helping. If two
    of the three are true, from your **original** folder:

    ```bash
    git worktree remove --force ../prs-agent-<slug>
    git branch -D feature/<issue>-<slug>
    ```

    Then do the ticket by hand. **This is a legitimate outcome and it is not a failure** —
    recognising it early is the judgement being assessed here.

✅ **Checkpoint:** both audit passes are done, you can explain any line a reviewer points at, and
the acceptance criteria are met in the running app.

---

## Part 5 — The pull request, and a teammate's

20. Push and open the pull request. All three sections, and here the third one carries the weight:

    - **What this changes** — and `Closes #N`
    - **How I verified it** — specifically, including the edge case from your table row
    - **AI use** — **what you rejected.** Structure it *accepted / changed / rejected*;
      [guide §7](lesson-03-guide-supervising-an-agent-in-a-worktree.md#7-writing-the-ai-use-section)
      has a worked example. "Used agent mode, accepted everything" gets sent back, because it's
      indistinguishable from not having looked.

21. **Review a teammate's**, and rotate. Their diff was generated too, so add five checks to your
    normal review:

    | Check | Pass |
    |---|---|
    | Diff is limited to the files the ticket names | |
    | No convention violations from the watch-list | |
    | Author explained the change in their own words, not the ticket's | |
    | It was actually run, not just read — "How I verified it" is specific | |
    | The diff is small enough to review honestly | |

    That last one is a real finding. If it's too big to read properly, say so rather than
    approving it anyway.
22. Then the twenty seconds that make the gate real: **ask the author why one specific line is the
    way it is.** Not to catch anyone out — it's what separates a diff someone owns from a diff
    someone accepted.
23. Once yours is approved and squash-merged, clean up. From your **original** folder:

    ```bash
    git worktree remove ../prs-agent-<slug>
    git switch main && git pull origin main
    git fetch --prune
    ```

    No `--force` this time — the work is merged, so there's nothing to lose.

✅ **Checkpoint:** your ticket is on `main`, `git worktree list` is back to one entry, and you
reviewed a teammate's generated pull request with the rubric.

---

**No stretch challenges in this block** — the backlog is the stretch work, and there's more of it
than any team can finish. If you're done, take the next ticket.

---

Generation removed the typing constraint and left the reviewing constraint exactly where it was.
Everything in this lab — the file list, the worktree, the two audit passes, the sentence about
what you rejected — exists to keep a diff you didn't type reviewable by someone who didn't write
it either. That's the job, and it doesn't change when the tool does.
