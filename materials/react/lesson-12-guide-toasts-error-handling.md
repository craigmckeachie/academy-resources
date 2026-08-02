# Lesson 12 Guide — Toasts and Centralized Error Handling

**Goal:** by the end of this lesson every CRUD action gives the user clear feedback —
**success and error toasts** via `react-hot-toast` — and your API modules share **one
place** that turns a failed HTTP response into a thrown `Error` your components can
catch and toast. You'll retrofit the Menu Item CRUD (list/create/edit/delete) with this
feedback and the shared fetch helpers. (The `<Toaster />` that renders them went into `App` in
Lesson 11 — here you restyle its toasts in the app's orange and make the feedback systematic.)

**The general pattern you're learning:** a **toast** is a small, auto-dismissing
message for success/error feedback. You call `toast.success(...)` after a successful
action and `toast.error(...)` in a `catch`. Underneath, the API module runs every
response through a shared **`checkStatus`** that turns a non-2xx status into a message a
**user** can understand, while the technical detail goes to the console for the **developer**.
Feedback the user can act on, plus one place that decides how failures read, is the polish
that makes an app feel finished.

> **How to use this guide.** Sections headed **▶ Code along** are ones you build into your
> project (each ends with a quick **Save and check**); unmarked sections are concept. Each
> code block carries its file name as a title bar.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`), and
> you have the Menu Item CRUD (list/create/edit/delete) from Lessons 3–7.

> **This lesson pays off a running promise.** Since Lesson 6 your API modules have used
> plain `fetch` with a hardcoded URL and (in a couple of spots) an inline
> `if (!response.ok) throw` guard. Here you build the shared **`fetchUtilities`** once and
> retrofit every module to it. **The guide converts one — Menu Items — and the lab converts
> the rest of the app**, so expect to finish this guide with the app half-converted on purpose.

---

## 1. ▶ Code along — Restyling the toasts

`react-hot-toast` needs one `<Toaster />` mounted near the app root — you added it bare in
Lesson 11's `App.tsx`, which is why toasts started appearing there. Its toasts currently use
the library's stock look: a **green** success check. Pass **`toastOptions`** to restyle every
toast at once — TableServe orange, and a width cap so a long error message wraps instead of
stretching across the screen:

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

- **`success.iconTheme`** sets the checkmark's colors — `primary` is the check itself, `secondary`
  the shape behind it. There's an `error` key alongside `success` if you ever want to recolor
  that icon too.
- **`style`** is plain CSS applied to every toast, camelCased like any React `style` object
  (Lesson 3).

**That's the only edit in this section.** One thing to know before moving on: these are
defaults for *all* toasts, and any individual call can override them — the `{ duration: 6000 }`
you'll pass to a single `toast.error` in section 4 wins over what's set here. That's why the
`<Toaster />` is mounted once and never rendered by hand: you configure it here, and everywhere
else you just *call* toasts (next).

**Save and check**

- Save a menu item — the success toast's check is now **TableServe orange** instead of the
  default green.
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

- **`checkStatus`** returns the response if `ok`. If not, it **splits the failure between two
  audiences**: the raw status, URL, and response body go to the **console, for you** — that's
  what you need to debug — while the `Error` it throws carries a **plain-language sentence for
  the user**, who can't act on a 500 and shouldn't be shown one. This is the single place that
  wording is decided, which is why every screen fails in the same voice.
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
+   delete(id: number) {
+     return fetch(`${url}/${id}`, { method: "DELETE" }).then(checkStatus);   // no parseJSON — no body
+   },
  };
```

**`delete` is brand new here** — Lesson 7 built the Menu Item form and deferred deleting to
this lesson, so your module has had `list`, `find`, `post`, and `put` until now. It's also the
one method that ends at `checkStatus`: a `204 No Content` has no body, so there's nothing for
`parseJSON` to parse. Section 4 wires it to a **Delete** menu item.

Now a component doesn't inspect status codes at all — it `try`s the call and `catch`es an
error whose `message` is **already written for the user**, so it can go straight into a toast
without translation.

> **No `401` to chase in practice** — this course has no auth enforcement, so you won't
> hit 401/403 from the API. The messages exist for completeness; the `default`
> ("error saving or retrieving data") is what you'll actually see, e.g. when the API is
> down.

!!! warning "Your turn — the other four modules are the lab"

    You've converted **one** module. `OrderAPI`, `OrderItemAPI`, `CategoryAPI`, and `StaffAPI`
    are all still on plain `fetch` with a hardcoded URL — **this lesson's lab converts every
    one of them**, using the same three edits you just made.

    So the app is deliberately **half-converted** when this guide ends. That's not a bug to
    chase: an unconverted module still works on the happy path, it just fails silently. The lab
    is where the app becomes consistent.

**Save and check**

- The Menu Items pages still load and save — you changed *how* a failure surfaces, not the
  happy path.
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
+             try {
+               await menuItemAPI.delete(menuItem.id);
+               onRemove(menuItem);                     // update parent state
+               toast.success("Successfully deleted.");
+             } catch (error: any) {
+               toast.error(error.message, { duration: 6000 });
+             }
+           }
+         }}>Delete</Dropdown.Item>
        </Dropdown.Menu>
    ...
  }
```

The `try`/`catch` matters here: now that `delete` runs through `checkStatus`, a failed DELETE
**throws**. Without the `catch` you'd get an unhandled rejection in the console and — worse —
`onRemove` would never run, or would run on a delete that didn't happen. Inside the `try`,
the card only leaves the list once the server confirms.

`onRemove` is a **required** prop, so `MenuItemsPage` won't compile until it passes one. Add
the remover and hand it down — exactly like `StaffPage`'s `removeStaff` from Lesson 6:

```diff title="src/menuItems/MenuItemsPage.tsx"
  function MenuItemsPage() {
    ...  // menuItems/loading state, loadMenuItems, useEffect

+   function removeMenuItem(deleted: IMenuItem) {
+     setMenuItems(menuItems.filter((menuItem) => menuItem.id !== deleted.id));
+   }
+
    return (
      ...
        {menuItems.map((menuItem) => (
-         <MenuItemCard key={menuItem.id} menuItem={menuItem} />
+         <MenuItemCard key={menuItem.id} menuItem={menuItem} onRemove={removeMenuItem} />
        ))}
      ...
    );
  }
```

Deleting updates state locally rather than re-fetching the list — one round trip, not two.

The `error.message` you toast is the sentence `checkStatus` wrote for the user — *"There was an
error saving or retrieving data."*, never `500 Internal Server Error` or a stack trace. The
status code, URL, and response body are already in the console for you. That division of labour
— **the user gets a message they can act on, the developer gets the detail** — is the whole
point of routing every call through one helper.

**Save and check**

- Save a valid menu item — a green **"Successfully saved."** toast.
- Delete one — confirm the dialog, the card **disappears from the grid**, and
  **"Successfully deleted."** shows.
- Stop the API and reload `/menuitems` — a **red error toast**, plus the `http error status`
  console log from `checkStatus`.

That's Menu Items finished, end to end.

!!! warning "Your turn — the other screens are the lab too"

    Section 3 made every API call throw on failure, so a screen whose fetch has no `catch` now
    fails **silently**. Menu Items is handled (above); **the lab takes the rest** — the Staff
    screens, plus the two still missing a `catch`.

    One thing to know before you go looking: not every `console.error` is a bug. `ErrorPage`'s
    (Lesson 5) is the **router's error boundary**, not a fetch `catch` — logging for the
    developer while the page shows the user "Oops!" is exactly the split you want. Leave that
    one alone.

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
- **`fetch` doesn't reject on 4xx/5xx** — a shared **`checkStatus`** throws on non-`ok`, so
  every API method (`.then(checkStatus).then(parseJSON)`) fails consistently.
- **Two audiences, one failure.** Technical detail (status, URL, body) goes to the **console
  for the developer**; the thrown `Error` carries a **plain-language message for the user**.
  Deciding that wording in one helper is what keeps the whole app failing in the same voice.
- Components don't read status codes — they `try` the call and toast `error.message` as-is,
  because it was written for the person reading it.
- Every CRUD action is the same shape: try → success toast → proceed; catch → error
  toast.

On PRS you'll build the same `fetchUtilities.ts` (`BASE_URL`, `checkStatus`,
`parseJSON`) and toast every create/edit/delete across Users, Vendors, Products,
Requests, and RequestLines.

---

## Build Steps

1. Pass `toastOptions` to the `<Toaster />` in `App.tsx` (mounted in Lesson 11) so every toast
   picks up the app's colors — an orange success check and a max width.
2. Create `src/utility/fetchUtilities.ts` with `BASE_URL`, `translateStatusToErrorMessage`,
   `checkStatus` (throws on non-`ok`), and `parseJSON`.
3. Refactor `MenuItemAPI.ts` so every method chains `.then(checkStatus).then(parseJSON)`,
   using `BASE_URL` for the URL — and **add the new `delete(id)`** method, which ends at
   `.then(checkStatus)` (no body to parse).
4. Wire toasts: change `loadMenuItems`'s `console.error` to `toast.error(error.message)`; add
   a **Delete** item to `MenuItemCard` (an `onRemove` prop, a `try`/`catch`, and success/error
   toasts), and give `MenuItemsPage` a `removeMenuItem` to pass as that prop; the Lesson-7
   `save` toasts already fire (nothing to add there).
5. Verify in the browser using section 5 — success toasts, a forced error toast + the
   `checkStatus` console log, form stays on failure.

**Then the lab**, which converts every other API module and screen so the whole app fails the
same way. The guide stops at Menu Items on purpose.
