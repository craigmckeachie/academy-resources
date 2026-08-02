# Lesson 15 Guide — Capstone Bridge: Building the PRS Front End

**This is the capstone bridge — there is no lab.** It's the hand-off from TableServe
(taught) to **PRS** (built independently). Everything you need is a pattern you've
already built; this lesson maps each PRS page to its TableServe twin, names every
exception explicitly, and sets expectations for the capstone. **This capstone is the
course's final project block** — you integrate the PRS backend (API pass) and the PRS
static markup (HTML/CSS pass) into a working React front end.

**Goal:** start the PRS capstone with a clear plan — knowing which TableServe page to
open as a reference for each PRS page, and knowing exactly which three things have no
reference at all.

> **The authoritative spec is the [PRS requirements](../specs/prs-requirements.md).** It defines every PRS field,
> route, workflow, and business rule. This bridge tells you *how* PRS maps to what you
> built; the requirements doc tells you *what* PRS must do. Keep both open.

---

## 1. The reference you already have

You don't start PRS from scratch. Three things are already done:

- **The PRS backend** (API pass) — Users, Vendors, Products, Requests (with
  `/review`, `/approve`, `/reject`), RequestLines. Verify it's green in Insomnia before
  you start the front end.
- **The PRS static markup** (HTML/CSS pass) — every PRS page as Bootstrap HTML. This is
  your **JSX conversion target**: rename `class`→`className`, `for`→`htmlFor`, wire
  `Link`/state/forms — the same conversion the TableServe React app is the finished example of.
- **The TableServe React app** (this pass) — your **pattern reference**. For every PRS
  page, open its TableServe twin and follow it.

The capstone is *integration*, not invention.

### Converting the static markup to JSX — use a helper

Renaming attributes by hand across every page is tedious and error-prone. Use the
**[HTML to JSX](https://marketplace.visualstudio.com/items?itemName=riazxrazor.html-to-jsx)**
VS Code extension: paste a chunk of your static HTML, run **HTML2JSX** from the command
palette, and it does the mechanical renames for you — `class`→`className`, `for`→`htmlFor`,
`stroke-width`→`strokeWidth` (and the rest of the camelCase SVG attributes), self-closing
tags, and `style="…"` → `style={{ … }}`.

Two things the tool **cannot** do — you finish these by hand:

- **The Bootstrap Icons sprite import.** The tool converts `<use href="…">` to
  `<use xlinkHref="…">`, but it can't turn the static `/assets/bootstrap-icons.svg` path
  into a module import. Add `import bootstrapIcons from "../assets/bootstrap-icons.svg";` at
  the top of the file and change each icon reference to
  ``<use xlinkHref={`${bootstrapIcons}#icon-id`} />`` — the same pattern you saw in
  TableServe's nav, cards, and buttons. (This is a build/module step, not a text rename.)
- **Interactive Bootstrap.** Dropdowns and modals that used `data-bs-toggle` in the static
  markup are **rebuilt as react-bootstrap** (`<Dropdown>`, `<Modal>` driven by React state),
  not machine-converted — exactly as you did on TableServe.

So the flow per page is: **paste HTML → HTML2JSX → fix the sprite imports → swap
`data-bs-*` widgets for react-bootstrap → wire `Link`, state, props, and forms.**

---

## 2. Page-by-page map (open the twin, build the PRS page)

| Build this PRS page | Open this TableServe page | Key pattern |
|---|---|---|
| App shell — `Layout`, `Header`, `AppNav` | the same three | `Outlet`, Context in the header, `isAdmin` nav gating — **but see below: you build these yourself** |
| `IndexPage` (`/` redirect) | `IndexPage` | redirect by sign-in state → `/signin` or `/requests` |
| `ErrorPage` | `ErrorPage` | `errorElement` on the root route |
| Sign In | Sign In | login → strip password → localStorage → Context |
| Users list | Staff list | card grid, conditional role label, skeleton |
| User form | Staff form | shared create/edit, **no FK**, role checkboxes |
| Vendors list + form | Categories | simple no-FK entity |
| Products list | Menu Items list | card grid, 3-dots |
| Product form | Menu Item form | shared create/edit, **Vendor FK dropdown** |
| Requests list | Orders list | **table**, status badges, **status filter** |
| Request Detail | Order Detail | `useParams`, workflow buttons, **Reject modal**, items table |
| Request Create/Edit | Order create/edit form | shared form with a **User FK** (like the Order form's Staff FK, pre-filled from Context and disabled); **Status disabled on create, editable on edit** — same as the Order form |
| RequestLine create/edit | Order Item form | **nested**, **derived Amount**, parent total |
| `utility/fetchUtilities.ts` | the same file | `BASE_URL` + `checkStatus`/`parseJSON` on every API module, `toast` in every `catch` |

Work in the order that unblocks the most: the **shell** first (every page renders inside it),
then Sign In + Context (everything needs the user), then the simple entities (Users, Vendors),
then Products (FK), then Requests and RequestLines (the workflow core).

### The shell is the one thing you were handed — now you build it

In Lesson 5 you were **given** `Header.tsx` and `AppNav.tsx`, finished, so the React lessons
could stay on React instead of markup conversion. That was a loan. On PRS you write them,
converting your own static `header` / `nav` partials from the HTML/CSS pass — **this is the
HTML→JSX moment the tool above exists for**, and the one place in the capstone where you're
typing something you never typed in TableServe.

Nothing about it is new, though: read the TableServe versions side by side with your static
partials and you'll see every piece. The two spots that need hand-finishing after HTML2JSX are
the ones named above — the **sprite import** for the nav icons, and rebuilding the header's
**user dropdown** as a react-bootstrap `<Dropdown>` rather than `data-bs-toggle`. Wire
`useStaffContext`'s PRS twin into the header for the signed-in name and Sign out, and gate the
maintenance nav links on `isAdmin`.

### One structural difference: PRS splits the list into its own component

Open the **Project Structure** section of the PRS requirements and you'll see a file TableServe
doesn't have — `ProductList.tsx`, `VendorList.tsx`, `UserList.tsx`, and for Requests the pair
`RequestTable.tsx` / `RequestRow.tsx`:

| | TableServe (what you built) | PRS (what the spec shows) |
|---|---|---|
| Fetch + hold state | `MenuItemsPage` | `ProductsPage` |
| `.map()` the collection | `MenuItemsPage` — same file | `ProductList` — its own component |
| Render one item | `MenuItemCard` | `ProductCard` |

**No new concept — it's one more props hand-off.** The page still fetches and owns state; it
passes the array down (`<ProductList products={products} onRemove={removeProduct} />`) and the
list does the `.map()`. Exactly the extraction you did in Lesson 5 when `MenuItemCard` came out
of `MenuItemsPage`, one level up.

**Follow the spec** — build the `List` component. It's what the PRS requirements describe, and
splitting fetch-and-state from rendering is the more common shape in real codebases. If you'd
rather keep the page-owns-everything shape you know, that works too and nothing downstream
breaks; just be consistent across all five entities rather than mixing.

---

## 3. The three named exceptions — no TableServe rehearsal

These have **no TableServe equivalent**. Expect to solve them fresh, on PRS:

### 3a. Dual-role user on Request

A Request relates to a User **twice** conceptually: the **submitter** (`UserId`, a real FK)
and the **reviewer** (any user with `IsReviewer` who acts on it). There is **one FK only** —
no `ReviewerId` column exists, and you don't need one; the second role comes from the flag on
`User`. TableServe's Order had a single `staffId` and no second role, so nothing rehearsed
this. In the UI it surfaces as: the request shows its submitter, and *reviewers* — anyone but
the submitter — get the Approve/Reject actions.

### 3b. $50 auto-approve rule

When a request is sent for review, **if its total is ≤ $50 the backend auto-approves it**
(status jumps straight to `APPROVED`, skipping the review queue). Your **Send for
Review** button just calls `PUT /api/requests/{id}/review`; the *backend* decides review
vs. auto-approve. So after the call, **re-fetch and navigate** — the request may already
be Approved. TableServe's linear workflow had no such branch. Don't implement the rule
in React — the API owns it; just don't assume the status became `REVIEW`.

### 3c. Avatar-circle-with-initials on User cards

PRS's User cards show a circular avatar with the user's initials. This was a **stretch
challenge** on Staff cards, deliberately not spelled out — the technique is a fixed-size
`d-flex` box that centers its text with `rounded-circle` (the Header's avatar shows it).
Build it yourself on the User card.

---

## 4. Workflow translation: Cancel → Reject

The Order **Cancel modal** (Lesson 9) is the direct rehearsal for the Request **Reject
modal** — the one workflow piece worth spelling out because the words differ:

| TableServe (Cancel) | PRS (Reject) |
|---|---|
| `btn-outline-danger` "Cancel Order" opens a modal | "Reject" opens a modal |
| required `cancellationReason` textarea | required `rejectionReason` textarea |
| `PUT /orders/{id}/cancel`, **plain string** body | `PUT /requests/{id}/reject`, **plain string** body |
| status → `CANCELLED`, re-fetch | status → `REJECTED`, navigate to `/requests` |

The other workflow buttons map cleanly too:

| PRS status | Buttons | TableServe analog |
|---|---|---|
| `NEW` | Send for Review | Start Preparing (advance) |
| `REVIEW` | Approve + Reject (disabled on your own request) | Mark Ready + Cancel |
| `APPROVED` / `REJECTED` | *(none — terminal)* | Served / Cancelled |

The **ownership check** is the same question in both apps — *"is this record mine?"*, asked by
comparing two ids — but the answer is **used for opposite purposes**, so don't copy the line
without reading it:

```tsx
// TableServe — owning the order ENABLES Cancel (and a manager may cancel anyone's)
disabled={!(order.staffId === staff?.id || staff?.isManager)}

// PRS — owning the request DISABLES Approve/Reject (and only reviewers get them at all)
disabled={request.userId === user?.id || !user?.isReviewer}
```

Same `===` on the same two ids in both; what flips is whether a match turns the button **on**
or **off**. The business rules explain why: you clean up **your own** orders, but you don't
approve **your own** spending. Note the role flag changes too — PRS gates these buttons on
`isReviewer` where TableServe gates Cancel on `isManager`.

---

## 5. Entity and field cheat-sheet

Same patterns, renamed:

```
Staff       → Users        (isManager→isReviewer, isAdmin→isAdmin)
Categories  → Vendors      (name/sortOrder → code/name/address/city/state/zip/phone/email)
MenuItems   → Products     (name/price/categoryId → partNumber/name/price/unit/vendorId)
Orders      → Requests     (tableNumber/notes/status → description/justification/deliveryMode/status)
OrderItems  → RequestLines (menuItemId/quantity/notes → productId/quantity)  [no Notes on RequestLine]
```

The *form pattern* never changes — only which fields you `register`. Check the
[PRS requirements → Data Model](../specs/prs-requirements.md#data-model) for each entity's
exact fields, and the [required validations](../specs/prs-requirements.md#required-validations)
table for every rule and message.

---

## 6. Expectations for the capstone

- **Regular instructor direction, not hands-on** — you drive; the instructor unblocks.
- **No new concepts** — if you reach for something you didn't build in TableServe (other
  than the three exceptions), stop and find the TableServe precedent first.
- **Integrate, verify in the browser** — wire the PRS static markup into React,
  fetching from your PRS API. Confirm each page in the browser (DevTools/Console/Network),
  the same way you verified TableServe.
- **Definition of done:** every PRS page works — sign in, all CRUD, the request workflow
  end to end (including auto-approve and reject-with-reason), role-gated UI, and the
  ownership check — with clean Console and correct status codes in Network.
- **…and every failure is visible.** Build `fetchUtilities.ts` on PRS the way you did on
  TableServe, and toast in every `catch`. Stop the API, load each list page, and confirm you
  get a **red toast** rather than a blank screen — a page that fails silently isn't done.

---

## The General Pattern (what to take away)

- The PRS capstone = **your PRS backend + your PRS static markup + the TableServe React
  patterns**, integrated. Open the TableServe twin for every page.
- **Everything maps** except the **three named exceptions** (dual-role user, $50
  auto-approve, avatar initials) — meet those fresh, on PRS.
- **Cancel → Reject** is the one workflow translation to keep straight; the rest is
  renamed entities and fields.
- The [PRS requirements](../specs/prs-requirements.md) are authoritative for *what*;
  TableServe is your reference for *how*.

Build PRS the way you built TableServe — one feature folder at a time, verified in the
browser. You've already done every part of it once.

> **One lesson left before you start.** [Lesson 16](lesson-16-guide-building-with-copilot.md)
> is a tooling lesson on **building with GitHub Copilot** — autocomplete → Chat → agent mode,
> and how to audit generated code against this project's conventions. It's deliberately last:
> you now have a complete, hand-built app to judge Copilot's output against, and a capstone
> ahead where the temptation to let it write whole features is real. It also pairs with a
> **capstone stretch goal** — build one PRS feature in agent mode against a review rubric.
