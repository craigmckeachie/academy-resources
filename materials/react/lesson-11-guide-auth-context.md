# Lesson 11 Guide — Sign In, localStorage, and Context

**Goal:** by the end of this lesson you have a working **Sign In** page that posts to
the login endpoint, stores the signed-in **Staff** object in **localStorage**, and
shares it across the whole app through **Context** — so the header shows the current
user, the nav/actions adapt to their role, and the **Cancel Order** button is disabled
when the signed-in staff member didn't take the order.

> **This is a worked-example lesson — there is no paired lab.** It pairs conceptually
> with the Lesson 7 form (Sign In is a small react-hook-form) and completes the auth
> flow the whole app depends on. You build it once, here, alongside the instructor.

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
provide it at the very top (in `App`), so the whole app can read it — which is why the router
gains an `App` root first.

Two Lesson-5 threads come together here. First, the router gains an **outer `App`
route** — the app-wide wrapper that holds Context (this lesson) and Toasts (Lesson 12)
and lets the **Sign In** page live outside the shell (§3). In Lesson 5 the route tree was
rooted at `Layout` with a single `Outlet`; wrap that in an `App` route now:

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

Now there are **two `Outlet`s**, each owned by a different route level: `App`'s `Outlet`
holds either `SignInPage` (no shell) or `Layout`; `Layout`'s `Outlet` holds the active
page (with the shell). `errorElement` moves up to the `App` route, and `App.tsx` imports
Bootstrap's CSS again (it lived in `Layout` only while `App` was out of the tree).

That wrapper's real payoff is **Context**. Three pieces do the work: **`createContext`** makes
the context object; a **`Provider`** (added to `App` next) supplies the value; and
**`useContext`** reads it from the nearest Provider above. You'll wrap `useContext` in a small
**`useStaffContext()`** hook so components just call that. Define it in `App.tsx`:

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
localStorage** so a refresh keeps you signed in:

```tsx title="src/App.tsx"
function getPersistedStaff() {
  const staffAsJSON = localStorage.getItem("staff");
  if (!staffAsJSON) return undefined;
  return JSON.parse(staffAsJSON);
}

function App() {
  const [staff, setStaff] = useState<IStaff | undefined>(getPersistedStaff());
  return (
    <StaffContext.Provider value={{ staff, setStaff }}>
      <Toaster /* … */ />
      <Outlet />
    </StaffContext.Provider>
  );
}

export default App;
```

Everything under the provider (the whole app) can now call `useStaffContext()`.

### The index redirect

The `index` route you just added points to an **`IndexPage`** that redirects by sign-in state —
it needs only the Context you set up above, so build it now (at the app root):

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

**Save and check:** open `/` — `IndexPage` redirects you (signed out → `/signin`, signed in →
`/orders`), and any page route still loads with a clean console and no "context not found"
errors. The **`signin`** route stays blank until you build `SignInPage` in the next section.

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

Now the **Sign In page** — a small react-hook-form (Lesson 7 pattern) that logs in on submit.
The outer centered card and logo come from the **static Sign In page** (the HTML/CSS design); the
react-wired **form** is what's new here:

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
    <form className="d-flex flex-column" onSubmit={handleSubmit(signin)}>
      <div className="mb-3">
        <label htmlFor="username" className="form-label">Username</label>
        <input id="username" type="text"
          {...register("username", { required: "Username is required" })}
          className={`form-control ${errors?.username && "is-invalid"}`} />
        <div className="invalid-feedback">{errors?.username?.message}</div>
      </div>
      <div className="mb-3">
        <label htmlFor="password" className="form-label">Password</label>
        <input id="password" type="password"
          {...register("password", { required: "Password is required" })}
          className={`form-control ${errors?.password && "is-invalid"}`} />
        <div className="invalid-feedback">{errors?.password?.message}</div>
      </div>
      <button className="btn btn-lg btn-primary">Sign in</button>
    </form>
  );
}

export default SignInPage;
```

- **`const { password: _, ...safeStaff } = …`** — object destructuring that **strips the
  password**: `password` is pulled off into `_` (unused), `...safeStaff` is everything else.
  Never store or display the password.
- `persistStaff` writes to localStorage; `setStaff` updates context; `navigate` goes to the
  app. A failed login toasts the error and stays put.

**Save and check:** go to `/signin` → the form renders (no shell — it's outside `Layout`).
Sign in with a seeded username and `test1234` → you land on `/orders`. In **DevTools →
Application → Local Storage** there's a `staff` entry **with no `password` field**. A wrong
password shows the error toast and keeps you on the page.

---

## 4. ▶ Code along — The header: reading context and signing out

The logo-only `Header` **provided in Lesson 5** now reads the context — showing the current
user in a react-bootstrap **`Dropdown`** (the same menu component as Lesson 6's 3-dots
actions), or a **Sign in** button when signed out. Extend it:

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
+             <Dropdown>
+               <Dropdown.Toggle /* avatar with initials + name */>
+                 {staff?.firstName.substring(0, 1)}{staff?.lastName.substring(0, 1)}
+                 <strong> {staff?.firstName} {staff?.lastName}</strong>
+               </Dropdown.Toggle>
+               <Dropdown.Menu>
+                 <Dropdown.Item href="#">Settings</Dropdown.Item>
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

**Save and check:** signed in, the header shows the user's initials + name with a dropdown;
**Sign out** flips it back to the **Sign in** button, clears the `staff` entry in Local
Storage, and returns you to `/signin`.

---

## 5. ▶ Code along — Role-based conditional UI

The role flags on the Staff object drive what the UI offers — the same conditional
rendering you've used all pass, keyed on `staff.isManager` / `staff.isAdmin`:

- Show admin-only nav/pages when `staff?.isAdmin`.
- Show manager-only actions when `staff?.isManager`.

For example, in **`AppNav`** read the context and wrap an admin-only nav item in
`{staff?.isAdmin && …}` — here the **Staff** link (the same wrap goes on Menu and Categories,
which is the lab's role-gating stretch):

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

The plan's headline role rule: **the Cancel Order button is disabled when the
signed-in staff member didn't take the order** — you can't cancel someone else's order.
On the Order Detail page, read the context (import `useStaffContext` from `../App`), compute
ownership, and add `disabled` to the **Cancel Order** button you built in Lesson 9:

```diff title="src/orders/OrderDetailPage.tsx"
  function OrderDetailPage() {
+   const { staff } = useStaffContext();       // the signed-in user
    ...
+   const isOwnOrder = order?.staffId === staff?.id;

    return (
      ...
        <button
          className="btn btn-outline-danger"
          onClick={openCancel}
+         disabled={!isOwnOrder}
        >
          Cancel Order
        </button>
      ...
    );
  }
```

`disabled={!isOwnOrder}` greys the button out unless the order's `staffId` matches the
signed-in staff's `id`. This **mirrors PRS's ownership rule exactly** — there, a
Reviewer may not Approve or Reject *their own* request, so those buttons are disabled
when `request.userId === currentUser.id`.

**Save and check:** open a Preparing order **you took** (matching `staffId`) → **Cancel
Order** is enabled; open one **someone else** took → it's greyed out. If you gated the Staff
nav on `isAdmin`, it appears only when you're signed in as an admin.

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
4. Open an order **you took** (matching `staffId`) at Preparing — **Cancel Order** is
   enabled. Open one **someone else** took — it's **disabled**.
5. If you wired admin-only nav, sign in as an admin vs. a non-admin and confirm the
   Staff link appears only for the admin.
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
- **Role flags drive conditional UI** (`{staff?.isAdmin && …}`), and an **ownership
  check** (`order.staffId === staff.id`) disables actions on records the user doesn't
  own.

On PRS: login stores the User object the same way; `isAdmin` gates the maintenance
pages; `isReviewer` gates Approve/Reject; and the **ownership check** disables
Approve/Reject on a reviewer's *own* request — the direct analog of this Cancel check.

---

## Build Steps

1. In `main.tsx`, bring `App` back as the route root: wrap the Lesson-5 tree in
   `{ path: "/", element: <App />, errorElement: <ErrorPage />, children: [...] }`, move
   `errorElement` up to it, add `signin` as a **sibling** of `Layout`, and an `index`
   route → `IndexPage` under `Layout`.
2. In `App.tsx`, create `StaffContext`, the `useStaffContext` hook, `getPersistedStaff`
   (reads localStorage), import Bootstrap's CSS, and wrap `<Outlet />` in
   `<StaffContext.Provider>` seeded from localStorage.
3. Build `IndexPage` (app root) — redirect by sign-in state (signed out → `/signin`, signed
   in → `/orders`); it's the target of the `index` route from step 1.
4. Add `findByAccount(username, password)` to `StaffAPI.ts` (POST `/api/staff/login`).
5. Build `SignInPage` (outside `Layout`): a react-hook-form that logs in, **strips the
   password** via destructuring, `persistStaff` + `setStaff`, then `navigate("/orders")`;
   error toast on failure.
6. Update `Header` to read context: user dropdown with initials + **Sign out**
   (clears localStorage + context) when signed in, else a **Sign in** `Link`.
7. Add role-based conditional UI, and on `OrderDetailPage` set
   `disabled={order?.staffId !== staff?.id}` on **Cancel Order**.
8. Verify in the browser using section 6 — sign in/out, password-free localStorage,
   refresh persistence, and the ownership-disabled Cancel button.
