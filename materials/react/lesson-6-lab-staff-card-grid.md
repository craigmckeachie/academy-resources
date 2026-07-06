# Lesson 6 Lab — Staff Card Grid with Conditional Rendering

Turn your fetched Staff list into a polished **card grid** — extract a `StaffCard`,
render **role badges conditionally**, and add **skeleton** loading placeholders. The
guide built a *table* (Orders) with conditional badges and skeletons; here you apply
the same conditional-rendering ideas to a *card grid*. Refer back to the guide for the
`&&` / lookup-function patterns and the skeleton setup.

---

## Steps

1. **Card grid tray** — in `StaffList`, wrap the `.map()` in
   `<section className="list d-flex flex-row flex-wrap bg-light gap-5 p-4 rounded-4">`.
2. **`StaffCard`** — the per-member card (props: `staff`, plus an `onRemove` callback
   you'll use in Lesson 12; wire the prop now, a `confirm`-based delete is fine). Show
   name, username, phone (`formatPhoneNumber`), and email.
3. **Conditional role badges** — render each badge only when its flag is true:
   ```tsx
   {staff.isManager && <span className="badge text-bg-primary mt-1">Manager</span>}{" "}
   {staff.isAdmin && <span className="badge text-bg-dark mt-1">Admin</span>}
   ```
4. **Skeletons** — add a `loading` flag (set around the fetch), build a
   `StaffCardSkeleton` (a copy of the card with `skeleton skeleton-text` bars), and
   render `{loading && staffCardSkeletons}` where `staffCardSkeletons` is
   `Array.from(Array(12), (_v, i) => <StaffCardSkeleton key={i} />)`.
5. **3-dots dropdown** — add a react-bootstrap `Dropdown` to each card with **Edit**
   (`as={Link} to={/staff/edit/${staff.id}}`) and **Delete** (confirm → API → remove).

> **No status badge here** — Staff has role flags, not a workflow status, so you use
> the plain `{flag && <badge>}` conditional rather than the `getTextBackgroundByStatus`
> lookup. Same idea, simpler condition.

---

## Verify in the browser

Browser checks are covered in the guide — section 7. With your API running and
`npm run dev` up:

1. Open `/staff` — a wrapping grid of cards, each showing only the role badges that
   apply (Manager, Admin, both, or neither).
2. Throttle to **Slow 3G** (DevTools → Network) and reload — the **skeleton cards**
   show during the fetch, then swap for real cards.
3. Open a card's **⋮** menu → **Delete** confirms and removes the card (check
   **Network** for the `DELETE`).
4. Console clean.

Same conditional-rendering + skeleton patterns, a card grid instead of a table —
exactly how you'll build the PRS **Users** card grid in the capstone (whose role label
is `Admin` / `Reviewer` / `no role assigned`).

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **Single role label** — [Reinforce] — instead of two badges, render one label:
  `Admin` if `isAdmin`, else `Manager` if `isManager`, else `no role assigned` (Admin
  wins). Write a small `getRoleLabel(staff)` helper — the lookup-function pattern from
  the guide, applied to roles. This is exactly PRS's User rule.
- **Empty-list message** — [Reinforce] — when `staff.length === 0` and not loading,
  render a "No staff yet" message with a ternary instead of an empty tray.
- **Dash for missing contact** — [Reinforce] — render `—` for a member with no phone or
  email (`{staff.email || "—"}`), matching the Orders table's empty-notes handling.
- **Avatar circle with initials** — [Reach] — add a circular avatar showing the
  member's initials to the left of the details, in a `d-flex gap-4` row. Work out the
  circle from a fixed-size flex box that centers its text with `rounded-circle`. This
  pattern is **left for you to solve** — you'll need it again on PRS's Users cards.
  Reference:
  [Bootstrap border-radius utilities (`rounded-circle`)](https://getbootstrap.com/docs/5.3/utilities/borders/).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that
span the whole React pass.
```
