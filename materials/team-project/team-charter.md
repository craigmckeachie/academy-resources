---
title: Team charter
---

# Team Charter

The working agreement for the team development block. It goes in your team repository's
`README.md` so it's in front of you, not filed away. Everything here exists because a team
that skips it loses a day to something avoidable.

---

## The rules

**One issue, one branch, one pull request.** Branch names carry the issue number:
`feature/12-vendor-detail-page`, `fix/31-line-delete-total`. If you find yourself fixing a
second thing, that's a second branch.

**Name things so a reviewer doesn't have to open the diff.** Branches are
`type/issue-number-short-slug`; commit messages and pull request titles are written in the
imperative — *"Recalculate request total when a line is deleted,"* not *"fixed bug."* Because
we squash-merge, **the pull request title becomes the permanent commit message on `main`** —
so `wip` on your own branch is fine, and a vague pull request title is not. Full guidance:
[Naming: branches and commits](../reference/git-collaboration-quickstart.md#naming-branches-and-commits).

**Nothing reaches `main` without a teammate's approval.** Direct pushes to `main` are
blocked. One approving review from someone who didn't write the code, every time.

**Reviewers rotate.** Don't review the same teammate twice in a row. On a team of three
that's automatic if you pay attention.

**Run the code before you approve it.** If you only read the diff, say so in your review —
that's honest, and it tells the author what they did and didn't get.

**The pull request description is part of the work.** Three things, every time:

- What changed, and `Closes #N`
- How you verified it — specifically
- Where you used AI, and what you changed or rejected in what it gave you

**A fix states the root cause.** "Fixed the total" is not a description — it says what you
touched, not what was wrong. *"The date was parsed in the browser's time zone and rendered
in UTC, so anything after 7pm displayed as the next day"* is.

<!-- Authoring note (not student-facing): this example must stay generic and outside the PRS
     domain entirely. An earlier version named specific PRS code, which risks matching work
     students are asked to reason about later in the block. Don't "improve" it by making it
     app-specific — the vague-vs-specific contrast is the whole point and it works better on
     something unrelated. This comment ships in the published page source, so it must not
     restate what the earlier example said. -->


**Fix what you were assigned, not what you happen to notice.** You will spot things that look
wrong — an odd colour, a clumsy label, a typo — in code no ticket sent you to. Don't quietly
correct them on an unrelated branch: it puts unexplained changes in a diff your reviewer is
reading for something else, and some of what looks wrong is deliberate. **File it as an issue
instead**, and let it be assigned. Noticing is valuable; the drive-by fix is what isn't.

**One database schema owner per sprint.** Only that person runs `Add-Migration`. Their migration
merges first; everyone else pulls `main` and runs `Update-Database` before continuing.
Parallel migrations against the same model produce a mess that costs half a day and teaches
nothing.

**Start every branch from a fresh `main`.**

```bash
git switch main && git pull origin main && git switch -c feature/12-slug
```

**Stand up for five minutes each morning.** What you finished, what you're on, what's
blocking you. Five minutes, standing, no laptops.

---

## AI in this block

The [AI use policy](../reference/ai-policy.md)'s deferred column is **open here.** The
capstone is behind you; generation and agent mode are now on the table, including running
agents autonomously in their own worktrees.

What doesn't change:

- **You own every line.** In review you'll be asked to explain any part of your diff. "The
  agent wrote it" is not an answer.
- **Scope an agent to one ticket.** If the diff touches files the issue doesn't name,
  that's a finding to report, not something to quietly keep.
- **The AI-use section of your pull request describes what you *rejected*.** "Used agent
  mode, accepted everything" gets sent back.
- **Convention violations are yours to catch.** Copilot will reach for DTOs, `[Authorize]`,
  a repository pattern, `EntityState.Modified`, Bootstrap `row`/`col` grid classes,
  Bootstrap by CDN, and `import type`. All wrong for this codebase. The
  [Copilot quick-start](../reference/copilot-quickstart.md) has the full watch-list.
- **Maintain the shared conventions file.** Your repository ships with
  `.github/copilot-instructions.md` — the rules Copilot gets sent on every Chat and agent
  request, for all three of you. When a review catches the same drift twice, the fix is a
  pull request against **that file**, not a third review comment. It's the one piece of this
  block that makes review cheaper instead of just more careful.

The limit on this block isn't how fast anyone can generate code. It's how much code three
people can honestly review. Generate accordingly.

---

## Definition of done

A ticket isn't finished until every one of these is true:

- [ ] Every acceptance criterion on the issue is met
- [ ] Verified in the running app — and in Insomnia if an endpoint changed
- [ ] Follows the existing conventions: no DTOs, no repository pattern, no `[Authorize]`,
      flexbox utilities only (no `row`/`col`), `_db.Entry(current).CurrentValues.SetValues(updated)`
      for PUT
- [ ] The pull request describes what changed, how it was verified, and where AI was used
- [ ] Approved by a teammate who ran it
- [ ] Squash-merged, branch deleted, `main` pulled

---

## What we're counting

Everything is visible in GitHub, which is the point — contribution shows up daily rather
than at the end. Per person, across the block:

| | Target |
|---|---|
| Pull requests authored | one per assigned ticket, minimum |
| Pull requests reviewed | at least as many as you authored |
| Merge conflicts resolved | at least one, hands on keyboard |
| Defects fixed with a documented root cause | at least one |

If you're at zero reviews halfway through, you're not participating — regardless of how
much code you've written.
