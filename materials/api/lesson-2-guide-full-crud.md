# Lesson 2 Guide — Full CRUD

**Goal:** by the end of this lesson your `StaffController` handles the full
set of CRUD operations — Create, Read, Update, and Delete — not just the GET
reads from the previous lesson. You'll learn the HTTP conventions for each verb,
how model
binding turns a JSON request body into a C# object, and how to hash passwords
with BCrypt so plaintext never touches the database.

**The general pattern you're learning:** every entity in a Web API exposes the
same five operations in the same shape — `GetAll`, `GetById`, `Create`, `Update`,
`Delete` (RCUD). Once you've written them once, every other controller is the
same skeleton with a different model.

---

## 1. The CRUD-to-HTTP mapping

CRUD is a database idea (Create, Read, Update, Delete). HTTP expresses those four
operations with verbs and status codes:

| Operation | HTTP Verb | Route | Success status | Not found | Bad request |
|-----------|-----------|-------|----------------|-----------|-------------|
| Read all | GET | `api/staff` | 200 OK | — | — |
| Read one | GET | `api/staff/5` | 200 OK | 404 | — |
| Create | POST | `api/staff` | 201 Created | — | — |
| Update | PUT | `api/staff/5` | 200 OK + body | 404 | 400 |
| Delete | DELETE | `api/staff/5` | 204 No Content | 404 | — |

Memorize this table — it's the contract every controller in this course honors.
The `[ApiController]` attribute and `ControllerBase` helper methods (`Ok()`,
`NotFound()`, `BadRequest()`, `CreatedAtAction()`, `NoContent()`) exist to make
returning these exact status codes easy.

---

## 2. Model binding — JSON in, C# object out

When a POST or PUT request arrives with a JSON body, ASP.NET Core automatically
deserializes it into the C# parameter you declare. This is **model binding**.

```csharp
[HttpPost]
public async Task<ActionResult<Staff>> Create(Staff newStaff)
```

The client sends:

```json
{ "username": "new.staff", "password": "test1234", "firstName": "New", ... }
```

ASP.NET matches JSON property names to `Staff` properties (case-insensitively) and
hands you a fully populated `newStaff` object. You never parse JSON by hand.

Because `StaffController` has `[ApiController]`, model binding for a complex type
like `Staff` reads from the **request body** by default — you don't need
`[FromBody]`.

---

## 3. BCrypt password hashing

Staff have passwords. Storing a password as plaintext is the single easiest
security mistake to make — anyone who can read the database can read every
password. **BCrypt** solves this by storing a one-way hash instead. You can
verify a password against the hash, but you can never turn the hash back into the
original text.

Add the NuGet package (**Tools → NuGet Package Manager → Manage NuGet Packages**):

```
BCrypt.Net-Next
```

Two methods matter:

```csharp
// Turn plaintext into a hash before saving
string hash = BCrypt.Net.BCrypt.HashPassword("test1234");

// Check a plaintext attempt against a stored hash (used at login — Lesson 5)
bool ok = BCrypt.Net.BCrypt.Verify("test1234", hash);
```

Every seed record in this course uses the same BCrypt hash — the plaintext is
`test1234`. That's how you'll log in during testing.

---

## 4. Create — POST

```csharp
// POST: api/Staff
[HttpPost]
public async Task<ActionResult<Staff>> Create(Staff newStaff) {
    newStaff.Password = BCrypt.Net.BCrypt.HashPassword(newStaff.Password);
    _db.Staff.Add(newStaff);
    await _db.SaveChangesAsync();

    return CreatedAtAction(nameof(GetById), new { id = newStaff.Id }, newStaff);
}
```

A few things to notice:

- **Hash first, save second** — the plaintext password from the request body is
  replaced with its BCrypt hash *before* it's added to the database.
- **`_db.Staff.Add(...)` then `SaveChangesAsync()`** — `Add` stages the insert in
  memory; `SaveChangesAsync` actually runs the SQL `INSERT`. After it completes,
  EF Core has populated `newStaff.Id` with the database-generated key.
- **`CreatedAtAction`** returns **201 Created**, includes the new object in the
  body, and adds a `Location` header pointing at `GetById` for the new record.
  `nameof(GetById)` avoids hardcoding the method name as a string.

---

## 5. Update — PUT

```csharp
// PUT: api/Staff/5
[HttpPut("{id}")]
public async Task<ActionResult<Staff>> Update(int id, Staff updatedStaff) {
    if (id != updatedStaff.Id) {
        return BadRequest();
    }

    var currentStaff = await _db.Staff.FindAsync(id);
    if (currentStaff == null) {
        return NotFound();
    }

    if (updatedStaff.Password != currentStaff.Password) {
        updatedStaff.Password = BCrypt.Net.BCrypt.HashPassword(updatedStaff.Password);
    }

    _db.Entry(currentStaff).CurrentValues.SetValues(updatedStaff);
    await _db.SaveChangesAsync();

    return Ok(currentStaff);
}
```

This is the **fetch-then-set** update pattern — the one you'll use in every
controller. Read it carefully:

- **`id` comes from the URL, `updatedStaff` from the body.** If they disagree the
  request is contradictory, so return **400 Bad Request**.
- **Fetch the current row first.** If `FindAsync` returns null, the record doesn't
  exist → **404 Not Found**.
- **Password guard** — if the incoming password differs from the stored hash, the
  caller is setting a new password, so hash it. If it's unchanged (the front end
  sent back the existing hash), leave it alone so you don't hash an already-hashed
  value.
- **`_db.Entry(currentStaff).CurrentValues.SetValues(updatedStaff)`** copies every
  property from the incoming object onto the tracked entity. This is the pattern we
  use in this course — **never** `_db.Entry(x).State = EntityState.Modified`.
- Return **200 OK** with the updated entity in the body.

---

## 6. Delete — DELETE

```csharp
// DELETE: api/Staff/5
[HttpDelete("{id}")]
public async Task<IActionResult> Delete(int id) {
    var staff = await _db.Staff.FindAsync(id);
    if (staff == null) {
        return NotFound();
    }

    _db.Staff.Remove(staff);
    await _db.SaveChangesAsync();

    return NoContent();
}
```

- Fetch first — no row means **404**.
- `Remove` stages the delete; `SaveChangesAsync` runs the SQL `DELETE`.
- **204 No Content** — the delete succeeded and there's nothing meaningful to
  return, so the body is empty. Notice the return type is `IActionResult`, not
  `ActionResult<Staff>`, because there's no entity to return.

---

## 7. The finished StaffController

With the previous lesson's `GetAll`/`GetById` plus this lesson's three methods, the controller is
complete:

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TableServe.Api.Data;
using TableServe.Api.Models;

namespace TableServe.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StaffController : ControllerBase
{
    private readonly TableServeDbContext _db;

    public StaffController(TableServeDbContext db)
    {
        _db = db;
    }

    // GET: api/staff
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Staff>>> GetAll()
    {
        return await _db.Staff.ToListAsync();
    }

    // GET: api/staff/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Staff>> GetById(int id)
    {
        var staff = await _db.Staff.FindAsync(id);
        if (staff == null) return NotFound();
        return staff;
    }

    // POST: api/staff
    [HttpPost]
    public async Task<ActionResult<Staff>> Create(Staff newStaff)
    {
        newStaff.Password = BCrypt.Net.BCrypt.HashPassword(newStaff.Password);
        _db.Staff.Add(newStaff);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = newStaff.Id }, newStaff);
    }

    // PUT: api/staff/5
    [HttpPut("{id}")]
    public async Task<ActionResult<Staff>> Update(int id, Staff updatedStaff)
    {
        if (id != updatedStaff.Id) return BadRequest();

        var currentStaff = await _db.Staff.FindAsync(id);
        if (currentStaff == null) return NotFound();

        if (updatedStaff.Password != currentStaff.Password)
            updatedStaff.Password = BCrypt.Net.BCrypt.HashPassword(updatedStaff.Password);

        _db.Entry(currentStaff).CurrentValues.SetValues(updatedStaff);
        await _db.SaveChangesAsync();
        return Ok(currentStaff);
    }

    // DELETE: api/staff/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var staff = await _db.Staff.FindAsync(id);
        if (staff == null) return NotFound();

        _db.Staff.Remove(staff);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
```

Notice the method order: **GetAll, GetById, Create, Update, Delete**. Keep every
controller in this order — it makes them easy to scan and compare.

---

## 8. Verifying with Insomnia

Insomnia setup (import, `baseUrl`) was covered in the Lesson 1 guide,
section 12. With the project running (no login required — the endpoints are open),
expand the **Staff** folder and work through the write operations:

1. **Create Staff** → Send → expect **201 Created** with the new staff object
   (note the generated `id`).
2. **Get All Staff** → Send → expect **200 OK**; the new record is now in the list.
3. **Update Staff** → Send → expect **200 OK** with the updated fields reflected.
4. **Delete Staff** → Send → expect **204 No Content** (empty body).
5. Run **Get Staff by Id** against the id you just deleted → expect **404 Not Found**.

Each request has after-response tests — check the **Tests** tab. Green = pass,
red = fail. If a test fails, the response panel shows expected vs. received.

> **Tip on passwords:** after **Create Staff**, look at the `Staff` row in SQL
> Server Object Explorer — the `Password` column holds a long `$2a$11$...` BCrypt
> hash, not the plaintext you sent. That's the whole point.

### Troubleshooting

- **400 Bad Request on Update** — the `id` in the URL doesn't match the `id` in
  the body. Make them the same.
- **415 Unsupported Media Type** — the request is missing the
  `Content-Type: application/json` header. The pre-built requests include it; if
  you craft your own, add it.
- **Connection error** — the project stopped running. Press F5 and confirm the
  port matches your `baseUrl`.

---

## The General Pattern (what to take away)

Every write operation follows the same three-beat rhythm:

1. **Validate / fetch** — check the id, fetch the current row, return `BadRequest`
   or `NotFound` if something's wrong.
2. **Mutate** — `Add`, `SetValues`, or `Remove` the entity.
3. **`SaveChangesAsync`** — commit, then return the correct status code
   (201 / 200 / 204).

When you build the PRS backend in the capstone, `UsersController` is this exact
controller with `Staff` swapped for `User` and `IsManager` swapped for
`IsReviewer`. The password hashing carries over verbatim.

---

## Build Steps

1. Install the **BCrypt.Net-Next** NuGet package
2. Add the `Create` (POST) method to `StaffController` — hash the password, then
   `Add` + `SaveChangesAsync`, return `CreatedAtAction`
3. Add the `Update` (PUT) method — id-match guard, fetch-then-set, password guard,
   return `Ok`
4. Add the `Delete` (DELETE) method — fetch, `Remove`, return `NoContent`
5. Run the project and verify all five operations in the **Staff** folder in
   Insomnia — see section 8
6. Confirm in SQL Server Object Explorer that a created staff member's `Password`
   column contains a BCrypt hash, not plaintext
