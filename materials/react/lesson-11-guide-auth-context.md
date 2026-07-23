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

## 2. Context — sharing the user across the tree

Two Lesson-5 threads come together here. First, the router gains an **outer `App`
route** — the app-wide wrapper that holds Context (this lesson) and Toasts (Lesson 12)
and lets the **Sign In** page live outside the shell (§3). In Lesson 5 the route tree was
rooted at `Layout` with a single `Outlet`; wrap that in an `App` route now:

```tsx
// main.tsx — App becomes the root; Layout nests inside it
const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    errorElement: <ErrorPage />,
    children: [
      { path: "signin", element: <SignInPage /> },   // sibling of Layout → no shell
      {
        element: <Layout />,
        children: [
          { index: true, element: <IndexPage /> },
          { path: "orders", element: <OrdersPage /> },
          { path: "menuitems", element: <MenuItemsPage /> },
          // …the rest of the page routes
        ],
      },
    ],
  },
]);
```

Now there are **two `Outlet`s**, each owned by a different route level: `App`'s `Outlet`
holds either `SignInPage` (no shell) or `Layout`; `Layout`'s `Outlet` holds the active
page (with the shell). `errorElement` moves up to the `App` route, and `App.tsx` imports
Bootstrap's CSS again (it lived in `Layout` only while `App` was out of the tree).

That wrapper's real payoff is **Context**. Passing the current user as a prop through
every component would be painful; Context lets any component read a shared value directly.
Define it in `App.tsx`:

```tsx
import { createContext, useContext, useState } from "react";
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

- `createContext` makes the context; `useContext` reads it. The `useStaffContext`
  wrapper throws if used outside the provider — a friendly guard.
- The context holds the `staff` object **and** its `setStaff` setter, so any component
  can read *or* change who's signed in (Sign In sets it; Sign Out clears it).

### Providing the value (and reading localStorage on startup)

`App` holds the state and wraps the app in the provider. It **seeds state from
localStorage** so a refresh keeps you signed in:

```tsx
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
```

Everything under the provider (the whole app) can now call `useStaffContext()`.

---

## 3. The Sign In page

Sign In sits **outside** the `Layout` (no header/nav) — the `signin` route you added to
the router in §2 is a **sibling** of the `Layout` route, so it renders in `App`'s `Outlet`
without the shell:

```tsx
{ path: "signin", element: <SignInPage /> },
```

It's a small react-hook-form (Lesson 7 pattern) that logs in on submit:

```tsx
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
  // … username + password inputs, Sign in button (see the static Sign In page)
}
```

- `staffAPI.findByAccount` POSTs `{ username, password }` to `/api/staff/login` and
  returns the full Staff object (password included).
- **`const { password: _, ...safeStaff } = …`** — object destructuring that **strips
  the password**: `password` is pulled off into `_` (unused), and `...safeStaff` is
  everything else. Never store or display the password.
- `persistStaff` writes to localStorage; `setStaff` updates context; `navigate` goes to
  the app. A failed login toasts an error and stays put.

```ts
findByAccount(username: string, password: string): Promise<IStaff> {
  return fetch(`${url}/login`, {
    method: "POST",
    body: JSON.stringify({ username, password }),
    headers: { "Content-Type": "application/json" },
  }).then(checkStatus).then(parseJSON);
},
```

---

## 4. The header — reading context and signing out

The `Header` reads the context to show the current user, or a Sign In button when
signed out:

```tsx
function Header() {
  const { staff, setStaff } = useStaffContext();
  const navigate = useNavigate();

  function signout() {
    localStorage.removeItem("staff");   // clear storage
    setStaff(undefined);                 // clear context → "signed out"
    navigate("/signin");
  }

  return (
    <header>
      {/* … logo … */}
      {staff ? (
        <Dropdown>
          <Dropdown.Toggle /* avatar with initials + name */>
            {staff?.firstName.substring(0, 1)}{staff?.lastName.substring(0, 1)}
            <strong> {staff?.firstName} {staff?.lastName}</strong>
          </Dropdown.Toggle>
          <Dropdown.Menu>
            <Dropdown.Item href="#">Settings</Dropdown.Item>
            <Dropdown.Divider />
            <Dropdown.Item as="button" onClick={signout}>Sign out</Dropdown.Item>
          </Dropdown.Menu>
        </Dropdown>
      ) : (
        <Link to="/signin" className="btn btn-primary">Sign in</Link>
      )}
    </header>
  );
}
```

`{staff ? (…user dropdown…) : (…Sign in button…)}` — the whole header adapts to whether
the context value is null. Sign Out clears both localStorage and context; the ternary
then flips to the Sign In button.

### Redirecting based on sign-in state

The index route redirects by context: signed out → `/signin`, signed in → `/orders`:

```tsx
function IndexPage() {
  const navigate = useNavigate();
  const { staff } = useStaffContext();
  useEffect(() => {
    if (!staff) navigate("/signin");
    else navigate("/orders");
  }, []);
  return null;
}
```

---

## 5. Role-based conditional UI

The role flags on the Staff object drive what the UI offers — the same conditional
rendering you've used all pass, keyed on `staff.isManager` / `staff.isAdmin`:

- Show admin-only nav/pages when `staff?.isAdmin`.
- Show manager-only actions when `staff?.isManager`.

```tsx
{staff?.isAdmin && (
  <Nav.Link as={Link} to="/staff">Staff</Nav.Link>
)}
```

### The Cancel ownership check

The plan's headline role rule: **the Cancel Order button is disabled when the
signed-in staff member didn't take the order** — you can't cancel someone else's order.
On the Order Detail page, read the context and compare ids:

```tsx
const { staff } = useStaffContext();
const isOwnOrder = order?.staffId === staff?.id;

<button
  className="btn btn-outline-danger"
  onClick={handleShowCancelModal}
  disabled={!isOwnOrder}
>
  Cancel Order
</button>
```

`disabled={!isOwnOrder}` greys the button out unless the order's `staffId` matches the
signed-in staff's `id`. This **mirrors PRS's ownership rule exactly** — there, a
Reviewer may not Approve or Reject *their own* request, so those buttons are disabled
when `request.userId === currentUser.id`.

---

## 6. Verifying in the browser

Verify in the **browser**. With your API running and `npm run dev` up:

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
3. Add `findByAccount(username, password)` to `StaffAPI.ts` (POST `/api/staff/login`).
4. Build `SignInPage` (outside `Layout`): a react-hook-form that logs in, **strips the
   password** via destructuring, `persistStaff` + `setStaff`, then `navigate("/orders")`;
   error toast on failure.
5. Update `Header` to read context: user dropdown with initials + **Sign out**
   (clears localStorage + context) when signed in, else a **Sign in** `Link`.
6. Implement the `IndexPage` redirect by sign-in state (signed out → `/signin`, signed in
   → `/orders`).
7. Add role-based conditional UI, and on `OrderDetailPage` set
   `disabled={order?.staffId !== staff?.id}` on **Cancel Order**.
8. Verify in the browser using section 6 — sign in/out, password-free localStorage,
   refresh persistence, and the ownership-disabled Cancel button.
```
