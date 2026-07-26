# Lesson 5 Lab — Route and Navigate to the Staff Page

Wire your **Staff** page into the shell you just built: give it a **route** and a **nav
link**, then **extract a `StaffCard`** using **props** — the same routing + prop-splitting
the guide did for Menu Items. Refer back to the guide for the route tree, `Link`, and props.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`) with
> CORS enabled and Staff seed data loaded. You're extending the `StaffPage` you built in
> Lesson 4 (fetch + map) and the shell (`Layout`, `AppNav`) from this lesson's guide.

---

## Steps

Same arc as the guide: **route + nav link → extract a Card with props.** Your `StaffPage`
already fetches and maps (Lesson 4); here it gains a route and a `StaffCard`.

1. **Add the route.** In `main.tsx`, add `{ path: "staff", element: <StaffPage /> }` **under
   `Layout`'s `children`** (so it gets the shell), and import `StaffPage`.
2. **Add the nav link.** In the provided `AppNav`, add a Staff `Nav.Item` — copy the icon
   pattern from the Orders/Menu items, using the `#people` icon (`bootstrapIcons` is already
   imported):
   ```tsx
   <Nav.Item as="li">
     <Nav.Link eventKey="/staff" as={Link} to="/staff">
       <svg className="bi pe-none me-2" width={16} height={16} fill="currentColor">
         <use xlinkHref={`${bootstrapIcons}#people`} />
       </svg>
       Staff
     </Nav.Link>
   </Nav.Item>
   ```
   **✅ Checkpoint:** click **Staff** — your staff cards render inside the shell, no full
   reload.
3. **Extract a `StaffCard` (props).** Pull the per-member card out of `StaffPage` into a
   `StaffCard` that takes a single `staff` **prop**, typed with an interface:
   ```tsx
   interface IStaffCardProps {
     staff: IStaff;
   }
   function StaffCard({ staff }: IStaffCardProps) { /* one card: name, username, role badges */ }
   ```
   `StaffPage` still fetches and maps; render `<StaffCard key={staffMember.id}
   staff={staffMember} />` inside the `.map()`. The page should look **exactly the same** —
   you've just moved one card's markup into a reusable component.

> **Add Staff button:** give `StaffPage`'s heading an **Add Staff** `<Link
> to="/staff/create">` button. The create page comes in Lesson 7, so the link 404s until
> then — that's fine.

---

## Verify in the browser

Browser checks are covered in the guide — section 7. With `npm run dev` running:

1. Click the **Staff** nav link — the URL becomes `/staff` and the staff cards render inside
   the shell, **no full reload**.
2. Click between **Staff**, **Menu**, and **Orders** — the `Header`/`AppNav` stay put; only
   the page swaps, and the active nav pill follows the URL.
3. Use **Back** — it returns to the previous page.
4. Open **DevTools → Console** — clean. A blank page usually means a missing import or a
   `path` typo.

Same routing + props + component-split pattern, a different entity — exactly how you'll route
the PRS **Users** page in the capstone.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **Active-link styling** — [Reinforce] — confirm the current page's nav pill is
  highlighted, and click around to watch it follow the URL. The guide's `AppNav` uses
  `useLocation()` + `defaultActiveKey` — trace how the active pill is chosen.
- **A pass-through prop** — [Reinforce] — add a `variant` prop to `StaffCard`
  (e.g. `"compact"`) and use it to toggle a class. Practice defining, typing, passing,
  and reading a second prop.
- **Spread the props** — [Reinforce] — build a `props` object and render
  `<StaffCard key={s.id} {...props} />` using the **spread operator** from the guide;
  confirm it behaves identically to passing each prop by hand.
- **A 404 route** — [Reach] — add a catch-all route (`path: "*"`) that renders a
  friendly "Page not found" component, so unknown URLs show your page instead of the
  generic error. Reference:
  [Route (react-router v6)](https://reactrouter.com/6.30.0/route/route).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that
span the whole React pass.
