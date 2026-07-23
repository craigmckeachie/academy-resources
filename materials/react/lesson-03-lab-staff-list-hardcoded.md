# Lesson 3 Lab — A Hardcoded Staff List

Build a **Staff** page that renders a hardcoded array of staff members — the same
component / JSX / interface / `.map()` pattern the guide used for Menu Items, on a
different entity. No API, no fetch — local data only, verified in the browser. Refer
back to the guide for the JSX rules and the `.map()` + `key` pattern.

---

## The Staff record

Each staff member has: `id`, `firstName`, `lastName`, `username`, and two role flags —
`isManager` and `isAdmin`. (Phone and email exist too, but skip them for this
fundamentals exercise.)

---

## Steps

1. Create the `src/staff/` feature folder.
2. In `src/staff/IStaff.ts`, define an `IStaff` **interface**:
   - `id: number | undefined`
   - `firstName: string`, `lastName: string`, `username: string`
   - `isManager: boolean`, `isAdmin: boolean`
3. In `src/staff/StaffPage.tsx`, declare this hardcoded `IStaff[]` array above the
   component — the roles are already mixed (a manager, an admin, one of both, one of
   neither):
   ```ts
   const staff: IStaff[] = [
     { id: 1, firstName: "Sam", lastName: "Diaz", username: "sdiaz", isManager: true, isAdmin: false },
     { id: 2, firstName: "Ana", lastName: "Cruz", username: "acruz", isManager: false, isAdmin: true },
     { id: 3, firstName: "Leo", lastName: "Park", username: "lpark", isManager: true, isAdmin: true },
     { id: 4, firstName: "Mia", lastName: "Nguyen", username: "mnguyen", isManager: false, isAdmin: false },
     { id: 5, firstName: "Owen", lastName: "Bell", username: "obell", isManager: true, isAdmin: false },
   ];
   ```
4. Write a `StaffPage` **component** that returns a heading and a `.list d-flex
   flex-row flex-wrap gap-5 p-4` tray, `.map()`-ing the array into one card per member.
   Each card shows:
   - First + last name (`fs-4 fw-medium`)
   - Username (`text-secondary`)
   - A role **badge** *only when the flag is true* — embed a JS expression:
     `{staffMember.isManager && <span className="badge text-bg-primary">Manager</span>}`
     and the same for `isAdmin` (`text-bg-dark`).
   - Give each card a **`key={staffMember.id}`**.
5. In `App.tsx`, render `<StaffPage />` (swap it in for `<MenuItemsPage />`, or render
   both).

> **`{flag && <span>…</span>}` is a first taste of conditional rendering** — when
> `flag` is false, nothing renders. Lesson 6 makes this pattern a first-class concept.

---

## Verify in the browser

Browser checks are covered in the guide — section 9. With `npm run dev` running:

1. Open the app — a wrapping grid of staff cards, one per array element, each showing
   name, username, and only the role badges that apply.
2. Open the **Console** (F12) — it should be clean. A "unique key" warning means a
   card is missing its `key={...}`.
3. Add another staff object to the array and save — a new card appears with no extra
   JSX.
4. Flip a member's `isAdmin` to `true` and save — the Admin badge appears. That's the
   `{flag && ...}` expression reacting to the data.

Same component / JSX / interface / `.map()` pattern, a different entity — exactly how
you'll start the PRS **Users** page in the capstone.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **Full name helper** — [Reinforce] — instead of `{staffMember.firstName}
  {staffMember.lastName}`, compute a `fullName` inside the `.map()` callback
  (`const fullName = \`${staffMember.firstName} ${staffMember.lastName}\`;`) and render
  `{fullName}`. Practice that `{ }` holds any JS expression, and the callback body can
  do work before the `return`.
- **Role label instead of badges** — [Reinforce] — add a line that shows a single role
  string: `Admin` if `isAdmin`, else `Manager` if `isManager`, else `no role assigned`
  (Admin wins when both are true). Use a ternary or an `if` in the callback. This is the
  exact rule PRS's User card uses.
- **Extract a `StaffCard` component** — [Reach] — move the per-card JSX into its own
  `StaffCard` function that takes the staff member as a **prop**
  (`function StaffCard({ staffMember }: { staffMember: IStaff }) { ... }`) and render
  `<StaffCard key={s.id} staffMember={s} />` from the `.map()`. Props are covered
  properly in Lesson 5 — peek ahead. Reference:
  [Passing props to a component (react.dev)](https://react.dev/learn/passing-props-to-a-component).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that
span the whole React pass.
```
