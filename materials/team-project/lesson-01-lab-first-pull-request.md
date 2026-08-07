---
title: "Lesson 1 Lab — Your first pull request, and your first conflict"
---

# Lesson 1 Lab — Your First Pull Request, and Your First Conflict

You've watched the loop. Now run it yourself — and this time all three of you edit the same
lines on purpose, so somebody has to resolve a real conflict.

Work through the parts in order. Don't coordinate who pushes first; the race is the point.

---

## Part 1 — Three branches, one table

Your repo's `README.md` has a **Sprint 1 assignments** table with a header row and nothing
under it. All three of you are about to add a row to it, in the same place, at the same time.

1. `git switch main && git pull origin main`
2. Branch off it — the pattern, and a filled-in example:

    ```bash
    # the pattern
    git switch -c chore/<issue>-sprint1-assignment-<yourname>

    # what yours actually looks like — issue #3, Craig
    git switch -c chore/3-sprint1-assignment-craig
    ```

    `chore/` because adding a row to a README isn't user-facing behaviour, and the number is
    **your** issue, not someone else's.
3. In `README.md`, add **one row** to the Sprint 1 assignments table: your name, the ticket
    ID you're taking, and one thing you want to get better at this block.
4. Commit in your editor's Git panel, with an imperative message:

    ```
    Add Craig to Sprint 1 assignments
    ```

5. `git push -u origin <your-branch>` — e.g.
    `git push -u origin chore/3-sprint1-assignment-craig`
6. Open the pull request on github.com. **Title it the same way you titled the commit** —
    it's what lands on `main` when this squash-merges. Then fill in all three template
    sections:

    ```markdown
    ## What this changes

    Adds my row to the Sprint 1 assignments table — name, ticket, and what I want to
    get better at this block.

    Closes #7

    ## How I verified it

    - Opened `README.md` on the branch page on GitHub — the table renders with my row
      in it, formatting intact
    - No other rows or sections changed

    ## AI use

    None.
    ```

    Short is fine here — the change is one table row. "None" is a perfectly good AI-use
    section, and a much better one than leaving it blank.

✅ **Checkpoint:** three pull requests are open against the same repo, all touching the same
lines of the same file. GitHub shows **Review required** on each.

---

## Part 2 — Review, and be reviewed

7. Open a teammate's pull request. Read the **Files changed** tab.
8. Leave **at least one line comment** — hover a line in the diff, click the blue **+**. A
    question counts:

    > Ticket 14 — is that the Vendor detail page? Checking we haven't both picked the same
    > one.

9. Click **Review changes**, write a one-line summary, and submit as **Approve** (or
    **Request changes** if something's genuinely off):

    > Read the diff — one row added to the table, nothing else touched. Approving.

    Nobody can *run* a README change, so "read the diff" is the honest summary here. Say
    what you actually did; on a real ticket that sentence will read "pulled it down and ran
    it."

10. When yours is approved, **Squash and merge** it. GitHub deletes the branch on its side
    automatically.
11. **Still only once yours is approved and merged** — bring your local `main` up to date and
    tidy your machine:

    ```bash
    git switch main && git pull origin main
    git fetch --prune
    git branch -d chore/3-sprint1-assignment-craig
    ```

Whoever merges first is done. Everyone else: your pull request now says **This branch has
conflicts that must be resolved.** That's Part 3.

✅ **Checkpoint:** at least one pull request is merged and visible on `main`. At least one
other is showing a conflict.

---

## Part 3 — Resolve the conflict

12. Confirm you're still on your feature branch — `git status`
13. `git pull origin main` — Git stops and reports the conflict in `README.md`
14. Open the file from VS Code's **Source Control** panel → **Resolve in Merge Editor**
15. Decide: mine, theirs, or both. Here it's **both** — every teammate's row belongs in the
    table. Order them however reads best.
16. `git add .`, then `git commit`, then `git push`
17. Search the whole project for `<<<<<<<` and confirm there are no hits
18. Reload the repo page on GitHub — the pull request now says **no conflicts**
19. Get it approved and squash-merge. Then `git switch main && git pull origin main` to bring
    your **local** `main` up to date before the next branch, and `git fetch --prune` plus
    `git branch -d <your-branch>` to clean up

✅ **Checkpoint:** `main`'s README shows **all three rows**. Nobody's row was lost, and no
conflict markers survived.

!!! warning "If your row vanished, you resolved it wrong"

    Accepting only one side is the most common first-conflict mistake — it silently discards
    a teammate's work and it looks clean. Check the merged file on `main` and count the
    rows. If one's missing, open a follow-up pull request and put it back.

---

## Part 4 — Now take your Sprint 1 ticket

The drill is over. Same loop, on real code this time — and from here the block is ticket-driven
rather than lesson-driven.

20. **Find your issue on GitHub.** Your instructor assigned one to each of you. Read it, including
    every acceptance criterion, before you write anything.
21. Branch from a fresh `main` — `feature/` now, not `chore/`, because this one changes behaviour
    a user can see:

    ```bash
    git switch main && git pull origin main
    git switch -c feature/<your-issue>-<short-slug>
    ```

22. Build it. **Keep the branch short** — push and open the pull request while it's still small,
    even as a draft.
23. **"How I verified it" now means you ran it.** A README row could only be read; this can be
    used. Say which page you loaded, what you clicked, and what you saw — and check every
    acceptance criterion on the issue against the running app. The bar is the charter's
    [definition of done](team-charter.md#definition-of-done).
24. **Review a teammate's**, and **run it before you approve it**. If you only read the diff, say
    so in your review — that's honest, and it tells the author what they did and didn't get.
25. Squash-merge, then the three commands from Part 2 to bring your local `main` up to date and
    tidy up.
26. If you finish early, ask for the next ticket. There's more work in the backlog than the sprint
    has room for, by design.

!!! note "No conflict this time — that's deliberate"

    Sprint 1's three tickets touch **no files in common**, so they can merge in any order and
    nobody has to resolve anything. That's the last time it'll be true. Sprint 2 puts more than
    one of you in the same file on purpose, and Lesson 2 is the briefing for it.

✅ **Checkpoint:** your ticket is merged into `main` with a teammate's approval, and you reviewed
one of theirs.

---

## Git drills

Optional — for when you finish early. Not required.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs some
research.

These are the only optional exercises in the block. From Lesson 2 on, the backlog **is** the
extra work — there's more of it than any team can finish, so a lab that ended with invented
challenges would just be competing with your next ticket. Git mechanics are the exception,
because right now you have somewhere to practise them and nothing depending on the result.

- **Make a harder conflict** — [Reinforce] — with a teammate, both edit *the same line* of
  the same README row (not two different rows) and resolve it. Notice how the merge editor
  helps less when the answer isn't "keep both."
- **Read the history** — [Reinforce] — run `git log --oneline --graph --all` after the
  merges land. Find your squashed commit and your teammates'. This is what a reviewer sees
  when they ask "when did this change?"
- **Undo a merge you got wrong** — [Reach] — deliberately resolve a conflict badly on a
  throwaway branch, then recover with `git merge --abort` *before* committing, and with
  `git reset --hard HEAD~1` *after*. Know which one applies when. Research:
  [`git merge` documentation](https://git-scm.com/docs/git-merge).
- **Protect yourself from a stale branch** — [Reinforce] — check how far behind you are with
  `git log --oneline main..HEAD` and `git log --oneline HEAD..main`. Work out which
  direction each one reports.

---

The loop doesn't change again — every ticket in this block is this same trip, and only the
size of the diff moves. What changes is the **conflict**. Keeping all three rows was obvious
because nothing could be silently wrong. Sprint 2 puts two of you in one file, where "keep
both" stops being obvious and a resolution can compile, render, and still be wrong. That's
Lesson 2.
