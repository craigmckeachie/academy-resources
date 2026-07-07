# Lesson 4 Guide — State, Effects, and Fetching Real Data

**Goal:** by the end of this lesson your Menu Items page shows **real data from your
Web API** instead of a hardcoded array. You'll learn the two hooks every data page
uses — **`useState`** to hold the fetched data and **`useEffect`** to fetch it when the
page loads — plus `fetch` with `async/await`. Along the way you'll hit the **CORS
error** and fix it live in the API.

**The general pattern you're learning:** a data page holds its records in **state**
(`useState`), **fetches** them once on mount (`useEffect`), and renders the state with
`.map()`. When the state changes, React re-renders automatically. This
state-plus-effect-plus-fetch shape is the backbone of every list and detail page in
the app.

> **Prerequisite:** your TableServe Web API from the API pass must be running, and its
> **CORS middleware enabled** (it was commented out during the API pass — this is the
> lesson where you turn it on). Seed data should be loaded so the endpoints return real
> menu items.

---

## 1. Why hooks

The hardcoded page from Lesson 3 never changed after it rendered. A real page has to:
load data *after* it appears, store that data somewhere, and re-render when it arrives.
Plain variables can't do that — reassigning a `const` doesn't tell React to re-render.

**Hooks** are functions React gives you to add these capabilities to a component. They
always start with `use`. The two you need now:

- **`useState`** — remembers a value across renders and re-renders when you change it.
- **`useEffect`** — runs code *after* the component renders (e.g. to fetch data).

**Rules of hooks:** call them at the **top level** of your component (never inside a
loop, condition, or nested function), and only from components. Your editor's ESLint
will warn you if you break this.

---

## 2. `useState` — holding data that changes

`useState` gives you a value and a function to update it:

```tsx
import { useState } from "react";
import { IMenuItem } from "./IMenuItem";

const [menuItems, setMenuItems] = useState<IMenuItem[]>([]);
```

- The **array destructuring** gives you two things: the current value (`menuItems`) and
  a setter (`setMenuItems`).
- `<IMenuItem[]>` types the state — it holds an array of menu items.
- `[]` is the **initial value** — an empty array, so the first render has something to
  `.map()` (an empty list) before data arrives.
- **Calling `setMenuItems(newValue)` re-renders the component** with the new value.
  That's the whole point: change state → React re-renders → the UI reflects the change.

Never mutate state directly (`menuItems.push(...)` won't re-render). Always call the
setter with a new value.

You'll usually track a **loading** flag too:

```tsx
const [loading, setLoading] = useState(false);
```

---

## 3. `useEffect` — running the fetch on mount

You want to fetch *once*, when the page first appears. That's `useEffect` with an empty
dependency array:

```tsx
import { useEffect } from "react";

useEffect(() => {
  loadMenuItems();
}, []);
```

- The **first argument** is the effect function — it runs after render.
- The **second argument `[]`** is the dependency array. Empty means "run this once,
  after the first render, and never again." (A non-empty array re-runs the effect when
  one of its values changes — you'll use that in Lesson 6 for the status filter.)
- Forgetting the `[]` makes the effect run after *every* render — which, if the effect
  sets state, loops forever. The empty array is what makes "fetch on mount" work.

---

## 4. Fetching with `async/await`

You met `async`/`await` in Lesson 2 — **the same keywords as C#**, where a JS async
function returns a `Promise<T>` (C#'s `Task<T>`). Here they do real work. The browser's
built-in **`fetch`** makes an HTTP request and returns a Promise. Wrap it in an `async`
function so you can `await` the response and the JSON:

```tsx
async function loadMenuItems() {
  setLoading(true);
  try {
    const response = await fetch("http://localhost:5556/api/menuitems");
    const data = await response.json();
    setMenuItems(data);
  } catch (error: any) {
    console.error(error);
  } finally {
    setLoading(false);
  }
}
```

- `await fetch(url)` sends a **GET** and waits for the response.
- `await response.json()` parses the JSON body into JavaScript objects.
- `setMenuItems(data)` stores it in state → re-render → the list shows real data.
- `try/catch/finally` handles network errors and always clears the loading flag.

The URL is your running API's address plus the route. Use the port your API prints
(the reference app uses `5556`).

### Extracting an API module

Rather than scatter `fetch` calls through components, the app centralizes them per
entity in a `{Entity}API.ts` module. Create `src/menuItems/MenuItemAPI.ts`:

```ts
import { IMenuItem } from "./IMenuItem";

const url = "http://localhost:5556/api/menuitems";

export const menuItemAPI = {
  list(): Promise<IMenuItem[]> {
    return fetch(url).then((response) => response.json());
  },
};
```

Now the component calls `menuItemAPI.list()` and doesn't care about the URL or JSON
parsing. (Lesson 12 hardens this module with shared status-checking and error handling;
for now a plain `.then(res => res.json())` is enough.)

---

## 5. Putting it together — the list component

```tsx
import { useEffect, useState } from "react";
import { IMenuItem } from "./IMenuItem";
import { menuItemAPI } from "./MenuItemAPI";

function MenuItemList() {
  const [loading, setLoading] = useState(false);
  const [menuItems, setMenuItems] = useState<IMenuItem[]>([]);

  async function loadMenuItems() {
    setLoading(true);
    try {
      const data = await menuItemAPI.list();
      setMenuItems(data);
    } catch (error: any) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadMenuItems();
  }, []);

  return (
    <section className="list d-flex flex-row flex-wrap bg-light gap-5 p-4 rounded-4">
      {loading && <p>Loading…</p>}
      {menuItems.map((menuItem) => (
        <div className="card p-4" style={{ width: "23rem" }} key={menuItem.id}>
          <span className="fs-4 fw-medium">{menuItem.name}</span>
          <span className="fs-5 fw-light">${menuItem.price}</span>
          <div className="badge text-secondary bg-primary-subtle mt-3">
            {menuItem.category?.name}
          </div>
        </div>
      ))}
    </section>
  );
}

export default MenuItemList;
```

Trace the flow: first render → `menuItems` is `[]`, nothing to map → effect runs →
`loadMenuItems` fetches → `setMenuItems(data)` → **re-render** with real data → cards
appear. `{loading && <p>Loading…</p>}` shows a message while the fetch is in flight
(Lesson 6 upgrades this to skeleton cards).

`menuItem.category?.name` uses **optional chaining** (`?.`) — if `category` is
`undefined`, it yields `undefined` instead of crashing. The API includes the nested
`category` because the controller `Include()`s it.

---

## 6. The CORS error — and fixing it live

The first time you fetch, you'll very likely see this in the Console:

```
Access to fetch at 'http://localhost:5556/api/menuitems' from origin
'http://localhost:5173' has been blocked by CORS policy: No
'Access-Control-Allow-Origin' header is present on the requested resource.
```

**What it means:** your React app runs on `localhost:5173`; your API on
`localhost:5556`. Different port = different **origin**. Browsers block cross-origin
requests unless the server explicitly allows them via **CORS** (Cross-Origin Resource
Sharing) headers. This is a browser security rule — the request often *reaches* the API
(you'll see it in the API logs), but the browser refuses to hand the response to your
JavaScript.

**The fix (in the API, not React):** enable the CORS middleware you registered but
commented out during the API pass. In `Program.cs`:

```csharp
// after builder.Build():
app.UseCors(policy =>
    policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
```

Restart the API. The header is now sent, the browser releases the response, and your
cards appear. (Wide-open CORS is an intentional teaching simplification — don't
tighten it.)

> **Diagnose it in DevTools:** the **Console** shows the CORS message; the **Network**
> tab shows the request with a failed/blocked status. Seeing it there — reaching the
> server but blocked by the browser — is the clearest way to understand what CORS is.

---

## 7. Verifying in the browser

Verification is in the **browser**, not Insomnia (Insomnia was the API pass; here you
confirm the *front end* renders the data). With your API running and `npm run dev` up:

1. Open the app. After a brief moment the **real** menu items load — the same records
   you'd see hitting `/api/menuitems` in Insomnia, now as cards.
2. Open **DevTools → Network**, filter to Fetch/XHR, and reload. You should see the
   `menuitems` request return **200** with a JSON array. Click it → **Response** to see
   the payload React consumed.
3. If the cards never appear, check the **Console** for the CORS error (section 6) or a
   failed request (API not running / wrong port).
4. Add a menu item in the database (or via Insomnia) and reload the page — it appears.
   The page is now driven by real data, not a hardcoded array.

---

## The General Pattern (what to take away)

- **`useState`** holds data that changes; calling its setter re-renders the component.
- **`useEffect(fn, [])`** runs `fn` once after mount — the place to kick off a fetch.
- **`fetch` + `async/await`** gets JSON from your API; store it with the state setter.
- A **`{Entity}API.ts`** module centralizes an entity's fetch calls.
- **CORS** blocks cross-origin fetches until the server sends the allow header — a
  server-side fix, diagnosed in DevTools.
- Every list and detail page from here on is this same shape: state + effect + fetch +
  `.map()`.

On PRS you'll write a `ProductAPI.ts` with a `list()` and a `ProductList` that fetches
in a `useEffect` — identical to this, different entity.

---

## Build Steps

1. Enable CORS in your API's `Program.cs` (uncomment/add `app.UseCors(...)`) and
   restart it.
2. Create `src/menuItems/MenuItemAPI.ts` exporting a `menuItemAPI` object with a
   `list()` that `fetch`es `/api/menuitems` and returns the parsed JSON.
3. In `MenuItemList.tsx`, add `useState` for `menuItems` (typed `IMenuItem[]`, initial
   `[]`) and `loading`.
4. Write an `async loadMenuItems()` that sets loading, `await`s `menuItemAPI.list()`,
   stores the result, and clears loading in `finally`.
5. Call it from `useEffect(() => { loadMenuItems(); }, [])`.
6. Render `menuItems.map(...)` into cards with a `key`, plus a `{loading && …}` message.
7. Verify in the browser using section 7 — real cards render, Network shows a 200, and
   the CORS error (if any) is resolved.
```
