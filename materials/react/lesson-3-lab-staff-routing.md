# Lesson 3 Lab — Route and Navigate to the Staff Page

Wire your **Staff** page into the app shell: give it a route, a nav link, and split it
into a `StaffList` + `StaffCard` using **props** — the same routing and
component-splitting the guide did for Menu Items. Refer back to the guide for the route
tree, `Link`, `Outlet`, and props.

---

## Steps

1. In `main.tsx`, add a `{ path: "staff", element: <StaffPage /> }` route **under
   `Layout`'s `children`** (so it gets the shell), and import `StaffPage`.
2. In `AppNav.tsx`, add a `Nav.Link as={Link} to="/staff"` item labeled **Staff**
   (reuse the `people` icon if you're carrying the sprite over).
3. Split your Staff list into two components:
   - `StaffList` — holds the state, fetches in `useEffect`, and `.map()`s.
   - `StaffCard` — takes a single `staff` **prop** (type an `IStaffCardProps`
     interface) and renders one card.
4. In the `.map()`, render `<StaffCard key={staffMember.id} staff={staffMember} />`.
5. Make `StaffPage` the route target: a heading + an **Add Staff** `<Link
   to="/staff/create">` button + `<StaffList />` (the create page comes in Lesson 5 —
   the link can 404 until then).

---

## Verify in the browser

Browser checks are covered in the guide — section 7. With `npm run dev` running:

1. Click the **Staff** nav link — the URL becomes `/staff` and the staff cards render
   inside the shell, **no full reload**.
2. Click between **Staff**, **Menu**, and **Orders** — the `Header`/`AppNav` stay put;
   only the page swaps. The active nav pill follows the URL.
3. Use **Back** — it returns to the previous page.
4. Check the **Console** — clean. A blank page usually means a missing import or a
   `path` typo.

Same routing + props + component-split pattern, a different entity — exactly how you'll
route the PRS **Users** page in the capstone.

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
```
