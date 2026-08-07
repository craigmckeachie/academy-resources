---
title: "Lesson 4 Lab — Reproduce, narrow, fix"
---

# Lesson 4 Lab — Reproduce, Narrow, Fix

A defect in code you didn't write, reported by someone who isn't a developer. This is the
checklist you work beside your issue — the guide's sequence, in the order you'll hit it.

**One defect at a time.** Finish and verify one before you take the next; three half-done
branches is the failure mode here.

<!-- Authoring note (not student-facing): TICKET-AGNOSTIC, same as the L2 and L3 labs. Students
     get different defects and the bug reports are instructor-only, so never name a defect, a
     file, or a cause — Part 3's table is keyed on the SHAPE of the root cause, not on BUG IDs.
     Do NOT walk BUG-05 or BUG-14 here; they are the L4 guide's reserved worked examples.
     The test-first step is CONDITIONAL by design — only a minority of the filed defects have a
     pure-function root cause. For the rest the Insomnia request or the browser IS the regression
     check, and saying so is what stops "no test" reading as a gap. See planning/team-project/
     sprint-4-bugs.md and tests.md.
     Part 5's reviewer gate (reproduce on main, then confirm gone on the branch) is the whole
     definition of done for this sprint — don't soften it to "read the diff".
     No stretch-challenge section anywhere in this block — the backlog is the stretch work. -->

Keep the [Lesson 4 guide](lesson-04-guide-working-a-bug-ticket.md) and the
[team charter](team-charter.md) open. You'll use more tools this sprint than any other: the
browser and DevTools, Insomnia, SQL Server Management Studio, and the terminal.

---

## Part 1 — Read the report, then reproduce it

1. **Read the issue twice.** The second time, look only for lines saying what *also* happens or
    what *isn't* broken — "products save fine", "refreshing doesn't help", "only on the list
    page". Write those down.
    [Guide §2](lesson-04-guide-working-a-bug-ticket.md#2-the-report-is-evidence-read-it-twice)
    has what each of them buys you. A working path to compare against is the best gift a report
    can give you.
2. **Reproduce it on your machine**, following the reporter's steps literally — **including which
    page they were on**. Some values in this app are computed twice, on the server and again in
    the browser, so the same number can be wrong on one screen and right on another. Checking a
    different screen is not the same test.
3. **Do not open the code yet.** Not the file you suspect, not an assistant.
4. **If you genuinely can't reproduce it**, don't close it. Write down which user you signed in
    as, which record, and what you saw instead — then ask the reporter. Nine times in ten it's a
    missing precondition: a role, a status, a record with an empty field. *"Cannot reproduce"*
    with evidence is a legitimate finding; without evidence it's a guess.

✅ **Checkpoint:** you have seen the bug happen, with your own eyes, on the screen the report
named.

---

## Part 2 — Narrow before you read

5. Ask the layer question: **is the data already wrong when it arrives, or does it go wrong after
    we touch it?** Then pick the tool that interrogates that layer:

    | Layer | Tool |
    |---|---|
    | The database | SSMS |
    | The API's own answer | Insomnia |
    | What actually crossed the wire | DevTools → Network |
    | Client state after it arrives | DevTools → Console, Application |
    | What got rendered | The page |

6. **Pick the cheapest test that splits that list in half** — usually one Insomnia `GET`, or one
    look at the Network tab. One request can eliminate an entire half of the application.
    [Guide §3](lesson-04-guide-working-a-bug-ticket.md#3-code-along-narrow-before-you-fix) walks
    a full narrowing.
7. **If the report handed you a working path**, diff the two paths instead of reading either in
    the abstract. You don't need to understand both — only to find the difference.
8. **Now read the code**, and only the twenty lines narrowing pointed you at.
9. **Using an assistant here is comprehension, not diagnosis** — the opposite of last sprint.
    *"Explain what this method does"* and *"where is the total calculated?"* are what it's good
    at. *"Why isn't this saving?"* produces a fluent, specific, sometimes completely wrong answer,
    and a confident wrong diagnosis is worse than none because you stop looking. Confirm anything
    it claims against the running app before you change a line —
    [guide §5](lesson-04-guide-working-a-bug-ticket.md#5-using-ai-on-code-you-didnt-write).
10. **If its diagnosis was wrong, write that down now** — you'll want it for the pull request, and
    it's the most useful sentence you'll put in there.

✅ **Checkpoint:** you can name the file and the function, and you got there with **evidence** —
a request, a query, a network response — not a theory.

---

## Part 3 — Prove it, then fix it

11. Branch from a fresh `main`:

    ```bash
    git switch main && git pull origin main && git switch -c fix/<issue>-<short-slug>
    ```

12. **Decide what your regression check is**, from the shape of the root cause:

    | If the cause is… | Prove the bug with | Before you fix |
    |---|---|---|
    | **a function you could call from a test** — takes values, returns a value, no database | a test, beside the code it tests | write it and **watch it go red** |
    | **a controller action** | the Insomnia request that exposed it | note the wrong response you got |
    | **rendering or client state** | the reporter's steps in the browser | note exactly what's on screen |

    Only a minority of these defects fall in the first row, and that's the boundary, not a gap —
    there's no C# test project in this course by design. For an API defect the **Insomnia request
    is** the regression check, which is why the definition of done asks for it.
13. **If you're writing a test, write it before you touch the source.** Run `npm test` and watch
    it fail. A test that was never red proves nothing about whether it would have caught anything
    — it's the most common way a suite ends up worthless.
    [Guide §6](lesson-04-guide-working-a-bug-ticket.md#6-code-along-the-failing-test-first).
14. **Fix it.** Then re-run whatever proved the bug in step 12 — the test goes green, or the
    Insomnia request now agrees with the database, or the screen shows the right thing.
15. **Check the siblings.** Other actions on the same controller, other callers of the same
    helper, the other screens rendering the same value. A defect in one of four sibling paths is
    very often in two of them. Note what you checked **and found clean**.
16. **If it turned out not to be a defect** — the code does exactly what it was told and the
    disagreement is about what it should have been told — stop and handle it as a design question
    instead: state the current behaviour and its mechanism, name the options with what each costs,
    recommend one, and escalate rather than quietly picking if your choice changes behaviour
    others depend on.
    [Guide §8](lesson-04-guide-working-a-bug-ticket.md#8-when-the-report-is-a-design-question-not-a-defect).

✅ **Checkpoint:** the thing that proved the bug now proves the fix — and you saw it fail first.

---

## Part 4 — The pull request states the root cause

17. **What this changes** is the root cause in plain language, not the edit you made:

    | Not a root cause | A root cause |
    |---|---|
    | "Fixed the vendor save" | "`Update` never called `SaveChangesAsync`, which `Create` and `Delete` both do — `SetValues` only mutates the tracked entity in memory" |

    Then `Closes #N`, and the sentence about siblings: *"I checked `Create` and `Delete`; both
    save correctly."*
18. **How I verified it** — the reproduction *and* the proof, in that order. If a test applies,
    say you saw it red before the fix existed. Your reviewer is going to check this by hand.
19. **AI use** — including whether its diagnosis held up. *"It blamed the form component; the
    Insomnia PUT disproved that in a minute"* is worth more than anything else in the section.
    [Guide §9](lesson-04-guide-working-a-bug-ticket.md#9-writing-the-fix-pull-request) has a
    worked example of all three.

✅ **Checkpoint:** someone who never saw the bug could read your description and explain to a
third person why it happened.

---

## Part 5 — Review a teammate's fix

**This is the gate for the whole sprint.** Several of these defects are one character; a reviewer
who only reads the diff cannot tell a fix from a plausible-looking change.

20. **Reproduce the original bug first, on `main`** — where it still exists:

    ```bash
    git fetch origin
    git switch main && git pull origin main
    ```

    Restart the API if the fix is server-side, then run the reporter's steps. **You should see
    the bug.** If you don't, you're testing the wrong thing — sort that out before you go near
    the diff.
21. **Now switch to their branch and run the same steps:**

    ```bash
    git switch fix/<their-issue>-<their-slug>
    ```

    Restart the API again. The bug should be gone, and nothing beside it should be broken.
22. Then read the diff and check three things the description claims:

    - Is a **root cause** stated, or just the change?
    - Did they say which **sibling paths** they checked and found clean?
    - If a test came with it — **ask whether they saw it red first.** Run `npm test` yourself.

23. Approve, or request changes and say specifically what. Then, once yours is approved and
    squash-merged:

    ```bash
    git switch main && git pull origin main
    git fetch --prune
    git branch -d fix/<issue>-<short-slug>
    ```

24. Take the next defect.

✅ **Checkpoint:** you reproduced a teammate's bug on `main`, watched it not happen on their
branch, and your own fix is merged with its root cause on the record.

---

**No stretch challenges in this block** — the backlog is the stretch work, and there's more of it
than any team can finish. If you're done, take the next defect.

---

Everything else in this block asked you to add something. This asked you to find something wrong
in code you'd never read, from a description written by someone who doesn't work in it. That's
what most of your first year looks like, and the order — reproduce, narrow, read, prove, fix — is
the part that transfers to every codebase you'll ever be handed.
