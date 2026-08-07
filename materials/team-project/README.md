# Team Project — Lesson Materials

This folder contains the materials for the **team development block** — the final stretch
of the course, after the PRS capstone. You work in teams of three in a shared GitHub
repository seeded with a working copy of PRS, taking tickets and defects from a backlog
your instructor writes.

Two things make this block different from everything before it. **You didn't write this
code** — you're working in a codebase handed to you, which is what your first weeks on the
job look like. And **the AI restrictions lift**: generation and agent mode are on the table
now, under the condition that a teammate reads every line before it merges.

## File types

**`lesson-{N}-guide-*.md`** — the concept reference (**I do**). Read through this during
the instructor-led session. Sections marked **▶ Code along** are ones you type as you go.

**`lesson-{N}-lab-*.md`** — the hands-on exercise (**You do**). Terse numbered steps — refer
back to the guide for the explanations.

**`team-charter.md`** — the working agreement. Not optional reading; it's what your pull
requests are held to.

## Schedule

| Lesson | Guide | Lab | Sprint it briefs |
|--------|-------|-----|---|
| 1 | [Collaborating in a shared repository](lesson-01-guide-collaborating-in-a-shared-repo.md) | [Your first pull request, and your first conflict](lesson-01-lab-first-pull-request.md) | Sprint 1 |
| 2 | [Depth in a shared codebase](lesson-02-guide-depth-in-a-shared-codebase.md) | [Working a vertical slice](lesson-02-lab-working-a-vertical-slice.md) | Sprint 2 |
| 3 | [Supervising an agent in a worktree](lesson-03-guide-supervising-an-agent-in-a-worktree.md) | [Handing off a ticket, and owning the result](lesson-03-lab-handing-off-a-ticket.md) | Sprint 3 |
| 4 | [Working a bug ticket](lesson-04-guide-working-a-bug-ticket.md) | [Reproduce, narrow, fix](lesson-04-lab-reproduce-narrow-fix.md) | Sprint 4 |

The block runs as **four sprints, each briefed by the lesson before it**:

```
Lesson 1 → Sprint 1 → Lesson 2 → Sprint 2 → Lesson 3 → Sprint 3 → Lesson 4 → Sprint 4 → cross-team review
```

Each **guide** explains the ideas; each **lab** is the checklist you work beside your GitHub issue.
Your instructor assigns the tickets themselves as issues.

## Start here

- [**Configuring Git**](configuring-git.md) — one-time global setup. **Do this first**, on
  the machine you'll be working on. Several of the settings exist specifically to prevent
  problems you'd otherwise hit once three people share a repository.
- [**Team charter**](team-charter.md) — the rules, the definition of done, and what's being
  counted. Read it before your first pull request.
- [**Git collaboration quick-start**](../reference/git-collaboration-quickstart.md) — the
  lookup sheet for branches, pull requests, conflicts, and worktrees. Keep it open.
- [**AI use policy**](../reference/ai-policy.md) — the deferred column opens up in this
  block. Know what changed and what didn't.
- [**Copilot quick-start**](../reference/copilot-quickstart.md) — the conventions watch-list
  is what you'll be auditing generated code against.

## Tips

- **You're working in PRS** (Users, Vendors, Products, Requests, RequestLines) — the same
  app you built in the capstone, but from a shared copy rather than yours.
- **You share a repository, not a database.** Each of you runs your own local SQL Server
  database from the same migrations and the same seed script.
- **All seeded passwords are the plaintext `test1234`.**
- **Run the API on the `http` profile** — the same as the capstone.
- **One schema owner per sprint.** Only that person runs `Add-Migration`. Everyone else
  pulls `main` and runs `Update-Database`.
- **Short branches merge easily.** A branch open for a few hours rarely conflicts; one open
  for days always does.
- **The bottleneck is review, not typing.** Three people can only honestly review so much
  code in a day — including the code an agent wrote for you.
