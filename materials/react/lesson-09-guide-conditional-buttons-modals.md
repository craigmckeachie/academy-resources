# Lesson 9 Guide — Status-Driven Workflow Buttons and Modals

**Goal:** by the end of this lesson the **Order Detail** page is interactive —
**workflow buttons that change with the order's status** and a **Cancel modal** with a
required-reason textarea. You call the API's custom workflow endpoints and re-fetch the
order to reflect the new state. (The order-item **delete-confirmation modal** comes in
Lesson 10, alongside the items table it acts on.)

> **The guide is a worked example — the lab builds something different.** The
> Cancel-with-reason modal directly rehearses PRS's **Reject** modal, and the status-driven
> buttons rehearse PRS's Send-for-Review / Approve / Reject. Because this pattern is a *named
> exception* (its closest PRS analog is taught directly on PRS), you build it once, in
> the guide, alongside the instructor — there's no second entity to repeat it on in
> TableServe. Follow along and build it on the Order Detail page. This lesson's **lab**
> then builds the **Categories list**, reusing patterns you already know.

**The general pattern you're learning:** **which actions are available depends on the
record's current status** — you render different buttons per status with conditional
rendering. A **modal** is a dialog held in state (an `isOpen` boolean) and rendered on top
of the page; use a **confirmation** modal for destructive actions and a **reason**
modal (required textarea) before a state change. After any action, **re-fetch** the
record so the page shows the new truth.

> **How to use this guide.** This is a worked example — you build it alongside the
> instructor. Sections headed **▶ Code along** are the build (each ends with a quick **Save
> and check**); §1 is concept. **Each code block carries its file name as a title bar** (e.g.
> `src/orders/OrderDetailPage.tsx`); a **`diff`** block shows the enclosing function or object
> with `...` for unchanged code and `+` / `-` for the lines you change.

> **Prerequisite:** your API is running **on the HTTP profile** (`http`, not `https`), and
> you have the Order Detail page from Lesson 8 — this lesson makes it interactive.

---

## 1. Modals are React state, not `data-bs-toggle`

*(Read this.)*

In the static pass, Bootstrap's JS opened modals via `data-bs-toggle="modal"`. In
React you control a modal with **state** and react-bootstrap's `Modal` component — no
data attributes:

```tsx
import { Modal } from "react-bootstrap";

const [isCancelOpen, setIsCancelOpen] = useState(false);
const openCancel = () => setIsCancelOpen(true);
const closeCancel = () => setIsCancelOpen(false);

<Modal show={isCancelOpen} onHide={closeCancel}>
  <Modal.Header closeButton>
    <Modal.Title>Cancel Order</Modal.Title>
  </Modal.Header>
  <Modal.Body>{/* … */}</Modal.Body>
</Modal>
```

- `show={isCancelOpen}` — the boolean state decides visibility. A button sets it
  `true` to open; `onHide` (the ✕ or backdrop) sets it `false`.
- The modal markup always sits in the page; state is what reveals it. This is
  conditional rendering (Lesson 6) driving a dialog.

---

## 2. ▶ Code along — Status-driven workflow buttons

TableServe's order workflow is linear: `Placed → Preparing → Ready → Served`, with
`Cancelled` branching off Placed/Preparing. **The advance button shown depends on the
current status** — pure conditional rendering.

Add a buttons `<div>` **inside the heading row you built in Lesson 8** — right after
`<h2>Order</h2>`, so the buttons sit to the right of the title (the row is already
`justify-content-between`). The unchanged lines are shown for context; the `+` lines are what
you add:

```diff title="src/orders/OrderDetailPage.tsx"
  function OrderDetailPage() {
    ...
    return (
      ...
      <div className="d-flex justify-content-between pb-4 mb-4 border-bottom border-2">
        <h2>Order</h2>
+       <div className="d-flex justify-content-end gap-2">
+         {order?.status === "PLACED" && (
+           <button className="btn btn-primary" onClick={startPreparing}>Start Preparing</button>
+         )}
+         {order?.status === "PREPARING" && (
+           <>
+             <button className="btn btn-primary" onClick={markReady}>Mark Ready</button>
+             <button className="btn btn-outline-danger" onClick={openCancel}>
+               Cancel Order
+             </button>
+           </>
+         )}
+         {order?.status === "READY" && (
+           <button className="btn btn-primary" onClick={markServed}>Mark Served</button>
+         )}
+         {/* SERVED and CANCELLED are terminal — no buttons */}
+       </div>
      </div>
      ...
    );
  }
```

| Status | Advance button | Cancel? |
|---|---|---|
| Placed | Start Preparing | yes |
| Preparing | Mark Ready | yes |
| Ready | Mark Served | no |
| Served / Cancelled | *(none — terminal)* | no |

Each `{order?.status === "X" && …}` shows its buttons only in that state. **Cancel
Order** doesn't act directly — it opens the Cancel modal, because cancelling requires a
reason (section 4).

**Save and check**

- Your editor flags `startPreparing`, `markReady`, `markServed`, and `openCancel` as **not
  defined** — expected; you add them in sections 3 and 4.

*Not yet: the buttons themselves. Once section 3's handlers are in, a **Placed** order shows
only **Start Preparing**, and a **Served** order shows none.*

---

## 3. ▶ Code along — Call the endpoints and re-fetch

The buttons' `onClick` handlers call the API's **custom workflow endpoints** (from the API
pass), then **re-load the order** so the page reflects the new status.

**Add the endpoints to `OrderAPI.ts` first** — the handlers you write next call them, so they
must exist or the handler code won't compile. They're plain PUTs to the id-before-verb routes
(plain `fetch` for now — Lesson 12 adds the shared `checkStatus`/`parseJSON` helpers):

```diff title="src/orders/OrderAPI.ts"
  export const orderAPI = {
    ...  // list, find, delete (Lessons 6–8)

+   startPreparing(id: number) {
+     return fetch(`${url}/${id}/startpreparing`, { method: "PUT" });
+   },
+   markReady(id: number)  { return fetch(`${url}/${id}/markready`,  { method: "PUT" }); },
+   markServed(id: number) { return fetch(`${url}/${id}/markserved`, { method: "PUT" }); },
  };
```

Now the three handlers, **inside the `OrderDetailPage` component, above the `return`** —
alongside the `loadOrder` from Lesson 8. Each hits its endpoint, toasts, then
`await loadOrder()` to re-fetch. `markReady` and `markServed` are `startPreparing` with the
endpoint swapped:

```diff title="src/orders/OrderDetailPage.tsx"
  function OrderDetailPage() {
    ...  // useParams, loading/order state, and loadOrder (Lesson 8)

+   async function startPreparing() {
+     if (!order?.id) return;
+     setLoading(true);
+     try {
+       await orderAPI.startPreparing(order.id);
+       toast.success("Successfully saved.");
+       await loadOrder();          // re-fetch → UI now shows the new status + buttons
+     } catch (error: any) {
+       toast.error(error.message);
+     } finally {
+       setLoading(false);
+     }
+   }
+
+   async function markReady() {
+     if (!order?.id) return;
+     setLoading(true);
+     try {
+       await orderAPI.markReady(order.id);
+       toast.success("Successfully saved.");
+       await loadOrder();
+     } catch (error: any) {
+       toast.error(error.message);
+     } finally {
+       setLoading(false);
+     }
+   }
+
+   async function markServed() {
+     if (!order?.id) return;
+     setLoading(true);
+     try {
+       await orderAPI.markServed(order.id);
+       toast.success("Successfully saved.");
+       await loadOrder();
+     } catch (error: any) {
+       toast.error(error.message);
+     } finally {
+       setLoading(false);
+     }
+   }

    useEffect(() => {
      loadOrder();
    }, []);
    ...
  }
```

**Re-fetching after the action** is the key idea: the server owns the status, so after it
changes you reload to get the truth rather than guessing locally. The new status flips which
buttons render.

**Save and check**

- Click **Start Preparing** on a Placed order — the badge flips to **PREPARING**.
- The buttons become **Mark Ready** and **Cancel Order** — that's the re-fetch re-rendering.
- **Network** shows the `PUT` to `…/startpreparing`.

---

## 4. ▶ Code along — The Cancel modal (required reason)

Cancelling needs a **reason**, so the modal holds a small react-hook-form with a required
textarea. This adds four pieces, **in dependency order** so each compiles as you add it — the
form type, the `cancel` API method, the modal's state and handlers, then the `<Modal>` markup.

**(a) The form type** — at the **top of the file** (module scope, above the component), by
the imports:

```diff title="src/orders/OrderDetailPage.tsx"
  ...  // imports (react-router, react-bootstrap Modal, react-hook-form, IOrder, orderAPI, …)

+ interface ICancelForm {
+   cancellationReason: string | undefined;
+ }

  function OrderDetailPage() {
    ...
  }
```

**(b) The `cancel` API method** — add it **to the `orderAPI` object** *before* the submit
handler below, which calls it; it sends the reason as a **plain string** body:

```diff title="src/orders/OrderAPI.ts"
  export const orderAPI = {
    ...  // list, find, delete, startPreparing, markReady, markServed

+   cancel(id: number, cancellationReason: string) {
+     return fetch(`${url}/${id}/cancel`, {
+       method: "PUT",
+       body: JSON.stringify(cancellationReason),   // plain string, not { reason: … }
+       headers: { "Content-Type": "application/json" },
+     });
+   },
  };
```

**(c) Modal state, open/close handlers, the form hook, and the submit handler** — **inside
the component, above the `return`** (this is the modal-state pattern from section 1, now made
real). Also add the imports `import { Modal } from "react-bootstrap";` and
`import { useForm, SubmitHandler } from "react-hook-form";`:

```diff title="src/orders/OrderDetailPage.tsx"
  function OrderDetailPage() {
    ...  // useParams, loading/order state, loadOrder, and the §3 workflow handlers

+   const [isCancelOpen, setIsCancelOpen] = useState(false);
+   const openCancel = () => setIsCancelOpen(true);   // ← the Cancel Order button (§2) calls this
+   const closeCancel = () => setIsCancelOpen(false);
+
+   const { register, handleSubmit, formState: { errors } } = useForm<ICancelForm>({
+     defaultValues: async () => ({ cancellationReason: undefined }),
+   });
+
+   const saveCancel: SubmitHandler<ICancelForm> = async (form) => {
+     if (!order?.id || !form.cancellationReason) return;
+     await orderAPI.cancel(order.id, form.cancellationReason);
+     setIsCancelOpen(false);
+     await loadOrder();
+   };

    return (
      ...
    );
  }
```

**(d) The modal markup** — **inside the `return`, as the first child of the `<section>`** (a
modal can live anywhere in the JSX; putting it first keeps it out of the layout flow, and it
only appears when `isCancelOpen` is `true`):

```diff title="src/orders/OrderDetailPage.tsx"
  function OrderDetailPage() {
    ...
    return (
      <section className="content container-fluid mx-5 my-2 py-4">
+       <Modal show={isCancelOpen} onHide={closeCancel}>
+         <Modal.Header closeButton>
+           <Modal.Title>Cancel Order</Modal.Title>
+         </Modal.Header>
+         <Modal.Body>
+           <form onSubmit={handleSubmit(saveCancel)}>
+             <div className="mb-3">
+               <label className="form-label" htmlFor="cancellationReason">Cancellation Reason</label>
+               <textarea
+                 {...register("cancellationReason", { required: "Cancellation reason is required" })}
+                 className={`form-control ${errors?.cancellationReason && "is-invalid"}`}
+                 id="cancellationReason" rows={6}
+               ></textarea>
+               <div className="invalid-feedback">{errors?.cancellationReason?.message}</div>
+             </div>
+             <div className="d-flex justify-content-end gap-2">
+               <button type="button" className="btn btn-outline-primary" onClick={closeCancel}>Cancel</button>
+               <button type="submit" className="btn btn-primary">Confirm</button>
+             </div>
+           </form>
+         </Modal.Body>
+       </Modal>
        <div className="d-flex justify-content-between pb-4 mb-4 border-bottom border-2">
          <h2>Order</h2>
          {/* … workflow buttons from §2 … */}
        </div>
        ...
      </section>
    );
  }
```

- The **required textarea** validates like any react-hook-form field — try to Confirm
  empty and the `invalid-feedback` shows; the modal stays open.
- On valid submit, `orderAPI.cancel(id, reason)` PUTs the reason as a **plain string
  body** to `/orders/{id}/cancel`, then the modal closes and the order re-loads (now
  `CANCELLED`, showing the reason via the `OrderHeader` conditional from Lesson 8).

> **This modal is the rehearsal for PRS's Reject modal** — a required `rejectionReason`
> textarea before a status change, PUT as a plain string to `/requests/{id}/reject`.
> Same shape, different words.

**Save and check**

- On a Preparing order, click **Cancel Order** — the **modal opens**.
- Click **Confirm** with the textarea empty — the required error shows and the modal **stays
  open**.
- Enter a reason and Confirm — the modal closes, the status is **CANCELLED**, and the reason
  shows in the summary.

---

## 5. Verifying in the browser

You've checked each piece as you built it; this is the full pass. With your API running and
`npm run dev` up:

1. Open a **Placed** order's detail — only **Start Preparing** shows. Click it → the status
   badge flips to PREPARING and the buttons become **Mark Ready** + **Cancel Order** (that's
   the re-fetch re-rendering). **Network** shows a PUT to `…/startpreparing`.
2. Click **Mark Ready** → READY, then **Mark Served** → SERVED and the buttons vanish
   (terminal). Each step is a PUT + re-fetch.
3. On a Preparing order, click **Cancel Order** — the modal opens. Click **Confirm** with the
   textarea empty → "Cancellation reason is required" shows, modal stays open. Enter a
   reason, Confirm → modal closes, status is CANCELLED, and the **Cancellation Reason**
   appears in the summary.
4. Console clean; each action shows the right request in **Network**.

---

## The General Pattern (what to take away)

- **Available actions depend on status** — render workflow buttons with
  `{status === "X" && <buttons/>}`; terminal states show none.
- A **modal** is a react-bootstrap `Modal` gated by **state** (`show={bool}` /
  `onHide`), not `data-bs-toggle`.
- Use a **reason modal** (required textarea via react-hook-form) before a state change.
  (The **confirmation modal** for deletes — store the target in state, `show={!!target}` —
  comes in Lesson 10 with the items table.)
- **Re-fetch after every action** so the page reflects server truth and the buttons
  update.
- Workflow endpoints are plain PUTs to id-before-verb routes; Cancel/Reject send a
  **plain string** reason body.

On PRS: Request Detail shows Send-for-Review (New) / Approve + Reject (Review), the
**Reject modal** is this Cancel modal, and each action re-fetches the request.

---

## Build Steps

1. Add `startPreparing`, `markReady`, `markServed`, and `cancel(id, reason)` to
   `OrderAPI.ts` (PUTs to the id-before-verb workflow routes; `cancel` sends a plain
   string body).
2. On `OrderDetailPage`, add the **workflow buttons** in the heading row, each gated by
   `{order?.status === "…" && …}`, calling an async handler that hits the endpoint,
   toasts, and `await loadOrder()`.
3. Add the **Cancel modal**: `isCancelOpen` state, a react-hook-form with a required
   `cancellationReason` textarea, `saveCancel` → `orderAPI.cancel` → close + re-fetch.
4. Verify using section 5 — buttons change per status, and the Cancel modal blocks an empty
   reason then flips the status to CANCELLED.
