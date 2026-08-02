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

> **The authoritative spec is `specs/prs-requirements.md`.** It defines every PRS field,
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
| Sign In | Sign In | login → strip password → localStorage → Context |
| Users list | Staff list | card grid, conditional role label, skeleton |
| User form | Staff form | shared create/edit, **no FK**, role checkboxes |
| Vendors list + form | Categories | simple no-FK entity |
| Products list | Menu Items list | card grid, 3-dots |
| Product form | Menu Item form | shared create/edit, **Vendor FK dropdown** |
| Requests list | Orders list | **table**, status badges, **status filter** |
| Request Detail | Order Detail | `useParams`, workflow buttons, **Reject modal**, items table |
| Request Create/Edit | Order create/edit form | shared form with a **User FK** (like the Order form's Staff FK, pre-filled from Context); status set by the workflow, not the form |
| RequestLine create/edit | Order Item form | **nested**, **derived Amount**, parent total |

Work in the order that unblocks the most: Sign In + Context first (everything needs the
user), then the simple entities (Users, Vendors), then Products (FK), then Requests and
RequestLines (the workflow core).

---

## 3. The three named exceptions — no TableServe rehearsal

These have **no TableServe equivalent**. Expect to solve them fresh, on PRS:

### 3a. Dual-role FK on Request

A Request relates to a User **twice** conceptually: the **submitter** (`UserId`, a real
FK) and the **reviewer** (any user with `IsReviewer` who acts on it). TableServe's Order
had a single `staffId` — there was no second role, so nothing rehearsed this. In the UI
this surfaces as: the request shows its submitter, and *reviewers* (not the submitter)
get the Approve/Reject actions.

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

The **ownership check** — Approve/Reject disabled when `request.userId === currentUser.id` —
is the Cancel check (Lesson 11) with different fields, **and the comparison flipped**. On
TableServe you may cancel an order you took (`isOwnOrder || isManager` *enables*); on PRS a
reviewer may **not** approve their own request (owning it *disables*). Copy the mechanism, not
the sign — and note PRS gates the buttons on `isReviewer` where TableServe gates Cancel on
`isManager`.

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

The *form pattern* never changes — only which fields you `register`. Check
`specs/prs-requirements.md` for each entity's exact fields and validation.

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

---

## The General Pattern (what to take away)

- The PRS capstone = **your PRS backend + your PRS static markup + the TableServe React
  patterns**, integrated. Open the TableServe twin for every page.
- **Everything maps** except the **three named exceptions** (dual-role FK, $50
  auto-approve, avatar initials) — meet those fresh, on PRS.
- **Cancel → Reject** is the one workflow translation to keep straight; the rest is
  renamed entities and fields.
- `specs/prs-requirements.md` is authoritative for *what*; TableServe is your reference
  for *how*.

Build PRS the way you built TableServe — one feature folder at a time, verified in the
browser. You've already done every part of it once.
