# Lesson 18 Lab — `parseJSON`, and the Inputs Nobody Planned For

Two jobs. **First**, test `parseJSON` — the third function in `fetchUtilities.ts`, and another
async one. **Then** go back to `formatPhoneNumber` and write the tests Lesson 17 deliberately
left out: the empty string, the `null` that TypeScript says can't happen, and a number that's
too short.

> **Prerequisite:** the guide's `src/utility/fetchUtilities.test.ts`, green. Leave `npm test`
> running in watch mode. The Vitest snippets from Lesson 17 earn their keep here — **`ia`** is
> the async `it` you'll want for every test in Part 1, and **`te`** gives you
> `expect().toEqual()`.

---

## Part 1 — `parseJSON`

```ts title="src/utility/fetchUtilities.ts"
export function parseJSON(response: Response) {
  return response.json();
}
```

One line, and it can still fail in a way your users would see.

1. Add `parseJSON` to the import at the top of `fetchUtilities.test.ts`, and a new `describe`
   block for it.
2. **The happy path.** Build a response with a JSON body and assert what comes out:

    ```ts title="src/utility/fetchUtilities.test.ts"
    it("parses a JSON body into an object", async () => {
      const response = new Response('{"id": 1, "name": "Fries"}');
      await expect(parseJSON(response)).resolves.toEqual({ id: 1, name: "Fries" });
    });
    ```

    **`toEqual`, not `toBe`.** `toBe` asks *"is it the same object?"* — and it never is, because
    `.json()` builds a fresh one. `toEqual` asks *"does it have the same contents?"*, which is
    what you meant. Try it with `toBe` once and read the failure; it's a message worth
    recognising later.

3. **The empty body.** A `204 No Content`, a proxy returning nothing, a crashed endpoint — the
   body is `""` and there's nothing to parse:

    ```ts
    it("rejects when the body is not valid JSON", async () => {
      await expect(parseJSON(new Response(""))).rejects.toThrow();
    });
    ```

    **Bare `toThrow()` here, on purpose.** The message comes from the JavaScript engine, not
    from your code, and it's worded differently across Node versions — asserting it would make
    the test fail on someone else's machine for no reason. This is exactly the guide's
    section 5 call: assert the message when the message *is* the behaviour, and don't when it
    isn't.

4. Add one more malformed case, and make it a realistic one: **an HTML error page.** When a
   proxy or a crashed server answers a request meant for your API, this is what comes back
   instead of JSON:

    ```ts
    it("rejects when the body is HTML rather than JSON", async () => {
      await expect(
        parseJSON(new Response("<!DOCTYPE html><h1>502 Bad Gateway</h1>"))
      ).rejects.toThrow();
    });
    ```

    If you've ever seen *"Unexpected token '<' … is not valid JSON"* in a browser console,
    that's this exact test, happening for real.

!!! note "Wait — isn't a plain string valid JSON?"

    Only in quotes, and that's a distinction worth getting straight now.

    JSON's top level can be a string, but it has to be **double-quoted**: `"Not found"` is valid
    JSON and parses to the string `Not found`. Bare `Not found` is not valid JSON at all.

    The catch is that `new Response("Not found")` doesn't send quotes. Those quotes are
    **JavaScript's**, marking where the string literal starts and ends — the bytes in the body
    are just `Not found`, so `.json()` chokes on the `N`. To send a body that really is a quoted
    JSON string you'd need the quotes *inside* the value: `new Response('"Not found"')`.

    Same reason the happy-path test above uses `'{"id": 1, "name": "Fries"}'` — single quotes
    outside so the double quotes survive into the body.

✅ **Checkpoint:** `parseJSON` has three tests, and you can say in one sentence why one of them
asserts a message and the others don't.

---

## Part 2 — `formatPhoneNumber`, the cases Lesson 17 skipped

Back to `formatUtilities.test.ts` and the function you already know has a trailing space.

```ts title="src/utility/formatUtilities.ts"
export function formatPhoneNumber(phoneNumber: string) {
  if (!phoneNumber) return;
  const first3Digits = phoneNumber.substring(0, 3);
  const middle3Digits = phoneNumber.substring(3, 6);
  const last3Digits = phoneNumber.substring(6, 10);
  return `(${first3Digits}) ${middle3Digits}-${last3Digits} `;
}
```

5. **Empty string.** Work out from the code what it returns before you run anything — that
   first line doesn't return a string:

    ```ts
    it("returns undefined for an empty string", () => {
      expect(formatPhoneNumber("")).toBeUndefined();
    });
    ```

6. **`null`.** TypeScript will stop you, and the fight is the lesson:

    ```ts
    it("returns undefined when the phone is null", () => {
      expect(formatPhoneNumber(null as any)).toBeUndefined();
    });
    ```

    You need `as any` because the parameter is typed `string` — and yet `null` is exactly what
    a staff member with no phone produces, because `IStaff` says `phone: string` while the API's
    column is nullable. **The cast isn't cheating; it's you reproducing what the network
    actually sends.** The guard on line 2 exists because someone hit this for real.

7. **Too short.** Seven digits, `"8005551"`. Predict the output from the code first, then
   assert it. It won't throw and it won't be empty — `substring` just runs off the end of the
   string and returns what's there.
8. Look at what you asserted in step 7 and answer the question the test raises: **is that a bug?**
   You now have three options and they're all defensible — leave it (garbage in, garbage out),
   return `undefined` for anything that isn't ten digits, or return the input unchanged. Write
   your answer as a comment above the test. Don't change the function; a shared formatter with
   a live caller isn't something you edit on the way past.

✅ **Checkpoint:** every branch of `formatPhoneNumber` now has a test — the ten-digit path from
Lesson 17, and the falsy guard and the short-input path from today. `npx vitest run` is green
across both files.

---

## Part 3 — Let Copilot find what you missed

9. Ask for **inputs, not assertions**:

    > Looking at `#formatUtilities.ts` and `#fetchUtilities.ts`, what edge cases should I be
    > testing that I'm not? List the inputs — don't write the tests.

10. Take its list and cross off everything you've already covered. For whatever's left, decide
    **yourself** what the correct output is, then write the test.

11. Now the check that matters: pick one test you kept and **make it fail on purpose** by
    changing the source, then change it back. A generated suggestion you've never seen red is
    unverified, no matter how sensible it reads.

✅ **Checkpoint:** at least one test in your suite came from a case you hadn't thought of, with
an expected value you chose.

---

## Stretch challenges

Optional — for when you finish early. Not required.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs some
research.

- **Ask for the whole thing, then audit it** — [Reinforce] — have Copilot write a complete
  suite for `formatUtilities.ts` in a scratch file. It'll be green immediately. Find every
  assertion that documents behaviour rather than specifying it — the trailing space is one;
  see if the short-input case is another. Delete the scratch file when you're done.
- **Quiet the console** — [Reach] — `checkStatus` logs on every failure, so your test output is
  full of noise. Research `vi.spyOn(console, "log")` and silence it for those tests. Then ask
  the better question: should a utility function be logging at all, or should its caller decide?
- **Boundaries, properly** — [Reinforce] — you tested 7 digits and 10. Add 9 and 11. One of
  them behaves in a way you probably didn't predict; `substring` doesn't mind either.
- **Test the thing that isn't tested** — [Reach] — `fetchUtilities.ts` also exports `delay`,
  which returns a function that returns a promise. Test that it resolves with the value it was
  given. You'll need to think about what `await` is doing in a test for the first time without
  a `Response` involved.
