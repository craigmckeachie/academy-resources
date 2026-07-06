# Lesson 8 Lab — A Category Detail View

Build a read-only **Category detail** page reached by id (`/categories/detail/:id`),
following the Order Detail pattern from the guide — **`useParams`** to read the id,
fetch the one record, render it as a **definition list**. Category is a simple entity,
so this is the detail pattern at its smallest. Refer back to the guide for `useParams`,
the `undefined`-initialized state guard, and the `<dl>` layout.

> **Note:** the finished TableServe app ships Categories as list + create/edit only —
> there's no Category detail page in the reference. You're building this one as
> **practice for the detail/params pattern** on a simple entity. Categories CRUD itself
> is provided starter code (walked through in Lesson 13); here you add just the detail
> view.

---

## The Category record

`id`, `name`, `sortOrder`. (That's the whole entity — no FK, no nested collections.)

---

## Steps

1. Ensure `CategoryAPI.ts` has `find(id)` (GET `/api/categories/{id}`) — add it if the
   provided module doesn't.
2. Build `CategoryDetailPage`: read `:id` with `useParams`, `Number(id)` it, and fetch
   into `useState<ICategory | undefined>(undefined)` in a `useEffect`.
3. Guard the render with `{category && …}`; show a `{loading && <p>Loading…</p>}` while
   fetching.
4. Render a heading row ("Category") and a `.detail-header` with a `<dl>` showing
   **Name** and **Sort Order** as `<dt>`/`<dd>` pairs.
5. Add an Edit (pencil) `Link` to `/categories/edit/:id` in the heading, and add the
   `categories/detail/:id` route under `Layout`.
6. Link to it from the Category card's **⋮** menu (add a **View** item, like Orders).

---

## Verify in the browser

Browser checks are covered in the guide — section 5. With your API running and
`npm run dev` up:

1. From `/categories`, open a card's **⋮ → View** → `/categories/detail/{id}` shows
   that category's Name and Sort Order.
2. Change the id in the URL and reload — a different category loads (that's `useParams`
   + the keyed fetch).
3. Click Edit → it navigates to the category edit form.
4. Console clean; **Network** shows `GET /api/categories/{id}`.

Same `useParams` + detail pattern on the simplest entity — the mechanics you'll reuse
on PRS's **Request Detail** (which adds workflow buttons and a child table in the next
lessons).

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **Menu items in this category** — [Reinforce] — below the summary, fetch
  `/api/menuitems`, filter to those whose `categoryId` matches, and list their names.
  Practice combining a route param with a second fetch and a `.filter()`.
- **Not-found handling** — [Reinforce] — if the fetch returns nothing (bad id), render a
  "Category not found" message instead of a blank summary, using a ternary on the
  `category` state.
- **Back button** — [Reinforce] — add a "Back to Categories" button that calls
  `navigate("/categories")` via `useNavigate`, reinforcing code-driven navigation.
- **Read the raw param** — [Reach] — `console.log(useParams())` and confirm the id is a
  **string**, then trace where you convert it with `Number(...)`. Read why params are
  strings. Reference:
  [useParams (react-router v6)](https://reactrouter.com/6.30.0/hooks/use-params).

Finished these and want more? See
[stretch-react-challenges.md](stretch-react-challenges.md) for bigger challenges that
span the whole React pass.
```
