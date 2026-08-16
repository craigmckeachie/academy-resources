---
title: "Lesson 2 Lab — Working a vertical slice (Sprint 2)"
---

# Lesson 2 Lab — Working a Vertical Slice (Sprint 2)

Your Sprint 2 ticket reaches from the database to the screen, and you're not the only person
in the code this week. This is the checklist you work beside your issue — the guide's sequence,
in the order you'll hit it.

Read your issue first. Then work the parts in order.

<!-- Authoring note (not student-facing): this lab is TICKET-AGNOSTIC on purpose. The three
     students hold different tickets and the backlog is instructor-only, so it must never
     restate acceptance criteria or branch per ticket. Part 3's table sorts by the SHAPE of a
     change, not by ticket ID — keep it that way.
     Part 4 must NOT name a file, a ticket pair, or a specific line. This sprint's collision is
     engineered and has to be DISCOVERED; naming the file tells the two students holding those
     tickets they're on a collision course. A generic warning is the whole point.
     Which tickets collide, and where, is instructor-only — it lives in the private planning
     notes and must never be restated here, not even in a comment. Comments ship in the
     published page source.
     No stretch-challenge section anywhere in this block — the backlog is the stretch work. -->

Keep the [Lesson 2 guide](lesson-02-guide-depth-in-a-shared-codebase.md), the
[team charter](team-charter.md), and the
[Git collaboration quick-start](../reference/git-collaboration-quickstart.md) open.

---

## Part 0 — Start the sprint

Together, at one screen, before anyone branches. Same routine as Lesson 1, section 7.

1. **Actions → Create sprint issues → Run workflow → `2`.** Six issues appear, unassigned.
2. **Read all six.** Three of them touch the requests list; you need to know whose is whose.
3. **Assign, respecting the dependencies** — they're on the issues:

    - **S2-D**, **S2-E** and **S2-F** all need **S1-C** merged first
    - **S2-F** needs **S2-D** merged first, and it's likely a different person — say so out
      loud now rather than discovering it when someone's blocked
    - **The migration ticket merges before anything else lands**

4. **Two each is the shape**, and six in a sprint is more than the sprint has room for — expect
   to carry one. **Check the plan with your instructor before anyone branches.**

✅ **Checkpoint:** six issues, assigned, dependencies understood, instructor has seen it.

---

## Part 1 — Before you branch

5. At standup, confirm **who the database schema owner is** this sprint — the one person allowed
    to change the database. If it isn't you, you do not run `Add-Migration` — not once, not to
    check something.
    [Guide §2](lesson-02-guide-depth-in-a-shared-codebase.md#2-migrations-in-a-team-the-database-schema-owner)
    has the half-day mess this prevents.

6. Read your issue and write down **which layers it touches**, in this order:

    ```
    SQL Server  →  Prs.Api controller  →  Prs.Web API module  →  Prs.Web component
     (a table)     (…Controller.cs)       (…API.ts)              (….tsx)
    ```

    Some tickets touch all four; some touch only the last one. Knowing which before you start is
    what stops a "small" ticket becoming three days.

7. If your ticket has a **dependency** on a teammate's — it says so on the issue — find out where
    theirs stands before you plan your day.

8. **When the database schema owner's migration merges**, stop what you're doing and take it:

    ```bash
    git switch main && git pull origin main
    ```

    Then `Update-Database` in the Package Manager Console. Now, not when you next happen to need
    it — a stale local database produces errors that look like bugs in your own code.

✅ **Checkpoint:** you can name the database schema owner, the layers your ticket touches, and
anything you're waiting on.

---

## Part 2 — The work

9. Branch from a **fresh** `main`:

    ```bash
    git switch main && git pull origin main && git switch -c feature/<issue>-<short-slug>
    ```

    e.g. `git switch -c feature/21-duplicate-request`. The number is **your** issue.

10. Work outside-in or inside-out, but **finish one layer before you start the next** — an endpoint
    you've verified in Insomnia is a fixed point you can build the page against. Half of each is
    the slowest way to do this.

11. **If you're adding a parameter to an endpoint that already has callers** —
    [guide §3](lesson-02-guide-depth-in-a-shared-codebase.md#3-extending-an-endpoint-without-breaking-it),
    all four at once:

    - optional, **with a default** (`string? foo = null`)
    - the filter applied **inside an `if`**, so no parameter means no filtering
    - `AsQueryable()` before the `if`
    - every existing `Include` still **before** the filter

12. **If you're adding a navigation property to a foreign key that already exists**, that is not a
    schema change and `Add-Migration` isn't yours to run —
    [guide §2](lesson-02-guide-depth-in-a-shared-codebase.md#2-migrations-in-a-team-the-database-schema-owner)
    on why an **empty** migration is the correct outcome there.

13. **Push and open the pull request early** — while it's still small, even if it's a draft. A
    branch open for a few hours rarely collides; one open for three days collides with everything.

✅ **Checkpoint:** your branch is pushed and its pull request is open, titled the way it should
read on `main` — imperative, and specific enough that a reviewer doesn't have to open the diff.

---

## Part 3 — Verify your own slice

Every ticket gets verified in the running app. What else you owe depends on the **shape** of your
change, not on which ticket you drew:

| If your ticket… | In the browser | In Insomnia | Also |
|---|---|---|---|
| **adds a table or column** | the page that displays it, with real seeded data | the new endpoints, **and every existing endpoint on that entity** | SSMS: the table exists, and your migration is the last row in `__EFMigrationsHistory` |
| **adds a new endpoint** to an existing controller | the button or page that calls it | the new endpoint — **and the ones beside it in the same folder**, unchanged | — |
| **adds a parameter** to an existing endpoint | the control that sets it, **and the page with that control untouched** | the call with **no new parameters at all** | — |
| **changes only the front end** | the feature, then **reload the page** — and every other control on that page | — | — |

14. Work your row of that table.
15. **If your change crosses the wire** — a new parameter, a new endpoint — do the check a diff
    can't show you: **change the control and watch the Network tab.** A parameter spelled one
    way in the controller and another way in the API module produces no error anywhere — the
    value just never arrives. Read the request URL that actually goes out; don't infer it from
    the code.

16. **If you touched a query**, the quiet one from
    [guide §3](lesson-02-guide-depth-in-a-shared-codebase.md#3-extending-an-endpoint-without-breaking-it):
    look at every column the page was already showing. A dropped `Include` doesn't throw. It
    empties a column.

17. **If your ticket is front end only**, there's no wire to watch and no query to break — so
    the equivalent is to **exercise everything that page could already do.** You've changed a
    component other features render through; the risk isn't a missing column, it's a control
    that worked yesterday and quietly doesn't now. Click all of them, including the ones your
    ticket never mentions.

18. Run through your issue's acceptance criteria one at a time and tick them off. The charter's
    [definition of done](team-charter.md#definition-of-done) is the bar, not "it works on my
    machine."

✅ **Checkpoint:** every acceptance criterion on your issue is ticked, and — if you touched an
endpoint — its **old** request returns exactly what it returned before your branch existed.

---

## Part 4 — If you hit a conflict

Sprint 1's conflict was three rows in a table and the answer was keep all three. Don't assume this
one works that way.

19. **Before you open the merge editor, find out what the other change was for.** The issue number
    is in the branch name and on the pull request. Read the issue.

20. Resolve for **both intents** — not for whichever side looks tidier, and not by accepting one
    side because the result compiles.

21. Confirm no markers survived — search the project for `<<<<<<<`.
22. **Run the app and exercise both features.** Yours *and* theirs, together, in one session. This
    is the step that catches a wrong resolution, and nothing else does.

23. Say in the pull request **what you merged and why**. Your reviewer is about to approve a
    resolution they didn't make and can't see the reasoning for.

!!! warning "A clean resolution is not a correct resolution"

    When two branches each add something to the same call, most of the ways to resolve it
    **compile and render a working page** — with one person's feature silently doing nothing.
    Nothing turns red. Nobody finds out until whoever wrote that feature goes to use it.

    [Guide §4](lesson-02-guide-depth-in-a-shared-codebase.md#4-when-keep-both-isnt-the-answer) has
    the four options and which three of them lie to you. The only proof is step 22.

✅ **Checkpoint:** both features work, in the same running app, after the merge.

---

## Part 5 — The pull request, and a teammate's

24. Fill in all three sections. On a vertical slice, "How I verified it" is where the work shows:

    ```markdown
    ## What this changes

    Adds a Duplicate action to the request detail page and the endpoint behind it.

    Closes #21

    ## How I verified it

    - Insomnia: the new endpoint returns 201 with the copied lines and the right total;
      Get All Requests and Get Request By Id are unchanged
    - Browser: duplicated request #4 — new request opens with all 3 lines and the same
      total, original untouched
    - Merged #19 into this branch; kept both parameters. Ran search with a status set
      and the new action, both work

    ## AI use

    Copilot Chat to explain how the existing total recalculation worked. Rejected its
    suggestion to add a DTO for the response — we return models directly.
    ```

25. **Review a teammate's**, and rotate — not the same person as last time. Run it, then work
    [guide §5](lesson-02-guide-depth-in-a-shared-codebase.md#5-reviewing-a-vertical-slice)'s four
    questions in order:

    - Does the endpoint still work for its **old** callers? Send the request with none of the new
      parameters.
    - Does the page still show **everything it showed before**?
    - Are the two halves **actually talking**? Change the control, watch the network request.
    - Was a migration involved, and was it **the database schema owner's**? A migration file on
      anyone else's branch is a finding, not a detail.

26. Leave at least one line comment, then submit **Approve** or **Request changes** with a summary
    of what you actually did. If you only read the diff, say so — the charter requires it, and on
    a vertical slice it tells the author exactly how much their approval is worth.

27. Once yours is approved: squash-merge, then

    ```bash
    git switch main && git pull origin main
    git fetch --prune
    git branch -d feature/21-duplicate-request
    ```

✅ **Checkpoint:** your ticket is on `main`, you've reviewed at least one teammate's, and your
local `main` is current for the next branch.

---

**No stretch challenges in this block** — the backlog is the stretch work, and there's more of it
than any team can finish. If you're done, take the next ticket.

---

Sprint 1 taught you the loop on a ticket that couldn't hurt anyone. This sprint the same loop
carries a change that spans four layers and lands in a file someone else is also editing. Nothing
about the mechanics changed — what changed is that "done" now includes the question you can't
answer from your own diff: *what does this break for someone I can't see?*
