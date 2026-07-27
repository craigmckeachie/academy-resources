# Lesson 6 Lab — Staff Card Grid: Conditional Badges, Skeletons, and a Dropdown

Apply Lesson 6's ideas to your **Staff card grid**. You already have `StaffPage`
(fetch + map) and `StaffCard` (extracted in Lesson 5); here you round out the card, add a
**3-dots menu**, and add **skeleton** loading placeholders. The guide built a *table*
(Orders); this is the same conditional-rendering + skeleton work on a *card grid*.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`) with
> Staff seed data loaded. You're extending the `StaffPage` + `StaffCard` from Lesson 5.

> **No status badge or filter here** — Staff has **role flags**, not a workflow status, so
> you use the plain `{flag && <badge>}` conditional (the `&&` shape), not the
> `getTextBackgroundByStatus` lookup, and there's no `useSearchParams` filter.

---

## Steps

Same arc as the guide's applicable parts: **round out the card → add the dropdown →
skeletons.**

1. **Round out `StaffCard`.** Alongside name and username, show **phone**
   (`formatPhoneNumber` from `formatUtilities.ts`) and **email**. Keep the conditional role
   badges — the `&&` shape, one badge per flag:
   ```tsx
   {staff.isManager && <span className="badge text-bg-primary mt-1">Manager</span>}{" "}
   {staff.isAdmin && <span className="badge text-bg-dark mt-1">Admin</span>}
   ```
2. **Add the 3-dots `Dropdown`.** Give `StaffCard` an `onRemove` prop (add
   `onRemove: (staff: IStaff) => void` to `IStaffCardProps`), add `delete(id)` to `staffAPI`,
   and add the menu — the same react-bootstrap `Dropdown` + sprite icon as the guide's
   `OrderRow` (imports: `Dropdown`, `Link`, `bootstrapIcons`, `staffAPI`):
   ```tsx
   <Dropdown className="d-inline">
     <Dropdown.Toggle className="btn btn-light" style={{ background: "none" }}>
       <svg className="bi pe-none" width={20} height={20} fill="#007AFF">
         <use xlinkHref={`${bootstrapIcons}#three-dots-vertical`} />
       </svg>
     </Dropdown.Toggle>
     <Dropdown.Menu>
       <Dropdown.Item as={Link} to={`/staff/edit/${staff.id}`}>Edit</Dropdown.Item>
       <Dropdown.Item as="a" href="#" onClick={async (event) => {
         event.preventDefault();
         if (confirm("Delete this staff member?") && staff.id) {
           await staffAPI.delete(staff.id);
           onRemove(staff);
         }
       }}>Delete</Dropdown.Item>
     </Dropdown.Menu>
   </Dropdown>
   ```
   `StaffPage` supplies `onRemove` as a `removeStaff` that filters the deleted member out of
   state (like `OrdersPage`'s `removeOrder`). **✅ Checkpoint:** the ⋮ menu opens; **Delete**
   confirms, removes the card, and **Network** shows a `DELETE`. (Edit 404s until Lesson 7.)
3. **Add skeletons.** On `StaffPage`, add a `loading` flag (set around the fetch), build a
   `StaffCardSkeleton` (a copy of the card with `skeleton skeleton-text` bars), and render
   `{loading && staffCardSkeletons}` where `staffCardSkeletons` is
   `Array.from(Array(12), (_v, i) => <StaffCardSkeleton key={i} />)`.

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
