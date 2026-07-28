# Lesson 4 Guide — State, Effects, and Fetching Real Data

**Goal:** by the end of this lesson your Menu Items page shows **real data from your Web
API** instead of the hardcoded array from Lesson 3. You'll learn the two hooks every data
page uses — **`useState`** to hold the fetched data and **`useEffect`** to fetch it when
the page loads — plus **`fetch`** with `async/await`. Along the way you'll hit the **CORS
error** and fix it live in the API.

**The general pattern you're learning:** a data page holds its records in **state**
(`useState`), **fetches** them once on mount (`useEffect`), and renders the state with
`.map()`. When the state changes, React re-renders automatically. This
state-plus-effect-plus-fetch shape is the backbone of every list and detail page in the
app.

> **How to use this guide.** Sections headed **▶ Code along** are ones you **build into
> your project** — type them as you go. Unmarked sections are concept: read them (or watch
> the instructor), but there's nothing to type yet. Each code block names the file it
> belongs in on its first line. The **Build Steps** at the end recap every ▶ Code along
> action in order.

> **Prerequisite:** you're picking up the `MenuItemsPage` you built in Lesson 3 (a
> hardcoded `IMenuItem[]` rendered as cards). Your **TableServe Web API must be running**
> with **seed data loaded**, so `/api/menuitems` returns real items. **Start it on the HTTP
> profile — pick `http` (not `https`) in Visual Studio's run-button dropdown** — this course
> uses plain HTTP to skip dev certificates, and your fetch URL is `http://localhost:…`. Its
> **CORS middleware** is still commented out from the API pass — **section 6** is where you
> turn it on.

---

## 1. Why hooks

*(Read this.)*

The hardcoded page from Lesson 3 never changed after it rendered. A real page has to load
data *after* it appears, store that data somewhere, and re-render when it arrives. Plain
variables can't do that — reassigning a `const` doesn't tell React to re-render.

**Hooks** are functions React gives you to add these capabilities to a component. They
always start with `use`. The two you need now:

- **`useState`** — remembers a value across renders and re-renders when you change it.
- **`useEffect`** — runs code *after* the component renders (e.g. to fetch data).

**Rules of hooks:** call them at the **top level** of your component (never inside a loop,
condition, or nested function), and only from components. Your editor's ESLint will warn
you if you break this.

---

## 2. `useState` — holding data that changes

*(Read this; you'll type it in section 5.)*

`useState` gives you a value and a function to update it:

```tsx
import { useState } from "react";
import { IMenuItem } from "./IMenuItem";

const [menuItems, setMenuItems] = useState<IMenuItem[]>([]);
```

- The **array destructuring** (Lesson 1) gives you two things: the current value
  (`menuItems`) and a setter (`setMenuItems`).
- `<IMenuItem[]>` types the state — it holds an array of menu items.
- `[]` is the **initial value** — an empty array, so the first render has something to
  `.map()` (an empty list) before data arrives.
- **Calling `setMenuItems(newValue)` re-renders the component** with the new value. That's
  the whole point: change state → React re-renders → the UI reflects the change.

Never mutate state directly (`menuItems.push(...)` won't re-render). Always call the setter
with a new value.

You'll track a **loading** flag too:

```tsx
const [loading, setLoading] = useState(false);
```

---

## 3. `useEffect` — running the fetch on mount

*(Read this; you'll type it in section 5.)*

You want to fetch *once*, when the page first appears. That's `useEffect` with an empty
dependency array:

```tsx
import { useEffect } from "react";

useEffect(() => {
  loadMenuItems();
}, []);
```

- The **first argument** is the effect function — it runs after render.
- The **second argument `[]`** is the dependency array. Empty means "run this once, after
  the first render, and never again." (A non-empty array re-runs the effect when one of its
  values changes — you'll use that in Lesson 6 for the status filter.)
- **Forgetting the `[]`** makes the effect run after *every* render — which, if the effect
  sets state, loops forever. The empty array is what makes "fetch on mount" work.

---

## 4. `fetch` with `async/await`, and an API module

*(Read this; you'll type it in section 5.)*

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

**Centralize the fetch in an API module.** Rather than scatter `fetch` calls through
components, the app keeps them per entity in a `{Entity}API.ts` module. The component then
calls `menuItemAPI.list()` and doesn't care about the URL or JSON parsing — you'll create
that file in section 5. (Lesson 12 hardens this module with shared status-checking and
error handling; for now a plain `.then(res => res.json())` is enough.)

---

## 5. ▶ Code along — Fetch the menu items

Now wire it together. You're editing the **`MenuItemsPage`** from Lesson 3 — swapping its
hardcoded array for a real fetch — and adding one new file.

**Step 1 — the API module.** Create the fetch wrapper:

```ts title="src/menuItems/MenuItemAPI.ts"
import { IMenuItem } from "./IMenuItem";

const url = "http://localhost:5556/api/menuitems";

export const menuItemAPI = {
  list(): Promise<IMenuItem[]> {
    return fetch(url).then((response) => response.json());
  },
};
```

Use the port **your** API prints when it starts (the reference app uses `5556`).

**Step 2 — swap the hardcoded array for fetched state.** Open
`src/menuItems/MenuItemsPage.tsx`. **Delete the hardcoded `menuItems` array** and, in its
place, add: `useState` for the items (typed `IMenuItem[]`, initial `[]`) and a `loading`
flag, an `async loadMenuItems()` that fetches through the API module, and a `useEffect` to
call it on mount. The card markup stays exactly as it was in Lesson 3:

```diff title="src/menuItems/MenuItemsPage.tsx"
+ import { useEffect, useState } from "react";
  import { IMenuItem } from "./IMenuItem";
+ import { menuItemAPI } from "./MenuItemAPI";

- const menuItems: IMenuItem[] = [
-   { id: 1, name: "Loaded Nachos", price: 9.99 },
-   { id: 2, name: "Mozzarella Sticks", price: 7.99 },
-   { id: 3, name: "Ribeye Steak", price: 24.99 },
- ];

  function MenuItemsPage() {
+   const [loading, setLoading] = useState(false);
+   const [menuItems, setMenuItems] = useState<IMenuItem[]>([]);
+
+   async function loadMenuItems() {
+     setLoading(true);
+     try {
+       const data = await menuItemAPI.list();
+       setMenuItems(data);
+     } catch (error: any) {
+       console.error(error);
+     } finally {
+       setLoading(false);
+     }
+   }
+
+   useEffect(() => {
+     loadMenuItems();
+   }, []);
+
    return (
      <section className="content container-fluid mx-5 my-2 py-4">
        <h2 className="pb-4 mb-4 border-bottom border-2">Menu</h2>
        <section className="list d-flex flex-row flex-wrap bg-light gap-5 p-4 rounded-4">
+         {loading && <p>Loading…</p>}
          {menuItems.map((menuItem) => (
            <div className="card p-4" style={{ width: "23rem" }} key={menuItem.id}>
              <span className="fs-4 fw-medium">{menuItem.name}</span>
              <span className="fs-5 fw-light">${menuItem.price}</span>
            </div>
          ))}
        </section>
      </section>
    );
  }

  export default MenuItemsPage;
```

Trace the flow: first render → `menuItems` is `[]`, nothing to map → the effect runs →
`loadMenuItems` fetches → `setMenuItems(data)` → **re-render** with real data → cards
appear. `{loading && <p>Loading…</p>}` shows a message while the fetch is in flight
(Lesson 6 upgrades this to skeleton cards).

> **Same `{ }`, `.map()`, and `key` as Lesson 3 — only the data source changed** (a
> hardcoded array → fetched state). The API actually returns *richer* objects than your
> stub (each item also has a `category`), but the card still shows just name and price;
> the polished card with the category badge comes in Lesson 6.

**Save and check:** the cards won't appear yet — the fetch is very likely blocked by
**CORS**. That's expected; you'll open the Console and fix it in section 6.

---

## 6. ▶ Code along — The CORS error, and fixing it live

*(This fix is in the **API** project, not React.)*

Open **DevTools** — press **F12** (or right-click the page → **Inspect**) — and click the
**Console** tab. The first time you fetch, you'll very likely see this error there:

```
Access to fetch at 'http://localhost:5556/api/menuitems' from origin
'http://localhost:5173' has been blocked by CORS policy: No
'Access-Control-Allow-Origin' header is present on the requested resource.
```

**What it means:** your React app runs on `localhost:5173`; your API on `localhost:5556`.
Different port = different **origin**. Browsers block cross-origin requests unless the
server explicitly allows them via **CORS** (Cross-Origin Resource Sharing) headers. This is
a browser security rule — the request often *reaches* the API (you'll see it in the API
logs), but the browser refuses to hand the response to your JavaScript.

**The fix (in the API):** you already registered CORS in the API pass —
`builder.Services.AddCors(...)` is active — and left only the **middleware** commented. So
just **uncomment the `app.UseCors();` line** after `builder.Build()`:

```csharp title="TableServe.Api/Program.cs"
app.UseCors();
```

Restart the API. The header is now sent, the browser releases the response, and your cards
appear. (Wide-open CORS is an intentional teaching simplification — don't tighten it.)

> **Diagnose it in DevTools:** the **Console** shows the CORS message; the **Network** tab
> shows the request with a failed/blocked status. Seeing it there — reaching the server but
> blocked by the browser — is the clearest way to understand what CORS is.

---

## 7. Verifying in the browser

Verification is in the **browser**, not Insomnia (Insomnia was the API pass; here you
confirm the *front end* renders the data). You've checked each piece as you built it; this
is the full pass. With your API running and `npm run dev` up:

1. Open the app. After a brief moment the **real** menu items load — the same records you'd
   see hitting `/api/menuitems` in Insomnia, now as cards.
2. Open **DevTools → Network**, filter to Fetch/XHR, and reload. You should see the
   `menuitems` request return **200** with a JSON array. Click it → **Response** to see the
   payload React consumed.
3. If the cards never appear, check the **Console** for the CORS error (section 6) or a
   failed request (API not running / wrong port).
4. Add a menu item in the database (or via Insomnia) and reload the page — it appears. The
   page is now driven by real data, not a hardcoded array.

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

On PRS you'll write a `ProductAPI.ts` with a `list()` and a `ProductsPage` that fetches in
a `useEffect` — identical to this, different entity.

---

## Build Steps

1. Make sure your **API is running** with seed data loaded.
2. Create `src/menuItems/MenuItemAPI.ts` exporting a `menuItemAPI` object with a `list()`
   that `fetch`es `/api/menuitems` and returns the parsed JSON.
3. In `MenuItemsPage.tsx`, **delete the hardcoded array** and add `useState` for
   `menuItems` (typed `IMenuItem[]`, initial `[]`) and `loading`.
4. Write an `async loadMenuItems()` that sets loading, `await`s `menuItemAPI.list()`,
   stores the result with `setMenuItems`, and clears loading in `finally`.
5. Call it from `useEffect(() => { loadMenuItems(); }, [])`, and render `{loading && …}`
   above the `menuItems.map(...)` (the card markup is unchanged from Lesson 3).
6. Hit the **CORS error**, then enable `app.UseCors(...)` in the API's `Program.cs` and
   restart the API.
7. Verify in the browser using section 7 — real cards render, Network shows a 200, and the
   CORS error is resolved.
