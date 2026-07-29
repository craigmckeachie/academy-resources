# Lesson 8 Lab — A Category Detail View

Build a read-only **Category detail** page reached by id (`/categories/detail/:id`),
following the Order Detail pattern from the guide — **`useParams`** to read the id,
fetch the one record, render it as a **definition list**. Category is a simple entity,
so this is the detail pattern at its smallest. Refer back to the guide for `useParams`,
the `undefined`-initialized state guard, and the `<dl>` layout.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`) with
> Categories seed data loaded.

> **Note:** you already started the Categories module in **Lesson 7** (the `ICategory`
> interface + a `list()` for the Menu Item form's dropdown). Here you add a `find` and a
> **detail view** — extra **practice for the detail/params pattern**. The finished reference
> app has no Category detail page, so reach it by **typing the URL**; the Categories **list**
> and **form** come in the Lesson 9–10 labs.

---

## The Category record

`id`, `name`, `sortOrder`. (That's the whole entity — no FK, no nested collections.)

---

## Steps

Same arc as the guide, on the simplest entity: **`find` → fetch by `:id` → definition list.**

1. Add `find(id)` (GET `/api/categories/{id}`) to the `CategoryAPI` you started in **Lesson 7**
   (it already has `ICategory` and `list`). You add `delete` / `post` / `put` in the Lesson
   9–10 labs.
2. Build `CategoryDetailPage`: read `:id` with `useParams`, `Number(id)` it, and fetch into
   `useState<ICategory | undefined>(undefined)` in a `useEffect`.
3. Guard the render with `{category && …}`; show a `{loading && <p>Loading…</p>}` while
   fetching.
4. Render a heading row ("Category") and a `<dl>` (inside a `d-flex flex-wrap gap-4` row)
   showing **Name** and **Sort Order** as `<dt>`/`<dd>` pairs.
5. Add the `categories/detail/:id` route under `Layout`. (An Edit pencil `Link` to
   `/categories/edit/:id` in the heading will 404 until the Lesson 10 lab builds the form —
   add it now or later.)
   **✅ Checkpoint:** type `/categories/detail/5` in the address bar → the detail renders;
   change the id → a different category loads. (There's no list or card to click from yet — the
   Lesson 9 lab builds the Category card, where you can add a **View** item that links here.)

---

## Verify in the browser

Browser checks are covered in the guide — section 5. With your API running and
`npm run dev` up:

1. Type `/categories/detail/5` in the address bar → the page shows that category's Name and
   Sort Order.
2. Change the id in the URL and reload — a different category loads (that's `useParams`
   plus the keyed fetch).
3. If you added the Edit link, clicking it 404s for now — the category edit form is the
   Lesson 10 lab.
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
