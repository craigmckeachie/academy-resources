---
title: "Lesson 1 Guide — Collaborating in a shared repository"
---

# Lesson 1 Guide — Collaborating in a Shared Repository

**Goal:** by the end of this lesson you can take a ticket in a repository three people are
working in, build it on a branch, open a pull request, get it reviewed, resolve a merge
conflict, and merge.

**The general pattern you're learning:** you already use Git alone — commit, push, repeat.
Working with other people doesn't add much *Git*; it adds a **gate**. Every change reaches
the shared branch through a pull request that another human has read. Everything in this
lesson exists to serve that gate: branches keep your work separate until it's ready,
conflicts are what happens when two people change the same thing, and a review is the
moment someone else takes responsibility alongside you.

> **This is a tooling lesson, not a build lesson.** There's no feature to add — you're
> learning the mechanics of the repository the rest of the block runs in. Verify by
> **observation**: watch the branch appear on GitHub, watch the pull request go green,
> watch the file change on `main`.

<!-- Authoring note (not student-facing): no entity build here. Git worktrees deliberately do
     NOT belong to this lesson — they moved to Lesson 3, where handing a ticket to an agent is
     the reason you need a second branch checked out. Don't move them back.
     See materials/CLAUDE.md → Team project (team-project/). -->


> **How to use this guide.** Sections marked **▶ Code along** are ones you type into your
> own machine as we go. Unmarked sections are concepts — read them, don't type them. Each
> ▶ section ends with a **Save and check** so a mistake surfaces immediately.

Keep the [Git collaboration quick-start](../reference/git-collaboration-quickstart.md) open
throughout. **Skim its first two tables now** — *How often you do each thing* and *Which tool
for which job*, about a minute — then leave it open and look things up as you need them.
It's a reference, not something to read cover to cover; this guide teaches the ideas and
tells you every command you need.

---

## 1. What changes when the repo is shared

Three things, and only three:

**`main` is protected.** You cannot push to it. Try, and GitHub refuses. This is deliberate:
it means `main` is always something the whole team agreed to, and it means nobody can
accidentally break everyone else's afternoon.

**Your work lives on a branch until it's reviewed.** A branch is a private workspace with a
name. Nothing you do there affects anyone until you ask for it to be merged.

**Someone else reads your code before it lands.** That's the pull request. It is the single
most valuable thing in this block — not because your code is suspect, but because reading
other people's code is most of what you'll do in your first year, and nobody gets good at
it by accident.

Everything else — the commands, the conflicts — is plumbing in service of those three.

!!! note "You already know more than you think"

    Committing, pushing, writing a message, reading a diff: all the same. The Git panel in
    Visual Studio and VS Code still does what it did. What's new is *branching on purpose*
    and *the review step*.

---

## 2. ▶ Code along — clone the team repo and get it running

> **Who does what:** the **repo owner** works the boxed section alone, first — the other two
> can't do anything until they publish. Then **all three** clone and get the app running.
> **Waiting on:** your invitation email, and you have to click it.

!!! warning "Configure Git first"

    If you haven't already, work through [Configuring Git](configuring-git.md) on this
    machine before you go any further. Several of those settings — `push.autoSetupRemote`,
    `pull.rebase false`, and the VS Code merge tool — are what make the next few sections
    behave the way this guide describes.

Your instructor has one **starter repository** — the same starting code for every team. One
person on your team is the **repo owner**: they take a copy of the starter, cut it loose
from the instructor's repository, and publish it as their own on their personal GitHub
account. That copy becomes your team's repository for the rest of the block.

**If you're the owner, work through the box below before anyone else clones anything.**
Everyone else: wait for their invitation, then skip to *Clone your team's repository*.

??? note "Repo owner only — make the starter yours, then publish it"

    This is the one time in this course you'll wire up a remote by hand. It's worth doing
    slowly, because it makes visible what a remote actually is: a name pointing at a URL.

    **Take a copy and cut it loose**

    1. Clone the instructor's starter and go into it:

        ```bash
        git clone <instructor-starter-url> prs-team-<n>
        cd prs-team-<n>
        ```

    2. Look at what you inherited before you delete it:

        ```bash
        git remote -v
        git log --oneline
        ```

        `origin` is pointing at your **instructor's** repository — push right now and you'd
        be pushing at them. That's what you're about to remove.

    3. Delete the entire history and its remote:

        ```bash
        rm -rf .git
        ```

        Everything Git knew about this folder lived in `.git` — every commit, and the
        `origin` remote. The files stay; the history is gone.

        !!! warning "This is the command that proves you're in Git Bash"

            `rm -rf` is a Unix command. PowerShell doesn't have it and will refuse — and
            so will everything else in this block that uses `&&`.

            Right-click the `prs-team-<n>` folder in File Explorer → **Show more options**
            → **Open Git Bash here**. On Windows 11 the first context menu you get is the
            short one, and it *doesn't* list Git Bash; **Show more options** opens the full
            menu that does. You want a prompt ending in `MINGW64 ~/… (main)`, not
            `PS C:\Users\…>`. See [Configuring Git](configuring-git.md).

    4. Start a fresh repository and make your own first commit:

        ```bash
        git init
        git add .
        git commit -m "Initial commit"
        ```

        `git init` creates the branch `main` because you set `init.defaultBranch` when you
        configured Git.

    **Publish it as yours**

    There are two routes to the same result. **Pick one and don't mix them** — the manual
    route starts by creating an empty repository on github.com, and the VS Code route
    creates that repository for you. Do both and you'll end up with two.

    !!! tip "The VS Code way — three clicks instead of two commands"

        With the folder open in VS Code, go to **Source Control**
        (<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd>) and click **Publish Branch**.
        The button only appears when a repository has no remote, which is exactly where
        `rm -rf .git` and `git init` just left you. Then:

        1. Sign in to GitHub if it asks — it opens a browser and comes back.
        2. Choose **Publish to GitHub public repository**. **Public, not private** — the
           private option is usually listed first, and this block needs public.
        3. Accept or edit the repository name. It defaults to your folder name.

        That one action does **all of steps 5, 6 and 7**: it creates the repository on
        github.com, adds `origin` pointing at it, pushes `main`, and sets the upstream. So
        **don't create the repository on github.com first** — there'd be nothing for the
        button to make.

        Confirm it landed the same way step 6 does:

        ```bash
        git remote -v
        ```

        Then skip to *Now lock it down*.

    !!! warning "Do the manual version at least once — steps 5–7"

        This is the **only** place in the whole course you wire up a remote by hand, and
        it's deliberate. `git remote add origin <url>` is the entire concept: `origin` is a
        nickname for a URL, nothing more. The button does the same three things, but it does
        them invisibly — and when a remote is wrong later (pointing at the wrong repository,
        or still at your instructor's starter), the fix is always `git remote`, never a
        button.

        Type it once here so you know what the button is doing. Use the button for the rest
        of your career.

    5. On github.com, create a **new, empty** repository — no README, no `.gitignore`, no
       license. Anything it adds becomes a conflict on your first push. Name it something
       your team will recognise, and make it **Public**.

    6. Point your local repository at it and push:

        ```bash
        git remote add origin https://github.com/<your-username>/<repo-name>.git
        git remote -v
        git push -u origin main
        ```

        `git remote add origin <url>` is the whole trick — `origin` is just a nickname for
        that URL. Run `git remote -v` again and you'll see it now points at *you*.

    7. Refresh the repository page on GitHub. The code is there, with exactly one commit.

    **Now lock it down** — in this order, or your own push above would have been blocked.

    8. **Invite your teammates.** **Settings → Collaborators → Add people**, entering each
       GitHub username, with **Write** access.

        **Tell them to go accept it.** Each teammate gets an email invitation and is not a
        collaborator until they click it — this is the most common reason a team stalls on
        the first morning, and the symptom is a confusing permissions error that never
        mentions an invitation.

    9. **Protect `main`.** **Settings → Rules → Rulesets → New ruleset → New branch
       ruleset**. Four things on this page, top to bottom:

        - **Ruleset Name** — call it `Protect main`.
        - **Enforcement status** — change it from **Disabled** to **Active**. It defaults to
          Disabled, and a disabled ruleset does *nothing*. This is the single easiest way to
          spend a day thinking `main` is protected when it isn't.
        - **Bypass list** — **leave it empty.** This is where the old branch-protection
          checkbox *"Do not allow bypassing"* went, and the logic is now inverted: instead of
          ticking a box to include yourself, you protect yourself by adding **nobody**. If
          **Repository admin** or **Organization admin** appears in the list, delete it — as
          the repo owner that role is *you*, and leaving it there means the rule binds your
          two teammates and not you, which defeats the point.
        - **Target branches** — **Add target → Include default branch**. `main` is your
          default branch, and targeting it this way survives a rename. (*Include by pattern*
          → `main` works too.)

    10. **Scroll down to Rules.** A couple are already ticked for you — **Restrict
        deletions** and **Block force pushes**. **Leave them on.** They stop anyone deleting
        `main` or rewriting its history, and neither interferes with normal work: your
        ruleset targets `main` only, so deleting a merged feature branch is unaffected.

        Add one more:

        - **Require a pull request before merging** — then, in the options that appear under
          it, set **Required approvals** to **1**. GitHub never lets you approve your own
          pull request, so 1 approval already means *someone else read it*.

        Leave the rest alone. *Require status checks* needs CI you don't have, and *Require
        review from Code Owners* needs a `CODEOWNERS` file. Click **Create**.

    11. **Settings → General → Pull Requests.** All three merge methods are ticked by
        default. You want exactly one:

        - **Allow merge commits** — **untick**
        - **Allow squash merging** — **leave ticked**
        - **Allow rebase merging** — **untick**

        Then tick **Automatically delete head branches** further down.

        GitHub won't let you untick all three, so leave squash alone and clear the other
        two. Squash-only is what makes the charter's rule true — one pull request becomes
        **one** commit on `main`, and the pull request *title* becomes its message. That's
        why a vague title matters and a messy branch history doesn't.

    12. **Test it.** Change a file, commit straight to `main`, and try to push. It must be
        **rejected**, and the error names your ruleset:

        ```
        remote: error: GH013: Repository rule violations found for refs/heads/main.
        remote: - Changes must be made through a pull request.
        ```

        If the push **succeeds**, the rule isn't doing anything — nine times out of ten the
        Enforcement status is still **Disabled**, or the bypass list isn't empty. Fix it
        before your team starts working, then undo your commit:
        `git reset --hard origin/main`.

    13. Give your teammates the repository URL.

**Clone your team's repository.** Once the owner has published and invited you, accept the
invitation, then clone **their** repository — not the instructor's starter:

```bash
git clone <your-team-repo-url>
cd <repo-folder>
```

!!! note "One repository this time, not two"

    In the capstone you had **two** repositories — one for `Prs.Api`, one for `Prs.Web`.
    This starter puts both in **one**, side by side:

    ```
    prs-team-3/
      Prs.Api/      ← the Web API — open Prs.Api.sln from in here
      Prs.Web/      ← the React front end
      Prs.Db/       ← the seed script
    ```

    That's deliberate. Almost every ticket in this block changes **both halves at once** — an
    endpoint and the page that calls it. In one repository that's a single branch, a single
    pull request, and one teammate reviewing the whole change. Split across two, the same
    ticket becomes two pull requests that have to merge in the right order, and a reviewer
    who only ever sees half of what you did.

    Both halves still run exactly as they did in the capstone. Only the folder layout changed.

Get both halves running, exactly as you did in the capstone:

1. Open `Prs.Api/Prs.Api.sln` in Visual Studio — the solution file lives inside the API folder,
   same as in the capstone. Point the connection string in `Prs.Api/appsettings.json` at your SQL
   Server and a **new** database name — your team shares a repository, not a database. Each of
   you runs your own.
2. In the Package Manager Console: `Update-Database`.
3. Run `Prs.Db/populate-prs.sql` in SSMS to seed it.
4. Start the API on the **http** profile.
5. In `Prs.Web`: `npm install`, then `npm run dev`.

**Save and check**

- Open the React app and sign in as `torrey.schoen` / `test1234` — the **Requests list
  loads with data**
- Open Insomnia, import `prs-insomnia.json`, set `baseUrl` to your API's address, and run
  **Get All Requests** — **green in the Tests tab**
- Run `git branch -vv` — you're on **`main`, tracking `origin/main`**

If the app doesn't run, stop here and fix it. Everything after this assumes a working
checkout.

---

## 3. The loop

One ticket, one trip around this:

```bash
git switch main && git pull origin main
git switch -c feature/12-vendor-detail-page
```

Build. Commit in your editor's Git panel as you go — several small commits are fine, they
get squashed into one at the end.

```bash
git push -u origin feature/12-vendor-detail-page
```

The `-u` is only needed the **first** time you push a branch — it records which remote
branch this one tracks. After that, and you'll push several more times on the same branch
while answering review comments, it's just `git push`.

Open the pull request on github.com. Get it reviewed. Squash-merge. Then:

```bash
git switch main && git pull origin main
```

!!! warning "That last line is the one people skip"

    Squash-merging updates `main` **on GitHub**, not on your machine. Skip
    `git switch main && git pull origin main` and your next branch starts from a stale `main`
    — manufacturing conflicts that didn't need to exist, in code you hadn't even touched yet.

    It's two seconds at the end of a ticket, or twenty minutes in the middle of the next one.

There's one more command you'll reach for mid-way through a ticket, when teammates merge
while you're still building — `git pull origin main`, run **from your feature branch**, to
bring their work into yours. That's section 6.

Two commands worth internalising now: `git status` tells you what's changed and what branch
you're on — run it constantly, it's free. `git switch -` jumps back to the branch you were
just on.

### Naming, before you create anything

That loop makes you name two things — a branch and a commit — and you're about to do both
for real in the next section. Working alone, names only had to make sense to you. They now
have to make sense to a reviewer.

**Branches:** `type/issue-number-short-slug`, lowercase with hyphens.

```
feature/12-vendor-detail-page
fix/31-line-delete-total
chore/1-add-craig-to-roster
```

The prefix is `feature/`, `fix/`, `chore/`, or `refactor/`. The **issue number** matters
most — it's what connects the branch to the pull request to the ticket, so anyone can find
out *why* this work exists. `craig-branch-2` tells a reviewer nothing.

**Commits:** write the message as an instruction, not a report. The test is whether it
completes *"If applied, this commit will ___."*

| Good | Not good |
|---|---|
| `Add requester filter to the requests list` | `update` |
| `Recalculate request total when a line is deleted` | `fixed bug` |

Capitalised, no full stop, under about 50 characters.

!!! tip "The pull request title is the message that lasts"

    Because we squash-merge, all of your branch's commits collapse into **one** commit on
    `main`, and **the pull request title becomes its message**. So commit as often and as
    scrappily as you like while you work — `wip` on your own branch harms nobody, it's about
    to disappear. The pull request title is the permanent one, and it's what `git log` on
    `main` shows forever.

Fuller guidance, including a table of what makes a bad name bad:
[Naming: branches and commits](../reference/git-collaboration-quickstart.md#naming-branches-and-commits).

---

## 4. ▶ Code along — a branch and a pull request

> **Who does what:** **all three of you, at the same time**, each on your own branch.
> **Waiting on:** nothing — don't coordinate who goes first.

We'll do the whole loop on something that can't break: adding your name to the repository
README.

All three of you are about to edit **the same section of the same file**. That's on purpose —
it's what produces the conflict in section 6.

```bash
git switch main && git pull origin main
git switch -c chore/1-add-<yourname>-to-roster
```

That branch name follows the pattern from the last section — `chore/` because adding your
name to a README isn't user-facing behaviour, and `1` because that's the issue number.

Open `README.md`, find the **Team roster** section, and add your name.

Commit it in your editor's Git panel. Apply the imperative test to your message:
`Add Craig to team roster` — *if applied, this commit will add Craig to team roster.* Not
`update`. Then:

```bash
git push -u origin chore/1-add-<yourname>-to-roster
```

Go to the repository on github.com. There's a banner offering to open a pull request from
your branch — click **Compare & pull request**. The description template is already there;
fill in all three parts:

- **What this changes** — one sentence, and `Closes #1`
- **How I verified it** — for this one, "read the rendered README on the branch"
- **AI use** — "none"

**Give the title the same care as a commit message** — it's the one that lands on `main`
when this is squash-merged. `Add Craig to team roster`, not `readme`.

Click **Create pull request**.

**Save and check**

- The pull request page shows **Files changed → 1**, and the diff is exactly your name
- It says **Review required** and the merge button is **not** available yet — that's branch
  protection doing its job
- Your branch appears in the repo's branch list on github.com

*Not yet: merging. That needs a teammate, which is the next section.*

---

## 5. ▶ Code along — reviewing a teammate's pull request

> **Who does what:** **all three** review. Then **only one merge will go through** — the other
> two get blocked, which is section 6.
> **Waiting on:** somebody has to approve yours before you can merge it, so this section can't
> be done alone.

**Review in a ring, not in pairs** — three people don't pair evenly. Agree on a direction and
stick to it: you review the person on your left, they review the person on theirs. Every pull
request gets exactly one reviewer, and nobody reviews their own.

Open the pull request you were assigned.

Read the diff on the **Files changed** tab. Hover a line and click the blue **+** to leave a
comment on it — try one, even if it's just a question. Line comments are how real review
conversations happen; a general "looks good" is worth very little to the author.

Then click **Review changes** and choose:

- **Approve** — you've read it and you're willing to put your name on it landing
- **Request changes** — something needs to happen first. This is not an insult; it's the
  mechanism working. Say specifically what.

Once someone approves yours, merge it — choose **Squash and merge**, so your several small
commits become one clean commit on `main`. GitHub deletes the branch on its side
automatically.

**Only one of you gets to do that.** Whoever merges first wins the race; the moment their
change lands, the other two pull requests turn red with **This branch has conflicts that must
be resolved** and the merge button switches off. That's not a mistake anyone made — it's three
people editing the same lines, which is exactly what you set up in section 4. Don't try to
force it. Resolving it is section 6.

**If you're the one who merged**, bring your local `main` up to date and tidy your machine:

```bash
git switch main && git pull origin main
git fetch --prune
git branch -d chore/1-add-<yourname>-to-roster
```

The first line is the one that matters — it brings the merged work into your local `main` so
your next branch starts from it. The other two are housekeeping: GitHub's auto-delete only
cleans up **its** side, so without them your machine keeps every branch you've ever made plus
a stale `origin/…` bookmark for each.

**If you're one of the two who got blocked**, don't run any of that yet — you still need your
branch, and section 6 is where you finish. Come back to these three commands after your pull
request merges.

**Save and check**

- Exactly **one** pull request shows **Merged** in purple; the other two show a conflict
- `main` on github.com shows **one name** in the README roster — not three, not yet
- Whoever merged: `git log --oneline -3` shows the **squashed commit** locally

!!! warning "Answering a review does not mean opening a second pull request"

    If a reviewer requests changes, you push **more commits to the same branch**. The pull
    request updates itself — same URL, same conversation, new commits. Almost everyone gets
    this wrong once. Now you won't.

---

## 6. ▶ Code along — staying current, and your first conflict

> **Who does what:** the **two of you whose pull requests got blocked**. Whoever merged in
> section 5 has nothing to resolve — watch over a shoulder, then do it for real in the lab.
> **Waiting on:** go one at a time. The second person resolves against **both** names, so let
> the first finish and merge before you start.

A teammate merged while your branch was open, so your branch doesn't have their name yet — and
GitHub won't let you merge on top of them until you deal with it. **Stay on your feature
branch** and pull `main` into it:

```bash
git pull origin main
```

One command, and you never leave your branch. `git pull` is really two commands in one —
`git fetch` downloads what's on GitHub, `git merge` combines it into the branch you're
standing on. So this merges GitHub's `main` straight into your feature branch.

If you touched different files, it merges silently and you're done. When two people change
the same lines, Git stops and asks. It marks the clash in the file:

```
<<<<<<< HEAD
  the version on your branch
=======
  the version coming from main
>>>>>>> main
```

Open the file from VS Code's **Source Control** panel and click **Resolve in Merge Editor**.
You get three panes — *Incoming*, *Current*, and the *Result* you're building — with buttons
to take either side or both.

The question is always the same: **do I want mine, theirs, or both?** Two people adding
different routes to the same array both belong — keep both. Two people rewriting the same
line of logic do not — stop, read what the other change was *for*, then decide.

**Here it's both** — every name on the roster belongs, in any order. Take theirs *and* yours.

```bash
git add .
git commit
git push
```

Your pull request goes green again. Get it approved, squash-merge, and then run the three
cleanup commands from section 5 that you skipped. **Then tell the third person to go** — they
resolve against a `main` that now has two names on it, which is the more realistic version and
worth watching.

**Save and check**

- The conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) are **gone from every file** —
  search the project for `<<<<<<<` to be sure
- **Count the names.** Every teammate who merged before you is still there, and yours is too.
  Nobody's name disappeared
- The pull request on GitHub now says **This branch has no conflicts with the base branch**
- Once all three have merged: `main` on github.com shows **all three names**

That middle check is the one that matters, and it's the one Git can't do for you. A conflict
can resolve cleanly and still leave you with two halves of two different ideas stitched
together — or, here, with a teammate's name silently dropped. It compiles. It looks finished.
The editor can't catch it; **looking at the result** can.

On a README that means counting names. On a real ticket it means running the app and clicking
through both features — which is exactly what you'll do from Sprint 2 onwards.

---

## 7. The backlog, the sprint, and who takes what

You've got the loop. The last thing you need before real work is where the work comes from.

**The backlog is every ticket that exists.** Yours lives in your repository, as files, under
`tickets/`. Nobody wrote them into GitHub for you — you'll do that, once per sprint.

**A sprint is the slice of the backlog you're attempting next.** It is smaller than the
backlog, and the gap between the two is not a problem to be solved.

!!! note "There will be more tickets than you can finish. That's the design."

    Every sprint in this block is deliberately oversubscribed. A team that finishes everything
    was under-loaded, and a backlog that runs dry leaves fast finishers idle.

    So **carrying tickets is normal, not failure.** What matters is that the ones you *did*
    take are finished — merged, reviewed, done — rather than five things all at 80%. At the end
    of a sprint you should be able to say which tickets landed and which didn't, without
    apology.

### Creating the issues

Once per sprint, one person does this for the team:

1. Open the repository's **Actions** tab on github.com — the row of tabs across the top,
   between **Pull requests** and **Projects**.
2. In the **left sidebar**, under the heading **All workflows**, click **Create sprint
   issues**. It's easy to miss: the middle of the page is a list of past *runs*, and the
   workflow you want is the small link on the left, not anything in that list. (On a
   narrow window the sidebar collapses — widen the browser or scroll down for it.)
3. On the right-hand side of the blue *"This workflow has a workflow_dispatch event
   trigger"* bar, click **Run workflow**. Pick the sprint number from the dropdown, then
   click the green **Run workflow** button.
4. Wait for the run to finish — refresh, and it should show a green tick rather than a
   spinning amber dot. A red **✗** means it failed; open the run to read why.
5. Refresh **Issues**. One issue per ticket, with the full description, the acceptance
   criteria, and any mockup.

They arrive **unassigned**, on purpose. Deciding who takes what is the planning, and it's
yours.

*(If Actions is unavailable, the same text is in `tickets/sprint-N/` — open a file, copy it
into a new issue by hand.)*

### Planning it

Five minutes, standing at a screen, all three of you:

- **Read every ticket in the sprint** — not just the one you expect to take. You need to know
  what your teammates are building, because in later sprints their work and yours meet in the
  same files.
- **Respect the dependencies.** Some tickets say *depends on* another. That's a real ordering
  constraint, not a suggestion, and getting it wrong means someone builds on something that
  isn't there yet.
- **One issue, one person.** Assign each on GitHub so the board says who's on what — no
  guessing at standup.
- **Leave the rest unassigned.** They're not forgotten, they're next. Whoever finishes first
  pulls one.
- **Then check with your instructor** before anyone branches. Some of the sequencing matters
  more than it looks.

**One issue, one branch, one pull request** — the charter's first rule — starts here. An issue
you didn't create is an issue nobody's tracking, and a branch with two tickets on it is a
review nobody can give properly.

> Everything above assumes one folder on one branch, which is all you need for a ticket you
> build by hand. When you hand a ticket to an AI agent you'll want **two** branches checked
> out at the same time, in two folders, so it can't write to the files you're working in.
> Git does that with a **worktree**, and it's where Lesson 3 starts.

---

## The General Pattern (what to take away)

- **The gate is the point.** Branches and conflicts are all in service of one idea: nothing
  reaches the shared branch without another person reading it.
- **The backlog is bigger than the sprint on purpose.** Carrying tickets is normal; finishing
  three properly beats having five at 80%.
- **Create the issues, then plan, then branch** — in that order, and never a branch without an
  issue behind it.
- **Small branches merge easily; long branches hurt.** A branch open for four hours rarely
  conflicts. One open for three days always does.
- **Always start from a fresh `main`.** `git switch main && git pull origin main` before every new
  branch. Most painful conflicts are self-inflicted by skipping it.
- **A conflict is a question, not an error.** Git is telling you it can't know which change
  wins. Answer it deliberately, then *run the app* — resolving cleanly is not the same as
  resolving correctly.
- **Review is the skill, not the paperwork.** Reading someone else's code and asking a
  useful question about it is most of what you'll do in your first year.
- **Isolation is what makes parallelism safe** — for three developers, and for one developer
  supervising three agents. Same primitive, same reason.

---

## Build Steps

1. Work through [Configuring Git](configuring-git.md) on this machine, if you haven't
    already. **Open Git Bash, not PowerShell**, for this and every command below — File
    Explorer → right-click the folder → **Show more options** → **Open Git Bash here**.
2. **Repo owner only — make the starter yours:** clone the instructor's starter, run
    `git remote -v` and `git log --oneline` to see what you inherited, then `rm -rf .git`,
    `git init`, `git add .`, `git commit -m "Initial commit"`.
3. **Repo owner only — publish it:** create a **new, empty, public** repo on your GitHub,
    then `git remote add origin <url>` and `git push -u origin main`. (VS Code's **Publish
    Branch** button does all of that in one action — but do it by hand this once, and
    *don't* pre-create the repo if you use the button.)
4. **Repo owner only — lock it down, in this order:** invite your teammates with **Write**
    access; add a **branch ruleset** on `main` — Enforcement **Active**, **bypass list
    empty**, *Require a pull request* with **1** approval, *Block force pushes*; set
    **squash merging** only; prove a direct push to `main` is rejected; then share the URL.
5. Accept the collaborator invitation — from the email or your GitHub notifications.
6. Clone **your team's** repository (not the instructor's starter); `git branch -vv` should
    show you on `main` tracking `origin/main`.
7. Open `Prs.Api/Prs.Api.sln`, point `appsettings.json` at **your own** database, run
    `Update-Database`, and seed with `populate-prs.sql`.
8. Start the API on the http profile; `npm install` and `npm run dev` in `Prs.Web`.
9. Verify: sign in to the React app, and run the **Requests** folder in Insomnia.
10. `git switch main && git pull origin main`, then branch:
    `git switch -c chore/1-add-<yourname>-to-roster`.
11. Add your name to the README's **Team roster** and commit with a real message.
12. `git push -u origin <branch>` and open the pull request, filling in all three sections
    of the template.
13. Review a teammate's pull request — leave at least one **line comment**, then Approve.
14. Squash-merge yours once approved (GitHub deletes the branch on its side), then locally:
    `git switch main && git pull origin main`, `git fetch --prune`, `git branch -d <branch>`.
15. On a branch that's fallen behind, run `git pull origin main`; resolve any conflict in
    the merge editor, commit, push, then re-run the app.
16. **Once per sprint:** Actions → **Create sprint issues** *(left sidebar, under All
    workflows — not the run list in the middle)* → **Run workflow** → the sprint
    number. Then plan as a team — read every ticket, respect the dependencies, assign one
    each, leave the rest unassigned, and check with your instructor before anyone branches.

The lab takes you through the same loop on your own, with a conflict you create on purpose —
and then sets up Sprint 1 for real.
