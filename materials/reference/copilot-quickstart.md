# GitHub Copilot Quick Start — Cheat Sheet

An evergreen reference for **GitHub Copilot**, TQL's preferred AI coding assistant.
Copilot suggests code, answers questions about a codebase, and can draft whole changes.
This sheet is the shared reference behind the Copilot lessons and stretch challenges in
every pass — keep it open while you use the tool.

> **The one rule that makes AI help instead of hurt: you own every line.** Copilot is a
> fast, confident junior pair-programmer that has never seen *your* project's rules. It
> is right often and wrong often, in the same tone. Your job is not to accept its output
> — it's to **judge** it. If you can't explain why a suggestion is correct, don't accept
> it. That judgment is the actual skill this course is teaching; the typing it saves is a
> side effect.

---

## Where Copilot lives in this course

You use two editors in this course, and Copilot shows up a little differently in each:

| Pass | Editor | Copilot surface you'll use most |
|---|---|---|
| API (C#) | **Visual Studio** | Inline **autocomplete** as you type controllers/models; **Chat** for the Lesson 7 code review |
| HTML/CSS | **VS Code** | Inline **autocomplete** + **Chat** for markup |
| React | **VS Code** | **Chat** and, later, **agent** workflows for features |

The three surfaces, simplest to most powerful:

1. **Inline autocomplete** — grey "ghost text" appears ahead of your cursor as you type.
   Press **Tab** to accept, **Esc** to dismiss, keep typing to ignore it. Best for the
   next line or two of code you already know you want.
2. **Copilot Chat** — a side panel where you ask questions in plain English. Select code
   first to give it context, then ask "explain this," "review this," or "write a test for
   this." Best for understanding, reviewing, and small scoped changes.
3. **Agent mode** — you hand Copilot a task ("add a delete endpoint to this controller")
   and it proposes edits across files as a **diff you approve or reject**. Most powerful,
   most in need of careful review. You meet this last, in the React pass.

---

## Set-up (once)

1. **Sign in with the GitHub account that has your TQL Copilot license.** Copilot is a
   paid service; TQL provisions access — use the account you were told to. (Personal
   accounts without a license won't get suggestions.)
2. **Install the extension.**
   - *Visual Studio:* Copilot ships with recent versions; if not, add it via
     **Extensions → Manage Extensions**. Sign in when prompted.
   - *VS Code:* install **GitHub Copilot** (and **GitHub Copilot Chat**) from the
     Extensions panel, then sign in.
3. **Confirm it's active.** Open a code file and start typing — you should see grey ghost
   text. The Copilot status icon in the editor's status bar shows whether it's enabled.

---

## The discipline: verify, don't trust

Run every suggestion through this before you accept it:

- **Do I understand it?** If you can't read it line by line and say what it does, reject
  it. Accepting code you can't explain is how bugs and security holes get in.
- **Does it match *this* project's conventions?** Copilot suggests what's common on the
  internet, not what your codebase does. See the watch-list below.
- **Does it actually run / render?** Verify it the same way you verify your own work —
  **Insomnia** for the API pass, the **browser + DevTools** for HTML/CSS and React. A
  confident suggestion that doesn't compile is still wrong.
- **Is it the smallest thing that works?** Prefer a two-line suggestion you understand
  over a twenty-line one you don't. You can always ask for more.

Copilot is genuinely good at: repetitive boilerplate (a fourth CRUD controller that
mirrors three you wrote), **explaining** unfamiliar code, **reviewing** code you wrote,
drafting test data, and remembering syntax you half-know. Lean on it there.

---

## ⚠️ House-style watch-list — where Copilot will fight this course

This course makes deliberate **teaching simplifications**. Copilot, trained on
production code from everywhere, will confidently suggest the "real-world" version and
push you off them. When it does, that's a *learning moment*, not advice — **reject it and
know why.** Catching these is one of the best signs you understand the material.

| Copilot will suggest… | This course does… | Why we skip it |
|---|---|---|
| DTOs / view models | Uses EF models directly in controllers | One less layer while you learn the core flow |
| A repository pattern | Injects `DbContext` straight into controllers | Same — fewer moving parts |
| JWT / `[Authorize]` / auth middleware | **No tokens**; login returns the user object, stored client-side | Auth is taught conceptually, not as production security |
| A tighter CORS policy | CORS wide open | Intentional for teaching |
| `EntityState.Modified` on update | Fetch-then-`SetValues` | The pattern the guides teach |
| `virtual` navigation properties / lazy loading | Explicit `Include()` every time | Makes data loading visible |
| Bootstrap `row`/`col` grid or CSS Grid | **Flexbox utilities only** | The one layout rule for the whole course |
| A Bootstrap CDN `<link>` | Bootstrap installed via **npm** | Matches how the project is built |

If a suggestion adds any of the left column, it's Copilot not knowing your rules — not a
gap in your code. (This list is also why "review your own code with Copilot" is such a
good exercise: it surfaces these on purpose.)

---

## Writing prompts that get better answers

Copilot is only as good as the context you give it:

- **Give it a reference.** "Match the structure and conventions of this file" plus an
  open example beats "write a controller" from nothing. (The AI-assisted seed-data
  stretch challenge works exactly this way — you hand it an existing script to imitate.)
  *How* you attach that reference matters — see **How to hand Copilot Chat your files**
  below.
- **Be specific about constraints.** "Use flexbox utilities, not the grid" or "no DTOs —
  use the model directly" steers it back toward house style before it drifts.
- **Ask it to explain, not just produce.** "Explain what this `Include()` does" turns
  Copilot into a tutor for code you're reading — a great use that isn't generation at all.
- **Work in small steps.** Ask for one method, review it, then the next — not a whole
  file you then have to untangle.

### How to hand Copilot Chat your files

The single biggest lever on answer quality is *what Copilot can actually see.* There are
several ways to give it context in Chat, and they are **not** equivalent:

| Method | How | What Copilot sees | Best for |
|---|---|---|---|
| **Paste / copy** | Copy code, paste into the prompt | A **static snapshot** — text only, no file path, not kept in sync | A short snippet, or code from outside the project |
| **Highlight (selection)** | Select code in the editor, then ask | Just the **selected lines**, live | "Explain / review / refactor *this*" |
| **Open (active) file** | Just have the file open | The **whole open file**, automatically | Questions about the file you're already in |
| **`#` file reference** | Type `#` and pick a file (or use the **Add Context** button, or drag a file into Chat) | The **full, live contents of a specific file** — even one you don't have open | "Match the conventions of *this* file" while writing another |
| **`#codebase`** | Type `#codebase` in the prompt | Copilot **searches the whole project** for relevant files | "Where is X handled?" across files you can't name |

A few things worth knowing:

- In VS Code your **current selection and active file are usually attached automatically**
  — they show as context chips above the prompt, and you can remove them.
- **Paste is a snapshot; a `#` reference is live.** Paste a controller, then edit it, and
  Copilot is still reasoning about the *old* text. A `#file` reference always reflects the
  file as it is now — prefer it over pasting for anything in the project.
- **More context isn't always better.** When you know exactly what the answer should
  resemble, attach the **one file to imitate**, not the whole `#codebase` — a narrower
  reference gives a sharper answer.
- **Visual Studio** (the API pass) has the same ideas — selection and open file as
  context, plus `#`-style references — the menus differ, but *what you choose to attach*
  is the same decision.

---

## Learn more

- [GitHub Copilot documentation](https://docs.github.com/en/copilot) — official docs for
  every editor and feature.
- [Copilot in Visual Studio](https://learn.microsoft.com/en-us/visualstudio/ide/visual-studio-github-copilot-install-and-states)
  — set-up and usage for the API pass.
- [Copilot in VS Code](https://code.visualstudio.com/docs/copilot/overview) — set-up and
  usage for the HTML/CSS and React passes.
