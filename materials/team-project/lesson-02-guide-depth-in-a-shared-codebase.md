---
title: "Lesson 2 Guide — Depth in a shared codebase"
---

# Lesson 2 Guide — Depth in a Shared Codebase

**Goal:** by the end of this lesson you can work a ticket that changes the database *and* the API
*and* the page in one branch, coordinate a migration with two other people, extend an endpoint
without breaking the callers you can't see, and resolve the kind of merge conflict where the wrong
answer still compiles.

**The general pattern you're learning:** Sprint 1 gave everyone a ticket in their own corner. This
sprint doesn't — three of you will be editing the same file, one of you owns the database, and every
ticket reaches from the browser to SQL Server and back. The skill isn't any single technique; it's
**working out what your change might break for someone else, before they find out.** Every section
below is one version of that question.

> **This is mostly a briefing, not a build.** The doing is your Sprint 2 ticket, and the lab is
> the checklist for it. The one exception is section 2's **▶ Code along** — five minutes with
> the migration files, which everyone runs.

<!-- Authoring note (not student-facing): near-concept-only by design. The ONLY ▶ Code along is
     §2's, and it is deliberately read-and-inspect (plus one empty Add-Migration that is
     immediately removed) — NOT building a table.
     Do NOT walk the Comment entity here: S2-A is an ASSIGNED ticket (student 1, the schema
     owner), so walking it hands them their first acceptance criterion. Walked items in this
     block are planted-but-never-filed only — AG-0, BUG-05, BUG-14.
     Also note two of three students must NOT run Add-Migration in Sprint 2 at all, so a
     create-a-table walkthrough would teach the opposite of the rule §2 exists to establish.
     Do NOT walk the S2-C/S2-D argument-list conflict on the real files: it is Sprint 2's
     engineered conflict and must be discovered. §4's snippet is deliberately generic.
     See planning/team-project/sprint-2-depth.md. -->

Keep the [team charter](team-charter.md) and the
[Git collaboration quick-start](../reference/git-collaboration-quickstart.md) open, and have
`Prs.Api` open in Visual Studio for section 2.

---

## 1. What's different about a second sprint

You've resolved a conflict already, in the Lesson 1 lab — but that was a **drill**, staged on a
README table so it couldn't hurt anything. The three Sprint 1 **tickets** were the opposite:
deliberately chosen to touch no files in common, so the real work merged in any order and nobody
had to think about anyone else's branch.

Both halves of that were on purpose. You met a conflict where the answer was obvious, and you
met the ticket loop without one. **This sprint stops separating them**, which is how a real
sprint actually looks.

This sprint, three things change at once:

**The codebase is now partly yours and partly theirs.** You'll open files your teammates wrote last
week, in a style that's *nearly* yours. Reading a colleague's recent work is different from reading
a stranger's old work: it's familiar enough that you stop paying attention, which is exactly when
you break something.

**Tickets are vertical slices.** A Sprint 2 ticket typically changes a controller action, an API
module, and a component — sometimes a database table too. One branch, one pull request, one reviewer
who has to follow the change from SQL Server to the screen.

**More than one person is in the same file.** Not by accident and not avoidably: the requests list
is where several of these tickets live. Section 4 is about what that costs and how to pay it.

!!! note "You already have the mechanics"

    Branch, commit, push, pull request, review, squash-merge, resolve a conflict — all of that is
    Lesson 1 and you've done it for real. Nothing here replaces it. This lesson is about the
    decisions that come *before* the commands.

---

## 2. Migrations in a team — the database schema owner

One ticket this sprint adds a database table. That student is the sprint's **database schema
owner**, and for the length of the sprint they are the only person who runs `Add-Migration`.

This is not ceremony. Here's the failure it prevents:

Two people each add a model, each run `Add-Migration`, each get a migration file stamped with a
timestamp and a snapshot of what they *think* the schema is. Both branches merge. Now `main` has two
migrations, each built on a snapshot that didn't include the other, and EF Core's model snapshot —
one file, `ModelSnapshot.cs` — has been written twice from two different starting points. Untangling
it costs half a day and teaches nothing.

**The rules for the sprint:**

- **Only the database schema owner runs `Add-Migration`.** Everyone else, nobody, not once.
- **The migration merges first.** Before anyone else's ticket lands.
- **Everyone else pulls `main` and runs `Update-Database`** — the moment it merges, not when they
  next happen to need it.

```
Package Manager Console, database schema owner only:
    Add-Migration AddComments
    Update-Database

Everyone else, after it merges:
    git switch main && git pull origin main
    Update-Database
```

**If you're not the database schema owner and you think you need a migration, you're wrong or
the ticket is.** Say so at standup rather than running the command. And one specific case worth
knowing, because it looks like a schema change and isn't:

!!! tip "Adding a navigation property to an existing foreign key is not a schema change"

    A collection property on the parent side of a relationship that already exists changes no
    columns. `Add-Migration` produces an **empty** migration, and that's the correct outcome — not
    a sign you did it wrong.

    If it comes out non-empty, **stop and read it.** Something else changed, and you're about to
    commit it by accident.

### ▶ Code along — look at what you're being protected from

**Everyone does this, schema owner or not**, and it takes five minutes. The rule above only
sounds like bureaucracy until you've seen the files it's protecting.

**1. Read the migration you've been running all along.** Open `Prs.Api/Migrations/` — there's one
migration in there, a timestamped file ending `_Init.cs`. You ran `Update-Database` in Lesson 1
to apply it and never looked inside. Do that now:

```csharp title="Prs.Api/Migrations/…_Init.cs"
migrationBuilder.CreateTable(
    name: "Users",
    // …columns, keys
```

Five `CreateTable` calls, seven `CreateIndex` calls, and a `Down()` that drops it all again.
This is what `Add-Migration` wrote by comparing your models to *nothing*. **It's generated C#,
not something anyone typed** — which is why the golden rule is that you never hand-edit one.

**2. Open `PrsDbContextModelSnapshot.cs`, in the same folder.** Scroll it. It's long, and this is
the part that matters:

> **It is one file, and it describes your entire schema.**

That's the whole argument from three paragraphs ago, made concrete. `Add-Migration` doesn't just
write a migration — it rewrites *this* file to be the new current state, then diffs against it
next time. **Two people running `Add-Migration` on branches that don't know about each other
produce two rewrites of one file, each correct on its own and neither aware of the other.** Git
merges it, EF Core reads a snapshot that matches neither branch, and every subsequent migration
is built on a lie.

There is no clean way to resolve that conflict by hand. That's the half-day.

**3. Run the command you were just told not to run — once, safely.** With your models untouched,
in the Package Manager Console:

```
Add-Migration Scratch
```

Open what it produced. **`Up()` and `Down()` are empty**, because nothing changed. That's the
tip above, seen for real rather than described — and it's how you'll recognise the
nav-property case mid-sprint instead of panicking at it.

Now take it back out:

```
Remove-Migration
```

`Remove-Migration` deletes the migration file *and* rolls `ModelSnapshot.cs` back to what it was.
Confirm with `git status` — **your working tree should be clean.** If anything is left over,
you've just learned something else useful about the tooling.

**4. Do the thing you'll actually do all sprint.**

```
Update-Database
```

For two of the three of you, that's the *only* migration command you'll run in Sprint 2 — and
you'll run it the moment the schema owner's work merges.

**Save and check**

- You've read a real `CreateTable` and a real `ModelSnapshot.cs`, and can say why one file being
  rewritten twice is unfixable.
- `Add-Migration Scratch` produced an **empty** migration, and `Remove-Migration` left
  `git status` clean.
- You know which of the three commands is yours this sprint.

!!! warning "That was the exception, and it's over"

    You ran `Add-Migration` once, on an unchanged model, before the sprint started, and removed
    it immediately. From here the rule in this section holds without exception: **if you are not
    the database schema owner, you do not run it** — not to check something, not on a branch you
    plan to throw away. Say it at standup instead.

---

## 3. Extending an endpoint without breaking it

Several tickets this sprint add a parameter to an endpoint that already has callers. The requests
list endpoint already takes an optional status:

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

*(An illustration to read, not a step — this is already in your repository.)*

Four things in that shape are doing work, and each is a way to break it:

| The shape | What it prevents |
|---|---|
| `string?` with **`= null`** | Every existing caller that sends no parameter still compiles and still works |
| Filter applied **inside an `if`** | No parameter means no filtering — not filtering on `null` and returning nothing |
| `AsQueryable()` before the `if` | The filter composes into the SQL instead of running in memory over every row |
| `Include` **before** the filter | The navigation property survives. Drop it and the page renders blank names with no error |

**The last one is the quiet one.** A missing `Include` doesn't throw and doesn't fail a test you
were likely to write — it just empties a column on screen. Whenever you touch a query, check that
whatever the page displays is still being loaded.

**And the acceptance criterion three of this sprint's tickets share:** the endpoint with **no** new
parameter must behave exactly as it did before. Not approximately. That's the contract every other
caller is relying on, including the ones you didn't write and the Insomnia collection you'll be
verified against.

---

## 4. When "keep both" isn't the answer

You've resolved one conflict already — three people added a row to the same table in a README, and
the answer was obvious: keep all three rows, in any order. Nothing was at stake because nothing
could be silently wrong.

This sprint you'll hit a different class. Here's its shape, in the abstract:

```ts
// Two branches, each adding one parameter to the same call and the same dependency array.

// theirs
const data = await api.list(filterA);
useEffect(() => { load(); }, [filterA]);

// yours
const data = await api.list(filterB);
useEffect(() => { load(); }, [filterB]);
```

Git stops and shows you both. There are four ways to resolve it and **three of them compile**:

- keep theirs — compiles, your feature silently does nothing
- keep yours — compiles, their feature silently does nothing
- keep both in the call but only one in the dependency array — compiles, and the feature whose
  parameter you dropped from the array works *only after a refresh*
- keep both, in both places — correct

!!! warning "A clean resolution is not a correct resolution"

    Every wrong option above produces a green build and a page that loads. The failure is somebody
    else's feature quietly not working, discovered days later by whoever reports it.

    Lesson 1 said *a conflict is a question, not an error*. This is the version where the question
    is hard: not "which line do I want?" but **"what were both of these changes for?"** You cannot
    answer that from the diff. You have to read the other ticket.

**So when you hit a conflict this sprint:**

1. **Find out what the other change was for** — the issue number is in the branch name and the pull
   request. Read it before you touch the merge editor.
2. **Resolve for both intents**, not for whichever side looks tidier.
3. **Run the app and exercise *both* features** — yours and theirs. This is the step that catches
   the three compiling wrong answers, and nothing else does.
4. **Say in the pull request what you merged and why.** Your reviewer is about to approve a
   resolution they didn't make.

And the prevention, which is cheaper than any of the above: **keep the branch short.** A branch open
for a few hours rarely collides. One open for three days collides with everything, and by then
you've forgotten what your own change was for.

---

## 5. Reviewing a vertical slice

Reviewing a one-file change is reading a diff. Reviewing a change that spans the database, the API
and a page is a different job, because the bugs live in the **seams** rather than in any one file.

Four questions, in order of how often they find something:

**Does the endpoint still work for its old callers?** Send the request with none of the new
parameters, in Insomnia. If the response changed shape or count, the ticket broke something nobody
asked it to touch.

**Does the page still show everything it showed before?** The blank-column failure from section 3 is
invisible in a diff and obvious in a browser.

**Are the two halves actually talking?** A parameter added to the controller and spelled differently
in the API module produces no error at all — the value just never arrives. Change the filter and
watch the network request, don't infer it.

**Was a migration involved, and was it the database schema owner's?** If a non-owner's branch
contains a migration file — or a changed `PrsDbContextModelSnapshot.cs` — that's a finding, not a
detail. You've read that file now; you know what a second rewrite of it costs.

Then the standing rule from the charter: **run it before you approve it**, and if you only read the
diff, say so in your review.

---

## The General Pattern (what to take away)

- **Ask what your change breaks for someone you can't see.** Old callers, other pages, the next
  person's merge. Every section above is that one question in a different costume.
- **One person owns the schema per sprint**, because `ModelSnapshot.cs` is a single file
  describing your whole schema, and two branches rewriting it produce a conflict with no correct
  hand resolution. Parallel migrations cost half a day and teach nothing.
- **Optional-with-a-default is how you extend an endpoint** — and the untouched call has to keep
  behaving exactly as it did.
- **A missing `Include` fails silently.** When you touch a query, check that what the page displays
  is still loaded.
- **A clean resolution is not a correct resolution.** Three of the four ways to resolve a
  parameter conflict compile. Read the other ticket, then run both features.
- **Short branches are the cheapest conflict prevention there is.**
- **Review the seams, not the files.** In a vertical slice, that's where the bugs are.

---

## Build Steps

1. Read `Prs.Api/Migrations/…_Init.cs` and `PrsDbContextModelSnapshot.cs`. Run
    `Add-Migration Scratch` on unchanged models, confirm it's **empty**, then `Remove-Migration`
    and check `git status` is clean.
2. Find out **who the database schema owner is** this sprint, and confirm it isn't you before you
    consider running `Add-Migration` again.
3. When the migration merges, **pull `main` and run `Update-Database`** — then, not later.
4. Read your ticket and work out **which layers it touches** — database, controller, API module,
    component — before you write anything.
5. If you're adding a parameter to an existing endpoint: **optional with a default**, filter inside
    an `if`, `Include` before the filter, and verify the **no-parameter** call is unchanged.
6. **Keep the branch short.** Push and open the pull request while it's still small.
7. On a conflict: **read the other ticket first**, resolve for both intents, then **run both
    features** and say in the pull request what you merged.
8. Reviewing: send the endpoint's **old** request in Insomnia, load the page, change the filter and
    watch the network tab, and check no unexpected migration file is in the diff.

The lab is the same sequence as a checklist you work beside your issue.
