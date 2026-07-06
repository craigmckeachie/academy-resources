# API Concepts — Lesson Materials

This folder contains the lesson materials for the Web API pass (Lessons 1–6). It
starts with a **no-code foundations lesson** — how web apps talk over HTTP, REST/JSON,
status codes, and Insomnia — then builds the TableServe Web API one entity at a time.

## File types

**`lesson-{N}-guide-*.md`** — the concept reference (**I do**). Read through this
during the instructor-led session. It explains the concepts being taught with
code examples and a step-by-step build walkthrough. Keep it open as a reference.

**`lesson-{N}-lab-*.md`** — the hands-on exercise (**You do**). Use this to build
a similar feature independently. Instructions are intentionally terse — refer back
to the guide and what you built alongside it as your model.

## Schedule

| Lesson | Guide | Lab |
|--------|-------|-----|
| 1 | [How web apps talk: architecture, HTTP/REST/JSON, Insomnia](lesson-1-guide-web-architecture-http-insomnia.md) | [DevTools & Insomnia exploration](lesson-1-lab-devtools-insomnia-exploration.md) |
| 2 | [Project setup, controllers, EF DbContext](lesson-2-guide-project-setup-crud.md) | [CategoriesController](lesson-2-lab-categories-controller.md) |
| 3 | [Full CRUD: POST/PUT/DELETE](lesson-3-guide-full-crud.md) | [MenuItemsController CRUD](lesson-3-lab-menuitems-controller.md) |
| 4 | [Nested data, Include(), FK lookups](lesson-4-guide-nested-data-fk-lookups.md) | [OrdersController with OrderItems](lesson-4-lab-orders-controller.md) |
| 5 | [Side-effect recalculation, workflow endpoints](lesson-5-guide-side-effects-workflow-endpoints.md) | [Order status workflow endpoints](lesson-5-lab-orderitems-workflow.md) |
| 6 | [Error handling, Insomnia, Login](lesson-6-guide-error-handling-login.md) | PRS backend capstone begins |

**Lesson 1 is a no-code foundations lesson** — you explore real HTTP traffic in the
browser and drive a public API in Insomnia, with no Visual Studio project. The
TableServe build starts in Lesson 2.

## Reference cheat sheets

Two evergreen cheat sheets in [`../reference/`](../reference/) back this pass — skim
them in Lesson 1 and keep them open throughout:

- [HTTP, REST, JSON & Status Codes](../reference/http-rest-status-codes.md)
- [Insomnia quick-start](../reference/insomnia-quickstart.md)

## Stretch challenges

Finished a lab early? Each lab ends with a short **Stretch challenges** section tied
to that lesson's concept. For bigger challenges that span the whole pass — a reports
controller, a new FK entity, pagination, and AI-assisted seed data — see
[Stretch challenges](stretch-api-challenges.md). None of it is required for the
capstone; it's optional extra practice, tagged **[Reinforce]** (builds on the guide)
or **[Reach]** (goes past it, with a reference link to research).

## Tips

- The guide and lab always use the **TableServe** domain (Staff, Categories,
  MenuItems, Orders, OrderItems)
- After the API pass you will build the **PRS backend independently** using
  TableServe as your reference — the same way the labs use the guide as a model
- This course has **no JWT/token authentication** — login returns the user object and
  every endpoint is open, so you never send an `Authorization` header or see a `401`
- All passwords in the seed data use the plaintext: `test1234`
