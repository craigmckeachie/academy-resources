# Lesson 4 Lab — Fetch the Staff List

Turn the hardcoded Staff list from Lesson 3 into one that **fetches real data** from your
Web API — the same `useState` + `useEffect` + `fetch` pattern the guide used for Menu
Items, on the Staff entity. Refer back to the guide for the hook rules and the API-module
shape.

> **Prerequisite:** your API is running **on the HTTP profile** (pick `http`, not `https`,
> in the run-button dropdown — the course skips dev certificates) with **CORS enabled** (you
> turned it on in the guide) and **Staff seed data** loaded. All seed passwords are
> `test1234`. You're editing the `StaffPage` from Lesson 3.

---

## Steps

Same arc as the guide: **the API module → swap your hardcoded array for a fetch.**

1. **The API module.** Create `src/staff/StaffAPI.ts` exporting a `staffAPI` object with a
   `list()` that `fetch`es `/api/staff` and returns the parsed JSON as `Promise<IStaff[]>`
   (mirror the guide's `MenuItemAPI`).
2. **Swap the hardcoded array for state.** In `StaffPage`, **delete the hardcoded `staff`
   array** and add:
   - `const [staff, setStaff] = useState<IStaff[]>([])`
   - an `async loadStaff()` that `await`s `staffAPI.list()` and calls `setStaff(data)`,
     wrapped in `try/catch`
   - `useEffect(() => { loadStaff(); }, [])`
3. **Render the fetched list.** `staff.map(...)` into the same cards from Lesson 3 — name,
   username, and the conditional role badges — each with `key={staffMember.id}`. The card
   markup doesn't change; only the *source* of `staff` does.

> Add the full `IStaff` fields now if you didn't in Lesson 3 (`password`, `phone`,
> `email`) so the interface matches the API response — you still only *display* name,
> username, and role.

---

## Verify in the browser

Browser checks are covered in the guide — section 7. With your API running and
`npm run dev` up:

1. Open the app — the **real** seeded staff load as cards.
2. Open **DevTools → Network**, filter Fetch/XHR, reload — the `staff` request returns
   **200** with a JSON array; click **Response** to see it.
3. If nothing loads, open **DevTools → Console** and check for a CORS error or a failed
   request (API down, running on the `https` profile, or wrong port).
4. Change a staff member's name in the database and reload — the card updates.

Same state + effect + fetch pattern, a different entity — exactly how you'll load the
PRS **Users** list in the capstone.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **A loading flag** — [Reinforce] — add a `const [loading, setLoading] = useState(false)`,
  set it around the fetch (`true` before, `false` in a `finally`), and render
  `{loading && <p>Loading…</p>}`. This is the seed of the skeleton pattern in Lesson 6.
- **Count in the heading** — [Reinforce] — show the number of staff next to the
  heading: `Staff ({staff.length})`. Confirm it starts at 0 and updates once the fetch
  resolves — a concrete look at state driving the UI.
- **Sort before rendering** — [Reinforce] — sort the fetched data by last name before
  `setStaff` (`data.sort((a, b) => a.lastName.localeCompare(b.lastName))`). The list
  renders in the order of the array — you control it in JS, not the markup.
- **Log the effect** — [Reach] — add a `console.log("effect ran")` inside the
  `useEffect` and a `console.log("rendered")` in the component body, then reload and
  read the order in the Console. Notice the effect runs *after* the first render, and
  (in development `StrictMode`) mounts run the effect twice on purpose. Reference:
  [Synchronizing with Effects (react.dev)](https://react.dev/learn/synchronizing-with-effects).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that
span the whole React pass.
