---
title: Downloads
---

# Downloads

Everything you import, run, or unzip during the course. These files live in the
academy-resources repo's [`files/`](https://github.com/craigmckeachie/academy-resources/tree/main/files)
folder — the links below download them directly.

## Seed data (SQL)

Run in SQL Server Management Studio **after** your tables exist (created by EF Core
migrations — see each pass's getting-started steps). Every seeded account's password is
the plaintext `test1234`.

- [`populate-tableserve.sql`](https://github.com/craigmckeachie/academy-resources/blob/main/files/populate-tableserve.sql) — TableServe seed data (Web API pass)
- [`populate-prs.sql`](https://github.com/craigmckeachie/academy-resources/blob/main/files/populate-prs.sql) — PRS seed data (capstone)

## Insomnia collections

Import into Insomnia (`File → Import`), then set the `baseUrl` environment variable to
your running API's address. No login required — every endpoint is open.

- [`tableserve-insomnia.json`](https://github.com/craigmckeachie/academy-resources/blob/main/files/tableserve-insomnia.json) — TableServe (Web API pass)
- [`prs-insomnia.json`](https://github.com/craigmckeachie/academy-resources/blob/main/files/prs-insomnia.json) — PRS (capstone)

## Starter scaffolds (HTML/CSS)

The Vite + Bootstrap starter projects for the HTML/CSS pass — skeleton pages you fill
in. Unzip, run `npm install`, then `npm run dev`. Push your unzipped copy to your own
GitHub to track your work.

- [`tableserve-design-starter.zip`](https://github.com/craigmckeachie/academy-resources/raw/main/files/tableserve-design-starter.zip) — TableServe (HTML/CSS pass, Lesson 3 on)
- [`prs-design-starter.zip`](https://github.com/craigmckeachie/academy-resources/raw/main/files/prs-design-starter.zip) — PRS (capstone)
