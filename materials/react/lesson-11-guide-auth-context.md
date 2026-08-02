# Lesson 11 Guide — Sign In, localStorage, and Context

**Goal:** by the end of this lesson you have a working **Sign In** page that posts to
the login endpoint, stores the signed-in **Staff** object in **localStorage**, and
shares it across the whole app through **Context** — so the header shows the current
user, the nav/actions adapt to their role, and the **Cancel Order** button is disabled
when the signed-in staff member didn't take the order.

> **The guide is a worked example — the lab builds something different.** Sign In/Context
> is a *named exception* with no second TableServe entity to repeat it on, so you build it
> once here, alongside the instructor. It pairs conceptually with the Lesson 7 form (Sign In
> is a small react-hook-form) and completes the auth flow the whole app depends on. This
> lesson's **lab** then builds the **Order create/edit form** — the last missing CRUD
> screen — which *applies* the Context you build here.

**The general pattern you're learning:** there is **no JWT/token** in this app. Login
returns the Staff object as JSON; the front end strips the password, stores the rest in
**localStorage**, and puts it in **Context**. "Signed in" simply means *the context
value is not null*. Role flags on that object (`isManager`, `isAdmin`) drive conditional
UI — client-side only.

> **Security note — intentional simplification.** Everything here is client-side. The
> API endpoints are wide open (no `[Authorize]`, no tokens) by design for this course.
> Don't add JWT or server-side auth — the goal is understanding the *flow*, not
> production security. Passwords *are* bcrypt-hashed server-side (seed password:
> `test1234`).

> **How to use this guide.** Sections headed **▶ Code along** are ones you build into your
> project (each ends with a quick **Save and check**); unmarked sections are concept. Each
> code block carries its file name as a title bar.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`) with
> Staff seed data loaded — you need a real username/password to sign in (`test1234`).

---

## 1. What "signed in" means here

```
POST /api/staff/login  →  { id, username, firstName, lastName, isManager, isAdmin, … }
        strip password ─┐
                        ▼
   store the rest in localStorage  +  set it in Context
        signed in  = context value is not null
        signed out = context value is null / cleared
```

No token is issued or sent with later requests. The stored Staff object *is* the
session. Refreshing the page reads it back from localStorage so the user stays signed
in.

---

## 2. ▶ Code along — Context: sharing the user across the tree

*(Read this first — Context is the lesson's big new idea.)*

The signed-in staff member is needed **all over the tree**: the `Header` shows their name, the
nav hides admin-only links, the Order Detail page checks who took the order. Those components
are scattered, so passing the user **down as a prop** would mean threading it through every
component in between — even ones that don't use it. That's **prop-drilling**, and it gets
tedious and brittle fast.

**React Context** is the built-in fix: you wrap part of the component tree in a **Provider**
that holds a value, and any component inside — however deep — reads it **directly** with the
**`useContext`** hook, no props passed. Think of it as a value scoped to a branch of the tree
that all descendants can reach into. You'll make one context for the signed-in `staff` and
provide it at the very top (in `App`), so the whole app can read it. You'll build `App` and its
pieces first, then **wire them into the router at the end of this section** — so everything the
router references already exists and the edit compiles straight away.

Start with the **Context**, defined in `App.tsx`. Three pieces do the work: **`createContext`**
makes the context object; a **`Provider`** (added to `App` next) supplies the value; and
**`useContext`** reads it from the nearest Provider above. You'll wrap `useContext` in a small
**`useStaffContext()`** hook so components just call that. `App.tsx` has sat unused since
Lesson 5 — it still holds the Lesson-3 page render — so **select all and replace the whole
file** with this (the CSS imports come back with it):

```tsx title="src/App.tsx"
import "bootstrap/dist/css/bootstrap.min.css";   // back in App now (it left the tree in Lesson 5)
import "./App.css";
import { Outlet } from "react-router-dom";
import { createContext, useContext, useState } from "react";
import { Toaster } from "react-hot-toast";
import { IStaff } from "./staff/IStaff";

export interface StaffContextType {
  staff: IStaff | undefined;
  setStaff: React.Dispatch<React.SetStateAction<IStaff | undefined>>;
}

const StaffContext = createContext<StaffContextType | undefined>(undefined);

export function useStaffContext(): StaffContextType {
  const staffContext = useContext(StaffContext);
  if (staffContext === undefined) throw new Error("context not found");
  return staffContext;
}
```

- The `useStaffContext` wrapper **throws if used outside the Provider** — a friendly guard so a
  missing Provider fails loudly instead of silently returning `undefined`.
- The context holds the `staff` object **and** its `setStaff` setter, so any component can read
  *or* change who's signed in (Sign In sets it; Sign Out clears it).

### Providing the value (and reading localStorage on startup)

`App` holds the state and wraps the app in the provider. It **seeds state from
localStorage** so a refresh keeps you signed in. Add this **below** the context code you just
wrote, in the same file:

```diff title="src/App.tsx"
  ...  // the imports, StaffContextType, StaffContext, and useStaffContext from above

+ function getPersistedStaff() {
+   const staffAsJSON = localStorage.getItem("staff");
+   if (!staffAsJSON) return undefined;
+   return JSON.parse(staffAsJSON);
+ }
+
+ function App() {
+   const [staff, setStaff] = useState<IStaff | undefined>(getPersistedStaff());
+   return (
+     <StaffContext.Provider value={{ staff, setStaff }}>
+       <Toaster />
+       <Outlet />
+     </StaffContext.Provider>
+   );
+ }
+
+ export default App;
```

Everything under the provider (the whole app) can now call `useStaffContext()`.

**What's `<Toaster />` doing here?** It's react-hot-toast's **render target** — the one component
that actually draws toasts on screen. Every `toast.success(…)` / `toast.error(…)` call just adds
a message to the library's queue; without a `<Toaster />` mounted somewhere in the tree, that
queue has nowhere to render and **nothing appears**. You've been writing those calls since
Lesson 7 (the Menu Item form's save and error handlers, then Lessons 8–10) and seeing no
pop-ups — this is why. Mount it **once**, near the root, and every call anywhere in the app
renders through it. Lesson 12 is the full treatment: it themes this `<Toaster />` with
`toastOptions` and pairs it with centralized fetch error handling.

`App` is about to be back in the route tree, so its CSS imports run again — **take the two you
parked in `Layout` in Lesson 5 back out**, or every page loads Bootstrap twice:

```diff title="src/Layout.tsx"
- import "bootstrap/dist/css/bootstrap.min.css";
- import "./App.css";
  import Header from "./Header";
  import AppNav from "./AppNav";
  ...
```

### The index redirect

You'll wire an `index` route to an **`IndexPage`** that redirects by sign-in state — it needs
only the Context above, so build it now (at the app root):

```tsx title="src/IndexPage.tsx"
import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useStaffContext } from "./App";

function IndexPage() {
  const navigate = useNavigate();
  const { staff } = useStaffContext();
  useEffect(() => {
    if (!staff) navigate("/signin");
    else navigate("/orders");
  }, []);
  return null;
}

export default IndexPage;
```

The router you wire **next** imports `SignInPage`, which you build for real in §3. Add a
**one-line placeholder** now so that edit — and the app — compiles and runs:

```tsx title="src/account/SignInPage.tsx"
// Placeholder — you build the real Sign In form in §3.
function SignInPage() {
  return <h1>Sign In</h1>;
}

export default SignInPage;
```

With **`App`**, **`IndexPage`**, and the Sign In placeholder all in place, **wire them into the
router** — every element it references now exists, so the edit compiles straight away. In Lesson
5 the tree was rooted at `Layout` with a single `Outlet`; wrap that in an outer **`App` route**
so the Provider is live and **Sign In** can sit outside the shell:

```diff title="src/main.tsx"
  const router = createBrowserRouter([
+   {
+     path: "/",
+     element: <App />,             // outer wrapper — holds Context + Toaster
+     errorElement: <ErrorPage />,  // moved up here from the Layout route
+     children: [
+       { path: "signin", element: <SignInPage /> },   // sibling of Layout → no shell
        {
          element: <Layout />,
-         errorElement: <ErrorPage />,
          children: [
+           { index: true, element: <IndexPage /> },
            { path: "orders", element: <OrdersPage /> },
            { path: "menuitems", element: <MenuItemsPage /> },
            ...
          ],
        },
+     ],
+   },
  ]);
```

Now there are **two `Outlet`s**, each owned by a different route level: `App`'s `Outlet` holds
either `SignInPage` (no shell) or `Layout`; `Layout`'s `Outlet` holds the active page (with the
shell). `errorElement` moves up to the `App` route.

**Save and check**

- Open `/` signed out — `IndexPage` redirects you to **`/signin`**.
- The Sign In **placeholder** renders with **no header or nav** — it's outside `Layout`.
- Open `/orders` and `/menuitems` — both still load **inside the shell**.
- Console is clean — no **"context not found"** error.
- Edit a menu item and Save — the green **"Successfully saved."** toast finally appears. That's
  the Lesson 7 `toast.success` call, rendering for the first time now that `<Toaster />` exists.

*Not yet: the signed-**in** → `/orders` redirect — you'll see that in §3, once you can sign in.*

---

## 3. ▶ Code along — The Sign In page

Sign In sits **outside** the `Layout` (no header/nav) — the `signin` route you added to
the router in §2 is a **sibling** of the `Layout` route, so it renders in `App`'s `Outlet`
without the shell:

```tsx
{ path: "signin", element: <SignInPage /> },
```

Sign In needs a login call, so **add `findByAccount` to `StaffAPI` first** — the page you build
next calls it (plain `fetch` with an inline status guard until Lesson 12):

```diff title="src/staff/StaffAPI.ts"
  export const staffAPI = {
    ...  // list, find, post, put (earlier lessons)

+   findByAccount(username: string, password: string): Promise<IStaff> {
+     return fetch(`${url}/login`, {
+       method: "POST",
+       body: JSON.stringify({ username, password }),
+       headers: { "Content-Type": "application/json" },
+     }).then((response) => {
+       if (!response.ok) throw new Error("Login failed");   // wrong credentials → reject
+       return response.json();
+     });
+   },
  };
```

> **Why the explicit `if (!response.ok) throw`?** `fetch` only rejects on a network failure,
> **not** on a 400/401 — so without this check a wrong password would resolve, not throw, and
> the `signin` handler's `catch` would never run. You've now written this same guard in a few
> modules; **Lesson 12 extracts it** into a shared `checkStatus` helper and drops it into every
> API module at once.

Sign In is a **centered card on a soft gradient background** — and that gradient is the only
thing on the page Bootstrap has no utility for, so it's a custom class. Add it to `App.css`
next to the `.skeleton` rules from Lesson 6:

```diff title="src/App.css"
  .skeleton { /* … Lesson 6 … */ }
  .skeleton-text { /* … Lesson 6 … */ }

+ .signin {
+   min-height: 100vh;
+   background: radial-gradient(
+     ellipse at center,
+     rgba(255, 243, 230, 1) 0%,
+     rgba(255, 250, 245, 0.5) 70%,
+     rgba(255, 255, 255, 1) 100%
+   );
+ }
```

Now build the real **Sign In page** — a small react-hook-form (Lesson 7 pattern) inside that
card. **Replace the whole §2 placeholder file** with this. The logo `<svg>` is the same one
already converted for you in the Lesson-5 `Header` (note the JSX conversion: `viewBox` keeps its
camelCase, `width={100}` is a number in braces, and `xmlns` stays as-is):

```tsx title="src/account/SignInPage.tsx"
import { useForm, SubmitHandler } from "react-hook-form";
import { useNavigate } from "react-router-dom";
import toast from "react-hot-toast";
import { staffAPI } from "../staff/StaffAPI";
import { useStaffContext } from "../App";
import { IStaff } from "../staff/IStaff";

interface IAccount { username: string; password: string; }

function persistStaff(staff: IStaff) {
  localStorage.setItem("staff", JSON.stringify(staff));
}

function SignInPage() {
  const navigate = useNavigate();
  const { setStaff } = useStaffContext();
  const { register, handleSubmit, formState: { errors } } = useForm<IAccount>({
    defaultValues: async () => ({ username: "", password: "" }),
  });

  const signin: SubmitHandler<IAccount> = async (account) => {
    try {
      const { password: _, ...safeStaff } = await staffAPI.findByAccount(
        account.username, account.password
      );
      persistStaff(safeStaff as IStaff);   // localStorage
      setStaff(safeStaff as IStaff);        // context
      navigate("/orders");
    } catch (error: any) {
      toast.error("Unsuccessful sign in. Please try again.");
    }
  };

  return (
    <main className="signin d-flex flex-column gap-4 justify-content-center align-items-center">
      <svg width={100} height={78} viewBox="0 0 78 32" fill="none"
        xmlns="http://www.w3.org/2000/svg">
        <path d="M55.5 0H77.5L58.5 32H36.5L55.5 0Z" fill="#FF7A00" />
        <path d="M35.5 0H51.5L32.5 32H16.5L35.5 0Z" fill="#FF9736" />
        <path d="M19.5 0H31.5L12.5 32H0.5L19.5 0Z" fill="#FFBC7D" />
      </svg>
      <span className="mx-2 fw-semibold" style={{ color: "#FF7A00" }}>TableServe</span>

      <div className="card w-25 p-4">
        <h4 className="card-title">Sign in</h4>
        <form className="d-flex flex-column" onSubmit={handleSubmit(signin)}>
          <div className="mb-3">
            <label htmlFor="username" className="form-label">Username</label>
            <input id="username" type="text"
              {...register("username", { required: "Username is required" })}
              className={`form-control ${errors?.username && "is-invalid"}`} />
            <div className="invalid-feedback">{errors?.username?.message}</div>
          </div>
          <div className="mb-1">
            <label htmlFor="password" className="form-label">Password</label>
            <input id="password" type="password"
              {...register("password", { required: "Password is required" })}
              className={`form-control ${errors?.password && "is-invalid"}`} />
            <div className="invalid-feedback">{errors?.password?.message}</div>
          </div>
          <div className="mb-4 form-text">
            <a href="#">Forgot It?</a>
          </div>
          <div className="d-grid gap-2">
            <button className="btn btn-lg btn-primary">Sign in</button>
          </div>
        </form>
      </div>
    </main>
  );
}

export default SignInPage;
```

- **`const { password: _, ...safeStaff } = …`** — this is **destructuring** (the `{ }` is on the
  *left* of `=`, so you're pulling values *out* of the returned object, not building one). It
  **strips the password**: `password` is pulled off into a throwaway variable named `_` (a
  conventional "ignore this"), and the **rest element `...safeStaff`** gathers *everything else*
  into a **new object** — `safeStaff` is created right here, equal to the staff record **minus
  its password**. That safe copy is what you store; never store or display the password. (The
  `...rest` must come last — a JS syntax rule, not an override order.)
- `persistStaff` writes to localStorage; `setStaff` updates context; `navigate` goes to the
  app. A failed login toasts the error and stays put.
- The page shell is all Bootstrap you already know: `.signin` (your new gradient) plus flex
  utilities center the logo and card, and `d-grid` makes the button full-width. **Forgot It?**
  is a placeholder link — no functionality required.

**Save and check**

- Go to `/signin` — the **centered card** on the orange gradient, logo above it, and the real
  form in place of the §2 placeholder.
- Sign in with a seeded username and `test1234` — you land on **`/orders`**.
- Open **DevTools → Application → Local Storage** — a `staff` entry with **no `password` field**.
- Open `/` — `IndexPage` forwards you to **`/orders`** (you're signed in now).
- Enter a wrong password — the **error toast** shows and you stay on the page.

*Not yet: the signed-**out** → `/signin` branch — §4's **Sign out** gives you that (or clear the
`staff` entry by hand).*

---

## 4. ▶ Code along — The header: reading context and signing out

Extend the logo-only `Header` **provided in Lesson 5** to read the context: show the current
user in a react-bootstrap **`Dropdown`** (the same menu component as Lesson 6's 3-dots
actions) when signed in, or a **Sign in** button when signed out:

```diff title="src/Header.tsx"
- import { Link } from "react-router-dom";
+ import { Link, useNavigate } from "react-router-dom";
+ import Dropdown from "react-bootstrap/Dropdown";
+ import { useStaffContext } from "./App";

  function Header() {
+   const { staff, setStaff } = useStaffContext();
+   const navigate = useNavigate();
+
+   function signout() {
+     localStorage.removeItem("staff");   // clear storage
+     setStaff(undefined);                 // clear context → "signed out"
+     navigate("/signin");
+   }

    return (
      <header>
        <div className="navbar bg-body-tertiary py-4 border-bottom">
          <div className="container-fluid">
            ...  {/* the logo Link — provided in Lesson 5 */}
+           {staff ? (
+             <Dropdown className="me-4">
+               <Dropdown.Toggle as="a" variant="light"
+                 className="d-flex text-secondary align-items-center text-decoration-none">
+                 <div
+                   style={{ width: "3rem", height: "3rem" }}
+                   className="d-flex bg-primary-subtle fs-5 text-secondary align-items-center justify-content-center rounded-circle me-2"
+                 >
+                   {staff?.firstName.substring(0, 1)}{staff?.lastName.substring(0, 1)}
+                 </div>
+                 <strong> {staff?.firstName} {staff?.lastName}</strong>
+               </Dropdown.Toggle>
+               <Dropdown.Menu>
+                 <Dropdown.Item href="#">Settings</Dropdown.Item>
+                 <Dropdown.Item href="#">Profile</Dropdown.Item>
+                 <Dropdown.Divider />
+                 <Dropdown.Item as="button" onClick={signout}>Sign out</Dropdown.Item>
+               </Dropdown.Menu>
+             </Dropdown>
+           ) : (
+             <Link to="/signin" className="btn btn-primary">Sign in</Link>
+           )}
          </div>
        </div>
      </header>
    );
  }
```

`{staff ? (…user dropdown…) : (…Sign in button…)}` — the whole header adapts to whether
the context value is null. Sign Out clears both localStorage and context; the ternary
then flips to the Sign In button.

Two details in the toggle worth naming. **`as="a"`** renders the toggle as a link rather than
react-bootstrap's default `btn btn-primary` — you want the user's name, not a blue button. And
the **avatar circle** is a fixed-size flex box (`3rem` square, `rounded-circle`,
`bg-primary-subtle`) centering the two initials, which `substring(0, 1)` pulls off the first and
last name. *(Making that same avatar work on the **Staff cards** is a stretch challenge — the
card version is yours to solve.)*

**Save and check**

- Signed in — the header shows your **initials in a circle** beside your name, with a dropdown.
- Click **Sign out** — the header flips to the **Sign in** button, the `staff` entry disappears
  from Local Storage, and you land on `/signin`.

---

## 5. ▶ Code along — Role-based conditional UI

The role flags on the Staff object drive what the UI offers — the same conditional
rendering you've used all pass, keyed on `staff.isManager` / `staff.isAdmin`. TableServe's
rules, in full:

| Signed-in staff member | Can reach / do |
|---|---|
| **Anyone signed in** | The **Orders** nav link, order detail, and the workflow buttons; can **Cancel** an order **they took** |
| **`isManager`** | Additionally: **Cancel any order**, not just their own |
| **`isAdmin`** | Additionally: the three **maintenance** nav links — **Menu Items**, **Categories**, **Staff** |

Two different jobs, and it's worth seeing the split: **`isAdmin` gates navigation** (whole
screens disappear from the nav), while **`isManager` gates one action** on a screen everyone
can already see. That's the same split PRS uses — `isAdmin` hides the Vendors/Products/Users
maintenance pages, `isReviewer` controls the Approve/Reject buttons on a Request everyone can
open.

Start with the nav. In **`AppNav`**, read the context and wrap an admin-only item in
`{staff?.isAdmin && …}`. The guide wires **one** link — **Staff** — so you see the shape; the
**lab's stretch challenge** repeats the identical wrap on **Menu Items** and **Categories**
(and on those pages' Add/Edit buttons):

```diff title="src/AppNav.tsx"
+ import { useStaffContext } from "./App";
  ...
  function AppNav() {
    const location = useLocation();
+   const { staff } = useStaffContext();
    ...
    return (
      <Nav /* … */>
        ...  // Orders — visible to everyone
+       {staff?.isAdmin && (
          <Nav.Item as="li">
            <Nav.Link eventKey="/staff" as={Link} to="/staff">
              ...  // icon + "Staff"
            </Nav.Link>
          </Nav.Item>
+       )}
        ...
      </Nav>
    );
  }
```

### The Cancel ownership check

The headline role rule: **you can cancel an order you took — and a manager can cancel
anyone's.** Two conditions, one button. On the Order Detail page, read the context, compute
ownership, and add `disabled` to the **Cancel Order** button you built in Lesson 9:

```diff title="src/orders/OrderDetailPage.tsx"
  ...  // the Lesson 8–10 imports
+ import { useStaffContext } from "../App";

  function OrderDetailPage() {
+   const { staff } = useStaffContext();       // the signed-in user
    ...
+   const isOwnOrder = order?.staffId === staff?.id;
+   const canCancel = isOwnOrder || staff?.isManager;

    return (
      ...
        <button
          className="btn btn-outline-danger"
          onClick={openCancel}
+         disabled={!canCancel}
        >
          Cancel Order
        </button>
      ...
    );
  }
```

`disabled={!canCancel}` greys the button out unless the order's `staffId` matches the
signed-in staff's `id` **or** that staff member is a manager. Signed out, both are false, so
it's disabled.

This is the **same mechanism** PRS uses for Approve/Reject — compare the record's user id to
the signed-in user's, combine with a role flag — though watch the **polarity**: PRS *disables*
Approve/Reject on your **own** request (a reviewer can't approve their own spending), while
TableServe *enables* Cancel on your own order (you clean up your own mistakes). Same check,
opposite sign; the pattern transfers, the business rule doesn't.

**Save and check**

- Open a Preparing order **you took** — **Cancel Order** is enabled.
- Open one **someone else** took, signed in as a non-manager — **Cancel Order** is greyed out.
- Sign in as a **manager** and open that same order — **Cancel Order** is enabled again.
- The **Staff** nav link shows for an admin, and is gone for a non-admin.

---

## 6. Verifying in the browser

You've checked each piece as you built it; this is the full pass. With your API running and
`npm run dev` up:

1. Open the app signed out — you land on `/signin` (the index redirect). The header
   shows a **Sign in** button.
2. Sign in with a seeded username and `test1234`. You go to `/orders`; the header now
   shows the user's initials + name.
3. Open **DevTools → Application → Local Storage** — there's a `staff` entry with the
   user object **and no `password` field** (it was stripped). **Refresh the page** — you
   stay signed in (state seeded from localStorage).
4. Open a Preparing order **you took** — **Cancel Order** is enabled. Open one **someone
   else** took — it's **disabled**. Sign in as a **manager** and open that same order — it's
   enabled again.
5. Sign in as an admin vs. a non-admin and confirm the **Staff** nav link appears only for
   the admin.
6. Click **Sign out** — the header flips to **Sign in**, localStorage's `staff` is gone,
   and you're back at `/signin`.
7. Try a wrong password — the error toast shows and you stay on Sign In.

---

## The General Pattern (what to take away)

- **No JWT** — login returns the user object; strip the password, store the rest in
  **localStorage**, and put it in **Context**. Signed in = context value not null.
- **Context** (`createContext` + a `useStaffContext` hook + a `Provider` in `App`)
  shares the user across the tree without prop-drilling; seed it from localStorage so
  refresh persists.
- **Sign Out** clears localStorage *and* context.
- **Role flags drive conditional UI**, at two different scopes: one flag hides whole
  **screens** from the nav (`{staff?.isAdmin && …}`), the other gates a single **action** on a
  shared screen (`staff?.isManager`).
- An **ownership check** (`order.staffId === staff.id`) decides what you may do to *your own*
  records — combined with the role flag, not instead of it.

On PRS: login stores the User object the same way; `isAdmin` gates the maintenance pages
(Vendors, Products, Users); `isReviewer` gates Approve/Reject on a Request page anyone can
open; and the same ownership comparison appears again — there to **disable** Approve/Reject on
a reviewer's *own* request, the mirror image of this Cancel rule.

---

## Build Steps

1. **Replace all of `App.tsx`**: the CSS imports (Bootstrap + `App.css`, moved back from
   `Layout`), `StaffContext`, the `useStaffContext` hook, `getPersistedStaff` (reads
   localStorage), and an `App` that wraps `<Outlet />` in `<StaffContext.Provider>` seeded from
   localStorage — with **`<Toaster />`** mounted alongside the `Outlet`, which is what finally
   renders the `toast` calls you've written since Lesson 7. **Delete those same two CSS imports
   from `Layout.tsx`** so they don't load twice.
2. Build `IndexPage` (app root) — redirect by sign-in state (signed out → `/signin`, signed
   in → `/orders`) — and a one-line **`SignInPage` placeholder**, so everything the router will
   reference already exists.
3. **Now wire the router** in `main.tsx`: wrap the Lesson-5 tree in
   `{ path: "/", element: <App />, errorElement: <ErrorPage />, children: [...] }`, move
   `errorElement` up to it, add `signin` as a **sibling** of `Layout`, and an `index`
   route → `IndexPage` under `Layout`. Everything it references (`App`, `IndexPage`, the
   `SignInPage` placeholder) now exists, so it compiles.
4. Add `findByAccount(username, password)` to `StaffAPI.ts` (POST `/api/staff/login`).
5. Add the `.signin` gradient rule to `App.css`, then **replace the placeholder** `SignInPage`
   (outside `Layout`) with the real page — logo, centered card, and a react-hook-form that logs
   in, **strips the password** via destructuring, `persistStaff` + `setStaff`, then
   `navigate("/orders")`; error toast on failure.
6. Update `Header` to read context: user dropdown with an initials avatar + **Sign out**
   (clears localStorage + context) when signed in, else a **Sign in** `Link`.
7. Wrap the **Staff** nav item in `AppNav` in `{staff?.isAdmin && …}`, and on
   `OrderDetailPage` compute `canCancel = isOwnOrder || staff?.isManager` and set
   `disabled={!canCancel}` on **Cancel Order**.
8. Verify in the browser using section 6 — sign in/out, password-free localStorage,
   refresh persistence, the admin-only Staff link, and Cancel enabled for your own orders
   plus any order when you're a manager.
