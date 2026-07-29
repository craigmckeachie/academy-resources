# Lesson 9 Lab — The Categories List

Categories is the last entity in TableServe without a screen. You've now built **two** card
grids from scratch — **Menu Items** (in the guides) and **Staff** (in the labs) — so build the
Categories list the same way, **mostly from memory**. This lab is deliberately light on code:
your `MenuItemsPage` / `StaffPage` and `MenuItemCard` / `StaffCard` are your templates — keep
them open beside this.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`) with
> **Categories seed data** loaded.

## The entity (already created in Lesson 7)

You made `ICategory` in Lesson 7 for the Menu Item dropdown — here it is for reference:

```ts title="src/categories/ICategory.ts"
export interface ICategory {
  id: number | undefined;
  name: string;
  sortOrder: number;
}
```

The whole model — no FK, no nested collections (the simplest entity in the app).

## Steps

Same arc as every list page you've built: **API module → card → page → route + nav.**

1. **`CategoryAPI.ts`** — add **`delete(id)`** (your module already has `list` from Lesson 7
   and `find` from the Lesson 8 lab), plain `fetch`; Lesson 12 hardens every module later.
2. **`CategoryCard`** — a card showing **name** and **sort order**, with the same **⋮
   `Dropdown`** as `StaffCard`: an **Edit** link (→ `/categories/edit/:id`) and a
   **Delete**-with-`confirm` that calls `categoryAPI.delete` then the `onRemove` prop. (Edit
   404s until the Lesson 10 lab builds the form.)
3. **`CategoriesPage`** — fetch into state in a `useEffect`, `.map()` the cards, show
   **skeletons** while loading (`CategoryCardSkeleton`, a card copy with `skeleton
   skeleton-text` bars), a `removeCategory` that filters state after a delete, and an
   **Add Category** button (→ `/categories/create`). Model it on `MenuItemsPage`.
4. **Route + nav** — register `categories` under `Layout` in `main.tsx`, and **add the
   Categories item to `AppNav`** (the `{/* Categories … */}` slot you left in Lesson 5 — copy
   the Menu / Orders `Nav.Link` shape; use an icon like `#tags`).
5. **✅ Checkpoint:** `/categories` shows one card per seeded category (skeletons first on a
   slow network); the **⋮ → Delete** confirms and removes a card; the **Categories** nav pill
   works.

## Verify in the browser

Browser checks work the same as your other list pages. With your API running and
`npm run dev` up:

1. Click the **Categories** nav item → the card grid renders, name + sort order per card.
2. Throttle to **Slow 3G** (DevTools → Network) and reload — skeleton cards show, then the
   real cards.
3. **⋮ → Delete** → confirm → the card disappears; **Network** shows a `DELETE`.
4. Console clean.

Same fetch + card-grid + dropdown + skeleton patterns you've done twice now, on the last
entity. On PRS this is **Vendors** — the simple no-FK reference entity.

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you've done; **[Reach]** goes past it and needs some research.

- **Sort by sort order** — [Reinforce] — sort the fetched categories by `sortOrder` before
  `setCategories` so they render in menu order.
- **Count in the heading** — [Reinforce] — show `Categories ({categories.length})` and watch
  it fill in after the fetch.
- **A reusable confirm modal** — [Reach] — replace the `window.confirm` delete with a
  react-bootstrap `Modal` (the state-driven pattern from Lesson 9's guide). Reference:
  [react-bootstrap Modal](https://react-bootstrap.netlify.app/docs/components/modal).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that span
the whole React pass.
