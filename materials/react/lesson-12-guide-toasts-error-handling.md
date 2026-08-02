# Lesson 12 Guide — Toasts and Centralized Error Handling

**Goal:** by the end of this lesson every CRUD action gives the user clear feedback —
**success and error toasts** via `react-hot-toast` — and your API modules share **one
place** that turns a failed HTTP response into a thrown `Error` your components can
catch and toast. You'll retrofit the Menu Item CRUD (list/create/edit/delete) with this
feedback and the shared fetch helpers. (The `<Toaster />` that renders them went into `App` in
Lesson 11 — here you theme it and make the feedback systematic.)

**The general pattern you're learning:** a **toast** is a small, auto-dismissing
message for success/error feedback. You call `toast.success(...)` after a successful
action and `toast.error(...)` in a `catch`. Underneath, the API module runs every
response through a shared **`checkStatus`** that throws a friendly `Error` on non-2xx,
so components have a consistent thing to catch. Feedback + centralized errors are the
polish that makes the app feel finished.

> **How to use this guide.** Sections headed **▶ Code along** are ones you build into your
> project (each ends with a quick **Save and check**); unmarked sections are concept. Each
> code block carries its file name as a title bar.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`), and
> you have the Menu Item CRUD (list/create/edit/delete) from Lessons 3–7.

> **This lesson pays off a running promise.** Since Lesson 6 your API modules have used
> plain `fetch` with a hardcoded URL and (in a couple of spots) an inline
> `if (!response.ok) throw` guard. Here you build the shared **`fetchUtilities`** once and
> retrofit **every** module (Menu Items, Orders, OrderItems, Staff, Categories) to it — the
> guide walks Menu Items; you repeat the same three-line change across the rest.

---

## 1. ▶ Code along — Theming the Toaster

`react-hot-toast` needs one `<Toaster />` mounted near the app root — you added it bare in
Lesson 11's `App.tsx`, which is why toasts started appearing there. Give it **`toastOptions`**
now to theme them (the brand orange check):

```diff title="src/App.tsx"
    <StaffContext.Provider value={{ staff, setStaff }}>
-     <Toaster />
+     <Toaster
+       toastOptions={{
+         success: { iconTheme: { primary: "#FF7A00", secondary: "white" } },
+         style: { maxWidth: 500 },
+       }}
+     />
      <Outlet />
    </StaffContext.Provider>
```

Mount it once; you never render toasts directly — you *call* them (next).

**Save and check**

- Save a menu item — the success toast's check is now **brand orange** instead of the default
  green.
- Console is clean.

---

## 2. Firing toasts

*(Read this — the two calls you'll wire into CRUD in section 4.)* Import the default `toast`
and call it wherever an action succeeds or fails:

```tsx
import toast from "react-hot-toast";

toast.success("Successfully saved.");
toast.error("There was an error saving or retrieving data.", { duration: 6000 });
```

- `toast.success(msg)` — a green check toast; use after a successful save/delete.
- `toast.error(msg, opts)` — a red toast; use in a `catch`. A longer `duration` gives
  the user time to read an error.

Toasts stack and auto-dismiss; no state or cleanup on your part.

---

## 3. ▶ Code along — Centralized fetch error handling

A `fetch` promise **doesn't reject on 404/500** — it resolves with a non-`ok` response.
So each API module runs responses through shared helpers in
`src/utility/fetchUtilities.ts` that turn a bad status into a thrown `Error`:

```ts title="src/utility/fetchUtilities.ts"
export const BASE_URL = "http://localhost:5556/api";

export function translateStatusToErrorMessage(status: number) {
  switch (status) {
    case 401: return "Please sign in again.";
    case 403: return "You do not have permission to view the data requested.";
    default:  return "There was an error saving or retrieving data.";
  }
}

export async function checkStatus(response: Response) {
  if (response.ok) return response;              // 2xx → pass through
  const httpError = {
    status: response.status, statusText: response.statusText,
    url: response.url, body: await response.text(),
  };
  console.log(`http error status: ${JSON.stringify(httpError, null, 1)}`);
  throw new Error(translateStatusToErrorMessage(httpError.status));
}

export function parseJSON(response: Response) {
  return response.json();
}
```

- **`checkStatus`** returns the response if `ok`, otherwise logs the detail and
  **throws** a friendly `Error` (the message a toast will show). This is the single
  place error text is decided.
- **`parseJSON`** parses the body — only reached for good responses.

Every API method chains these, so errors are consistent everywhere:

```diff title="src/menuItems/MenuItemAPI.ts"
+ import { BASE_URL, checkStatus, parseJSON } from "../utility/fetchUtilities";

- const url = "http://localhost:5556/api/menuitems";
+ const url = `${BASE_URL}/menuitems`;

  export const menuItemAPI = {
    list(): Promise<IMenuItem[]> {
-     return fetch(url).then((response) => response.json());
+     return fetch(url).then(checkStatus).then(parseJSON);
    },
    ...  // find, post, put: the identical change — end each with .then(checkStatus).then(parseJSON)
    delete(id: number) {
-     return fetch(`${url}/${id}`, { method: "DELETE" });
+     return fetch(`${url}/${id}`, { method: "DELETE" }).then(checkStatus);   // no parseJSON — no body
    },
  };
```

Now a component doesn't inspect status codes — it just `try`s the call and `catch`es a
ready-made `Error`.

> **No `401` to chase in practice** — this course has no auth enforcement, so you won't
> hit 401/403 from the API. The messages exist for completeness; the `default`
> ("error saving or retrieving data") is what you'll actually see, e.g. when the API is
> down.

**Now retrofit every other module the same way.** `OrderAPI`, `OrderItemAPI`, `StaffAPI`, and
`CategoryAPI` were all written with plain `fetch` and a hardcoded URL. In each: import
`{ BASE_URL, checkStatus, parseJSON }`, change `const url` to `` `${BASE_URL}/orders` `` (etc.),
and chain `.then(checkStatus).then(parseJSON)` on every method (a bodiless `delete`/`put`
uses just `.then(checkStatus)`). The inline `if (!response.ok) throw` you wrote in Lesson 11's
`findByAccount` becomes a plain `.then(checkStatus)` too — that's the guard, now shared.

**Save and check**

- Every page still fetches and saves — you changed *how* errors surface, not the happy path.
- Console is clean.

---

## 4. ▶ Code along — Wiring toasts into CRUD

With `checkStatus` throwing and the `<Toaster />` mounted, every CRUD action follows one shape:
**`try` the API call → `toast.success` → (navigate/update); `catch` → `toast.error`.** Here you
finish that for Menu Items: the **List** catch swaps its `console.error` placeholder for a
toast, the form's **save** already has toasts (Lesson 7) and now they fire, and **Delete** is
new.

### List — swap the placeholder log for a toast

`loadMenuItems` (Lesson 4) catches errors with a `console.error` placeholder. Now that toasts
work, surface the error to the user instead (and import `toast`):

```diff title="src/menuItems/MenuItemsPage.tsx"
+ import toast from "react-hot-toast";
  ...
  async function loadMenuItems() {
    setLoading(true);
    try {
      const data = await menuItemAPI.list();
      setMenuItems(data);
    } catch (error: any) {
-     console.error(error);
+     toast.error(error.message, { duration: 6000 });
    } finally {
      setLoading(false);
    }
  }
```

### Create / Edit — already wired

`MenuItemForm`'s `save` (Lesson 7) already has this shape — `toast.error(error.message)` in the
`catch` (with a `return` to stay on the form) and `toast.success("Successfully saved.")` after
the save. It did nothing visible before; with the `<Toaster />` mounted (Lesson 11) and
`checkStatus` throwing a friendly `error.message` (§3), those toasts now fire. **No change
needed** — just confirm it's there.

### Delete — add it to the `MenuItemCard` ⋮ dropdown (built in Lesson 7)

Lesson 7 gave `MenuItemCard` a **⋮** dropdown with an **Edit** item; now add a **Delete** item
beside it. Like `StaffCard` (Lesson 6), give the card an **`onRemove`** prop so it can tell
`MenuItemsPage` to drop the deleted card, and import `toast` + `menuItemAPI`:

```diff title="src/menuItems/MenuItemCard.tsx"
+ import { menuItemAPI } from "./MenuItemAPI";
+ import toast from "react-hot-toast";
  ...  // Card, Dropdown, Link, IMenuItem, bootstrapIcons (Lesson 7)

  interface IMenuItemCardProps {
    menuItem: IMenuItem;
+   onRemove: (menuItem: IMenuItem) => void;
  }

- function MenuItemCard({ menuItem }: IMenuItemCardProps) {
+ function MenuItemCard({ menuItem, onRemove }: IMenuItemCardProps) {
    ...
        <Dropdown.Menu>
          <Dropdown.Item as={Link} to={`/menuitems/edit/${menuItem.id}`}>Edit</Dropdown.Item>
+         <Dropdown.Item as="a" href="#" onClick={async (event) => {
+           event.preventDefault();
+           if (confirm("Are you sure you want to delete this menu item?") && menuItem.id) {
+             await menuItemAPI.delete(menuItem.id);
+             onRemove(menuItem);                     // update parent state
+             toast.success("Successfully deleted.");
+           }
+         }}>Delete</Dropdown.Item>
        </Dropdown.Menu>
    ...
  }
```

`MenuItemsPage` passes `onRemove` as a `removeMenuItem` that filters the deleted item out of
state — exactly like `StaffPage`'s `removeStaff` from Lesson 6.

The `error.message` you toast is exactly the friendly string `checkStatus` threw — that
handshake between the utility and the `catch` is the whole point.

**Save and check**

- Save a valid menu item — a green **"Successfully saved."** toast.
- Delete one — **"Successfully deleted."**
- Stop the API and reload `/menuitems` — a **red error toast**, plus the `http error status`
  console log from `checkStatus`.

---

## 5. Verifying in the browser

You've checked each piece as you built it; this is the full pass. With your API running and
`npm run dev` up:

1. Save a valid menu item → a green **"Successfully saved."** toast; delete one → a
   **"Successfully deleted."** toast.
2. **Force an error:** stop the API (or change `BASE_URL` to a wrong port) and reload
   `/menuitems` — a red error toast appears and the **Console** logs the `http error
   status` detail from `checkStatus`. Restart the API and confirm it recovers.
3. In the create form, trigger a server rejection (e.g. a duplicate that violates a
   unique constraint) → the red toast shows the friendly message and you **stay on the
   form** (the `return` in `catch`).
4. Confirm toasts **auto-dismiss** and stack if you fire several quickly.
5. Console shows only the intentional `checkStatus` log on errors — otherwise clean.

---

## The General Pattern (what to take away)

- **Toasts** = user feedback: `toast.success` after a good action, `toast.error` in a
  `catch`. Mount one `<Toaster />` at the root.
- **`fetch` doesn't reject on 4xx/5xx** — a shared **`checkStatus`** throws a friendly
  `Error` on non-`ok`, so every API method (`.then(checkStatus).then(parseJSON)`) fails
  consistently.
- Components don't read status codes — they `try` the call and `catch` a ready-made
  `error.message` to toast.
- Every CRUD action is the same shape: try → success toast → proceed; catch → error
  toast.

On PRS you'll build the same `fetchUtilities.ts` (`BASE_URL`, `checkStatus`,
`parseJSON`) and toast every create/edit/delete across Users, Vendors, Products,
Requests, and RequestLines.

---

## Build Steps

1. Ensure `<Toaster />` is mounted in `App.tsx` (from Lesson 11).
2. Create `src/utility/fetchUtilities.ts` with `BASE_URL`, `translateStatusToErrorMessage`,
   `checkStatus` (throws on non-`ok`), and `parseJSON`.
3. Refactor `MenuItemAPI.ts` so every method chains `.then(checkStatus).then(parseJSON)`
   (delete just `.then(checkStatus)`), using `BASE_URL` for the URL.
4. **Repeat that retrofit across `OrderAPI`, `OrderItemAPI`, `StaffAPI`, and `CategoryAPI`** —
   `BASE_URL` + `.then(checkStatus).then(parseJSON)`; replace Lesson 11's inline
   `if (!response.ok) throw` in `findByAccount` with `.then(checkStatus)`.
5. Wire toasts: change `loadMenuItems`'s `console.error` to `toast.error(error.message)`; add
   a **Delete** item to `MenuItemCard` (with an `onRemove` prop + `toast.success`); the Lesson-7
   `save` toasts already fire (nothing to add there).
6. Verify in the browser using section 5 — success toasts, a forced error toast + the
   `checkStatus` console log, form stays on failure.
