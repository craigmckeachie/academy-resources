# API Stretch Challenges

Optional, off-the-critical-path work for when you finish a lab early. **None of
this is required for the PRS capstone** — it's here to keep you sharp and let you
push past what the guides cover.

Each lab also has its own short **Stretch challenges** section tied to that
lesson's concept. The challenges below are the bigger, cross-cutting ones that
span the whole API pass — reach for them once you're comfortably ahead.

## How the challenges are labeled

- **[Reinforce]** — extends something a guide already showed you. No new concept;
  you have everything you need.
- **[Reach]** — goes past the guides. You'll need to do some research on your own;
  a reference link is provided as a starting point. Expect to read and experiment.

Everything you build here should still be verifiable in Insomnia, the same way the
labs are — add a request, hit the endpoint, confirm the response.

---

## 1. Reports controller — [Reach]

Add a read-only `ReportsController` with endpoints that summarize data across
orders rather than returning rows one-for-one. No new tables — this is pure query
composition with LINQ `GroupBy` / `Sum` / `Count` over the data you already have.

Suggested endpoints:

- `GET /api/reports/sales-by-status` — total `Order.Total` grouped by `Status`
- `GET /api/reports/top-menu-items` — menu items ranked by quantity ordered
  (group `OrderItems` by `MenuItemId`, sum `Quantity`)
- `GET /api/reports/orders-per-staff` — order count grouped by the `Staff` member

Return anonymous objects or a small result shape — you don't need a new model.
This pulls together the `Include` work from Lesson 4 and the totals thinking from
Lesson 5.

**Research:** [Grouping data with LINQ](https://learn.microsoft.com/en-us/dotnet/csharp/linq/standard-query-operators/grouping-data)
— shows `GroupBy` plus aggregating each group (the `Max`/subquery examples near the
bottom translate directly to `Sum`/`Count`).

This is the most open-ended challenge here — there's always one more report you
could add.

---

## 2. Tables entity + foreign key — [Reinforce]

Right now `Order.TableNumber` is just a bare integer. Normalize it into a real
`Tables` reference entity with a foreign key — re-running the exact
Category → MenuItem FK pattern from Lessons 2 and 3, but entirely on your own.

1. Add a `Table` model (`Id`, `Name` or `Number`, maybe `Seats`).
2. Add `DbSet<Table> Tables` to `TableServeDbContext`.
3. Give `Order` a `TableId` FK and a `Table? Table` navigation property (you can
   keep `TableNumber` or replace it).
4. `Add-Migration AddTables`, `Update-Database`, seed a few tables.
5. `Include(order => order.Table)` in `OrdersController` so the table comes back
   nested, just like `Staff`.
6. Build a `TablesController` with full CRUD.

If you can do this without re-reading the MenuItems guide, you've internalized the
FK pattern you'll need for `Products` (VendorId) on PRS.

---

## 3. Pagination — [Reach]

Add `?skip=` and `?take=` query parameters to one or more list endpoints so a
caller can page through results instead of getting everything at once. Apply it to
`GetAll` with `.Skip(skip).Take(take)`, and remember pagination needs a stable
`OrderBy` to be correct.

**Research:** [Pagination in EF Core](https://learn.microsoft.com/en-us/ef/core/querying/pagination)
— start with the "Offset pagination" section (`Skip`/`Take`); the keyset section is
further reading if you're curious.

---

## 4. Seed data expansion (AI-assisted) — [Reinforce]

Grow the seed data so your API returns a richer, more realistic dataset — modeled
on your own favorite restaurant if you like. Rather than hand-writing dozens of
`INSERT` statements, use an AI assistant to generate them **and give the AI your
existing seed script as the reference** so the output is structured correctly.

Steps:

1. Open `TableServe.Db/populate-tableserve.sql` — the full seed script you've been
   using.
2. Paste it into your AI assistant and tell it to **match this file's structure
   exactly**: the same table insert **order** (Categories before MenuItems, Staff
   before Orders, Orders before OrderItems) and the same foreign-key handling, so
   every relationship still lines up and nothing references a row that doesn't
   exist yet.
3. Ask it to generate additional rows for the restaurant of your choice — more
   categories, menu items, staff, and a handful of orders with items.
4. Read what it produced before you run it. Confirm the insert order is right and
   the FK values point at rows that actually exist.
5. Run the script, then verify the new data comes back through the **existing**
   Insomnia requests (Get All Menu Items, Get All Orders, Get Order by Id, etc.).

The skill here is as much about *directing the AI with a good reference* as it is
about the SQL — the seed script is the contract the generated data has to honor.

---

You'll reuse all of these instincts on the PRS capstone: aggregation queries,
adding an FK entity, paging a long list, and seeding realistic data are exactly
the kinds of things you'll reach for once the core CRUD is working.
