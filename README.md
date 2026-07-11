<p align="center">
  <img src="assets/max-logo.png" alt="MAX Technical Training — MAX Solutions" width="360">
</p>

# TQL Software Development Academy — Course Materials

Welcome. These are the lesson materials for the back half of the bootcamp. You'll
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
| **1 · Web API** | C# / ASP.NET Core back end (TableServe) | 1–6 | [API materials »](materials/api/README.md) |
| **2 · HTML / CSS** | Static Bootstrap front end (TableServe) | 1–5 | [HTML/CSS materials »](materials/html-css/README.md) |
| **3 · React** | React + TypeScript front end (TableServe) | 1–13 | [React materials »](materials/react/README.md) |

Each pass README has the full lesson-by-lesson schedule linking every guide and lab.

## Capstone — PRS

Across the passes you build the **Purchase Request System (PRS)** independently. The
authoritative requirements — data model, endpoints, pages, and business rules — live
in [PRS requirements](materials/specs/prs-requirements.md).

## Reference cheat sheets

Evergreen references to keep open throughout — [`materials/reference/`](materials/reference/):

- [HTTP, REST, JSON & Status Codes](materials/reference/http-rest-status-codes.md)
- [Insomnia quick-start](materials/reference/insomnia-quickstart.md)

## Downloads — [`files/`](files/)

Ready-to-use files you import or run during the course:

- `populate-tableserve.sql` / `populate-prs.sql` — seed-data scripts (run in SSMS)
- `tableserve-insomnia.json` / `prs-insomnia.json` — Insomnia collections to import
- `tableserve-design-starter.zip` / `prs-design-starter.zip` — HTML/CSS starter scaffolds (unzip, then run `npm install`)

## Good to know

- **Domain:** TableServe (Staff, Categories, MenuItems, Orders, OrderItems) is what
  every guide and lab teaches; PRS (Users, Vendors, Products, Requests, RequestLines)
  is what you build in the capstone.
- **No JWT/auth:** login returns the user object and every endpoint is open — you
  never send an `Authorization` header or see a `401`.
- **Seed password:** every seeded account's password is the plaintext `test1234`.
