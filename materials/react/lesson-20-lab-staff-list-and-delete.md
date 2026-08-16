# Lesson 20 Lab — `StaffList`, and Deleting a Card *(optional)*

Same job on your own entity, then the piece Lesson 19 had to leave out: **clicking Delete.**
That one needs both tools at once — `vi.spyOn` for the confirm dialog, MSW for the request
behind it.

> **Prerequisite:** the guide's `src/mocks/handlers.ts` and `src/mocks/server.ts`, and its
> `MenuItemList.test.tsx` green.

Two things about `StaffList` differ from the guide's target, and both matter:

- `staffAPI.list()` has **no `delay`** — the data comes back fast. You still need `findBy`, but
  there's no loading state to assert.
- Its URL is `http://localhost:5556/api/staff`.

---

## Part 1 — Render the list

1. Add a `staff` array and a `http.get` handler for the staff endpoint to
   `src/mocks/handlers.ts`, alongside the menu-item one. Two or three staff members is plenty —
   give one of them `isManager: true` so you have something distinguishing to assert.
2. Create `src/staff/StaffList.test.tsx` — `.tsx`, `@vitest-environment jsdom` docblock, and
   the same three lifecycle lines from the guide.
3. Write the happy path: render inside `<MemoryRouter>`, then `await screen.findByText(...)` a
   staff member's username. Assert the second one is on screen too.
4. Prove it's your handler driving this: change a name in `handlers.ts` and watch the test fail
   with the new value.

✅ **Checkpoint:** `StaffList` renders from your fake API, with no real API running.

---

## Part 2 — The error path

5. Add a test that overrides the handler with `server.use(...)` returning **401** instead of a
   500:

    ```ts
    return new HttpResponse(null, { status: 401 });
    ```

6. Render `<Toaster />` alongside the list, and assert the message that appears.

    **Work out what that message should be before you run it.** It's not the generic one — it
    comes from `translateStatusToErrorMessage`, which you tested in Lesson 18, and 401 has its
    own case.

✅ **Checkpoint:** a 401 produces a different toast from a 500, and your test asserts the right
one. That's your Lesson 18 unit test and this component test agreeing about the same function.

---

## Part 3 — Delete a card

This is the flow Lesson 19 stopped at. `StaffCard`'s Delete item calls `confirm()`, then
`staffAPI.delete(id)`, then `onRemove(staff)` — and `StaffList` filters that staff member out
of its state, so the card disappears.

7. Add a **DELETE handler** to `handlers.ts`. The id varies, so use a path parameter:

    ```ts
    http.delete("http://localhost:5556/api/staff/:id", () => {
      return new HttpResponse(null, { status: 204 });
    }),
    ```

    204 No Content is what the API really returns for a delete — check the HTTP conventions
    table from the API pass if you want to confirm it.

8. In the test, stub the dialog so the code proceeds past it — adding `vi` to your `vitest`
   import:

    ```ts
    import { vi } from "vitest";

    vi.spyOn(window, "confirm").mockReturnValue(true);
    ```

    Without this, jsdom has no `confirm` to call and the click goes nowhere.
9. Now drive it as a user would — this is three steps, not one:

    - `await` a `findBy` for the staff member you're about to delete, so the list has loaded
    - open that card's **⋮ menu** (`getByRole`, and remember there's more than one card on
      screen now — you'll need to scope it)
    - click **Delete**

10. Assert the card is **gone**. It won't vanish instantly — the delete is a request, so use
    `waitFor`:

    ```tsx
    import { waitFor } from "@testing-library/react";

    await waitFor(() => {
      expect(screen.queryByText("ada.lovelace")).not.toBeInTheDocument();
    });
    ```

    `waitFor` retries the assertion until it passes or times out. `findBy` waits for something
    to **appear**; `waitFor` is how you wait for anything else — including something
    disappearing.

11. Assert the **other** staff member is still there. A delete that removes the wrong row, or
    every row, would pass a test that only checked the first assertion.

✅ **Checkpoint:** clicking Delete removes one card and leaves the rest, driven entirely by a
fake server and a stubbed dialog.

> **Why scoping the ⋮ button matters here:** with three cards rendered there are three buttons
> with the same role and no accessible name. `getByRole("button")` now throws *"found multiple
> elements"* — the exact failure the Lesson 19 lab's first stretch predicted. Use
> `within(...)` around the card you want, or give the toggle an `aria-label` and query it by
> name.

---

## Stretch challenges

Optional — for when you finish early. Not required.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs some
research.

- **The empty list** — [Reinforce] — return `[]` from the handler. What does `StaffList` render?
  Probably nothing at all — no rows, no message. Write the test that describes the current
  behaviour, then decide whether an empty state would be better and say why in a comment.
- **A delete that fails** — [Reinforce] — override the DELETE handler to return 500. The card
  should stay, and an error toast should appear. This is the case that's nearly impossible to
  produce by hand and takes four lines here.
- **When the user says no** — [Reinforce] — `mockReturnValue(false)` on the confirm stub. Assert
  the card is still there *and* that no DELETE went out. Research MSW's
  `server.events.on("request:start", …)` if you want to prove the second half properly.
- **Reuse the handlers in the browser** — [Reach] — MSW's `setupWorker` runs the same
  `handlers.ts` in a real browser, so you can develop the front end with the API stopped. Get
  `npm run dev` working against your fake data. That's the payoff most teams actually adopt MSW
  for.
