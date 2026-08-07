# Lesson 19 Lab — Testing `StaffCard` *(optional)*

Same job as the guide, on your own entity. `StaffCard` renders more than `MenuItemCard` does —
an avatar, four fields, and **two badges that only appear for some staff** — so this one has
real conditional rendering to pin down.

> **Prerequisite:** the guide's setup — `jsdom`, the three `@testing-library` packages,
> `vitest.setup.ts`, and the `setupFiles` line in `vite.config.ts`.

Here's what it puts on screen:

```tsx title="src/staff/StaffCard.tsx"
{staff.firstName.substring(0, 1)}{staff.lastName.substring(0, 1)}   {/* avatar initials */}
<strong>{staff.firstName} {staff.lastName}<Dropdown …/></strong>
<span className="text-secondary">{staff.username}</span>
<span className="text-secondary">{formatPhoneNumber(staff.phone)}</span>
<span className="text-secondary">{staff.email}</span>
{staff.isManager && <span className="badge text-bg-primary mt-1">Manager</span>}
{staff.isAdmin && <span className="badge text-bg-dark mt-1">Admin</span>}
```

---

## Part 1 — Render it

1. Create `src/staff/StaffCard.test.tsx` — **`.tsx`**, with the `@vitest-environment jsdom`
   docblock at the top. Copy the shape from the guide's file.
2. You need three different staff members in this lab, so build a **factory** rather than three
   near-identical objects:

    ```tsx title="src/staff/StaffCard.test.tsx"
    function makeStaff(overrides: Partial<IStaff> = {}): IStaff {
      return {
        id: 1,
        username: "ada.lovelace",
        password: "",
        firstName: "Ada",
        lastName: "Lovelace",
        phone: "8005551234",
        email: "ada@tableserve.test",
        isManager: false,
        isAdmin: false,
        ...overrides,
      };
    }
    ```

    `Partial<IStaff>` means *"any subset of those properties"*, and the spread lets each test
    override only what it cares about. A test that says `makeStaff({ isAdmin: true })` tells the
    reader exactly what this case is about — everything else is scenery.

3. Write the first test: render inside `<MemoryRouter>` (`StaffCard` has a `Link` too), with a
   no-op `onRemove`, and assert the **username**, the **email**, and the **avatar initials**
   (`"AL"`) are on screen.

✅ **Checkpoint:** one test green, and Lessons 17–18 still green alongside it.

---

## Part 2 — An old friend returns

4. Assert the phone number. Write it the way it looks on screen:

    ```tsx
    expect(screen.getByText("(800) 555-1234")).toBeInTheDocument();
    ```

5. Run it.

✅ **Checkpoint:** it **passes** — with no trailing space in your assertion.

!!! note "Why this passes here and failed in Lesson 17"

    `formatPhoneNumber` still returns `"(800) 555-1234 "`. Nothing changed. But Testing
    Library's queries **normalize whitespace** before matching — they trim the ends and collapse
    runs of spaces — because that's what the browser does when it renders text, and the whole
    point of these queries is to find text *the way a user sees it*.

    So the same trailing space that made your unit test go red in Lesson 17 is invisible here,
    for exactly the same reason it's invisible in the browser. Two kinds of test, two honest
    answers:

    - The **unit test** asserts what the function returns — the space is really there.
    - The **component test** asserts what the user reads — the space really isn't visible.

    Neither is wrong, and this is a good instinct to leave the course with: **when two tests
    disagree, check whether they're asking different questions** before you assume one is
    broken.

---

## Part 3 — Conditional rendering

The badges are the interesting part of this component: three different staff members produce
three different screens.

6. **A manager** — `makeStaff({ isManager: true })`. Assert `"Manager"` is present, and that
   `"Admin"` is **not**. Remember which query family asserts absence.
7. **An admin** — `makeStaff({ isAdmin: true })`. The mirror image.
8. **Neither** — plain `makeStaff()`. Assert both badges are absent.
9. Now break the component on purpose: change `{staff.isManager && …}` to `{staff.isAdmin && …}`
   so both badges key off the same flag. Which of your three tests go red? Put it back.

✅ **Checkpoint:** three tests covering three states, and you've watched them catch a real
mix-up.

> **Step 9 is the argument for writing all three.** A single test with a manager would have
> stayed green through that change. It's the *absence* assertions that caught it — the same
> reason Lesson 17's `default` case mattered.

---

## Part 4 — The interaction

10. Add the dropdown test, as in the guide: assert `"Edit"` is absent, `await user.click` the
    toggle found with `getByRole("button")`, then assert `"Edit"` and `"Delete"` are present.
11. Run the whole suite once, cleanly:

    ```bash
    npx vitest run
    ```

✅ **Checkpoint:** `StaffCard` has six tests — content, phone, three badge states, and the
menu — and every file from Lessons 17–19 is green in one run.

> **Not tested, on purpose:** clicking **Delete**. It calls `confirm()` and then hits the API,
> which needs mocking — out of scope, and the guide's section 6 says why.

---

## Stretch challenges

Optional — for when you finish early. Not required.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs some
research.

- **Ask for the accessible name** — [Reinforce] — the ⋮ toggle is `getByRole("button")` with no
  name, which works only because there's exactly one button on this card. Put two `StaffCard`s
  on screen in one test and watch that query fail with *"found multiple elements."* Then fix it
  the right way: give the toggle an `aria-label` in the component, and query
  `getByRole("button", { name: "Staff actions" })`. **A component that's hard to query is often
  a component that's hard for a screen reader**, and you just improved both.
- **The missing state** — [Reinforce] — a staff member who is neither manager nor admin gets no
  badge at all. PRS's user cards say *"no role assigned"* instead. Which reads better to
  somebody scanning a list of forty people? Write the test you'd want first, then decide.
- **Test the card that has a skeleton** — [Reinforce] — `MenuItemCardSkeleton` takes no props
  and renders placeholder markup. What's even worth asserting about it? Work out the answer
  before you write anything; *"nothing useful"* is a legitimate conclusion and knowing why is
  the point.
- **Past the boundary** — [Reach] — `MenuItemList` fetches its data, so testing it means faking
  `fetch`. Research `vi.mock` or **MSW**, and get one test passing that renders the list with a
  fake response. You're outside the course here — notice how much more setup it takes, and how
  much more there is to get subtly wrong.
