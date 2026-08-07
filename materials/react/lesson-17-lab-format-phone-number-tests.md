# Lesson 17 Lab — Testing `formatPhoneNumber`

Same file, second function. You covered every branch of `getTextBackgroundByStatus` with the
instructor; now do `formatPhoneNumber` on your own.

It's four lines long and you've been rendering its output since Lesson 6. Your first test is
going to fail anyway, and the reason it fails is the whole point of the lab.

> **Prerequisite:** Vitest installed and `src/utility/formatUtilities.test.ts` created in the
> guide. Leave `npm test` running in watch mode in a second terminal.

Here's the function, unchanged, in your project:

```ts title="src/utility/formatUtilities.ts"
export function formatPhoneNumber(phoneNumber: string) {
  if (!phoneNumber) return;
  const first3Digits = phoneNumber.substring(0, 3);
  const middle3Digits = phoneNumber.substring(3, 6);
  const last3Digits = phoneNumber.substring(6, 10);
  return `(${first3Digits}) ${middle3Digits}-${last3Digits} `;
}
```

---

## Part 1 — Write the obvious test

1. Add a **second `describe` block** to `formatUtilities.test.ts`, below the first one — same
   file, because it's testing the same module. Add `formatPhoneNumber` to the import from
   `./formatUtilities`.
2. Write the test you'd expect to write. A ten-digit number in, a formatted number out:

    ```ts title="src/utility/formatUtilities.test.ts"
    describe("formatPhoneNumber", () => {
      it("formats a ten-digit number", () => {
        expect(formatPhoneNumber("8005551234")).toBe("(800) 555-1234");
      });
    });
    ```

3. Save, and read the terminal.

✅ **Checkpoint:** it **fails** — and if you can't see why, keep reading. You didn't make a
mistake typing it.

---

## Part 2 — Read the failure

4. Look at the Expected and Received lines. They will appear to be **the same string**.

    They aren't. `formatPhoneNumber` returns a **trailing space** — look at the end of the
    template literal: `` `…-${last3Digits} ` ``. Vitest is reporting the difference honestly;
    a trailing space is just invisible in a terminal.

5. When two strings look identical but don't match, **make the invisible visible.** Any of
   these settles it in seconds:

    ```ts
    console.log(JSON.stringify(formatPhoneNumber("8005551234")));
    console.log(formatPhoneNumber("8005551234")?.length);
    ```

    `JSON.stringify` puts quotes around it so you can see where it ends. The length is 15 where
    you expected 14. Delete the `console.log` once you've seen it.

6. Fix the **test**, not the function — assert what the code actually does:

    ```ts
    expect(formatPhoneNumber("8005551234")).toBe("(800) 555-1234 ");
    ```

✅ **Checkpoint:** green — and you now know something about a function you've been shipping
since Lesson 6.

!!! note "Why nobody ever noticed"

    `formatPhoneNumber` has exactly one caller — `StaffCard.tsx`, where its output goes into a
    `<span>`. **HTML collapses trailing whitespace**, so the space has never once been visible
    on screen. It took a test four seconds to find something a year of looking at the page
    never would.

    That's not a bug you need to fix today, and *"assert what it does, not what you assumed"*
    is the lesson. But notice what just happened: the test didn't confirm what you knew, it
    **told you something you didn't**. That's the part people don't expect from testing.

---

## Part 3 — Finish the job

7. Add a second case with a different number, so the test isn't pinned to one lucky string.
8. **Prove these can fail**, the same way you did in the guide: change one expected value to
   something wrong, watch the failure name *that* `it`, and put it back.
9. Re-read your two test names. Do they read as sentences that say what's being asserted?
   `it("formats a ten-digit number")` does. `it("works")` doesn't.
10. Run the whole file once, cleanly:

    ```bash
    npx vitest run
    ```

✅ **Checkpoint:** eight tests green in one file — six from the guide, two of yours — and
you've seen at least one of yours red on purpose.

> **What's deliberately missing:** what happens for `null`, for `""`, or for a seven-digit
> number. Those are **edge cases**, and they're Lesson 18 — along with the fact that this
> function's first line returns `undefined` rather than a string.

---

## Stretch challenges

Optional — for when you finish early. Not required.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs some
research.

- **Rename the lie** — [Reinforce] — `last3Digits` is assigned `phoneNumber.substring(6, 10)`,
  which is **four** digits. The name has been wrong since the file was written and no test can
  catch it, because tests assert behaviour and not names. Rename it to something true, save,
  and watch your tests stay green. *That* is what a suite is for — changing code without
  having to be brave about it.
- **Find the callers** — [Reinforce] — before you'd change a shared function for real, you'd
  find everything that depends on it. Search the project for `getTextBackgroundByStatus`: it
  has two callers, on two different screens. One fix, two places affected — check rather than
  assume.
- **Break the app, watch the test** — [Reinforce] — change one `case` in
  `getTextBackgroundByStatus` to the wrong class and leave it. Which is faster at telling you
  something's wrong: `npm test`, or opening the Orders page and looking at the badges? Put it
  back.
- **Test-drive a new one** — [Reach] — write the tests *first* for a function that doesn't
  exist yet: `formatCurrency(amount: number)` returning `"$12.99"`. Write three failing tests,
  then write the function until they pass. You'll meet this order again in the team block,
  where it's how defects get fixed.
