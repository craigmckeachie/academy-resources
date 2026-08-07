# Lesson 20 Guide — Testing a Page That Fetches *(optional)*

**Goal:** by the end of this lesson you can test a page that loads its own data — run a fake API
in front of your component with **MSW**, assert the rows that come back, catch the loading state
on the way past, and force a **500** to prove the error handling works. You'll do it on
`MenuItemList`; the lab does `StaffList` and the delete flow.

**The general pattern you're learning:** Lesson 19 stopped at components you hand props to.
Every interesting page in this app doesn't take props — it goes and gets its own data, and
that's the thing that made it untestable. The fix isn't to replace your code with a fake, it's
to **replace the network** and let all of your code run.

> **How to use this guide.** Sections headed **▶ Code along** are ones you build into your
> project (each ends with a quick **Save and check**); unmarked sections are concept.

> **Prerequisite:** **Lesson 19** — this builds directly on its setup (jsdom, React Testing
> Library, `vitest.setup.ts`). If you skipped 19, skip this too.

!!! note "Also optional, and also self-contained"

    One more package and one more concept. Everything it needs lives in this lesson, and
    Lessons 17–19 keep working untouched.

<!-- Authoring note (not student-facing): L20 is OPTIONAL and depends on L19's setup. It
     REVERSES L19 §6's "mocking is out of scope" boundary — that section now points here, so
     keep the two in sync if either is regenerated.
     MSW v2 API: `http` + `HttpResponse` from "msw", `setupServer` from "msw/node". Do not
     write v1 syntax (`rest.get`, `res(ctx.json())`).
     Handler URLs must match TableServe's real BASE_URL — http://localhost:5556/api — which is
     5556, NOT 5555 (that's PRS). menuItemAPI.list() also calls delay(200), which is what makes
     the loading assertion in §5 possible; don't remove it from the reference app.
     Lifecycle (listen/resetHandlers/close) is deliberately IN THE TEST FILE rather than in
     vitest.setup.ts, so L17–L18's node-environment tests are unaffected. §3 says why. -->

---

## 1. Two ways to fake a server, and why we're picking one

`MenuItemList` calls `menuItemAPI.list()`, which calls `fetch`. In a test there's no API
running, so something has to stand in. You have two options and they are **not** equivalent.

**Mock the module** — Vitest can replace `MenuItemAPI.ts` with a fake:

```ts
vi.mock("./MenuItemAPI");   // menuItemAPI.list() now returns whatever you say
```

Cheap, built in, and it cuts out more than you'd like. Look at what `list()` actually does:

```ts
return fetch(url).then(delay(200)).then(checkStatus).then(parseJSON);
```

Mock the module and **none of that runs** — not `checkStatus`, not `parseJSON`, not the URL it
builds. You'd be testing your component against your own idea of what your API module does.

**Mock the network** — MSW (Mock Service Worker) intercepts the `fetch` itself and answers it.
Your real `MenuItemAPI.ts` runs, your real `checkStatus` runs, your real `parseJSON` runs. The
only thing that isn't real is the server on the other end.

That's the one we'll use, and the reason is the sentence from Lesson 19: *the more your tests
resemble the way your software is used, the more confidence they can give you.* Faking the last
hop resembles reality; faking your own module doesn't.

!!! note "`vi.mock` isn't wrong — it's for a different job"

    Use it when the thing you need to control **isn't HTTP**: a browser dialog, a random
    number, the clock. Section 6 does exactly that with `window.confirm`, because there's no
    network involved in a confirm box.

    The rule of thumb: **network → MSW, everything else → `vi.mock` / `vi.spyOn`.**

---

## 2. ▶ Code along — install MSW and describe your fake API

```bash
npm i -D msw
```

Handlers describe what the fake server does. Create them in a `mocks` folder:

```ts title="src/mocks/handlers.ts"
import { http, HttpResponse } from "msw";
import { IMenuItem } from "../menuItems/IMenuItem";

export const menuItems: IMenuItem[] = [
  {
    id: 1,
    name: "Loaded Fries",
    price: 8.5,
    categoryId: 2,
    category: { id: 2, name: "Sides", sortOrder: 1 },
  },
  {
    id: 2,
    name: "House Burger",
    price: 14,
    categoryId: 1,
    category: { id: 1, name: "Mains", sortOrder: 0 },
  },
];

export const handlers = [
  http.get("http://localhost:5556/api/menuitems", () => {
    return HttpResponse.json(menuItems);
  }),
];
```

Then the server that runs them:

```ts title="src/mocks/server.ts"
import { setupServer } from "msw/node";
import { handlers } from "./handlers";

export const server = setupServer(...handlers);
```

Two things worth noticing:

- **The URL has to match what your app really requests.** `BASE_URL` in
  `utility/fetchUtilities.ts` is `http://localhost:5556/api`, and `MenuItemAPI.ts` appends
  `/menuitems`. Get this wrong and MSW won't intercept — it'll warn you about an unhandled
  request, which is the error message to recognise.
- **`msw/node`, not `msw`.** Same library, two environments: `setupServer` for tests in Node,
  `setupWorker` for a real browser. You want the first.

---

## 3. ▶ Code along — start and stop it around your tests

MSW has to be switched on before tests run and off afterwards. Create the test file:

```tsx title="src/menuItems/MenuItemList.test.tsx"
/**
 * @vitest-environment jsdom
 */
import { describe, it, expect, beforeAll, afterEach, afterAll } from "vitest";
import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { server } from "../mocks/server";
import MenuItemList from "./MenuItemList";

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

| | |
|---|---|
| `server.listen()` | Start intercepting, once, before anything runs |
| `server.resetHandlers()` | Undo any per-test overrides, so one test can't leak into the next |
| `server.close()` | Stop intercepting and give `fetch` back |

That middle one matters more than it looks — section 5 overrides a handler to return a 500, and
without the reset every test after it would get a 500 too.

!!! note "MSW's docs put these three lines in a shared setup file"

    And on a real project you would, once several files need them. We're keeping them in the
    test file so **Lessons 17 and 18 stay exactly as they are** — those run in plain Node and
    have no business starting a fake server.

---

## 4. ▶ Code along — the happy path, and a new kind of query

Here's the test you'd expect to write, and it fails:

```tsx
it("shows the menu items", () => {
  render(<MemoryRouter><MenuItemList /></MemoryRouter>);
  expect(screen.getByText("Loaded Fries")).toBeInTheDocument();   // ❌
});
```

`getByText` looks **right now**, and right now the fetch hasn't come back — `MenuItemList`
renders empty, then fills in when the promise resolves. Nothing you learned in Lesson 19 waits
for anything, because props arrive instantly and data doesn't.

That's what `findBy…` is for. It's the same query, but it **returns a promise and retries until
the element turns up**:

```tsx title="src/menuItems/MenuItemList.test.tsx"
describe("MenuItemList", () => {
  it("renders a card for each menu item the API returns", async () => {
    render(
      <MemoryRouter>
        <MenuItemList />
      </MemoryRouter>
    );

    expect(await screen.findByText("Loaded Fries")).toBeInTheDocument();
    expect(await screen.findByText("House Burger")).toBeInTheDocument();
    expect(await screen.findByText("Sides")).toBeInTheDocument();
  });
});
```

**The three query families, now complete:**

| | When nothing matches | Waits? |
|---|---|---|
| `getBy…` | throws | no |
| `queryBy…` | returns `null` | no |
| `findBy…` | rejects after ~1s | **yes** — for data that hasn't arrived |

Rule of thumb: **the first thing you assert after a fetch is a `findBy`.** Once you've awaited
that, the data is on screen and `getBy` works fine for everything else.

**Save and check**

- **1 passed** — with no API running. Stop your `dotnet run` if it's up; the test doesn't care.
- Change `"Loaded Fries"` in `handlers.ts` and watch the test fail with the new name. **You're
  driving the API now.**

---

## 5. ▶ Code along — the loading state, and the error path

`menuItemAPI.list()` has `.then(delay(200))` in it — a deliberate 200ms pause so the skeletons
are visible in the browser. That pause is real in tests too, which makes the loading state
something you can actually assert:

```tsx title="src/menuItems/MenuItemList.test.tsx"
  it("shows skeletons while the menu items are loading", async () => {
    const { container } = render(
      <MemoryRouter>
        <MenuItemList />
      </MemoryRouter>
    );

    expect(container.querySelectorAll(".skeleton").length).toBeGreaterThan(0);

    await screen.findByText("Loaded Fries");
    expect(container.querySelectorAll(".skeleton")).toHaveLength(0);
  });
```

*(Skeletons are decorative — no text, no role — so this is one of the rare fair uses of
`container.querySelector`. Reach for it when there's genuinely nothing a user could perceive to
query by, not when a role would have worked.)*

Now the half nobody tests. Override the handler **for this test only**:

```tsx title="src/menuItems/MenuItemList.test.tsx"
import { http, HttpResponse } from "msw";
import { Toaster } from "react-hot-toast";

  it("shows an error toast when the API fails", async () => {
    server.use(
      http.get("http://localhost:5556/api/menuitems", () => {
        return new HttpResponse(null, { status: 500 });
      })
    );

    render(
      <MemoryRouter>
        <MenuItemList />
        <Toaster />
      </MemoryRouter>
    );

    expect(
      await screen.findByText("There was an error saving or retrieving data.")
    ).toBeInTheDocument();
  });
```

Read what just happened, because it's the payoff for two lessons:

- MSW returned a **500**.
- Your real `checkStatus` saw a non-ok response and threw — **the function you unit-tested in
  Lesson 18**, now running inside a component.
- The message came from your real `translateStatusToErrorMessage`, which is why the assertion
  is that exact sentence.
- `MenuItemList`'s `catch` called `toast.error`, and `<Toaster />` rendered it.

**`<Toaster />` has to be in the render.** In the app it lives in `App.tsx`; a toast with
nothing to display it is queued and invisible. If you assert a toast and get nothing, that's
almost always why.

And `server.use()` only applies until the next `afterEach` — that's `resetHandlers()` doing its
job, and it's why the happy-path test still passes after this one.

**Save and check**

- **3 passed.**
- Comment out `afterEach(() => server.resetHandlers())` and re-run. Watch the earlier tests
  start failing depending on the order they ran in. Put it back — that's the line that keeps
  tests independent.

---

## 6. When `vi.spyOn` is the right tool

Clicking **Delete** on a card calls `confirm()` before it calls the API. `confirm` isn't a
network request — it's a browser dialog, and jsdom doesn't implement one. MSW can't help; this
is the `vi.mock` family's job:

```tsx
vi.spyOn(window, "confirm").mockReturnValue(true);
```

Now the code under test gets `true` and carries on to the DELETE, which **MSW** handles. Two
tools, one flow, each doing the part it's suited to — and that's the lab.

---

## The General Pattern (what to take away)

- **Replace the network, not your own code.** Mocking your API module skips the fetch helpers
  you wrote; mocking the network runs them.
- **Network → MSW. Everything else → `vi.mock` / `vi.spyOn`.**
- **`findBy…` is the query for data that hasn't arrived** — it waits and retries. `getBy` right
  after a `render` will always be too early.
- **Reset handlers between tests**, or a 500 you set up in one test leaks into the next.
- **Override per test with `server.use()`** — one handler for the happy path in `handlers.ts`,
  the failures declared where they're being tested.
- **The error path is worth more than the happy path**, because it's the one nobody ever clicks
  through by hand.
- **Assert a toast and you must render `<Toaster />`** — the component that displays it isn't
  the component under test.

---

## Build Steps

1. `npm i -D msw`.
2. Create `src/mocks/handlers.ts` with sample menu items and a `http.get` handler for
   `http://localhost:5556/api/menuitems`.
3. Create `src/mocks/server.ts` exporting `setupServer(...handlers)` from `msw/node`.
4. Create `src/menuItems/MenuItemList.test.tsx` with the `@vitest-environment jsdom` docblock
   and the `listen` / `resetHandlers` / `close` lifecycle.
5. Write the happy-path test using **`await screen.findByText(...)`**, and confirm it passes
   with your API stopped.
6. Try it with `getByText` instead, watch it fail, and put `findBy` back.
7. Add the loading test — assert `.skeleton` elements exist, then that they're gone once the
   data arrives.
8. Add the error test: `server.use(...)` returning a 500, render `<Toaster />`, and assert the
   message your `translateStatusToErrorMessage` produces.
9. Comment out `resetHandlers()`, watch tests interfere with each other, and restore it.
