# Lesson 7 Lab — Review Your PRS API with Copilot

Turn the review skill from the guide on the **PRS backend you built in the capstone.** Go
controller by controller, ask Copilot to review each, and **triage every suggestion** into
accept / reject / ignore — with a one-line reason. The point isn't to change much code;
it's to prove you can tell a real bug from a difference of convention in code you wrote.

Refer back to the guide for the three buckets and the constraints prompt, and keep the
[Copilot quick-start](../reference/copilot-quickstart.md) open for the convention
watch-list.

---

## Steps

1. Open your **PRS API** with Copilot Chat available.
2. For **each** controller — `UsersController`, `VendorsController`, `ProductsController`,
   `RequestsController`, `RequestLinesController` — attach it with a **`#` file
   reference** and ask for a review of bugs and correctness issues. Use the guide's
   **constraints paragraph** so the review is mostly real bugs, not convention noise.
3. For every suggestion, record its **bucket and a one-line reason**:
   - **Accept** — a genuine bug (missing `404` on `GetById`, no existence check before
     `SetValues`, a missing `Include()` so `User`/`Vendor`/`Product` comes back `null`,
     wrong status code).
   - **Reject** — a convention violation. Expect at least: a **DTO** suggestion, an
     **`[Authorize]`/JWT** suggestion, a **repository/service layer** suggestion,
     **`EntityState.Modified`**, tighter **CORS**, or **`virtual`** nav properties. Reject
     each and name the course's reason.
   - **Ignore** — noise or a misread (method renames, async nags).
4. **Apply the real fixes** (Bucket A). Leave everything in Bucket B and C alone.
5. **Verify in Insomnia.** For every fix you applied, re-run that entity's folder in the
   **PRS** collection and confirm it's still **green**. A change that turns a test red gets
   reverted or corrected — Copilot's confidence isn't proof.

---

## The one thing to hand in — your "what Copilot got wrong" list

Write a short list (aim for 3–5 items) of suggestions Copilot made that were **wrong for
this codebase**, each with the reason it doesn't apply here. For example:

- *Suggested an `IReviewerService` + repository — rejected; we inject `PrsDbContext`
  straight into controllers.*
- *Suggested `[Authorize]` on `RequestsController` — rejected; no JWT in this course, every
  endpoint is open by design.*
- *Suggested a `RequestDto` to prevent over-posting — rejected; we use the EF model
  directly.*

That list **is** the deliverable — it's the evidence you can tell an AI's generic advice
from what your project actually decided.

---

## Watch for the PRS-specific pieces

Copilot has no idea about the two PRS rules with no TableServe rehearsal, so review its
comments on them extra carefully:

- The **`/review` auto-approve** rule (`Total <= 50` → status `APPROVED`). If Copilot
  "simplifies" it away or flags it as a bug, that's a misread — it's the intended business
  rule.
- The **dual-role FK** on `Request` (submitter `UserId`, plus reviewer permission via
  `IsReviewer`). Copilot may suggest a second FK column or an `[Authorize]` role check —
  neither belongs here.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs some
research.

- **Review with and without the constraints** — [Reinforce] — review one controller
  *without* the constraints paragraph, then again *with* it. Count how many convention
  suggestions the constraints removed. That difference is Copilot learning your rules from
  the prompt.
- **Cross-controller consistency** — [Reach] — use a **`#codebase`** prompt to ask whether
  all five controllers return the same status codes for GET/POST/PUT/DELETE and consistently
  `Include()` their navigation properties. Read the answer critically and confirm anything
  it claims against the actual files. Reference:
  [Copilot Chat in VS Code](https://code.visualstudio.com/docs/copilot/overview).
- **Copilot as tutor** — [Reinforce] — pick a line you're least sure about (the
  `SetValues` update, the auto-approve check, an `Include`) and ask Copilot to **explain**
  it. Confirm its explanation matches what your code actually does.
- **Explain the reject** — [Reinforce] — for one Bucket-B suggestion, ask Copilot *why*
  it recommended that pattern (e.g. "why would a DTO help here?"). Understanding the real
  trade-off is what lets you reject it on purpose instead of by rote.

---

This is the same review-and-triage habit you'll use on every codebase in your career: the
review is only as good as the engineer judging it — and here that engineer is you, on code
you understand well enough to overrule the AI.
