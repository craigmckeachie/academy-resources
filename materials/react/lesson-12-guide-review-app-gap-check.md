# Lesson 12 Guide — Review / Buffer: Full-App Review and PRS Gap-Check

**This is a review / buffer lesson — there is no lab.** It's a full read-through of the
finished TableServe front end and an explicit **gap-check**: for every pattern PRS will
need, confirm you can point to where TableServe already does it. Anything you can't
find, you fix now — before the capstone, where there are no new concepts to lean on.

**Goal:** leave this lesson certain that every PRS page and behavior has a TableServe
precedent you understand, and with a working, complete TableServe front end.

---

## 1. The whole app, one tour

Walk the app the way a user would, naming the pattern behind each screen:

| Screen | Patterns in play | Lessons |
|---|---|---|
| Sign In | react-hook-form, login, localStorage, Context | 5, 9 |
| Menu Items list | fetch, card grid, skeleton, 3-dots delete | 2, 4 |
| Menu Item form | shared create/edit, **FK dropdown** (Category) | 5 |
| Staff list | fetch, card grid, **conditional role badges**, skeleton | 4 |
| Staff form | shared create/edit, **no FK**, checkboxes | 5 |
| Categories | provided — card grid + no-FK form | 11 |
| Orders list | **table**, status badges, **`useSearchParams` filter**, 3-dots | 4 |
| Order Detail | `useParams`, definition-list, **status workflow buttons**, **modals** | 6, 7 |
| Order Item form | **nested child**, **derived fields** (`watch`), parent total | 8 |

If any row is shaky, re-open that lesson's guide.

---

## 2. The PRS gap-check

Every PRS page maps to a TableServe page you built. Confirm each mapping — this is the
capstone's blueprint:

| PRS page/feature | TableServe precedent | Notes |
|---|---|---|
| User sign in | Staff Sign In | localStorage, Context, no JWT |
| Users list + form | Staff list + form | card grid, role flags, **no FK** |
| Vendors list + form | Categories (provided) | simple no-FK entity |
| Products list + form | Menu Items list + form | **FK dropdown** (Vendor ↔ Category) |
| Requests list | Orders list | **table**, status badges, status **filter** |
| Request Detail | Order Detail | `useParams`, workflow buttons, **Reject modal** |
| RequestLine create/edit | Order Item form | **nested**, **derived Amount**, parent total |
| Toasts + errors everywhere | Lesson 10 | `checkStatus` + `toast` |

**Read the mapping in both directions:** for a PRS page, know its TableServe twin; for a
TableServe page, know the PRS page it rehearses.

---

## 3. The three named exceptions — no TableServe rehearsal

Three PRS patterns have **no TableServe equivalent** and are taught directly on PRS.
Know now that you'll meet them fresh in the capstone (Lesson 13 covers them in detail):

1. **Dual-role FK on Request** — a Request has a submitter (`UserId`) *and* a reviewer
   relationship via `IsReviewer`. Orders had only one staff FK — no rehearsal.
2. **$50 auto-approve rule** — sending a Request with total ≤ $50 for review
   auto-approves it. TableServe's linear workflow has no business-rule branch like this.
3. **Avatar-circle-with-initials** on User cards — left for you to solve (it was a
   stretch challenge on Staff cards). The Header's avatar shows the technique; the User
   card is yours to build.

These are the *only* things in the PRS front end without a direct TableServe answer.

---

## 4. TableServe → PRS: what actually changes

The capstone is not new concepts — it's the same patterns with **renamed entities and
different fields/workflow**:

- **Entities:** Staff→Users, Categories→Vendors, MenuItems→Products, Orders→Requests,
  OrderItems→RequestLines.
- **Workflow words:** `Placed/Preparing/Ready/Served/Cancelled` →
  `New/Review/Approved/Rejected`; **Cancel modal → Reject modal** (required reason,
  plain-string body).
- **Role flags:** `isManager/isAdmin` → `isReviewer/isAdmin`; the **Cancel ownership
  check** → Approve/Reject disabled on your **own** request.
- **Fields differ** (a Vendor has address/city/state/zip; a Product has part
  number/unit) — the *form pattern* is unchanged; only the fields change.

---

## 5. Verifying in the browser

With your API running and `npm run dev` up, do a final pass:

1. Click every nav link; open every list; create, edit, and delete a record in each.
2. Run an order through its full workflow (Placed → Preparing → Ready → Served) and
   cancel another with a reason.
3. Add, edit, and delete order items; watch the Total recompute.
4. Sign out and back in; confirm the Cancel ownership check and any role-gated UI.
5. Keep the **Console** and **Network** open — no errors, correct status codes
   throughout.

A clean full pass here means TableServe is a complete, working reference you can lean on
for every PRS screen.

---

## The General Pattern (what to take away)

- The finished app is **eight repetitions of one feature-folder pattern**, plus a shared
  shell, auth/Context, and a detail/workflow page.
- **Every PRS page has a TableServe precedent** — except the three named exceptions.
- The capstone changes **entities, fields, and workflow words**, not concepts.

Next lesson (13) is the **capstone bridge** — it turns this gap-check into an explicit
plan and expectations for building PRS.
```
