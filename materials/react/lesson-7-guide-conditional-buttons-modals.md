# Lesson 7 Guide — Status-Driven Workflow Buttons and Modals

**Goal:** by the end of this lesson the **Order Detail** page is fully interactive —
**workflow buttons that change with the order's status**, a **Cancel modal** with a
required-reason textarea, and a **delete-confirmation modal** for order items. You call
the API's custom workflow endpoints and re-fetch the order to reflect the new state.

> **This is a worked-example lesson — there is no paired lab.** The Cancel-with-reason
> modal directly rehearses PRS's **Reject** modal, and the status-driven buttons
> rehearse PRS's Send-for-Review / Approve / Reject. Because this pattern is a *named
> exception* (its closest PRS analog is taught directly on PRS), you build it once, in
> the guide, alongside the instructor — there's no second entity to repeat it on in
> TableServe. Follow along and build it on the Order Detail page.

**The general pattern you're learning:** **which actions are available depends on the
record's current status** — you render different buttons per status with conditional
rendering. A **modal** is a dialog held in state (`show`/`setShow`) and rendered on top
of the page; use a **confirmation** modal for destructive actions and a **reason**
modal (required textarea) before a state change. After any action, **re-fetch** the
record so the page shows the new truth.

---

## 1. Modals are React state, not `data-bs-toggle`

In the static pass, Bootstrap's JS opened modals via `data-bs-toggle="modal"`. In
React you control a modal with **state** and react-bootstrap's `Modal` component — no
data attributes:

```tsx
import { Modal } from "react-bootstrap";

const [showCancelModal, setShowCancelModal] = useState(false);
const handleShowCancelModal = () => setShowCancelModal(true);
const handleCloseCancelModal = () => setShowCancelModal(false);

<Modal show={showCancelModal} onHide={handleCloseCancelModal}>
  <Modal.Header closeButton>
    <Modal.Title>Cancel Order</Modal.Title>
  </Modal.Header>
  <Modal.Body>{/* … */}</Modal.Body>
</Modal>
```

- `show={showCancelModal}` — the boolean state decides visibility. A button sets it
  `true` to open; `onHide` (the ✕ or backdrop) sets it `false`.
- The modal markup always sits in the page; state is what reveals it. This is
  conditional rendering (Lesson 4) driving a dialog.

---

## 2. Status-driven workflow buttons

TableServe's order workflow is linear: `Placed → Preparing → Ready → Served`, with
`Cancelled` branching off Placed/Preparing. **The advance button shown depends on the
current status** — pure conditional rendering:

```tsx
<div className="d-flex justify-content-end gap-2">
  {order?.status === "PLACED" && (
    <button className="btn btn-primary" onClick={startPreparing}>Start Preparing</button>
  )}
  {order?.status === "PREPARING" && (
    <>
      <button className="btn btn-primary" onClick={markReady}>Mark Ready</button>
      <button className="btn btn-outline-danger" onClick={handleShowCancelModal}>
        Cancel Order
      </button>
    </>
  )}
  {order?.status === "READY" && (
    <button className="btn btn-primary" onClick={markServed}>Mark Served</button>
  )}
  {/* SERVED and CANCELLED are terminal — no buttons */}
  <Link to={`/orders/edit/${order?.id}`} className="btn btn-outline">✎</Link>
</div>
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

---

## 3. Calling workflow endpoints and re-fetching

The advance buttons call the API's **custom workflow endpoints** (from the API pass),
then **re-load the order** so the page reflects the new status:

```tsx
async function startPreparing() {
  if (!order?.id) return;
  setLoading(true);
  try {
    await orderAPI.startPreparing(order.id);
    toast.success("Successfully saved.");
    await loadOrder();          // re-fetch → UI now shows the new status + buttons
  } catch (error: any) {
    toast.error(error.message);
  } finally {
    setLoading(false);
  }
}
```

`markReady` and `markServed` are identical against their endpoints. The API methods are
plain PUTs to the id-before-verb routes:

```ts
startPreparing(id: number) {
  return fetch(`${url}/${id}/startpreparing`, { method: "PUT" })
    .then(checkStatus).then(parseJSON);
},
markReady(id: number) { return fetch(`${url}/${id}/markready`, { method: "PUT" })… },
markServed(id: number) { return fetch(`${url}/${id}/markserved`, { method: "PUT" })… },
```

**Re-fetching after the action** is the key idea: the server owns the status, so after
it changes you reload to get the truth rather than guessing the new state locally. The
new status flips which buttons render.

---

## 4. The Cancel modal — a required reason before a state change

Cancelling needs a **reason**, so the modal body holds a small react-hook-form with a
required textarea. This is a self-contained form *inside* the detail page:

```tsx
interface ICancelForm {
  cancellationReason: string | undefined;
}

const { register, handleSubmit, formState: { errors } } = useForm<ICancelForm>({
  defaultValues: async () => ({ cancellationReason: undefined }),
});

const saveCancel: SubmitHandler<ICancelForm> = async (form) => {
  if (!order?.id || !form.cancellationReason) return;
  await orderAPI.cancel(order.id, form.cancellationReason);
  setShowCancelModal(false);
  await loadOrder();
};
```

```tsx
<Modal show={showCancelModal} onHide={handleCloseCancelModal}>
  <Modal.Header closeButton>
    <Modal.Title>Cancel Order</Modal.Title>
  </Modal.Header>
  <Modal.Body>
    <form onSubmit={handleSubmit(saveCancel)}>
      <div className="mb-3">
        <label className="form-label" htmlFor="cancellationReason">Cancellation Reason</label>
        <textarea
          {...register("cancellationReason", { required: "Cancellation reason is required" })}
          className={`form-control ${errors?.cancellationReason && "is-invalid"}`}
          id="cancellationReason" rows={6}
        ></textarea>
        <div className="invalid-feedback">{errors?.cancellationReason?.message}</div>
      </div>
      <div className="d-flex justify-content-end gap-2">
        <button type="button" className="btn btn-outline-primary" onClick={handleCloseCancelModal}>Cancel</button>
        <button type="submit" className="btn btn-primary">Confirm</button>
      </div>
    </form>
  </Modal.Body>
</Modal>
```

- The **required textarea** validates like any react-hook-form field — try to Confirm
  empty and the `invalid-feedback` shows; the modal stays open.
- On valid submit, `orderAPI.cancel(id, reason)` PUTs the reason as a **plain string
  body** to `/orders/{id}/cancel`, then the modal closes and the order re-loads (now
  `CANCELLED`, showing the reason via the `OrderHeader` conditional from Lesson 6).

```ts
cancel(id: number, cancellationReason: string) {
  return fetch(`${url}/${id}/cancel`, {
    method: "PUT",
    body: JSON.stringify(cancellationReason),   // plain string, not { reason: … }
    headers: { "Content-Type": "application/json" },
  }).then(checkStatus);
},
```

> **This modal is the rehearsal for PRS's Reject modal** — a required `rejectionReason`
> textarea before a status change, PUT as a plain string to `/requests/{id}/reject`.
> Same shape, different words.

---

## 5. The delete-confirmation modal

Deleting an order item uses a **confirmation** modal instead of `window.confirm`. Hold
the *item to delete* in state — non-null means "show the modal for this item":

```tsx
const [orderItemToDelete, setOrderItemToDelete] = useState<IOrderItem | undefined>(undefined);

function handleShowDeleteItemModal(orderItem: IOrderItem) { setOrderItemToDelete(orderItem); }
function handleCloseDeleteItemModal() { setOrderItemToDelete(undefined); }

async function removeOrderItem() {
  if (!orderItemToDelete?.id) return;
  await orderItemAPI.delete(orderItemToDelete.id);
  setOrderItemToDelete(undefined);
  toast.success("Successfully deleted.");
  await loadOrder();          // re-fetch so the total + rows update
}
```

```tsx
<Modal show={!!orderItemToDelete} onHide={handleCloseDeleteItemModal}>
  <Modal.Header closeButton><Modal.Title>Delete Order Item</Modal.Title></Modal.Header>
  <Modal.Body>
    <p>Are you sure you want to delete this order item?</p>
    <div className="d-flex justify-content-end gap-2">
      <button className="btn btn-outline-primary" onClick={handleCloseDeleteItemModal}>Cancel</button>
      <button className="btn btn-danger" onClick={removeOrderItem}>Delete</button>
    </div>
  </Modal.Body>
</Modal>
```

- `show={!!orderItemToDelete}` — the double-bang turns the item-or-undefined into a
  boolean: an item present → modal open. Storing the *item* (not just a boolean) means
  the confirm handler knows exactly which one to delete. A trash button per row calls
  `handleShowDeleteItemModal(orderItem)`.
- After deleting, re-fetch the order so the items table and the recalculated **Total**
  update (the API recomputes `Order.Total` — you built that in the API pass).

---

## 6. Verifying in the browser

Verify in the **browser**. With your API running and `npm run dev` up:

1. Open a **Placed** order's detail — only **Start Preparing** shows. Click it → the
   status badge flips to PREPARING and the buttons become **Mark Ready** + **Cancel
   Order** (that's the re-fetch re-rendering). **Network** shows a PUT to
   `…/startpreparing`.
2. Click **Mark Ready** → READY, then **Mark Served** → SERVED and the buttons vanish
   (terminal). Each step is a PUT + re-fetch.
3. On a Preparing order, click **Cancel Order** — the modal opens. Click **Confirm**
   with the textarea empty → "Cancellation reason is required" shows, modal stays open.
   Enter a reason, Confirm → modal closes, status is CANCELLED, and the **Cancellation
   Reason** appears in the summary.
4. Click a row's **trash** → the delete-confirm modal opens; **Delete** removes the item
   and the **Total** updates.
5. Console clean; each action shows the right request in **Network**.

---

## The General Pattern (what to take away)

- **Available actions depend on status** — render workflow buttons with
  `{status === "X" && <buttons/>}`; terminal states show none.
- A **modal** is a react-bootstrap `Modal` gated by **state** (`show={bool}` /
  `onHide`), not `data-bs-toggle`.
- Use a **reason modal** (required textarea via react-hook-form) before a state change,
  and a **confirmation modal** (store the target in state, `show={!!target}`) for
  deletes.
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
3. Add the **Cancel modal**: `showCancelModal` state, a react-hook-form with a required
   `cancellationReason` textarea, `saveCancel` → `orderAPI.cancel` → close + re-fetch.
4. Add the **delete-confirm modal**: `orderItemToDelete` state, `show={!!orderItemToDelete}`,
   `removeOrderItem` → delete → clear + re-fetch; a trash button per item row opens it.
5. Verify in the browser using section 6 — buttons change per status, both modals work,
   validation blocks an empty reason, totals update.
```
