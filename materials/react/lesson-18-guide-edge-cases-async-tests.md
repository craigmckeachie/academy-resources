# Lesson 18 Guide — Edge Cases, Errors, and Async Tests

**Goal:** by the end of this lesson you can test the inputs nobody planned for — `null`, empty,
malformed, at the boundary — test a function whose whole job is to **throw**, write an
**`async`** test with `await expect(...).rejects.toThrow()`, and build a fake `Response` to feed
a function that normally only ever sees one from the network. Then you'll point Copilot at the
same file and find out the one thing generated tests reliably get wrong.

**The general pattern you're learning:** Lesson 17 tested what a function is *for*. This one
tests what happens when it's handed something it wasn't expecting — which is where the bugs
are, because the happy path is the one everybody already tried by hand. The question to keep
asking is **"what's the worst thing a caller could pass this?"** and then writing that down as
an assertion instead of hoping.

> **How to use this guide.** Sections headed **▶ Code along** are ones you build into your
> project (each ends with a quick **Save and check**); unmarked sections are concept.

> **Prerequisite:** Lesson 17 — Vitest installed, `"test": "vitest"` in `package.json`, and
> `src/utility/formatUtilities.test.ts` green. Your API does **not** need to be running.

!!! warning "Still the terminal, not the browser"

    Same as Lesson 17. Nothing here changes what the app looks like, and the signal you're
    reading is **red → green**.

<!-- Authoring note (not student-facing): terminal-not-browser is deliberate — don't
     "correct" it to DevTools. Still the DEFAULT NODE ENVIRONMENT: no jsdom, no
     vitest.setup.ts, no @testing-library/* — those are L19's, and installing them here breaks
     "L19 is optional".
     MOCKING fetch (vi.mock / MSW) is out of scope for the whole course. checkStatus is
     testable precisely because you can hand it a real Response you built yourself — that is
     the point of §4, not a workaround.
     TableServe's and PRS's fetchUtilities.ts differ ON PURPOSE. DO NOT sync them in either
     direction, and do not draw attention to any difference between them anywhere in the React
     materials. The reason is instructor-only and is recorded in the private planning notes —
     it must not be restated here, including in a comment. -->

---

## 1. The happy path is the path already tested by hand

You've clicked through TableServe for twelve lessons. Every time you did, you tested the happy
path — a real menu item, a real order, a phone number with ten digits in it. Nobody has ever
tried the Staff page with a staff member whose phone is empty, because you seeded the data and
you gave everyone a phone.

So the tests worth writing are the ones for inputs you can't easily produce by clicking:

| Category | Ask |
|---|---|
| **Empty** | `""`, an empty array, an empty response body |
| **Missing** | `null`, `undefined` — including from a field your TypeScript type swears is a `string` |
| **Boundary** | One below, exactly at, one above — 9 digits, 10 digits, 11 digits |
| **Malformed** | The right type, the wrong shape — a status that isn't a status, text where JSON was promised |

The last column of that table is the job. You don't need every input; you need the one from
each category that would embarrass you.

!!! note "TypeScript is not a runtime guarantee"

    Look at `formatPhoneNumber`'s first line:

    ```ts
    export function formatPhoneNumber(phoneNumber: string) {
      if (!phoneNumber) return;
    ```

    The parameter is typed `string`, so why guard against a falsy value that "can't" happen?

    Because it can. `IStaff` declares `phone: string`, but the API's `Staff.Phone` is
    `string?` — **optional in the database, non-optional in the interface.** A staff member
    saved without a phone comes back as `null`, TypeScript never sees it, and the guard is the
    only thing standing between that and a crash.

    Types describe what you *promised*. Data describes what *arrived*. Tests are where you
    check the second one.

---

## 2. The target: `fetchUtilities.ts`

Every API module in your app runs its responses through this file. It's the most-used code you
have and the least-clicked, because you only reach the interesting parts when something has
already gone wrong.

```ts title="src/utility/fetchUtilities.ts"
export function translateStatusToErrorMessage(status: number) {
  switch (status) {
    case 401:
      return "Please sign in again.";
    case 403:
      return "You do not have permission to view the data requested.";
    default:
      return "There was an error saving or retrieving data.";
  }
}

export async function checkStatus(response: Response) {
  if (response.ok) return response;

  const httpError = { /* … */ };
  console.log(`http error status: ${JSON.stringify(httpError, null, 1)}`);

  let errorMessage = translateStatusToErrorMessage(httpError.status);
  throw new Error(errorMessage);
}
```

Two functions, two new problems. The first is a plain `switch` like Lesson 17's — but its
`default` case is doing much more work than a fallback usually does. The second is `async`,
takes a `Response`, and **throws on purpose**, which is a thing you haven't asserted yet.

---

## 3. ▶ Code along — the case that catches everything

Create the test file beside the code:

```ts title="src/utility/fetchUtilities.test.ts"
import { describe, it, expect } from "vitest";
import { translateStatusToErrorMessage, checkStatus } from "./fetchUtilities";

describe("translateStatusToErrorMessage", () => {
  it("asks the user to sign in again on 401", () => {
    expect(translateStatusToErrorMessage(401)).toBe("Please sign in again.");
  });

  it("reports a permissions problem on 403", () => {
    expect(translateStatusToErrorMessage(403)).toBe(
      "You do not have permission to view the data requested."
    );
  });

  it("falls back to the generic message on 500", () => {
    expect(translateStatusToErrorMessage(500)).toBe(
      "There was an error saving or retrieving data."
    );
  });

  it("falls back to the generic message on 404", () => {
    expect(translateStatusToErrorMessage(404)).toBe(
      "There was an error saving or retrieving data."
    );
  });
});
```

**Two tests for the `default` branch, not one.** In Lesson 17 the unknown-status case was one
test because the branch was a genuine fallback. Here it isn't: `404` and `500` are the two
statuses this app hits *most*, and both land in `default` by design. Writing them separately
records that as a decision rather than an accident — and if someone adds `case 404:` next
year, exactly one test goes red and its name tells them which behaviour they changed.

**Save and check**

- **4 passed.**
- Break the 403 message by one character — a full stop, a capital — and watch it fail. Message
  strings are user-visible copy; asserting them exactly is the point.

---

## 4. ▶ Code along — testing a function that throws

`checkStatus` needs a `Response`. In the app, one arrives from `fetch`. In a test, **you build
one** — `Response` is built into Node, so there's nothing to import and nothing to mock:

```ts
new Response("", { status: 404 })
```

That's a real `Response` object with a real status. `checkStatus` can't tell the difference,
which is exactly why this works.

Now, asserting a throw. Your instinct is a `try`/`catch`, and it has a trap in it:

```ts
// Don't do this — it passes when the function DOESN'T throw
it("throws on 404", async () => {
  try {
    await checkStatus(new Response("", { status: 404 }));
  } catch (error: any) {
    expect(error.message).toBe("There was an error saving or retrieving data.");
  }
});
```

If `checkStatus` stopped throwing tomorrow, the `catch` never runs, no assertion ever executes,
and the test **passes**. A green test proving nothing — the exact failure Lesson 17 warned
about. Use Vitest's matcher instead, which fails when nothing is thrown:

```ts title="src/utility/fetchUtilities.test.ts"
describe("checkStatus", () => {
  it("returns the response unchanged when it's ok", async () => {
    const response = new Response("{}", { status: 200 });
    await expect(checkStatus(response)).resolves.toBe(response);
  });

  it("throws the generic message on 404", async () => {
    await expect(
      checkStatus(new Response("", { status: 404 }))
    ).rejects.toThrow("There was an error saving or retrieving data.");
  });

  it("throws the sign-in message on 401", async () => {
    await expect(
      checkStatus(new Response("", { status: 401 }))
    ).rejects.toThrow("Please sign in again.");
  });
});
```

Four things are new, and all four transfer:

| | |
|---|---|
| `async () => {}` | The test function itself is async, because the thing it's testing is |
| **`await expect(...)`** | You `await` the *assertion*, not the call. Forget the `await` and the test finishes before the promise settles — and passes regardless |
| `.rejects.toThrow(msg)` | Asserts the promise rejects **and** the message matches. Fails if nothing throws |
| `.resolves.toBe(x)` | The mirror image, for the success path |

**Missing the `await` on line 2 of that table is the most common async-test bug there is.** It
produces a test that passes no matter what the code does, and nothing about it looks wrong.

**Save and check**

- **7 passed** across the file.
- Your terminal is now full of `http error status: {...}` — that's `checkStatus`'s own
  `console.log` firing on every failing status. It's noise, not a problem: the function logs
  for the developer's benefit and your test just triggered it three times. **Tests surface
  side effects you'd forgotten were there.**

    This is the first place Lesson 17's editor extension earns its keep: hit **Run** above a
    single `it` and you get that test's output and one log line, instead of the whole file's.
- Delete the `await` from one of the `rejects` tests. It still passes. Put it back. That's the
  trap, seen once.

---

## 5. Asserting a message vs. asserting that it broke

`toThrow()` with no argument asserts only that *something* threw. `toThrow("…")` asserts the
message too.

Prefer the message when the message is the behaviour — and here it is. `translateStatusToErrorMessage`
exists solely to decide what the user reads; a test that only checks "it threw" would pass even
if every status produced the same unhelpful sentence, which is the bug most worth catching.

Prefer the bare `toThrow()` when the message is incidental and likely to be reworded — you don't
want a copy edit turning fifty tests red.

---

## 6. ▶ Code along — did you actually get every branch?

So far you've answered that by reading the code and counting. Vitest can answer it by watching
which lines actually ran:

```bash
npm i -D @vitest/coverage-v8
npx vitest run --coverage
```

You get a table per file. **The column worth reading is the last one, `Uncovered Line #s`** —
not the percentages:

```
File                | % Stmts | Uncovered Line #s
--------------------|---------|-------------------
 formatUtilities.ts |     100 |
 fetchUtilities.ts  |   85.71 | 34-37
```

Go and look at lines 34–37. It's `delay` — exported, used by `MenuItemAPI` and `CategoryAPI`,
and never once called by a test. You didn't know that; the tool did.

That run also wrote an HTML version, with no configuring needed. Open **`coverage/index.html`**
in a browser (right-click it in VS Code → *Reveal in File Explorer*, or `start
coverage/index.html`), click into `src/utility/fetchUtilities.ts`, and you get the source with
a colour down the side: **green ran, red never did.** `delay` is solid red.

Add `coverage` to your `.gitignore` — it's regenerated on every run, and committing a few
hundred generated files makes a pull request unreadable:

```diff title="TableServe.Web/.gitignore"
  node_modules
  dist
+ coverage
```

!!! warning "Covered doesn't mean checked"

    A line counts as covered because a test *ran* it — nobody asked whether you asserted
    anything about it. This reports **100%** and verifies nothing:

    ```ts
    it("formats a phone number", () => {
      formatPhoneNumber("8005551234");   // no expect() at all
    });
    ```

    So it's a **checklist of what you missed**, never a score to chase.

**Save and check**

- `coverage/index.html` opens, and `delay` is red.
- `git status` doesn't mention `coverage`.
- Most of `src/` shows no coverage at all — **expected**, it's all components, which are
  Lesson 19.

---

## 7. Generating tests with Copilot — and the one thing it gets wrong

Lesson 17 kept AI switched off, and here's the debt being paid: you now know what a test is,
you've watched one go red, and that's the minimum needed to see the mistake that follows.

Test generation is genuinely one of the things assistants are best at. Try it — with your
conventions file and `#fetchUtilities.ts` as context:

> Write Vitest tests for `#formatUtilities.ts`.

What comes back will be well-organised, correctly imported, thorough about branches, and
**green on the first run.** Look closely at what it produced for `formatPhoneNumber`:

```ts
expect(formatPhoneNumber("8005551234")).toBe("(800) 555-1234 ");
```

It has faithfully asserted the trailing space you found in Lesson 17's lab. Of course it has —
it read the code and wrote down what the code does.

!!! warning "Generated tests describe. Hand-written tests specify."

    An assistant cannot know what a function was *supposed* to do. It can only observe what it
    *does* and turn that into assertions. So a generated suite over code with a defect in it
    goes **green**, and now the defect is pinned in place — anyone who fixes it breaks a test
    and, more often than you'd like, "fixes" the test instead.

    **And it will score beautifully on the coverage you just ran** — every branch executed,
    every assertion agreeing with the defect. That's section 6's warning and this one being
    the same warning: *executed* and *verified* are different words, and neither a coverage
    percentage nor a green generated suite can tell them apart. Only you deciding the expected
    value can.

    That's not a reason to avoid generation. It's the reason **you** have to decide the
    expected values. The assertions are the specification, and specifying is your job.

**So use it for the half it's actually good at.** Not *"write my tests"* — ask:

> Looking at `#formatUtilities.ts`, what edge cases should I be testing that I haven't?

Now it's doing the thing you want: enumerating inputs — a `null`, an empty string, a number
that's too short, a non-numeric string — while **you** write down what each one *should*
return. That division holds up:

| You decide | Let it draft |
|---|---|
| What the correct output is | The list of inputs worth trying |
| Whether current behaviour is right or a bug | The `describe`/`it` scaffolding around your assertions |
| Which failures matter | Test names, once you've said what's asserted |

And one rule that makes the difference visible: **if a generated test has never been red, treat
it as unverified.** Change the source, watch it fail, change it back. That's the same
proof-it-can-fail move from Lesson 17, and it's the only thing that separates a test from a
paragraph of decoration.

> You'll meet this exact failure again in the **team block**, from the other side: some test
> tickets there get handed to an agent, and the reviewer's job is to spot a suite that went
> green over a bug that was never fixed.

---

## The General Pattern (what to take away)

- **The happy path is already tested** — by you, by hand, for twelve lessons. Write tests for
  empty, missing, boundary, and malformed instead.
- **TypeScript describes what you promised; data is what arrived.** A `string` parameter can
  receive `null` from an API whose column is nullable.
- **A function you can hand a fake object to is a testable function.** `new Response("", {
  status: 404 })` is a real `Response` — no mocking library required.
- **`await expect(...).rejects.toThrow(msg)`**, not `try`/`catch` — the `catch` version passes
  when nothing throws.
- **Forgetting `await` on the assertion** makes an async test pass unconditionally. It's the
  most common bug in async tests and it's invisible.
- **Split the `default` branch by the cases you actually hit**, so a future change turns exactly
  one named test red.
- **`--coverage` is a map of what you didn't run** — read the uncovered line numbers, or open
  `coverage/index.html` and look for red. Never chase the percentage: a test with no `expect`
  in it still reports 100%.
- **Generated tests describe current behaviour; they can't specify intended behaviour.** Let AI
  suggest the inputs; you decide the expected outputs — and note that a generated suite scores
  *well* on coverage while agreeing with the bug.

---

## Build Steps

1. Create `src/utility/fetchUtilities.test.ts` beside `fetchUtilities.ts`.
2. Test `translateStatusToErrorMessage` for **401**, **403**, and the `default` branch via
   **both 404 and 500**.
3. Break one message by a single character, confirm the failure, and restore it.
4. Add a `describe` for `checkStatus`. Build responses with
   `new Response("", { status: n })` — nothing to import.
5. Assert the ok path with `await expect(...).resolves.toBe(response)`.
6. Assert the 404 and 401 paths with `await expect(...).rejects.toThrow("…")`.
7. **Delete one `await`**, watch the test pass anyway, and put it back.
8. `npm i -D @vitest/coverage-v8`, then `npx vitest run --coverage`. Open
   `coverage/index.html`, find the red block in `fetchUtilities.ts`, and add `coverage` to
   `.gitignore`.
9. Ask Copilot to generate tests for `#formatUtilities.ts` and find the assertion that pins
   the trailing space. Don't keep it.
10. Re-ask for **edge cases you're missing** instead, and write the expected values yourself.
