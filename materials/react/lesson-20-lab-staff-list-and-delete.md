# Lesson 20 Lab — `StaffPage`, and Deleting a Card *(optional)*

Same job on your own entity, then the piece Lesson 19 had to leave out: **clicking Delete.**
That one needs both tools at once — `vi.spyOn` for the confirm dialog, MSW for the request
behind it.

> **Prerequisite:** the guide's `src/mocks/handlers.ts` and `src/mocks/server.ts`, and its
> `MenuItemsPage.test.tsx` green.

`StaffPage` is the same shape as the guide's `MenuItemsPage` — it fetches on mount, shows
`StaffCardSkeleton`s while `loading`, maps cards, and hands `StaffCard` a `removeStaff` as
`onRemove`. So every test in the guide transfers directly. One thing changes: **its URL is
`http://localhost:5556/api/staff`.**

---

## Part 1 — Render the list

1. Add the staff data to `src/mocks/handlers.ts`, alongside the menu items. Typing it out
   teaches you nothing, so paste it:

    ```diff title="src/mocks/handlers.ts"
      import { http, HttpResponse } from "msw";
      import { IMenuItem } from "../menuItems/IMenuItem";
    + import { IStaff } from "../staff/IStaff";

      // ... the menuItems array

    + export const staff: IStaff[] = [
    +   {
    +     id: 1,
    +     username: "ada.lovelace",
    +     password: "",
    +     firstName: "Ada",
    +     lastName: "Lovelace",
    +     phone: "8005551234",
    +     email: "ada@tableserve.test",
    +     isManager: true,
    +     isAdmin: false,
    +   },
    +   {
    +     id: 2,
    +     username: "grace.hopper",
    +     password: "",
    +     firstName: "Grace",
    +     lastName: "Hopper",
    +     phone: "8005559876",
    +     email: "grace@tableserve.test",
    +     isManager: false,
    +     isAdmin: false,
    +   },
    +   {
    +     id: 3,
    +     username: "alan.turing",
    +     password: "",
    +     firstName: "Alan",
    +     lastName: "Turing",
    +     phone: "8005554321",
    +     email: "alan@tableserve.test",
    +     isManager: false,
    +     isAdmin: false,
    +   },
    + ];
    ```

    **Three members, one of them a manager**, and both facts pay off later: Part 3 deletes one
    and checks the other two are still there, and three cards is what makes the ⋮ buttons
    ambiguous. `password: ""` because the API never sends a hash back to the client.

2. Now write the `http.get` handler yourself, in the `handlers` array beside the menu-items one.
   The URL is the part worth getting right — if MSW doesn't intercept, it warns you about an
   unhandled request rather than failing your assertion.
3. Create `src/staff/StaffPage.test.tsx` — `.tsx`, beside the component. It's the same skeleton
   as the guide's `MenuItemsPage.test.tsx`, so open that file next to this one. Here's where
   everything goes; you write the contents:

    ```tsx title="src/staff/StaffPage.test.tsx"
    /**
     * @vitest-environment jsdom
     */
    // imports

    // the three server lifecycle lines go HERE — module scope, outside describe

    describe("StaffPage", () => {
      // Part 1 — the happy path
      // Part 1 — the loading state
      // Part 2 — the 401 error toast
      // Part 3 — the delete flow
    });
    ```

    **The lifecycle lines sit outside `describe`, not inside it.** `beforeAll` starts one fake
    server for the whole file; nesting it in the block would still work here but stops being
    true the moment you add a second `describe`. Everything else — every `it` you write from
    here on — goes inside the one `describe`.

4. Write the happy path: render inside `<MemoryRouter>`, then `await screen.findByText(...)` a
   staff member's username. Assert the second one is on screen too.
5. Prove it's your handler driving this: change a name in `handlers.ts` and watch the test fail
   with the new value.
6. Add the loading test, the same way the guide did it: assert `.skeleton` elements are on
   screen straight after `render(...)`, then that they're gone once you've awaited a `findBy`.

✅ **Checkpoint:** `StaffPage` renders from your fake API, with no real API running.

---

## Part 2 — The error path

1. Add a test that overrides the handler with `server.use(...)` returning **401** instead of a
   500:

    ```ts
    return new HttpResponse(null, { status: 401 });
    ```

2. Render `<Toaster />` alongside the list, and assert the message that appears.

    **Work out what that message should be before you run it.** It's not the generic one — it
    comes from `translateStatusToErrorMessage`, which you tested in Lesson 18, and 401 has its
    own case.

✅ **Checkpoint:** a 401 produces a different toast from a 500, and your test asserts the right
one. That's your Lesson 18 unit test and this component test agreeing about the same function.

---

## Part 3 — Delete a card

This is the flow Lesson 19 stopped at. `StaffCard`'s Delete item calls `confirm()`, then
`staffAPI.delete(id)`, then `onRemove(staff)` — and `StaffPage` filters that staff member out
of its state, so the card disappears.

1. Add a **DELETE handler** to `handlers.ts`. The id varies, so use a path parameter:

    ```ts
    http.delete("http://localhost:5556/api/staff/:id", () => {
      return new HttpResponse(null, { status: 204 });
    }),
    ```

    204 No Content is what the API really returns for a delete — check the HTTP conventions
    table from the API pass if you want to confirm it.

2. Add a fourth `it` inside your `describe`, and stub the dialog on its first line. This is the
   shell the next three steps fill in — add `vi` to your `vitest` import, and `within` to the
   `@testing-library/react` one:

    ```tsx title="src/staff/StaffPage.test.tsx"
    it("removes a staff member when Delete is confirmed", async () => {
      const user = userEvent.setup();
      vi.spyOn(window, "confirm").mockReturnValue(true);

      // render StaffPage inside MemoryRouter — same as your other tests

      // next — wait for the list, then open one card's ⋮ and click Delete

      // then — assert that card is gone

      // and   — assert the other two are still there
    });
    ```

    jsdom *has* a `window.confirm` — that's why there's something to spy on — but it isn't
    implemented: it logs a "Not implemented" notice and returns `undefined`, which is falsy, so
    without the stub the `if (confirm(...))` is never true and the delete never runs.

3. Fill in that first comment. Wait for the list, open one card's **⋮ menu**, click **Delete**
   — and the middle part is the interesting one: there are three cards now, so three
    identical ⋮ buttons, and a bare `getByRole("button")` throws *"found multiple elements"*.
    Narrow the search to one card first:

    ```tsx
    await screen.findByText("ada.lovelace");

    const card = screen.getByText("ada.lovelace").closest("div") as HTMLElement;

    await user.click(within(card).getByRole("button"));
    await user.click(within(card).getByText("Delete"));
    ```

    **Two things here are new.** `within(element)` gives you the same `getBy…` / `queryBy…`
    queries you already know, but searching inside one element instead of the whole screen —
    import it from `@testing-library/react` beside `render` and `screen`. And `.closest("div")`
    isn't Testing Library at all, it's plain DOM: walk *up* from an element until you hit a
    matching ancestor. Starting at the username `<span>` that's the card's root `<div>`, because
    the `<address>` in between isn't a `div`.

    The cast to `HTMLElement` is there because `closest` can return `null`, and `within` won't
    take a maybe-null value.

4. Assert the card is **gone**. It won't vanish instantly — the delete is a request — so use
    `waitFor`, adding it to your `@testing-library/react` import alongside `within`:

    ```tsx
    await waitFor(() => {
      expect(screen.queryByText("ada.lovelace")).not.toBeInTheDocument();
    });
    ```

    `waitFor` retries the assertion until it passes or times out. `findBy` waits for something
    to **appear**; `waitFor` is how you wait for anything else — including something
    disappearing.

5. Assert the **other two** are still there. A delete that removed the wrong card, or every
    card, would sail through a test that only checked the first assertion.

✅ **Checkpoint:** clicking Delete removes one card and leaves the rest, driven entirely by a
fake server and a stubbed dialog.

> **That scoping was the Lesson 19 lab's first stretch coming true.** Three cards, three buttons
> with the same role and no accessible name — so the query can't tell them apart. `within(...)`
> works around it. The actual fix is to give the toggle an `aria-label="Staff actions"` in
> `StaffCard`, after which `getAllByRole("button", { name: "Staff actions" })` distinguishes
> them by something a screen reader can also hear.

---

## Stretch challenges

Optional — for when you finish early. Not required.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs some
research.

- **The empty list** — [Reinforce] — return `[]` from the handler. What does `StaffPage` render?
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
