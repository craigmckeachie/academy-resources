# Lesson 5 Guide — Error Handling, Insomnia Review & Login

**Goal:** tie the pass together. You'll review the error-handling
conventions every controller has been following, do a full pass through the
Insomnia collection across all five entities, and drop in the pre-written
**Login** endpoint. After this lesson, the TableServe backend is complete — and in
the capstone you build the PRS backend on your own using it as your reference.

There is **no lab for this lesson** — the PRS backend capstone begins. This lesson
is consolidation and the one piece of new code (Login).

---

## 1. The error-handling conventions you've been using

You haven't written a single `try/catch` in this pass — and that's intentional. The
`[ApiController]` attribute plus `ControllerBase`'s helper methods handle the
common cases for you. What you *have* done consistently is return the **right
status code for the right situation**. Here's the full contract:

| Situation | What you return | Status |
|-----------|-----------------|--------|
| Read succeeded | the entity / list | 200 OK |
| Created succeeded | `CreatedAtAction(...)` | 201 Created |
| Update succeeded | `Ok(entity)` | 200 OK |
| Delete succeeded | `NoContent()` | 204 No Content |
| Entity not found | `NotFound()` | 404 |
| URL id ≠ body id (PUT) | `BadRequest()` | 400 |
| Malformed JSON body | *automatic* (`[ApiController]`) | 400 |

Key points:

- **`[ApiController]` auto-validates the request.** If the JSON body is malformed
  or a required field's type is wrong, ASP.NET returns a **400** with a problem
  document *before your method even runs*. You don't check for it.
- **404 vs. 400 is a real distinction.** 404 means "the thing you asked for
  doesn't exist." 400 means "your request itself is wrong" (like the id mismatch
  on PUT). Returning the right one is part of a well-behaved API.
- **Fetch-before-save is your existence check.** You never wrote an
  `EntityExists()` helper — every method fetches the row first, and a `null`
  result *is* the 404. That single pattern covers Update, Delete, and GetById.

### What we deliberately did NOT add

- **No global exception middleware / custom error pages** — out of scope; the
  defaults are fine for this course.
- **No validation attributes beyond `[StringLength]`** on the models — the API
  trusts the front end to send sensible data.
- **No `[Authorize]`, no JWT, no auth middleware** — see the Login section below.

---

## 2. Full Insomnia review across all entities

Confirm every endpoint you built in this pass responds correctly. Do this in two
phases: first run the **whole collection at once** to see everything pass, then go
back through the requests **one at a time** to actually look at the responses. With
the project running, the endpoints are open — no login is needed first.

### Phase 1 — Run the whole collection at once

Click the top-level **TableServe** collection in the sidebar, open its **Runner**
tab, select all requests, and **Run** them in one pass. The Runner sends every
request in every folder and reports each after-response test as pass or fail.

The after-response tests verify the **status code** and **top-level response
structure** on each request. **A wall of green across every folder means your
backend matches the contract.** If anything is red, note which folder and request
failed, open that controller, and compare it against the conventions from the
earlier guides. Fix and re-run until the whole collection is green.

*(If your version of Insomnia doesn't show a Runner, you can still run each request
by hand as in Phase 2 and read the **Tests** tab on each one — the checks are the
same, just one request at a time.)*

### Phase 2 — Walk each request and inspect the response

A green run tells you the status codes and shapes are right, but not what's *in*
each response. Now go folder by folder, send each request, and read the response
body. Here's what to look for in each:

**Staff** — GetAll 200 (array) · GetById 200 · GetById 9999 → 404 · Create 201 ·
Update 200 · Delete 204

**Categories** — GetAll 200 · GetById 200 · Create 201 · Update 200 · Delete 204

**MenuItems** — GetAll 200 (each item has a nested `category`) · GetById 200 ·
Create 201 (response includes `category`) · Update 200 · Delete 204

**Orders** — GetAll 200 (each has nested `staff`) · `?status=PLACED` filters the
list · GetById 200 (nested `staff` + `orderItems`, each with `menuItem`) ·
Create 201 · Update 200 · Start Preparing / Mark Ready / Mark Served 200 (status
advances) · Cancel 200 (`status` = CANCELLED, `cancellationReason` set) ·
Delete 204

**OrderItems** — GetAll 200 · GetById 200 · Create 201 (parent order `total` goes
up) · Update 200 · Delete 204 (parent `total` goes down)

The details worth eyeballing here are the ones a pass/fail test doesn't show you:
the **nested navigation properties** (`category`, `staff`, `orderItems`), the
**status advancing** through the Order workflow, and the parent Order **`total`
moving up and down** as you add and remove OrderItems.

---

## 3. Login — the pre-written endpoint

Login is the last piece. **Read this section carefully — the auth model in this
course is deliberately minimal, and it's important you understand exactly what it
is and isn't.**

### What login actually does

There is **no JWT and no token** in this application. The Login endpoint:

1. Looks up the staff member by `username`.
2. Verifies the submitted password against the stored BCrypt hash.
3. If it matches, returns the **full Staff object** as JSON. If not, returns
   **404**.

That's the entire login. There is no token to issue, store, or send back on later
requests. Later, in the React pass, the front end will store the returned Staff
object in `localStorage` — and "signed in" will simply mean "we have a stored
Staff object." Nothing is enforced on the server; every endpoint stays wide open.

This is a **teaching simplification, not a real security boundary** — and the
specs say so explicitly. The learning objective is understanding the *flow* of
authentication, not building production security.

### The drop-in code

Add this action to `StaffController` (it goes above `GetAll` by convention). It's
provided for you — you don't write it from scratch:

```csharp
// POST: api/Staff/login
[HttpPost("login")]
public async Task<ActionResult<Staff>> Login(Staff credentials)
{
    var staff = await _db.Staff
                        .SingleOrDefaultAsync(staff => staff.Username == credentials.Username);

    if (staff == null || !BCrypt.Net.BCrypt.Verify(credentials.Password, staff.Password))
    {
        return NotFound();
    }

    return staff;
}
```

Things to notice:

- **`[HttpPost("login")]`** — the route is `POST api/staff/login`. It's a POST
  because credentials go in the body, never in the URL.
- **The parameter is a `Staff` object**, but only `Username` and `Password` are
  read from it — the rest are ignored. Reusing the model keeps things simple.
- **`BCrypt.Net.BCrypt.Verify(plaintext, hash)`** is the counterpart to the
  `HashPassword` you used on Create back in Lesson 2. It re-hashes the attempt and
  compares — it never "un-hashes" the stored value.
- **Same 404 for both failure cases** — unknown username *and* wrong password both
  return `NotFound()`, so an attacker can't tell which usernames exist. (There's no
  `Unauthorized()` here because there's no auth scheme to be unauthorized against.)

### ⚠️ Do not "improve" this

Do not add `[Authorize]` attributes, JWT bearer middleware, token generation, or a
tighter CORS policy. These omissions are intentional and the same on PRS. If a
tutorial or AI assistant suggests adding JWT, that's out of scope for this course.

---

## 4. Verifying Login in Insomnia

Expand the **Auth** folder:

1. **Login** with `jordan.reyes` / `test1234` → Send → expect **200 OK** with a
   full Staff object (`id`, `username`, `firstName`, roles, etc.).
2. Change the password in the body to something wrong → Send → expect **404 Not
   Found**.
3. Change the username to one that doesn't exist → Send → also **404**.

The **Tests** tab confirms a 200 and that the response has `id` and `username`
fields. Remember: every seed account's password is the plaintext `test1234`.

> **Note:** nothing else in the collection depends on Login — there's no token to
> carry forward, and every other endpoint works whether or not you've logged in.
> Running Login is optional: it just confirms your credentials and shows the Staff
> object shape.

---

## The General Pattern (what to take away)

You've now built a complete Web API following one repeating shape:

1. **Model** → **DbContext `DbSet`** → **Program.cs registration** → **Controller**
2. **RCUD** on every entity: GetAll, GetById, Create, Update, Delete
3. **Right status code for every outcome**: 200 / 201 / 204 / 400 / 404
4. **Related data** via navigation properties + `Include` / `ThenInclude`, with
   `[JsonIgnore]` to break cycles
5. **Side effects** (recalculate the parent) and **workflow endpoints**
   (`/{resource}/{id}/{verb}`) where CRUD isn't enough
6. **Login** that verifies a BCrypt password and returns the entity — no tokens

Everything you built on TableServe in this pass has a direct PRS equivalent:

| TableServe (this pass) | PRS (capstone) |
|------------------------|-----------------|
| Staff | Users |
| Categories | Vendors |
| MenuItems (FK → Category) | Products (FK → Vendor) |
| Orders (workflow, total, nested items) | Requests (workflow, total, nested lines) |
| OrderItems (recalc parent total) | RequestLines (recalc parent total) |
| Cancel (reason branch) | Reject (reason branch) |
| status-advance endpoints | review / approve endpoints |

Two PRS pieces have **no TableServe rehearsal** and will be taught directly:
the **dual-role FK** (a Request references a User as both submitter and reviewer)
and the **$50 auto-approve rule** on the Review endpoint. Everything else, you've
already done — just with different entity names.

---

## Next: the PRS backend capstone

During the capstone you'll build the PRS backend independently — Users, Vendors,
Products, Requests (with `/review`, `/approve`, `/reject`), and RequestLines — drop
in the same pre-written Login code, and verify everything with the PRS Insomnia
collection. There's regular instructor direction, but the code is yours to write. TableServe is
your worked reference for every pattern except the two named exceptions above.
