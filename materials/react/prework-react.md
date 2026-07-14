# React Prework — Optional Head Start

**Optional. Not required for the capstone.** This packet is for students who finish the
PRS backend capstone early and want to get a running start on the React pass instead of
waiting. Nothing here is graded, and skipping it costs you nothing — the React pass
teaches all of it from scratch.

**What it front-loads:** React opens with two intro lessons — **JavaScript, then
TypeScript, for C# developers** (Lessons 1–2) — and first fetches real data in Lesson 4.
This packet is a light on-ramp to exactly that material, ending with a mini-project that
calls **your own PRS API** from the browser. When those lessons arrive, they'll feel like
review instead of a firehose.

**The one big idea:** you already know how to program. React is written in JavaScript +
TypeScript, and TypeScript is close enough to C# that most of this is *translation*, not
new concepts. Learn the handful of genuinely new pieces (destructuring, spread, modules,
`fetch`) and the rest maps onto what you already know.

> For the full treatment of Parts 1–2 below, the actual lesson guides are right here in
> this folder: [JavaScript for C# developers](lesson-01-guide-javascript-for-csharp-devs.md)
> and [TypeScript for C# developers](lesson-02-guide-typescript-for-csharp-devs.md). This
> packet is the short, do-it-yourself version — the lessons go deeper.

---

## Before you start

- **Node.js** installed (`node --version` should print v18+).
- Your **PRS API runs** and you can hit it (you just finished it). Run it over **`http`**,
  not `https`, so the browser doesn't block it over a self-signed dev certificate — the
  same reason the Insomnia collection uses an `http://` base URL.
- **Two tools, two jobs:** you **edit code in VS Code** and **observe in the browser** —
  the running page plus **DevTools → Console / Network** (F12, or right-click → Inspect).
  You never type code into DevTools; it's only for reading output. (No Insomnia here — this
  is the front-end world now.)

---

## Part 0 — Set up the scratch project (once)

Create the same throwaway TypeScript sandbox the React pass uses in Lessons 1–2. From a
folder **outside** your API work:

```bash
npm create vite@latest js-ts-playground -- --template vanilla-ts
cd js-ts-playground
npm install
npm run dev
```

`--template vanilla-ts` gives you plain TypeScript with **no framework** — just a file to
run code in. Open the `js-ts-playground` folder in **VS Code** — that's where you edit
code. `npm run dev` prints a URL (usually `http://localhost:5173`); open it in the
**browser** and show **DevTools → Console**. Now edit `src/main.ts` **in VS Code** and
save — Vite reloads the page automatically, and anything you `console.log(...)` appears in
the browser Console. You write code in the editor; the browser (and its DevTools) is only
for running and reading output. This is your C# console app equivalent.

You are **not** throwing this project away — it's the exact sandbox Lessons 1–2 use, so
you're set up early.

---

## Part 1 — JavaScript & TypeScript warm-up

Work through this checklist in `src/main.ts`, logging results to the Console. Each item is
anchored to the C# you already know. Don't just read — type a line or two for each and
watch the output. If you already know modern JS/TS, skim this and jump to **Part 2**.

**JavaScript (Lesson 1 material):**

- [ ] `const` by default, `let` when a value changes; never `var`. Compare with `===` /
      `!==` (never `==`). `const` is like C#'s `var`, but not reassignable.
- [ ] **Arrow functions** — `const double = (n) => n * 2;` — same idea and same `=>` as a
      C# lambda.
- [ ] **Template literals** — `` `${item} — $${price}` `` — C#'s `$"{item} — ${price}"`,
      with backticks.
- [ ] **Objects & destructuring** — `const { name, price } = product;` pulls properties
      into variables in one line. No C# equivalent; worth slowing down for.
- [ ] **Spread** — `const copy = { ...product, onSale: true };` makes a **new** object
      (doesn't mutate). Also `[...arr, next]` for arrays.
- [ ] **`.map()` and `.filter()`** — these are **LINQ's `.Select()` and `.Where()`**:
      `products.map(p => p.name)`, `products.filter(p => p.price < 50)`. Both return a
      **new** array. Rendering a list in React is just `.map()` — this is the single most
      important pattern to bring with you.
- [ ] **ES modules** — `export` from one file, `import` into another. Components are
      default exports; helpers/interfaces/hooks are named exports (`import { x } from`).

**TypeScript (Lesson 2 material):**

- [ ] The **type map**: `number` for every C# numeric (`int`/`long`/`double`/`decimal`),
      `string`, `boolean`, `T[]` for `List<T>`, `Record<K,V>` for `Dictionary<K,V>`.
- [ ] **`interface`** describes a data shape — the front-end echo of your C# model class.
      We prefix ours with `I` (`IProduct`, `IRequest`). TypeScript matches **structurally**
      (by shape, not name) — that's the one real surprise coming from C#.
- [ ] **Optional `?`** (`phone?: string`) and **union `|`** (`number | null`,
      `"NEW" | "REVIEW" | "APPROVED"`) — how TS expresses `string?` and enum-like values.
- [ ] **`async`/`await`** — identical keywords to C#. The only new part: a JS async
      function returns a **`Promise<T>`** (C#'s `Task<T>`). You'll use this in Part 2.

**References (official docs):**
- [TypeScript for Java/C# Programmers](https://www.typescriptlang.org/docs/handbook/typescript-in-5-minutes-oop.html)
  — written for exactly your background.
- [MDN: Destructuring](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment)
  — the one genuinely new idea.

---

## Part 2 — Mini-project: call your own PRS API from the browser

This is the payoff. You'll fetch real data from the PRS backend you just built, type it,
transform it, and render it — the exact shape of what React does, minus React. Do it all
in `src/main.ts`.

### 1. Describe the data with an interface

Mirror your PRS `Product` model as a TypeScript interface (this is Lesson 2's whole
point — the interface is the front-end echo of your C# model):

```ts
export interface IProduct {
  id: number;
  partNumber: string;
  name: string;
  price: number;
  unit: string;
  photoPath: string | null;   // C# string? → string | null
  vendorId: number;
  vendor?: { id: number; code: string; name: string };  // included by GetAll — see below
}
```

### 2. Fetch the list

`fetch` + `await` + `.json()` is the whole data-loading pattern. Point `BASE_URL` at
**your** PRS API's port:

```ts
const BASE_URL = "http://localhost:5555/api";  // ← use your API's actual port

async function loadProducts(): Promise<IProduct[]> {
  const response = await fetch(`${BASE_URL}/products`);
  if (!response.ok) throw new Error(`Request failed: ${response.status}`);
  return response.json();
}

async function main() {
  try {
    const products = await loadProducts();
    console.log(products.length, "products");
    console.log(products.map((p) => p.name));            // LINQ .Select
    console.log(products.filter((p) => p.price < 50));   // LINQ .Where
    console.log(products[0].vendor);                     // the included nav object
  } catch (error) {
    console.error(error);
  }
}

main();
```

Notice `products[0].vendor` is a whole nested object, not just a `vendorId` — because your
`ProductsController.GetAll` uses `.Include(product => product.Vendor)`. That's the same
navigation-property idea from the API pass, now visible in the browser.

> **`async`/`await`, not `.then()`** — `fetch` returns a **Promise** (JavaScript's
> `Task<T>`), and there are two ways to handle one: `await` it inside an `async` function
> and wrap errors in `try`/`catch` — the C# style, and what this packet uses — or chain
> `.then(...).catch(...)`. They're the same thing, two spellings. You'll see the `.then()`
> form in step 5 and all over MDN; prefer `async`/`await` for readable top-to-bottom code.

### 3. Hit the CORS wall (expected!)

Your first run will very likely **fail** with a message like *"blocked by CORS policy"* in
the Console, and the Network tab will show the request in red. This is not a bug — it's the
browser's **Cross-Origin Resource Sharing** rule: your scratch app runs on
`http://localhost:5173` and your API on a different port, so they're different *origins*,
and the browser blocks the cross-origin read unless the API opts in.

The fix: your PRS `Program.cs` already has a wide-open CORS policy registered from the API
pass, with the `app.UseCors()` line **commented out**. Uncomment it and restart the API:

```csharp
app.UseCors();   // ← was commented out; enable it so the browser can read the API
```

> You're getting an early look at something the **React pass covers in Lesson 4** ("hit a
> CORS error, fix it live"). Leave the policy wide open — this course uses a permissive
> dev CORS policy on purpose; don't lock it down.
>
> Reference: [MDN: Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS).

### 4. Render the list to the page (a `.map()` preview of React)

Rendering a list is just a transform: an **array of data** mapped into an **array of
markup**. Replace the sandbox `#app` contents:

```ts
async function render() {
  const products = await loadProducts();
  const app = document.querySelector<HTMLDivElement>("#app")!;
  app.innerHTML = `
    <ul>
      ${products.map((p) => `<li>${p.name} — $${p.price} (${p.vendor?.name ?? "no vendor"})</li>`).join("")}
    </ul>
  `;
}

render();
```

When React arrives, you'll write almost this exact `.map()` — but producing **JSX
elements** instead of a string of HTML, and letting React put them on the page. Same idea,
nicer tools.

### 5. (Optional) The other style — a `.then()` chain

`.then()` / `.catch()` is the original way to handle a Promise, and you'll meet it
constantly — MDN examples use it, and the real TableServe/PRS front ends centralize fetch
in a `fetchUtilities` module composed with `.then()` chains. It's the same Promise as
`async`/`await`, just written as a chain; small compose-and-forget helpers read nicely this
way:

```ts
async function checkStatus(response: Response): Promise<Response> {
  if (response.ok) return response;
  throw new Error(`There was an error retrieving data (${response.status}).`);
}

function parseJSON<T>(response: Response): Promise<T> {
  return response.json();
}

// .then() runs on success; .catch() handles a rejection — the chain form of try/catch:
fetch(`${BASE_URL}/products`)
  .then(checkStatus)
  .then((response) => parseJSON<IProduct[]>(response))
  .then((products) => console.log(products.length, "products"))
  .catch((error) => console.error(error));
```

That's the exact same request as `loadProducts()` in step 2 — pick whichever reads better.
This course leans on `async`/`await` (it maps to C#) and reaches for `.then()` chains for
tiny helpers like these.

### 6. (Optional) Create a product with POST

Send a body and read back what the API returns (a preview of the create-form flow):

```ts
const response = await fetch(`${BASE_URL}/products`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    partNumber: "PRE-001", name: "Prework Widget", price: 12.99,
    unit: "Each", photoPath: null, vendorId: 1,
  }),
});
const created = await response.json();
console.log("created id:", created.id, "with vendor:", created.vendor?.name);
```

Because `main.ts` is an ES module, you can `await` at the top level — no wrapper function
needed.

Reference: [MDN: Using the Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch).

---

## Part 3 — What this sets you up for

Everything you touched returns in the React pass — you'll recognize it instead of meeting
it cold:

| What you did here | Where it returns |
|---|---|
| `interface IProduct`, typed arrays | Lessons 2–3 (typed data, the `I{Entity}` interface per feature folder) |
| `.map()` / `.filter()` on the response | Lesson 3 (rendering a list = transforming an array into UI) |
| `fetch` + `async`/`await` + `.json()` | Lesson 4 (loading real data into a page) |
| Hitting and fixing the CORS error | Lesson 4 (the live CORS moment) |
| The `checkStatus` / `parseJSON` helper | Lesson 12 (centralized fetch + error handling) |
| POST with a JSON body | Lesson 7 (create/edit forms) |

You do **not** need to start React itself, install React, or write any JSX — stop at the
edge of the language and the browser APIs. That boundary is exactly where Lesson 3 picks
up.

---

## Guardrails

- **Optional and ungraded** — do as much or as little as you like; stop any time.
- **No tokens / no auth headers.** The PRS endpoints are open (no JWT in this course), so
  `fetch` needs no `Authorization` header. Don't add one.
- **Keep CORS wide open** — enable it, don't restrict it. It's a deliberate dev
  simplification.
- **Run the API over `http`**, and use *your* API's port in `BASE_URL`.
