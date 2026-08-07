---
title: Home
---

# TQL Software Development Academy

Welcome. These are the course materials for the back half of the bootcamp. You'll
build a full-stack web application in three passes — a **Web API** back end, a
**static HTML/CSS** front end, and a **React** front end — then rebuild the
equivalent independently as your **capstone**.

## How the course works

Every pass *teaches* on one app — **TableServe**, a restaurant order-management
system — and then has you *apply* it to a second app — **PRS**, a purchase-request
system — on your own:

- **Guide (I do)** — the concept reference you read during the instructor-led
  session, with code examples and a step-by-step build.
- **Lab (You do)** — a terse hands-on exercise building a parallel feature; you
  refer back to the guide as your model.
- **Capstone (PRS)** — you build the PRS equivalent independently, using the
  TableServe work as your reference. No new concepts, different entity names.

## The three passes

| Pass | What you build | Lessons | Start here |
|---|---|---|---|
| **1 · Web API** | C# / ASP.NET Core back end (TableServe) | 1–6 | [Web API »](api/README.md) |
| **2 · HTML / CSS** | Static Bootstrap front end (TableServe) | 1–6 | [HTML / CSS »](html-css/README.md) |
| **3 · React** | React + TypeScript front end (TableServe) | 1–13 | [React »](react/README.md) |

Use the left sidebar to move between lessons; the right sidebar is the table of
contents for the page you're on.

## Capstone — PRS

Across the passes you build the **Purchase Request System (PRS)** independently. The
authoritative requirements — data model, endpoints, pages, and business rules — are
in [PRS requirements](specs/prs-requirements.md).

**Before you start a capstone, read the [AI use policy](reference/ai-policy.md).** During a
capstone, AI reads code with you; it doesn't write code for you — explaining, researching,
debugging, and reviewing your own code are allowed; generating components and agent mode
wait until afterwards.

## After the capstone — the team project

The course closes with a **[team development block](team-project/README.md)**: teams of
three work a ticket backlog in a shared GitHub repository, using branches, pull requests,
code review, and Git worktrees — and this is where AI generation and agent mode open up,
gated by a teammate's review. Start with the
[team charter](team-project/team-charter.md).

## Reference cheat sheets

Evergreen references to keep open throughout:

- [AI use policy](reference/ai-policy.md)
- [Git collaboration quick-start](reference/git-collaboration-quickstart.md)
- [HTTP, REST, JSON & Status Codes](reference/http-rest-status-codes.md)
- [Insomnia quick-start](reference/insomnia-quickstart.md)

## Downloads

All the seed scripts, Insomnia collections, and starter scaffolds you import, run, or
unzip during the course are on the **[Downloads](downloads.md)** page.

## Good to know

- **Domain:** TableServe (Staff, Categories, MenuItems, Orders, OrderItems) is what
  every guide and lab teaches; PRS (Users, Vendors, Products, Requests, RequestLines)
  is what you build in the capstone.
- **No JWT/auth:** login returns the user object and every endpoint is open — you
  never send an `Authorization` header or see a `401`.
- **Seed password:** every seeded account's password is the plaintext `test1234`.
