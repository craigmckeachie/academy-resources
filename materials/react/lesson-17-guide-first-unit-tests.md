# Lesson 17 Guide — Your First Unit Tests

**Goal:** by the end of this lesson you can install **Vitest** into the TableServe front end,
write a test file that lives beside the code it tests, describe what a function should do with
`describe` / `it` / `expect`, run the suite in **watch mode**, and — the habit the rest of this
block depends on — **prove a test can fail before you trust it passing.** You'll cover every
branch of `getTextBackgroundByStatus`; in the lab you do the same for `formatPhoneNumber`, and
it will tell you something about that function nobody noticed for years.

**The general pattern you're learning:** a **unit test** is a small piece of code that calls
one function with a known input and asserts the exact output. That's all. Its value isn't that
it's clever — it's that it's **repeatable**: you check the behaviour once by hand, write it
down as an assertion, and from then on the machine checks it every time anyone changes
anything. The skill is choosing which inputs are worth writing down, and asserting *exactly*
what comes back rather than what you assume comes back.

> **How to use this guide.** Sections headed **▶ Code along** are ones you build into your
> project (each ends with a quick **Save and check**); unmarked sections are concept. Each
> code block carries its file name as a title bar.

> **Prerequisite:** the TableServe front end from Lessons 3–12, with
> `src/utility/formatUtilities.ts` in it. Your API does **not** need to be running for this
> lesson — that's part of the point.

!!! warning "This lesson verifies in the terminal, not the browser"

    Every other lesson in this pass ends with you opening DevTools. This one doesn't, and
    neither does Lesson 18. The thing you're learning to read is **red → green in a terminal**,
    not a rendered page. Nothing here changes what the app looks like.

<!-- Authoring note (not student-facing): terminal-not-browser is deliberate and is the one
     place in the React pass where that's true — don't "correct" it back to DevTools on a
     regeneration. L17 installs plain vitest in the DEFAULT NODE ENVIRONMENT only. jsdom,
     vitest.setup.ts, @testing-library/react and user-event belong to L19 and must not be
     installed here, or "L19 is optional" stops being true.
     Do NOT fix formatPhoneNumber's trailing space or the misnamed last3Digits in the
     reference app — the lab's payoff depends on both. See materials/CLAUDE.md → Testing
     lessons. -->

!!! note "AI stays off for this lesson — it comes back in Lesson 18"

    You just spent Lesson 16 learning to generate code, so this will feel like a step
    backwards. It isn't. Generated tests fail in one specific, invisible way, and **you cannot
    see that failure if you have never written a test by hand or watched one go red.** Lesson
    18 hands the tool back and shows you exactly what it does wrong. Type these yourself
    first — there are about forty lines of them in the whole lesson.

---

## 1. What a unit test is — and what it isn't

A unit test takes **one function**, gives it **one input**, and asserts **one expected output**.
It doesn't open a browser, doesn't call your API, doesn't touch the database. That's what makes
it fast enough to run on every save.

| A unit test is good for | Not this lesson |
|---|---|
| A function that takes values and returns a value | Anything that renders — that's Lesson 19 |
| Formatting, calculating, mapping, translating | Anything that fetches — mocking `fetch` is out of scope for this course |
| Every branch of a `switch` or an `if` | Whether the page *looks* right |

Look at what that rules in. Almost everything you've written this pass is a component, and
components are the *hard* thing to test. But `src/utility/formatUtilities.ts` is two plain
functions — values in, values out, no React anywhere. That's why we start there, and it's a
useful habit in reverse too: **code that's easy to test is usually code you pulled out of a
component on purpose.**

Here's the target, exactly as it is in your project:

```ts title="src/utility/formatUtilities.ts"
export function getTextBackgroundByStatus(status: string) {
  switch (status) {
    case "PLACED":
      return "text-bg-secondary";
    case "PREPARING":
      return "text-bg-warning";
    case "READY":
      return "text-bg-info";
    case "SERVED":
      return "text-bg-success";
    case "CANCELLED":
      return "text-bg-danger";
    default:
      return "";
  }
}
```

Six paths through it: five statuses and the `default`. Six tests, then — and *"six"* is a
number you can get from reading the code, which is the first useful thing tests make you do.

---

## 2. ▶ Code along — installing Vitest

**Vitest** is a test runner built for Vite projects, which is what yours is. It reads your
existing Vite config, so there is almost nothing to set up.

In `TableServe.Web`:

```bash
npm i -D vitest
```

**`-D` is short for `--save-dev`.** It puts Vitest in `devDependencies` rather than
`dependencies` — the difference being *does the running app need this?* React and Bootstrap do,
so they're regular dependencies. Vitest, TypeScript and ESLint are things **you** need while
building, and never ship to a user; `npm run build` leaves them out. Open `package.json` after
it installs and you'll see `vitest` land in the same list as `vite` and `typescript`.

Then add one line to the `scripts` block:

```diff title="TableServe.Web/package.json"
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
+   "test": "vitest",
    "preview": "vite preview"
  },
```

Order doesn't matter to npm — it goes above `preview` so the line that was last stays last. Add
it at the end instead and you also have to put a comma on `preview`, since JSON allows no
trailing comma on the final entry.

Run it:

```bash
npm test
```

**Save and check**

- Vitest starts and reports **no test files found** — it's looking, and there's nothing there
  yet. That's the correct output for right now.
- Press **`q`** to quit. (It's sitting in watch mode, which is section 6.)

!!! note "That's the whole setup"

    No config file, no environment to choose, no transformer to wire up. That's because these
    are plain TypeScript functions running in Node — nothing has to pretend to be a browser.
    **Lesson 19 changes that**, because rendering a component does need a fake browser, and
    it installs what it needs when it needs it.

---

## 3. ▶ Code along — your first test

Test files live **beside the code they test**, with `.test.ts` in the name. Not in a separate
`tests/` folder at the root — next to the file, so you can't edit one without seeing the other.

```
src/utility/
  formatUtilities.ts
  formatUtilities.test.ts    ← new
```

Create it with a single test:

```ts title="src/utility/formatUtilities.test.ts"
import { describe, it, expect } from "vitest";
import { getTextBackgroundByStatus } from "./formatUtilities";

describe("getTextBackgroundByStatus", () => {
  it("returns the secondary badge class for PLACED", () => {
    expect(getTextBackgroundByStatus("PLACED")).toBe("text-bg-secondary");
  });
});
```

Three pieces, and you'll write them a thousand more times:

| | What it does |
|---|---|
| `describe("...", () => {...})` | Groups related tests. Name it after the **thing** — usually the function |
| `it("...", () => {...})` | One test. Name it after the **behaviour**, so it reads as a sentence: *it returns the secondary badge class for PLACED* |
| `expect(actual).toBe(expected)` | The assertion. `toBe` is exact equality — the whole string, character for character |

**Save and check**

```bash
npm test
```

- **1 passed.** Vitest found the file, ran it, and the assertion held.

---

## 4. Prove it can fail

You have one green test. Here is the uncomfortable question: **how do you know it ran?**

A test file with a typo'd import, a `describe` you never called, or an assertion comparing two
things that are both `undefined` can sit there looking green forever. Green is not evidence
until you've seen the same test go red.

So break it on purpose. Change the expected value to something you know is wrong:

```ts title="src/utility/formatUtilities.test.ts"
    expect(getTextBackgroundByStatus("PLACED")).toBe("text-bg-primary");
```

Vitest fails and shows you both sides:

```
 FAIL  src/utility/formatUtilities.test.ts > getTextBackgroundByStatus > returns the secondary badge class for PLACED

 AssertionError: expected 'text-bg-secondary' to be 'text-bg-primary'

 - Expected
 + Received

 - text-bg-primary
 + text-bg-secondary
```

Read that carefully, because it's the output you'll spend the rest of your career reading.
**Expected** is what you wrote in the test. **Received** is what the function actually returned.
The function is fine here; the test was wrong — which is worth knowing, because *your test being
wrong* is at least as common as your code being wrong.

Now put it back to `"text-bg-secondary"` and watch it go green.

**Save and check**

- You have seen this test **red**, and then **green**, and you changed only the expectation
  between them. Now the green means something.

!!! tip "Red before green, for the rest of the course"

    This is a small version of a habit that gets serious later. In the team block you'll fix
    defects, and the rule there is **write the failing test first** — reproduce the bug as a
    red test, *then* fix the code and watch it turn green. A test written after a fix, that
    passes the first time it's ever run, proves nothing about whether it would have caught
    anything.

---

## 5. ▶ Code along — cover every branch

One status down, five paths to go. Before you type five more `it` blocks by hand, get the
editor to do it.

### Install the Vitest snippets

In VS Code's **Extensions** panel, search for **Vitest Snippets** by *dein Software*
(`deinsoftware.vitest-snippets`) and install it —
[marketplace listing](https://marketplace.visualstudio.com/items?itemName=deinsoftware.vitest-snippets).

Type the prefix and press **Tab**. These are the ones worth learning today:

| Type | Tab | You get |
|---|---|---|
| `iv` | ⇥ | `import { it, expect, describe } from 'vitest'` |
| `d` | ⇥ | `describe('group', () => { … })` |
| `i` | ⇥ | `it('should', () => { … })` |
| `ia` | ⇥ | `it('should', async () => { … })` — you'll want this in Lesson 18 |
| `tb` | ⇥ | `expect().toBe()` |
| `te` | ⇥ | `expect().toEqual()` — for objects, in Lesson 18's lab |

After it expands, **Tab** again jumps between the placeholders — the test name, then the body.

!!! note "You typed the first one by hand on purpose"

    Same principle as everywhere else in this course: build it once yourself so you know what
    the shortcut is producing, then stop doing it manually. A snippet you can't read is just a
    faster way to be confused.

    One thing to fix every time it expands: the placeholder name is `'should'`. **Replace it
    with the behaviour**, as a sentence — `it("returns the warning badge class for PREPARING")`.
    Section 7 is about why that matters, and a file full of `it('should')` is exactly what it's
    warning you about.

*(Snippets are a convenience, not a requirement. If you can't install extensions on your
machine, type them out — the lesson is identical.)*

Now fill in the remaining paths:

```ts title="src/utility/formatUtilities.test.ts"
import { describe, it, expect } from "vitest";
import { getTextBackgroundByStatus } from "./formatUtilities";

describe("getTextBackgroundByStatus", () => {
  it("returns the secondary badge class for PLACED", () => {
    expect(getTextBackgroundByStatus("PLACED")).toBe("text-bg-secondary");
  });

  it("returns the warning badge class for PREPARING", () => {
    expect(getTextBackgroundByStatus("PREPARING")).toBe("text-bg-warning");
  });

  it("returns the info badge class for READY", () => {
    expect(getTextBackgroundByStatus("READY")).toBe("text-bg-info");
  });

  it("returns the success badge class for SERVED", () => {
    expect(getTextBackgroundByStatus("SERVED")).toBe("text-bg-success");
  });

  it("returns the danger badge class for CANCELLED", () => {
    expect(getTextBackgroundByStatus("CANCELLED")).toBe("text-bg-danger");
  });

  it("returns an empty string for an unknown status", () => {
    expect(getTextBackgroundByStatus("BANANA")).toBe("");
  });
});
```

**The last one is the interesting test**, and it's the one people leave out. Five tests prove
the cases you thought of; the sixth pins down what happens when someone passes something you
*didn't* think of. `"BANANA"` isn't a joke — it stands in for a typo, a new status added to the
API next year, or a `status` field that arrived empty. The `default` branch is real code and it
deserves an assertion like any other.

**Save and check**

- **6 passed.**
- Deliberately break one of the middle ones, confirm Vitest names *that* test in the failure,
  and put it back. Vitest tells you which `it` failed — which is the entire reason test names
  are written as sentences.

---

## 6. Three ways to run them

### Watch mode — the default

`npm test` doesn't exit. It watches your files and re-runs on save, and that changes how you
work: you leave it running in a second terminal beside your editor and glance at it, rather
than running anything deliberately.

| Key | Does |
|---|---|
| `a` | Re-run **a**ll tests |
| `f` | Re-run only the **f**ailed ones |
| `q` | **Q**uit |

### One run, then exit

Which is what you want in a build pipeline, and what a teammate wants when checking your pull
request:

```bash
npx vitest run
```

### ▶ From the editor — running just one test

Watch mode re-runs everything. When one test is failing and you want to poke at *that one*,
the command line gets awkward fast:

```bash
npx vitest run -t "returns the danger badge class for CANCELLED"
```

Nobody types that twice. Install **Jest / Vitest Runner** by *firsttris*
(`firsttris.vscode-jest-runner`) from the Extensions panel —
[marketplace listing](https://marketplace.visualstudio.com/items?itemName=firsttris.vscode-jest-runner).
Despite the name it handles Vitest, and it needs no configuration.

Reopen `formatUtilities.test.ts` and look above each `describe` and each `it` — there's now a
small **`Run | Debug`** link on the line above:

- **Run** on one `it` runs **only that test**, and prints the result in a terminal panel.
- **Run** on the `describe` runs that group.
- **Debug** launches it with the debugger attached, so a breakpoint inside the function under
  test actually stops. That's the fastest way to answer *"what is this thing even returning?"*

You also get every test listed in VS Code's **Testing** panel (the flask icon in the activity
bar), with a green tick or red cross beside each one.

!!! note "The terminal is still the source of truth"

    Green ticks in a sidebar are pleasant and they hide the thing you actually need to read.
    When a test fails, go and read the **Expected/Received** output — that's section 4, and
    it's the skill that carries into the team project, where the whole workflow is `npm test`
    going red and then green in a terminal.

    Use the editor buttons to run **one** test quickly. Use the terminal to find out **why**
    it failed.

*(An alternative, if you'd rather: the Vitest team publish their own extension,
`vitest.explorer`. It uses gutter icons and the Testing panel instead of CodeLens, with no
`Run | Debug` links in the code. Either is fine — this course's examples describe the
CodeLens one.)*

---

## 7. Naming — and why it's the part that pays

A failing test is a message to whoever reads it, usually future you at 4pm. The name is the
whole message, because a red line in a terminal is all you get before you go digging.

### `describe` names the thing. `it` finishes the sentence.

Vitest prints them **joined together** when something fails:

```
FAIL  getTextBackgroundByStatus > returns an empty string for an unknown status
```

Read that out loud — it's a sentence, and every rule below falls out of that one fact.

- **`describe`** takes the name of the unit exactly as it's spelled in the code:
  `describe("getTextBackgroundByStatus", …)`. Not "the badge helper", not "formatUtilities
  tests". You want to be able to search for it.
- **`it`** finishes *"it ___"*, in the third person: **returns**, **throws**, **formats**,
  **renders**, **shows**, **disables**.

### Three rules that do the work

**Start with the verb, and skip "should".** `it("returns the danger badge class")`, not
`it("should return the danger badge class")` — every test *should* do something, so the word
carries no information and lengthens every line of output. (This is also the placeholder the
snippet drops in, so it's the thing to overwrite.)

**Say when.** A verb alone can't tell two tests apart. The shape is **verb → what → when**:

| Vague | Better |
|---|---|
| `it("returns a badge class")` | `it("returns the danger badge class for CANCELLED")` |
| `it("handles bad input")` | `it("returns undefined when the phone is null")` |
| `it("works")` | `it("formats a ten-digit number")` |

**Describe the behaviour, not the machinery.** `it("returns an empty string for an unknown
status")` stays true forever. `it("hits the default case of the switch")` becomes a lie the day
someone rewrites that `switch` as a lookup object — and the test itself would still pass, so
nothing tells you the name went stale.

### Don't repeat yourself across the two names

`describe` already said the function name, so the `it` shouldn't:

```ts
// ❌ getTextBackgroundByStatus > getTextBackgroundByStatus returns "" for a bad status
it("getTextBackgroundByStatus returns \"\" for a bad status", …)

// ✅ getTextBackgroundByStatus > returns an empty string for an unknown status
it("returns an empty string for an unknown status", …)
```

!!! tip "For components, the subject is the user"

    Same rule, different noun. When you get to **Lesson 19** the thing you're naming isn't a
    return value, it's what appears on screen: `it("shows the Manager badge for a manager")`,
    `it("reveals Edit and Delete when the menu is opened")`. Never
    `it("sets showMenu to true")` — that's the machinery again, and it's the version that
    breaks when someone renames a variable.

### And two rules that aren't about naming

**One behaviour per `it`.** Three assertions in one test means the second and third never run
once the first fails — so you fix one thing, re-run, and discover another. Separate tests all
report at once, and each one has a name telling you what it was.

**Assert the exact value.** `toBe("text-bg-secondary")` is a real check. Asserting merely that
something was returned, or that a string isn't empty, passes for a function that's badly wrong.
The lab is about to show you why this one matters more than it sounds.

**Test the branches, not the lines.** Six tests here because there are six paths, not because
there are twenty-four lines.

---

## The General Pattern (what to take away)

- A **unit test** is one function, one input, one asserted output — no browser, no API, no
  database. That's what makes it fast enough to run on every save.
- **Write one by hand, then let snippets write the rest** — but always replace the `'should'`
  placeholder with the behaviour you're asserting.
- **Editor buttons to run one test; the terminal to find out why it failed.** The green tick
  tells you less than the Expected/Received output does.
- **Tests live beside the code they test**, named `*.test.ts`.
- **`describe` names the unit; `it` finishes the sentence** — Vitest prints them joined, so
  read them together. Verb first, no "should", and say *when*:
  `returns the danger badge class for CANCELLED`.
- **Name the behaviour, not the machinery.** A name that describes a `switch` goes stale the
  day someone rewrites it, and nothing turns red to tell you.
- **A test you've never seen fail is not yet evidence.** Break it on purpose once; read the
  Expected/Received output; put it back.
- **The `default` branch deserves a test.** The cases you didn't think of are the ones that
  reach production.
- **Assert exactly**, not approximately — a loose assertion passes for badly wrong code.
- Pure functions are easy to test, which is a reason to keep pulling logic *out* of components.

---

## Build Steps

1. In `TableServe.Web`, run `npm i -D vitest`.
2. Add `"test": "vitest"` to the `scripts` block in `package.json`.
3. Run `npm test` and confirm it reports **no test files found**.
4. Create `src/utility/formatUtilities.test.ts` beside `formatUtilities.ts`.
5. Import `describe`, `it`, `expect` from `vitest`, and `getTextBackgroundByStatus` from
   `./formatUtilities`.
6. Write one test for `PLACED`, and run it — **1 passed**.
7. **Break it on purpose**, read the Expected/Received output, and put it back.
8. Install the **Vitest Snippets** extension (`deinsoftware.vitest-snippets`) and learn four
   prefixes: `iv`, `d`, `i`, `tb`.
9. Add the remaining four statuses **and the unknown-status case** — six tests, all green.
   Rename every `'should'` placeholder to the behaviour it's asserting.
10. Install **Jest / Vitest Runner** (`firsttris.vscode-jest-runner`) and use the `Run` link
    above a single `it` to run that test on its own.
11. Leave `npm test` running in watch mode while you work through the lab.
