# React Stretch Challenges

Optional, off-the-critical-path work for when you finish a lab early. **None of this is
required for the PRS capstone** — it's here to keep you sharp and let you push past what
the guides cover.

Each lab also has its own short **Stretch challenges** section tied to that lesson's
concept. The challenges below are the bigger, cross-cutting ones that span the whole
React pass — reach for them once you're comfortably ahead.

## How the challenges are labeled

- **[Reinforce]** — extends something a guide already showed you. No new concept; you
  have everything you need.
- **[Reach]** — goes past the guides. You'll need to do some research on your own; a
  reference link is provided as a starting point. Expect to read and experiment.

Everything you build here is verified the same way the labs are — in the **browser**,
with your API running and `npm run dev` up (DevTools Console/Network). There's no new
verification tool.

> **Respect the intentional simplifications.** This app has **no JWT/token auth**, no
> DTOs, no repository pattern, and wide-open CORS — all deliberate. No stretch challenge
> should add `[Authorize]`, tokens, or a tighter CORS policy. Auth stays exactly as
> Lesson 9 built it: a Staff object in localStorage + Context, null-check for signed-in.

---

## 1. Model your own restaurant — [Reinforce]

The app renders seeded TableServe data. Reseed the **database** with your own favorite
restaurant's menu, categories, staff, and orders so the whole React app reflects a real
place you know — then confirm the front end shows it with **no code changes**.

1. Write (or AI-generate) SQL inserts for your restaurant's categories, menu items, and
   staff, matching the existing column shapes. Give your AI assistant the seed script
   from the API pass as the reference so the structure matches exactly.
2. Re-run the seed and reload the React app — the fetched cards, tables, and dropdowns
   all reflect the new data automatically.
3. Confirm FK relationships still line up: every menu item's Category badge is a real
   category, and order totals equal the sum of their items.

The lesson: because the UI is **data-driven** (fetch + `.map()`), changing the data
changes the whole app without touching a component. (This mirrors the AI-assisted
seed-data challenge from the API pass.)

---

## 2. A brand-new entity, end to end — [Reinforce]

Add a feature the app doesn't have — **Tables** (the physical dining tables) — building
the entire feature folder from patterns you already know, with **no new concepts**.

1. Add a `Tables` entity to the API (model + controller + migration) — a `TableNumber`
   and `Seats`. Remember to `Add-Migration` and `Update-Database`, and give the new
   non-nullable column a sensible default if the table already has rows.
2. Build the React feature folder: `ITable.ts`, `TableAPI.ts`, `TablesPage`,
   `TableList` + `TableCard` (+ skeleton), and a shared `TableForm` (no FK).
3. Register the routes under `Layout` and add a **Tables** nav link.
4. Toasts on every CRUD action, via `checkStatus` + `toast`.

If you can stand this up without re-reading the guides, you've internalized the
feature-folder pipeline you'll run five times on PRS.

---

## 3. A reusable `useFetch` custom hook — [Reach]

Every list page repeats the same shape: a `data` state, a `loading` flag, a
`useEffect` that fetches. Extract it into a **custom hook** — your own `use…` function
that packages state + effect — and use it in two list pages.

```tsx
function useFetch<T>(fetcher: () => Promise<T>, initial: T) {
  const [data, setData] = useState<T>(initial);
  const [loading, setLoading] = useState(false);
  useEffect(() => {
    (async () => {
      setLoading(true);
      try { setData(await fetcher()); }
      catch (e: any) { toast.error(e.message); }
      finally { setLoading(false); }
    })();
  }, []);
  return { data, loading };
}
```

Use it: `const { data: menuItems, loading } = useFetch(menuItemAPI.list, []);`. Custom
hooks are just functions that call other hooks — the same rules apply (top-level,
`use` prefix). Not covered in the guides — research custom hooks:
[Reusing logic with custom Hooks (react.dev)](https://react.dev/learn/reusing-logic-with-custom-hooks).

---

## 4. A dark-mode toggle in Context — [Reach]

You built one Context (the signed-in Staff). Add a **second** — a theme Context — and a
header toggle that flips Bootstrap 5.3's `data-bs-theme="dark"` on the `<html>` element.

1. Create a `ThemeContext` holding `theme` + `setTheme` (model it on `StaffContext`).
2. Provide it in `App`, seeding from localStorage so the choice persists (like the Staff
   object does).
3. A header button flips the theme; an effect writes `document.documentElement.setAttribute("data-bs-theme", theme)`.
4. Check your custom `App.css` overrides (the orange brand, the sign-in gradient) still
   look right in dark mode.

This reuses the exact Context + localStorage pattern from Lesson 9 for a different piece
of shared state. Not covered in the guides — research color modes:
[Bootstrap color modes](https://getbootstrap.com/docs/5.3/customize/color-modes/).

---

## 5. Client-side search on a list — [Reinforce]

Add a **search box** above a card grid (Menu Items or Staff) that filters the already-
fetched list as you type — no new request.

1. Add a `const [search, setSearch] = useState("")` and a controlled `<input>`.
2. Before `.map()`, filter: `menuItems.filter(m => m.name.toLowerCase().includes(search.toLowerCase()))`.
3. Confirm typing narrows the grid live and clearing restores it.

This is `useState` + conditional data + `.map()` — all Lesson 1–4 tools — combined.
(Contrast it with the Orders **status filter**, which lives in the URL via
`useSearchParams` and re-fetches; this one filters in memory.)

---

## 6. A reusable ConfirmModal component — [Reach]

Lesson 7 built a delete-confirm modal inline on the Order Detail page. Extract a generic
**`ConfirmModal`** component (props: `show`, `title`, `message`, `onConfirm`,
`onCancel`) and reuse it for the delete confirmations on your **card/row dropdowns**
(replacing the `window.confirm` calls).

1. Build `ConfirmModal` wrapping react-bootstrap's `Modal`, driven entirely by props.
2. In a list component, hold `itemToDelete` state and render
   `<ConfirmModal show={!!itemToDelete} … onConfirm={reallyDelete} />`.
3. Confirm it opens per item, deletes on confirm, and closes on cancel — with a nicer UX
   than the browser `confirm` dialog.

This is props + `show={!!state}` from Lesson 7, generalized. Not covered as a reusable
component in the guides — research composing components with props:
[Passing props to a component (react.dev)](https://react.dev/learn/passing-props-to-a-component).

---

## 7. Consolidate formatting utilities — [Reinforce]

Currency formatting (`new Intl.NumberFormat("en-US", { style: "currency", currency:
"USD" }).format(...)`) is repeated in the OrderHeader, the items table, and the
OrderItem form. Pull it into a single `formatCurrency(amount)` helper in
`utility/formatUtilities.ts` (alongside `formatPhoneNumber` and
`getTextBackgroundByStatus`) and use it everywhere.

1. Add `export function formatCurrency(amount: number) { return new Intl.NumberFormat(…).format(amount); }`.
2. Replace each inline `Intl.NumberFormat` call with `formatCurrency(...)`.
3. Confirm every currency display still renders identically.

One source of truth for money formatting — the same instinct as the single
status-badge-color function. Reference:
[Intl.NumberFormat (MDN)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat).

---

You'll reuse every one of these instincts on the PRS capstone: reseeding to your own
data, standing up a new entity's full feature folder, extracting shared hooks and
components, and consolidating utilities are exactly the moves you'll reach for once the
core PRS pages are in place.
```
