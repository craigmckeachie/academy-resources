---
title: Configuring Git
---

# Configuring Git

One-time global setup so Git behaves the way this course's team workflow expects. You've
been committing your own work all along; these settings are what make **pushing branches,
opening pull requests, and resolving conflicts** go smoothly once three people share a
repository.

Run this before the team development block. It's global configuration, so you only do it
once per machine.

## All at once

Rather than pasting eleven commands into a terminal one at a time — where a dropped
character or a mangled quote is easy to miss — put them in a script file and run it once.

1. Open **VS Code**. Create a new file and save it as `setup-git.sh`. Any folder is fine
    (your user folder or Desktop is easiest) — these are **global** settings, so where you
    run it from doesn't matter. You can delete the file afterwards.

1. Paste this in, then replace the name and email on the first two lines with your own:

    ```bash title="setup-git.sh"
    #!/usr/bin/env bash
    set -e

    git config --global user.name "FIRST_NAME LAST_NAME"
    git config --global user.email "my_name@example.com"
    git config --global init.defaultBranch main
    git config --global push.default current
    git config --global push.autoSetupRemote true
    git config --global pull.rebase false
    git config --global core.editor "code --wait"
    git config --global merge.tool vscode
    git config --global mergetool.vscode.cmd 'code --wait $MERGED'
    git config --global diff.tool vscode
    git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'

    echo ""
    echo "Git configured. Your global settings are now:"
    echo ""
    git config --global --list
    ```

    !!! warning "Change the line endings to LF before you save"

        Look at the **bottom-right of the VS Code status bar**. If it says **CRLF**, click
        it and choose **LF**. A shell script saved with Windows line endings fails with a
        baffling error:

        ```
        ./setup-git.sh: line 2: $'\r': command not found
        ```

        This catches almost everyone the first time, and the error message never mentions
        line endings.

1. **Save the file.**

1. Open **Git Bash** in the folder you saved it in — right-click the folder in File
    Explorer and choose **Open Git Bash here**, or open the folder in VS Code and pick
    **Git Bash** from the terminal's dropdown.

    !!! warning "Git Bash, not PowerShell"

        `chmod` is a Unix command. It exists in Git Bash (which ships with Git for Windows)
        but not in PowerShell or Command Prompt. Check the terminal dropdown says **bash**.

1. Give the file permission to run, then run it:

    ```sh
    chmod +x setup-git.sh
    ./setup-git.sh
    ```

    `chmod +x` marks the file as executable — without it, `./setup-git.sh` refuses with
    *Permission denied*. The `./` says "the script in this folder," not a command installed
    on the system.

    !!! tip "If `chmod` doesn't stick"

        Some drive and folder configurations don't preserve the executable bit. You can skip
        it entirely and hand the file to bash directly:

        ```sh
        bash setup-git.sh
        ```

1. Read the output. The script prints every global setting when it finishes, so you've
    already verified it — compare against the list below.

1. To check again at any time:

    ```sh
    git config --global --list
    ```

    You should see output similar to but NOT exactly like the following.

    ```
    user.name=John Doe
    user.email=jdoe@example.com
    init.defaultbranch=main
    push.default=current
    push.autosetupremote=true
    pull.rebase=false
    core.editor=code --wait
    merge.tool=vscode
    mergetool.vscode.cmd=code --wait $MERGED
    diff.tool=vscode
    difftool.vscode.cmd=code --wait --diff $LOCAL $REMOTE
    ```

    **Do you see every setting the script ran?** If one is missing, the script stopped
    early — scroll back for the error.

    !!! tip "If the output stops with a colon"

        You may get a few settings followed by a `:` at the bottom of the screen. That's the
        pager. Press **Enter** to see more lines, or **q** to quit back to the prompt.

    !!! tip

        Add the `--show-origin` flag to see which file each setting is stored in:
        `git config --global --list --show-origin`

## What each setting does

You don't need to memorize these, but it's worth knowing why they're here — several of them
exist specifically to prevent a problem you'd otherwise hit in the team block.

| Setting | Why |
|---|---|
| `user.name` / `user.email` | Stamped on every commit you make. **Use the same email as your GitHub account** or your commits won't be linked to your profile. |
| `init.defaultBranch main` | New repositories start on `main` instead of `master`. Applies to repos you create from now on, not existing ones. |
| `push.default current` | `git push` pushes the branch you're on, without you naming it. |
| `push.autoSetupRemote true` | The first push of a new branch just works — see below. |
| `pull.rebase false` | `git pull` **merges** rather than rebases. This course merges `main` into your branch; rebasing rewrites history and leads to force-pushing a branch a teammate may already be reviewing. |
| `core.editor "code --wait"` | Git opens VS Code for commit messages and waits for you to close the tab. Without `--wait`, Git thinks you finished instantly and takes an empty message. |
| `merge.tool` / `mergetool.vscode.cmd` | Lets `git mergetool` open VS Code's merge editor for conflicts. |
| `diff.tool` / `difftool.vscode.cmd` | Lets `git difftool` show diffs side by side in VS Code. |

??? note "The three ways Git can reconcile diverged branches — and why we chose merge"

    With no `pull.rebase` set, `git pull` stops dead the first time your branch and the
    remote have diverged, and makes you pick:

    ```
    hint: You have divergent branches and need to specify how to reconcile them.
    hint:   git config pull.rebase false  # merge
    hint:   git config pull.rebase true   # rebase
    hint:   git config pull.ff only       # fast-forward only
    fatal: Need to specify how to reconcile divergent branches.
    ```

    You set this above, so you shouldn't meet it here. You will meet it on a machine that
    hasn't been configured — a new laptop, a new job — so it's worth knowing what you'd be
    choosing between:

    | Option | What it does | Verdict |
    |---|---|---|
    | `pull.rebase false` — **merge** | Makes a merge commit when the branches have diverged | **Ours.** Never rewrites history, so nothing ever needs force-pushing, and each conflict is resolved once |
    | `pull.rebase true` — rebase | Recreates your commits on top of theirs as *new* commits | Rewrites history, which means force-pushing a branch a teammate may be reviewing. You can also hit the same conflict once per replayed commit |
    | `pull.ff only` | Refuses to reconcile and stops; you decide manually | Defensible once you're experienced, but it fails at the moment you most need to sync, and the recovery isn't obvious |

    **This prompt is not about a merge conflict.** It's asking *how to combine two branches*,
    and it appears before Git has even looked for conflicting lines. A merge conflict is a
    separate event — the same lines changed on both sides — and it can happen under any of
    these three.

!!! tip "What does `push.autoSetupRemote` do?"

    It prevents this, which otherwise happens on the **first push of every new branch**:

    ```
    fatal: The current branch feature/my-cool-branch has no upstream branch.
    To push the current branch and set the remote as upstream, use
        git push --set-upstream origin feature/my-cool-branch
    ```

    With the setting on, a plain `git push` sets the upstream for you. You'll still see
    `git push -u origin <branch>` written out in the guides — that's the explicit form, and
    it does the same thing.

    For more detail, read
    [this article](https://dev.to/this-is-learning/this-new-git-push-config-will-save-you-lot-of-frustration-27a9).

---

Next: the [team charter](team-charter.md) for how the team works, and
[Lesson 1](lesson-01-guide-collaborating-in-a-shared-repo.md) for the branch → pull request
→ review → merge loop. The
[Git collaboration quick-start](../reference/git-collaboration-quickstart.md) is the sheet
to keep open once you're working.
