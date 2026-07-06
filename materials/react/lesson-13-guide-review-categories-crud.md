# Lesson 13 Guide — Review / Buffer: The Categories CRUD Walkthrough

**This is a review / buffer lesson — there is no lab.** Its job is catch-up time and a
guided read of the **Categories** feature, which is **provided as finished starter
code** (not built live). Categories is the simplest full CRUD in the app — a card grid,
a skeleton, a no-FK shared form — so reading it end to end is the cleanest way to see
every pattern from Lessons 3–12 working together on one entity.

**Goal:** be able to open the `categories/` folder and explain each file's role, tracing
how the pieces you learned separately combine into a complete feature. If you fell
behind on any lesson, this is the lesson to catch up.

> **Why provided, not built?** Categories mirrors Menu Items (a card grid + shared
> form) with *no new concept*. Handing it over finished frees class time and gives you a
> correct reference to compare your own Menu Items / Staff code against. On PRS,
> **Vendors** is the equivalent simple entity — you'll build it yourself using this as
> the model.

---

## 1. The feature folder, file by file

Categories follows the standard feature-folder pattern (every entity uses it):

| File | Role | Lesson it draws on |
|---|---|---|
| `ICategory.ts` | The TypeScript interface (`id`, `name`, `sortOrder`) | 1 |
| `CategoryAPI.ts` | `list` / `find` / `post` / `put` / `delete`, via `checkStatus`/`parseJSON` | 2, 10 |
| `CategoriesPage.tsx` | Route target — heading, **Add Category** link, renders the list | 3 |
| `CategoryList.tsx` | Fetches in `useEffect`, holds state, `.map()`s cards, skeletons | 2, 4 |
| `CategoryCard.tsx` | One card (props `category`, `onRemove`), 3-dots dropdown | 3, 4 |
| `CategoryCardSkeleton.tsx` | Grey placeholder card shown while loading | 4 |
| `CategoryForm.tsx` | Shared create/edit form (no FK), react-hook-form | 5 |
| `CategoryCreatePage.tsx` / `CategoryEditPage.tsx` | Thin wrappers around the form | 5 |

Read them in that order — interface → API → page → list → card → form. Each file should
now look familiar: it's the pattern from its lesson, on Categories.

---

## 2. What to notice while reading

- **`CategoryList`** is Lesson 4 + 6: `useState<ICategory[]>([])`, a `loading` flag, a
  `loadCategories` in `useEffect(…, [])`, skeletons via `{loading && …}`, and a
  `removeCategory` that filters state after a delete.
- **`CategoryCard`** is Lesson 5 + 6: a `category` **prop**, a react-bootstrap
  `Dropdown` with **Edit** (`as={Link}`) and **Delete** (confirm → `categoryAPI.delete`
  → `onRemove` → success toast).
- **`CategoryForm`** is Lesson 7 minus the FK dropdown: `useForm<ICategory>`,
  `defaultValues` returning `emptyCategory` (create) or `categoryAPI.find(id)` (edit),
  `register` on Name (required) and Sort Order (`valueAsNumber`), and a `save` that
  POSTs when `!id` else PUTs, then `navigate("/categories")`.
- **The pages** are Lesson 7's thin wrappers — a title and `<CategoryForm />`.

If any of these reads as unfamiliar, that's the lesson to revisit before the capstone.

---

## 3. Wiring it in

Categories only needs its routes registered under `Layout` and a nav link — both like
every other entity:

```tsx
{ path: "categories", element: <CategoriesPage /> },
{ path: "categories/create", element: <CategoryCreatePage /> },
{ path: "categories/edit/:id", element: <CategoryEditPage /> },
```

Plus the **Categories** `Nav.Link` in `AppNav` (already there from Lesson 5).

---

## 4. Verifying in the browser

With your API running and `npm run dev` up:

1. Open `/categories` — the card grid renders (skeletons first on a slow network), each
   card showing name + sort order with a **⋮** menu.
2. **Add Category** → empty form; Save → back to the list with the new card. **Edit** →
   pre-filled form; Save → updated. **Delete** → confirm → card removed, success toast.
3. Compare this behavior side by side with your **Menu Items** and **Staff** pages —
   they should feel identical because they're the same patterns.
4. Console clean.

---

## Catch-up checklist

Use the buffer to close any gaps. You should have, working in the browser:

- [ ] Menu Items — list (fetch), card grid, shared form with Category FK dropdown
- [ ] Staff — list (fetch), card grid with conditional role badges + skeletons, shared
      form with checkboxes
- [ ] Orders — table with status badges, `useSearchParams` filter, 3-dots menu
- [ ] Order Detail — definition-list summary, status-driven workflow buttons, Cancel
      modal, delete-confirm modal
- [ ] Order Item — nested form with derived Price/Amount and parent-total recalculation
- [ ] Sign In + Context — localStorage persistence, role UI, Cancel ownership check
- [ ] Toasts + `checkStatus` across CRUD

Anything unchecked, fix it now — the capstone assumes all of it.

---

## The General Pattern (what to take away)

- Every entity is the **same feature folder**: interface, API module, page, list, card
  (or row), skeleton, shared form, thin create/edit wrappers.
- A new entity introduces **no new concept** — it's the Lessons 3–12 patterns applied
  again. Reading Categories proves it.
- The provided Categories code is your **reference implementation** to compare your own
  code against — and the model for PRS's **Vendors**.

On PRS, **Vendors** is this walkthrough's twin — a simple no-FK entity you build from
these same eight files.
```
