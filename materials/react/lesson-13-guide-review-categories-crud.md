# Lesson 13 Guide — Review / Buffer: The Feature-Folder Pattern

**This is a review / buffer lesson — there is no lab.** You've now built the **complete
TableServe front end** — five entities (Staff, Categories, MenuItems, Orders, OrderItems),
each the *same feature folder*. This lesson is catch-up time plus a guided look **back** at
that repeated pattern, using **Categories** — your simplest entity, built in the Lesson 9–10
labs — as the clearest example. The goal is a rock-solid mental model before the PRS capstone,
where you build the same pattern five more times.

**Goal:** open any entity's folder and explain each file's role, and confirm every screen
works in the browser. If you fell behind anywhere, this is the lesson to catch up.

> **Why look at Categories?** It's the **simplest** full CRUD you built — a card grid, a
> skeleton, and a no-FK shared form — so the feature-folder pattern shows through with the
> least noise. Everything here you also did (with a wrinkle or two) for Menu Items, Staff, and
> Orders. On PRS, **Vendors** is Categories' twin.

---

## 1. The feature folder, file by file

Every entity you built follows the same shape. Here it is for Categories — open your own
`src/categories/` folder and read along:

| File | Role | Lesson it draws on |
|---|---|---|
| `ICategory.ts` | The TypeScript interface (`id`, `name`, `sortOrder`) | 3 |
| `CategoryAPI.ts` | `list` / `find` / `post` / `put` / `delete`, built up one method at a time (via `checkStatus`/`parseJSON` after Lesson 12) | 7–10, 12 |
| `CategoriesPage.tsx` | Route target — heading + **Add Category** button; fetches in `useEffect`, holds state, `.map()`s cards, skeletons | 4, 5, 6 |
| `CategoryCard.tsx` | One card (props `category`, `onRemove`) with the ⋮ dropdown | 5, 6 |
| `CategoryCardSkeleton.tsx` | Grey placeholder card shown while loading | 6 |
| `CategoryForm.tsx` | Shared create/edit form (no FK), react-hook-form | 7, 10 |
| `CategoryCreatePage.tsx` / `CategoryEditPage.tsx` | Thin wrappers around the form | 7, 10 |

**The table is in reading order** — open `ICategory.ts` first and work down it. Each file leans
on the one above: the API returns objects in the interface's shape, the page calls the API, the
card renders one of the items the page maps over, and the form writes back through the API.
Every file is just its lesson's pattern applied to Categories.

> The **page fetches and maps directly** — like your `MenuItemsPage` / `StaffPage` /
> `OrdersPage`. There's no separate `List` component in **this** app; the page owns the state.
> *(The PRS spec does split the `.map()` into a `{Entity}List` component — one extra props
> hand-off, no new idea. Lesson 15 covers the swap.)*

---

## 2. The same pattern, five times — what changed each time

Categories is the plain version. Each of your other entities is the same folder with **one
twist** — and that's the whole map of the front end:

| Entity | The twist over the plain Categories pattern |
|---|---|
| **Staff** | role-flag **badges** on the card, **checkboxes** (no FK) on the form; feeds Sign In |
| **Menu Items** | a **Category FK dropdown** on the form |
| **Orders** | a **table** (not cards) with status badges + a `useSearchParams` **filter**; a **detail page** with status-driven **workflow buttons** and a **Cancel modal**; a **Staff FK** form pre-filled from **Context** |
| **Order Items** | a **nested child** form (scoped to an order) with **derived fields** (`watch`) and a parent **Total** the API recalculates |

If you can see Categories as the base case and each of the others as "base + one idea," you
understand the whole front end.

---

## 3. Wiring recap

Every entity is reachable the same way — routes under `Layout` plus a nav item:

```tsx
{ path: "categories", element: <CategoriesPage /> },
{ path: "categories/create", element: <CategoryCreatePage /> },
{ path: "categories/edit/:id", element: <CategoryEditPage /> },
```

…plus its **`Nav.Link`** in `AppNav`. Confirm the four **top-level** entities — Orders, Menu
Items, Categories, Staff — have routes *and* a nav link.

**Order Items is the deliberate exception:** it has routes
(`orders/detail/:id/orderitem/create` and `…/edit/:itemId`) but **no nav link**, because a
child collection is only reachable *through its parent* — you get there from an order's detail
page, never from the sidebar. On PRS, RequestLines works exactly the same way.

---

## 4. Catch-up checklist — the complete app

Use the buffer to close any gaps. In the browser, you should have **all** of:

- [ ] **Sign In + Context** — login, localStorage persistence, role-based UI, the Cancel ownership check
- [ ] **Staff** — list, card grid with role badges + skeletons, shared form (checkboxes)
- [ ] **Categories** — list + card grid + skeletons, shared no-FK form *(Lesson 9–10 labs)*
- [ ] **Menu Items** — list, card grid, shared form with the **Category FK dropdown**
- [ ] **Orders** — table with status badges + filter + 3-dots menu; **create/edit form** *(Lesson 11 lab)*
- [ ] **Order Detail** — definition-list summary, workflow buttons, Cancel modal
- [ ] **Order Items** — nested form (derived Price/Amount), items table, delete-confirm modal, parent total recalculating
- [ ] **Toasts + `checkStatus`** across every CRUD action

Anything unchecked, fix it now — the capstone assumes the whole app works.

---

## 5. Verifying in the browser

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`) with all
> seed data loaded.

Do a quick pass on Categories (your simplest entity) to confirm the pattern end to end:

1. Open `/categories` — the card grid renders (skeletons first on a slow network), each card
   showing name + sort order with a **⋮** menu.
2. **Add Category** → empty form; Save → back to the list with the new card. **⋮ → Edit** →
   pre-filled; Save → updated. **Delete** → confirm → card removed, success toast.
3. Compare side by side with **Menu Items** and **Staff** — identical behavior, because they're
   the same patterns.
4. Console clean.

---

## The General Pattern (what to take away)

- Every entity is the **same feature folder**: interface, API module, page (fetch + map +
  skeletons), card (or row), skeleton, shared form, thin create/edit wrappers.
- A new entity introduces **no new concept** — it's the Lessons 3–12 patterns again. You
  proved it five times.
- **Categories is the base case**; every other entity is "base + one idea" (a badge, an FK
  dropdown, a table, a nested child).

On PRS you build this **five more times** — Users, Vendors, Products, Requests, RequestLines —
the same folders, the same twists. **Vendors** is Categories' twin.
