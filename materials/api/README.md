# API Concepts — Lesson Materials

This folder contains the lesson materials for the Web API pass (Lessons 1–5).

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
| 1 | [Project setup, controllers, EF DbContext](lesson-1-guide-project-setup-crud.md) | [CategoriesController](lesson-1-lab-categories-controller.md) |
| 2 | [Full CRUD: POST/PUT/DELETE](lesson-2-guide-full-crud.md) | [MenuItemsController CRUD](lesson-2-lab-menuitems-controller.md) |
| 3 | [Nested data, Include(), FK lookups](lesson-3-guide-nested-data-fk-lookups.md) | [OrdersController with OrderItems](lesson-3-lab-orders-controller.md) |
| 4 | [Side-effect recalculation, workflow endpoints](lesson-4-guide-side-effects-workflow-endpoints.md) | [Order status workflow endpoints](lesson-4-lab-orderitems-workflow.md) |
| 5 | [Error handling, Insomnia, Login](lesson-5-guide-error-handling-login.md) | PRS backend capstone begins |

## Stretch challenges

Finished a lab early? Each of Lessons 1–4 ends with a short **Stretch challenges**
section tied to that lesson's concept. For bigger challenges that span the whole
pass — a reports controller, a new FK entity, pagination, and AI-assisted seed
data — see [Stretch challenges](stretch-api-challenges.md). None of it is required
for the capstone; it's optional extra practice, tagged **[Reinforce]** (builds on
the guide) or **[Reach]** (goes past it, with a reference link to research).

## Tips

- The guide and lab always use the **TableServe** domain (Staff, Categories,
  MenuItems, Orders, OrderItems)
- After the API pass you will build the **PRS backend independently** using
  TableServe as your reference — the same way the labs use the guide as a model
- All passwords in the seed data use the plaintext: `test1234`
