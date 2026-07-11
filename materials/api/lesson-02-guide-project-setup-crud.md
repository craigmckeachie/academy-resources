# Lesson 2 Guide — Web API Project Setup

**Goal:** by the end of this lesson you have a working ASP.NET Core Web API
project connected to a SQL Server database via Entity Framework Core, with a
`StaffController` that handles GET requests, verified live in Insomnia. No forms,
no complex relationships — this lesson is purely about getting the pipeline working
end to end.

**The general pattern you're learning:** data flows from SQL Server → EF Core →
Controller → HTTP response. Every controller you build for the rest of this pass
follows this same pipeline.

---

## 1. What is a Web API?

A Web API is a program that listens for HTTP requests and returns data — usually
JSON — instead of HTML pages. The front end (React, mobile app, Insomnia) sends
requests; the API responds with data. That's the entire job.

In this course, your React front end will talk to your Web API the same way a
browser talks to any web service — over HTTP, using GET/POST/PUT/DELETE.

```
React App  ──HTTP request──▶  Web API  ──query──▶  SQL Server
           ◀──JSON response──           ◀──data───
```

---

## 2. Creating the Project

In Visual Studio: **File → New → Project → ASP.NET Core Web API**

Settings to choose:
- Framework: **.NET 8**
- Authentication: **None**
- Configure for HTTPS: **yes**
- Enable OpenAPI support: **yes** (gives you Swagger for testing)
- Use controllers: **yes** (not minimal API)

This generates a working project with one sample `WeatherForecastController`.
You'll delete that shortly — it's just scaffolding to show the pattern.

---

## 3. Project Structure

After creation, the key files are:

```
TableServe.Api/
  Controllers/          ← your controllers live here
  Models/               ← create this folder — entity classes live here
  Data/                 ← create this folder — DbContext lives here
  Program.cs            ← wires everything together (DI, middleware, routing)
  appsettings.json      ← connection string and other config
  TableServe.Api.csproj ← project file, NuGet packages declared here
```

Delete `WeatherForecast.cs` and `Controllers/WeatherForecastController.cs` —
you won't need them.

---

## 4. NuGet Packages

You need two packages for EF Core with SQL Server. Install via **NuGet Package Manager**
or the **Package Manager Console**:

```
Microsoft.EntityFrameworkCore.SqlServer
Microsoft.EntityFrameworkCore.Tools
```

`SqlServer` is the EF Core database provider. `Tools` gives you the `Add-Migration`
and `Update-Database` commands in the Package Manager Console.

---

## 5. The Model

A model is a C# class whose properties map directly to columns in a database table.
Create `Models/Staff.cs`:

```csharp
namespace TableServe.Api.Models;

public class Staff
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Email { get; set; }
    public bool IsManager { get; set; }
    public bool IsAdmin { get; set; }
}
```

A few things to notice:
- `string.Empty` as the default value avoids null warnings on required strings
- `string?` (with the `?`) marks a property as nullable — optional in the database
- `bool` defaults to `false` automatically — no explicit default needed
- EF Core will treat a property named `Id` as the primary key automatically

---

## 6. The DbContext

The DbContext is EF Core's gateway to the database. It holds a `DbSet<T>` for
each table you want to query. Create `Data/TableServeDbContext.cs`:

```csharp
using Microsoft.EntityFrameworkCore;
using TableServe.Api.Models;

namespace TableServe.Api.Data;

public class TableServeDbContext : DbContext
{
    public TableServeDbContext(DbContextOptions<TableServeDbContext> options)
        : base(options) { }

    public DbSet<Staff> Staff { get; set; }
}
```

`DbContextOptions` is passed in from `Program.cs` via dependency injection — the
DbContext doesn't configure its own connection, it receives the configuration from
outside. This is why you can swap databases in tests without changing the DbContext.

---

## 7. The Connection String

In `appsettings.json`, add your SQL Server Express connection string:

```json
{
  "ConnectionStrings": {
    "TableServeDb": "Server=.\\SQLEXPRESS;Database=TableServeDb;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

- `.\SQLEXPRESS` points to the SQL Server Express instance installed on your machine
- `Trusted_Connection=True` uses Windows authentication — no username/password needed
- `TrustServerCertificate=True` avoids SSL certificate errors in development

---

## 8. Wiring It Up in Program.cs

`Program.cs` is where you register services (dependency injection) and configure
the HTTP pipeline (middleware). Add the DbContext registration before `builder.Build()`:

```csharp
builder.Services.AddDbContext<TableServeDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("TableServeDb")));
```

This tells ASP.NET Core: "whenever a controller asks for a `TableServeDbContext`,
create one using the SQL Server connection string from `appsettings.json`."

Also add CORS — **but comment out `app.UseCors()` for now**. You'll uncomment it
live when the React front end first tries to call this API and hits a CORS error:

```csharp
// Register CORS policy
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});
```

And in the middleware pipeline after `builder.Build()`:

```csharp
// app.UseCors(); // ← uncomment this when React front end calls the API
```

---

## 9. Migrations and the Database

EF Core creates your database from your models using **migrations** — a versioned
record of every change to your schema. Run these in the **Package Manager Console**
(Tools → NuGet Package Manager → Package Manager Console):

```
Add-Migration InitialCreate
Update-Database
```

`Add-Migration` generates a C# file describing the schema (creates a `Migrations/`
folder in your project). `Update-Database` applies those changes to SQL Server,
creating the `TableServeDb` database and `Staff` table if they don't exist.

After running `Update-Database`, open **SQL Server Object Explorer** in Visual Studio
(View → SQL Server Object Explorer) to verify your `TableServeDb` database and
`Staff` table exist.

---

## 10. Seed Some Data

Run this in SSMS to add a few Staff records so your GET endpoints return real data:

```sql
INSERT INTO [dbo].[Staff]
    ([Username], [Password], [FirstName], [LastName], [Phone], [Email], [IsManager], [IsAdmin])
VALUES
    ('jordan.reyes', '$2a$11$gPJJsroTfOFOyThpMTqctu8TIjSKNbjKG0f.Hlw/4xggmy8VS1cMa',
     'Jordan', 'Reyes', '3035558214', 'jordan.reyes@example.com', 1, 1)

INSERT INTO [dbo].[Staff]
    ([Username], [Password], [FirstName], [LastName], [Phone], [Email], [IsManager], [IsAdmin])
VALUES
    ('riley.thompson', '$2a$11$gPJJsroTfOFOyThpMTqctu8TIjSKNbjKG0f.Hlw/4xggmy8VS1cMa',
     'Riley', 'Thompson', '2065518843', 'riley.thompson@example.com', 0, 0)

INSERT INTO [dbo].[Staff]
    ([Username], [Password], [FirstName], [LastName], [Phone], [Email], [IsManager], [IsAdmin])
VALUES
    ('morgan.ellis', '$2a$11$gPJJsroTfOFOyThpMTqctu8TIjSKNbjKG0f.Hlw/4xggmy8VS1cMa',
     'Morgan', 'Ellis', '4048825671', 'morgan.ellis@example.com', 0, 1)
```

---

## 11. Your First Controller

A controller is a class that handles incoming HTTP requests and returns responses.
Create `Controllers/StaffController.cs`:

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
}
```

A few things to notice:

- **`[ApiController]`** — tells ASP.NET this is an API controller. Enables
  automatic model validation and JSON binding.
- **`[Route("api/[controller]")]`** — sets the base URL. `[controller]` is replaced
  with the class name minus "Controller" — so `StaffController` becomes `api/staff`.
- **`ControllerBase`** — the base class for API controllers. Provides helper methods
  like `NotFound()`, `Ok()`, `BadRequest()`. These all return `IActionResult` —
  an interface representing "some kind of HTTP response." `NotFound()` sends a 404,
  `Ok(data)` sends a 200 with JSON.
- **Constructor injection** — the DbContext is injected automatically by ASP.NET's
  DI container, the same system you registered it in `Program.cs`.
- **`async/await`** — database calls are I/O operations. Making them async frees
  the thread to handle other requests while waiting for SQL Server. Always use the
  async versions: `ToListAsync`, `FindAsync`, etc.

---

## 12. Verifying with Insomnia

Insomnia is an API testing tool — it lets you send HTTP requests to your API
and inspect the responses without needing a front end. You've been given a
pre-built collection for TableServe that covers every endpoint with tests
already configured.

### Importing the collection

1. Open Insomnia
2. Click **File → Import**
3. Navigate to and select [`tableserve-insomnia.json`](https://github.com/craigmckeachie/academy-resources/blob/main/files/tableserve-insomnia.json) from the academy-resources
   `files/` folder
4. The **TableServe** collection appears in the left sidebar with folders for
   Auth, Staff, Categories, MenuItems, Orders, and OrderItems

### Setting the base URL

The collection uses an environment variable called `baseUrl` so you only need
to set your port number once rather than in every request.

1. Run the project in Visual Studio (F5) — a browser opens with a URL like
   `https://localhost:7234`
2. Note the port number (e.g. `7234`)
3. In Insomnia, click the environment dropdown at the top of the sidebar
   (it may say "No Environment" or show a gear icon)
4. Select **Manage Environments → Base Environment**
5. Set `baseUrl` to match your port:
   ```json
   {
     "baseUrl": "https://localhost:7234"
   }
   ```
6. Save and close

### Trying the Login request

The collection has an **Auth** folder with a Login request. TableServe.Api does
not implement token-based authentication — there's no JWT and no
`Authorization` header on any request in the collection. Once the API is
running, **every endpoint is open**; Login just verifies the username/password
and returns the full Staff object.

Because there's no token to carry forward, **you don't have to log in before
calling the other endpoints** — they work regardless. Login is still worth
running once as a quick sanity check that your credentials work and to see the
shape of a Staff record:

1. Expand the **Auth** folder
2. Click **Login**
3. Click **Send** — you should get a `200 OK` with a Staff object in the
   response (id, username, firstName, etc.)

### Verifying your Staff endpoints

With the project running:

1. Expand the **Staff** folder
2. Click **Get All Staff** → Send → expect `200 OK` with 3 staff records
3. Click **Get Staff by Id** → Send → expect `200 OK` with Jordan Reyes
4. Click **Get Staff by Id (Not Found)** → Send → expect `404 Not Found`

Each request has after-response tests that run automatically — look for the
**Tests** tab in the response panel. Green = pass, red = fail. If a test
fails, the response panel shows what was expected vs. what was received.

### What to do if you see connection errors

Make sure the project is still running in Visual Studio — if it stopped,
press F5 again and verify the port number matches your `baseUrl`.

---

## The General Pattern (what to take away)

Every controller in this course follows the same shape:

1. **Model** — a C# class mapping to a database table
2. **DbContext** — holds a `DbSet<T>` for each table
3. **Program.cs** — registers the DbContext with DI
4. **Controller** — receives the DbContext via constructor injection, queries it,
   returns JSON

When you build the PRS backend in the capstone, you'll repeat this exact pattern
for five entities. The only things that change are the model properties and the
controller name.

---

## Build Steps

1. Create a new **ASP.NET Core Web API** project named `TableServe.Api`
2. Delete `WeatherForecast.cs` and `Controllers/WeatherForecastController.cs`
3. Install NuGet packages: `Microsoft.EntityFrameworkCore.SqlServer` and
   `Microsoft.EntityFrameworkCore.Tools`
4. Create `Models/Staff.cs` with the properties listed in section 5
5. Create `Data/TableServeDbContext.cs` with a `DbSet<Staff>`
6. Add the SQL Express connection string to `appsettings.json`
7. Register the DbContext in `Program.cs`
8. Add CORS to `Program.cs` with `app.UseCors()` commented out
9. Run `Add-Migration InitialCreate` then `Update-Database` in Package Manager Console
10. Verify the `Staff` table exists in SQL Server Object Explorer
11. Run the seed INSERT statements in SSMS
12. Create `Controllers/StaffController.cs` with `GetAll` and `GetById`
13. Run the project, import the Insomnia collection, set `baseUrl`, and verify
    the Staff endpoints (optionally try Login too) — see section 12 for full details
