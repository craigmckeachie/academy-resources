---
title: "Lesson 4 Guide — Working a bug ticket"
---

# Lesson 4 Guide — Working a Bug Ticket

**Goal:** by the end of this lesson you can take a bug report written by someone who isn't a
developer, reproduce it, narrow it to one layer of the application before reading any code,
state the root cause in a sentence, and open a pull request that proves the fix.

**The general pattern you're learning:** debugging feels like it's about knowing the codebase.
It isn't — you're about to fix defects in code you didn't write and have never read. It's about
**narrowing**, and there is one question you ask over and over: *is the data already wrong when
it arrives, or does it go wrong after we touch it?* Each answer halves what's left. Reading code
is what you do **last**, once narrowing has told you which twenty lines to read.

> **This is a tooling lesson, not a build lesson.** There's no feature to add — the practice is
> the bug bash that follows. Verify by **observation**, and this lesson uses more tools than any
> other in the course: the browser and its DevTools, Insomnia, SQL Server Management Studio, and
> the terminal for one failing test.

<!-- Authoring note (not student-facing): no entity build here — there's nothing to construct.
     The lab is a Sprint 4 runbook (reproduce → narrow → failing test first → root cause →
     reviewer reproduces the original bug), not a second walked example. The two defects walked
     below are reserved for this guide; check the instructor notes before substituting either. -->


> **How to use this guide.** Sections marked **▶ Code along** are ones you run on your own
> machine — two real defects are sitting in your repository right now, and you'll reproduce and
> fix both. Unmarked sections are concepts; read them, don't type them. Each ▶ section ends with
> a **Save and check**.

The [AI use policy](../reference/ai-policy.md) matters here in a way it didn't in Lesson 3. That
lesson used an assistant to *write* code. This one uses it to *read* code — a different skill,
arguably the more valuable one for a first job, and one with a specific failure mode. That's
section 5.

---

## 1. Reproduce before you diagnose

Your first move on any bug ticket is to make it happen on your own machine. Not read the code.
Not ask an assistant. Not form a theory.

Two reasons, and the second is the one people underrate:

- **You cannot tell whether you fixed something you never saw broken.** A fix verified only
  against your understanding of the code is a guess with extra steps.
- **Reproducing is itself a narrowing move.** Half of what looks like "I can't reproduce this"
  turns out to be reproducing the wrong thing.

### Reproduce on the screen the reporter described

This app computes some values **twice** — once on the server, stored on the record, and once in
the browser for display. Two different pieces of code, in two different languages, producing
what should be the same number. So "the total is wrong" can be true on the requests list and
false on the request's own detail page, or the other way round.

That means following the reporter's steps literally, including which page they were looking at.
Checking a different screen that shows the same value is not the same test, and it's how a real
defect gets closed as *cannot reproduce*.

### When you genuinely can't reproduce it

Don't close it. Write down exactly what you tried — which user you signed in as, which record,
what you saw — and ask the reporter. The most common cause is a missing precondition they didn't
think to mention: a particular role, a particular status, a record with an empty field.

---

## 2. The report is evidence — read it twice

A good bug report has already narrowed the search for you, and the most valuable line is
usually the throwaway one at the end.

| The reporter also said | What it hands you |
|---|---|
| "Products and Users save correctly — it's only vendors" | **A working path to diff against** — the single most efficient debugging tool there is |
| "Refreshing doesn't help" | Rules out stale state in the browser |
| "If I refresh, everything comes back correctly" | The opposite — the data is fine, the screen isn't |
| "It worked last week" | Something changed; the history is worth reading |
| "The API returns it correctly when I check in Insomnia" | The back end is exonerated; stay in the front end |
| "It only happens to users created this week" | A precondition, and probably the whole answer |

Two same-shaped code paths where one works and one doesn't is the best gift a report can give
you. You don't have to understand either path in the abstract — you only have to find the
difference between them, which is a much smaller job.

!!! tip "This is also how to write one"

    When you file a bug during the block, include what's *also* true and what's *not* broken.
    "Only vendors, and only on save" is worth three paragraphs of description.

---

## 3. ▶ Code along — narrow before you fix

Here's a report sitting in your repository right now:

> **Reported by:** Sam, procurement
>
> I changed a vendor's city, got a green "Successfully saved" message, and the list still shows
> the old city. Nothing I do makes it stick.
>
> **Steps:** open Vendors, edit any vendor's city, save. Look at that vendor's card.
>
> **Expected:** the card shows the new city. **Actual:** it shows the old city. Refreshing
> doesn't help. Products and Users save correctly — it's only vendors.

**Reproduce it first.** Edit a vendor's city, save, and watch the toast appear over a list that
still shows the old value.

Now resist the urge to open `VendorForm.tsx`. The success toast is the loudest thing on screen,
so it's where instinct sends you — and it's the one place the bug isn't. Instead, ask the layer
question: **is the data already wrong when it arrives, or does it go wrong after we touch it?**

The layers, from the data outward, and the tool that interrogates each:

| Layer | Tool |
|---|---|
| The database | SQL Server Management Studio |
| The API's own answer | Insomnia |
| What actually crossed the wire | DevTools → **Network** |
| Client state after it arrives | DevTools → **Console**, **Application** |
| What got rendered | The page itself |

You want the cheapest test that splits that list in half. Here, it's Insomnia:

1. `GET /api/vendors/{id}` for the vendor you just edited. It returns the **old** city.

    That one request eliminates the entire front end. React isn't mangling anything — it's
    faithfully displaying what the API gave it.

2. Now `PUT /api/vendors/{id}` with a new city. It returns **200, and the body shows the new
    city.**

3. `GET /api/vendors/{id}` again. **Old city.**

Stop and look at what you have: a PUT that reports success *with the new value in its response
body*, and a GET immediately afterwards that disagrees with it. Both cannot be right.

4. Confirm which one is lying, in SSMS:

    ```sql
    SELECT Id, Name, City FROM Vendors WHERE Id = 5
    ```

    The old city. So the write was accepted and never persisted.

**Only now open the code** — and you know exactly where to look: `VendorsController`, the
`Update` action. The report already told you `Create` works, so read them side by side.

`Update` mutates the tracked entity with
`_db.Entry(currentVendor).CurrentValues.SetValues(updatedVendor)` and then returns
`Ok(currentVendor)`. That's why the response body looked right — the object it serialised had
been updated **in memory**. What's missing is the line `Create` and `Delete` both have:

```csharp
await _db.SaveChangesAsync();
```

**Save and check**

- Insomnia: `PUT` then `GET` now **agree** on the new city
- SSMS: the `City` column has **actually changed**
- The browser: edit a city, save, and the list shows the **new** value
- Editing a **product** and a **user** still works — you didn't break the paths that were fine

!!! note "Why the toast wasn't lying either"

    `VendorForm.save` shows the success toast whenever the request doesn't throw, and a 200
    doesn't throw. The toast was honestly reporting *the request completed*. You read it as
    *the data was saved*. Those are different claims, and the gap between them is where this
    class of bug lives.

---

## 4. What that walkthrough was actually teaching

Not "vendors don't save." Three transferable moves:

- **The loudest symptom is rarely the location.** The toast, the blank page, the wrong colour —
  those are where the problem *surfaced*, which is usually the last link in the chain.
- **Interrogate the layer, not the code.** Three requests in Insomnia and one query in SSMS
  narrowed a whole application to one action, without reading a line of C#. Reading code is
  precise but slow; narrowing is coarse but instant. Do them in that order.
- **A 200 is not evidence of a write.** Neither is a correct-looking response body. Only reading
  the data back from the source of truth proves persistence.

---

## 5. Using AI on code you didn't write

This is the block's other AI mode, and it's the opposite of Lesson 3's. There, you supervised
something writing code. Here you use it to **read** code faster than you could alone — which is
exactly the situation you'll be in for your first months on any real codebase.

It's genuinely good at this:

- *"Explain what this method does, line by line."*
- *"Where in this codebase is a request's total calculated?"*
- *"What does `_db.Entry(current).CurrentValues.SetValues(updated)` actually do?"*
- *"What are the likely causes of `Cannot read properties of undefined (reading 'name')`?"*

And it has one specific, expensive failure mode:

> **"Why isn't the vendor's city saving?"**

It has not run your application. It cannot see your database. It will nonetheless produce a
fluent, confident, specific answer — often naming a real file and a plausible line — and it may
be entirely wrong. A confident wrong diagnosis is more expensive than no diagnosis, because you
stop looking.

!!! warning "An explanation is a hypothesis, not a finding"

    It tells you **where to look**. It never tells you **what is true**. Confirm it in the
    running app, in Insomnia, in SSMS, or in the console before you change a line — and notice
    that this is the same discipline as section 3, just applied to a different source of
    claims.

Use it to shorten the **reading**, never to skip the **narrowing**. The narrowing produces
evidence; the explanation produces a guess. Only one of those belongs in a pull request.

And when it *was* wrong, write that down — your pull request asks whether the assistant's
explanation held up, and "it blamed the form component; the actual cause was in the controller"
is the most useful sentence in the whole description.

---

## 6. ▶ Code along — the failing test first

Here's the second defect in your repository:

> **Reported by:** Marcus, finance
>
> The status colours are backwards. I nearly re-submitted a request that had actually been
> approved. APPROVED shows red and REJECTED shows green. NEW and REVIEW look right.

Reproduce it: open the requests list and look at the badges.

Narrow it: a badge colour is pure rendering, so this is the front end, and it's one hop.
`RequestRow.tsx` renders the badge class from `getTextBackgroundByStatus(request.status)`, which
lives in `src/utility/formatUtilities.ts`.

Now look at what that function *is*: a string goes in, a string comes out. No database, no
component, no `await`. Which means the fastest, most permanent way to reproduce this bug is not
to click anything — it's to write the assertion.

Your repository already has a test file for this helper — the reference test that shipped with
the starter. Run it before you touch anything:

```bash
npm test
```

**It passes.** Look at why — this is **already in your repository, nothing to type:**

```ts title="Prs.Web/src/utility/formatUtilities.test.ts"
describe("getTextBackgroundByStatus", () => {
  it("returns the primary badge class for NEW", () => {
    expect(getTextBackgroundByStatus("NEW")).toBe("text-bg-primary");
  });

  it("returns an empty string for an unknown status", () => {
    expect(getTextBackgroundByStatus("BANANA")).toBe("");
  });
});
```

It only ever asked about `NEW` and a nonsense value — and those two are fine. **A green test
suite sitting on top of a real bug**, because nobody wrote the assertion that would have caught
it. That's worth more than a lecture about coverage.

Add the two cases the report is actually about:

```diff title="Prs.Web/src/utility/formatUtilities.test.ts"
  describe("getTextBackgroundByStatus", () => {
    ...

+   it("returns the success badge class for APPROVED", () => {
+     expect(getTextBackgroundByStatus("APPROVED")).toBe("text-bg-success");
+   });
+
+   it("returns the danger badge class for REJECTED", () => {
+     expect(getTextBackgroundByStatus("REJECTED")).toBe("text-bg-danger");
+   });
  });
```

```bash
npm test
```

**Two red tests. That is your reproduction** — and unlike clicking through the app, it stays
reproduced forever.

Then fix the function, and watch them go green. Then one more step people skip: **find every
place that function is used.** It's called from `RequestRow.tsx` for the list badge and
`RequestHeader.tsx` for the detail badge. One fix covers both — but you should have checked
rather than assumed.

**Save and check**

- `npm test` was **green before you added anything** — the shipped tests never asked about
  APPROVED or REJECTED
- After adding the two cases, `npm test` showed **two failures**, before you touched
  `formatUtilities.ts`
- After the fix, `npm test` is **green** again — and this time that means something
- The requests **list** shows APPROVED green and REJECTED red
- A request's **detail** page agrees with the list

!!! warning "A test that never failed proves nothing"

    This is the whole reason for the order. A test written *after* a fix, which passes the
    first time it runs and was never seen red, tells you nothing about whether it would have
    caught the bug — and it's the most common way test suites end up worthless. Watch it fail
    first, and say so in the pull request.

### When there's no test to write

Section 3's defect had no pure function in it — the cause was a missing `SaveChangesAsync`
inside a controller action with an injected `DbContext`, and this course deliberately has no C#
test project. That's not a gap in your work; it's the boundary. For API defects, the Insomnia
request **is** the regression check, which is why the definition of done asks for it.

The rule of thumb: **if the root cause is a function you could call from a test, write the test
first.** If it isn't, narrow and verify with the tool that fits the layer.

---

## 7. Root cause is not the same as the change you made

The charter asks a fix's pull request to state the **root cause**. The difference:

| Not a root cause | A root cause |
|---|---|
| "Fixed the vendor save" | "`Update` never called `SaveChangesAsync`, which `Create` and `Delete` both do — `SetValues` only mutates the tracked entity in memory" |
| "Swapped the colours" | "`getTextBackgroundByStatus` returned the danger class for APPROVED and the success class for REJECTED — two cases transposed in the `switch`" |

The second column is worth writing for a reason beyond the paperwork: **it tells you where else
to look.** "This one write path was missing a step the others have" immediately raises the
question *are there other write paths, and do they all have it?* Ask it every time. A defect that
appears in one of four sibling paths is very often in two of them.

So before you open the pull request:

- **Look at the siblings.** Other actions on the same controller, other callers of the same
  helper, the other screens that render the same value.
- **Search for the pattern**, not just the instance. If the cause was a transposed pair in a
  `switch`, read the whole `switch`.
- **Say what you checked and found clean.** "I checked `Create` and `Delete`; both save
  correctly" is a genuinely useful sentence for your reviewer.

---

## 8. When the report is a design question, not a defect

Some reports describe behaviour that is working exactly as written. The code does what it was
told; the disagreement is about what it should have been told. You'll know you're in one of
these when you find the cause in five minutes and then can't decide what to do about it.

That's not a failure to diagnose. It's a design decision, and it needs handling differently:

- **Say plainly what the current behaviour is and why it happens** — the mechanism, not a
  judgement.
- **Name the options**, with what each costs. Usually there are two or three, and they differ in
  what they break for someone else.
- **Recommend one, and say why you rejected the others.**
- **Escalate rather than quietly picking**, if your choice changes behaviour other people depend
  on. A one-line code change can be a policy change.

A pull request that does this is more valuable than one that silently picks an answer, even when
it picks the same answer — because the next person can see the decision was made on purpose.

---

## 9. Writing the fix pull request

Same template, three parts, and on a defect each one has a specific job:

```markdown
## What this changes

Closes #31

`VendorsController.Update` mutated the tracked entity with `SetValues` and returned it,
but never called `SaveChangesAsync` — so the 200 response contained the new values while
the database kept the old ones. `Create` and `Delete` both save correctly; I checked.

## How I verified it

- Insomnia: `PUT /api/vendors/5` then `GET /api/vendors/5` now agree (they disagreed before)
- SSMS: confirmed the `City` column actually changes
- Browser: edited a vendor's city, saved, list shows the new value after a refresh
- Re-checked that editing a product and a user still save

## AI use

Asked Copilot Chat to explain what `CurrentValues.SetValues` does — accurate and useful.
Also asked why the city wasn't saving; it blamed `VendorForm.tsx` not sending the field,
which the Insomnia PUT disproved in about a minute. Diagnosis was wrong, the explanation
of `SetValues` was right.
```

Note what the AI-use section does there: it records a **wrong** diagnosis and how it was
disproved. That's not an admission of anything — it's the most informative thing in the
description, and it's exactly what the charter is asking for.

---

## The General Pattern (what to take away)

- **Reproduce first, on the screen the reporter named.** You can't verify a fix to something
  you never saw fail, and the same value is sometimes computed in two places.
- **Ask the layer question, not the code question.** *Is it already wrong when it arrives, or
  does it go wrong after we touch it?* Then pick the tool that interrogates that layer.
- **Read the code last.** Narrowing is coarse and instant; reading is precise and slow. In that
  order, reading is cheap.
- **A 200 and a plausible response body are not evidence of a write.** Read the data back.
- **The reporter's throwaway sentence is usually the best line in the report** — especially when
  it names something that *works*.
- **An AI explanation is a hypothesis.** It's excellent at telling you what code does and
  unreliable at telling you why your app is broken. Verify before you act, and record it when it
  was wrong.
- **If the root cause is a function you could call from a test, write the failing test first.**
  A test that was never red proves nothing.
- **Root cause, not change.** Stating it properly is what tells you where else the same bug is.

---

## Build Steps

1. Read the issue twice. Note every line that says what *also* happens or what *isn't* broken.
2. **Reproduce it**, following the reporter's steps literally — including which page they were
    on. If you can't, write down what you tried and ask them, rather than closing it.
3. Ask the layer question and pick the **cheapest test that splits the layers in half** — usually
    an Insomnia GET, or the Network tab.
4. Narrow to one layer, then one file, then one function. **Read the code last.**
5. If the report handed you a working path (*"products save fine"*), **diff the two paths**
    instead of reading either one in the abstract.
6. Use an assistant to explain unfamiliar code — then **confirm its diagnosis against the
    running app** before acting on it.
7. **If the cause is a pure function, write the failing test now** — watch it go red before you
    fix anything.
8. Fix it. Watch the test go green, or re-run the Insomnia request that proved the bug.
9. **Check the siblings** — the other actions on that controller, the other callers of that
    helper — and say in the pull request what you found clean.
10. If the report turns out to be a design question, **state the options and recommend one**
    rather than silently picking.
11. Open the pull request: **root cause in plain language**, specific verification steps, and an
    AI-use section that says where the assistant was wrong.
12. Review a teammate's fix by **reproducing the original bug on their branch** — then confirming
    it's gone.

There's no lab for this lesson — the bug bash is the lab, and there are more defects filed than
your team can finish, so take the next one when you're done.
