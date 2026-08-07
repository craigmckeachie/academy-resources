# Lesson 19 Guide — Component Testing with React Testing Library *(optional)*

**Goal:** by the end of this lesson you can render a React component in a test, assert what a
**user would see** on the screen it produces, click something with `user-event`, and check what
appeared as a result — without a browser open. You'll do it on `MenuItemCard`; the lab does
`StaffCard`.

**The general pattern you're learning:** a component test asks *"given these props, what's on
the screen?"* and *"after the user does this, what's on the screen now?"* — nothing else. It
never asks what the component's state variable is called or which hook it used. That
restraint is the entire discipline: **test the thing your user experiences, so your tests
survive you rewriting how it works.**

> **How to use this guide.** Sections headed **▶ Code along** are ones you build into your
> project (each ends with a quick **Save and check**); unmarked sections are concept.

> **Prerequisite:** Lessons 17 and 18 — Vitest installed and both utility test files green.

!!! note "This lesson is optional, and it's the only one that installs anything"

    Lessons 17 and 18 needed one package. This one needs four, plus a config change, because
    rendering a component means giving Node something that pretends to be a browser. That's
    exactly why it's the optional one and why it's last: **skip it and nothing you already
    have breaks.** Lessons 17–18 keep running in plain Node, untouched.

!!! warning "Still the terminal, not the browser"

    You're about to render components, and you still won't open DevTools. The DOM here exists
    only in memory, for the length of one test. The signal is still **red → green**.

<!-- Authoring note (not student-facing): L19 is OPTIONAL and must stay self-contained — all
     four packages, vitest.setup.ts and the config change belong here and nowhere earlier, or
     "optional" stops being true.
     Environment is opted into PER FILE with the @vitest-environment docblock, deliberately,
     NOT globally in vite.config.ts: L18 builds real `new Response(...)` objects and must keep
     running in the node environment. Don't "simplify" this by setting environment: "jsdom"
     globally.
     MOCKING (vi.mock / MSW) is out of scope for the whole course — §6 states that boundary
     explicitly, and the Delete item is the concrete example. Don't add a mocked-fetch section. -->

---

## 1. What changes when the unit is a component

Everything you've tested so far took values and returned values. A component takes **props**
and produces **DOM**, so two things have to change:

- **Something has to be the browser.** `document`, `window`, elements — none of that exists in
  Node. **jsdom** is a browser-shaped implementation of the DOM in pure JavaScript, and it's
  enough for this.
- **You need a way to look at the result.** That's **React Testing Library**: `render()` puts
  your component into that fake DOM, and `screen` queries it the way a person would — *find
  the text "Fries"*, *find the button*.

And one thing deliberately doesn't change: **you still assert what's on screen.** Not the
props object, not internal state, not which hook ran. If you rename a state variable and a test
breaks, that test was testing the wrong thing.

| Testing Library asks | It never asks |
|---|---|
| Is this text on the screen? | What's in `useState` right now? |
| Is there a button here? | Did `useEffect` run twice? |
| After a click, did that appear? | What did the component re-render as? |

---

## 2. ▶ Code along — the setup Lessons 17 and 18 didn't need

In `TableServe.Web`:

```bash
npm i -D jsdom @testing-library/react @testing-library/user-event @testing-library/jest-dom
```

| Package | Why |
|---|---|
| `jsdom` | The fake browser |
| `@testing-library/react` | `render()` and `screen` |
| `@testing-library/user-event` | Clicks and typing that behave like a real user's |
| `@testing-library/jest-dom` | Readable DOM matchers — `toBeInTheDocument()` |

That last one has to be registered before your tests run, so create a setup file at the root of
`TableServe.Web`:

```ts title="TableServe.Web/vitest.setup.ts"
import "@testing-library/jest-dom/vitest";
```

And point Vitest at it:

```ts title="TableServe.Web/vite.config.ts"
/// <reference types="vitest" />
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  test: {
    setupFiles: "./vitest.setup.ts",
  },
});
```

**Save and check**

- `npm test` — your **Lesson 17 and 18 tests still pass**, unchanged. You've added matchers,
  not changed how anything runs.

!!! note "Why the fake browser isn't switched on globally"

    You might expect `environment: "jsdom"` in that config. It isn't there on purpose. Your
    utility tests don't need a browser and start faster without one — and Lesson 18's tests
    build real `Response` objects, which belong to Node rather than to jsdom.

    So the browser gets switched on **per file**, by the file that needs it, with a comment at
    the top. You'll write it in the next section. Pay for what you use.

---

## 3. ▶ Code along — render it and look at it

Here's what you're testing, trimmed to what it puts on screen:

```tsx title="src/menuItems/MenuItemCard.tsx"
<span className="fs-4 lh-l fw-medium">{menuItem.name}</span>
<span className="fs-5 fw-light">${menuItem.price}</span>
<div className="badge …">{menuItem.category?.name}</div>
```

Three things a user reads. Test those three things.

```tsx title="src/menuItems/MenuItemCard.test.tsx"
/**
 * @vitest-environment jsdom
 */
import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import MenuItemCard from "./MenuItemCard";
import { IMenuItem } from "./IMenuItem";

const menuItem: IMenuItem = {
  id: 1,
  name: "Loaded Fries",
  price: 8.5,
  categoryId: 2,
  category: { id: 2, name: "Sides", sortOrder: 1 },
};

describe("MenuItemCard", () => {
  it("shows the menu item's name, price, and category", () => {
    render(
      <MemoryRouter>
        <MenuItemCard menuItem={menuItem} onRemove={() => {}} />
      </MemoryRouter>
    );

    expect(screen.getByText("Loaded Fries")).toBeInTheDocument();
    expect(screen.getByText("$8.5")).toBeInTheDocument();
    expect(screen.getByText("Sides")).toBeInTheDocument();
  });
});
```

Four things worth stopping on:

**The docblock at the top** is what switches jsdom on for this file only. It has to be a `/** */`
comment, and it has to be at the top.

**The file is `.tsx`, not `.ts`** — it contains JSX now.

**`MemoryRouter` is not optional.** `MenuItemCard` renders a `<Link>`, and a `Link` outside a
router throws. In the app there's always a router above it; in a test you have to supply one.
`MemoryRouter` is the version that keeps its history in memory instead of the URL bar. **When a
component blows up in a test but works in the app, it's usually asking for context it normally
gets from a parent** — a router, a provider, a layout.

**`onRemove={() => {}}`** — the prop is required, and this test doesn't care what it does. An
empty function satisfies the type and says *"not what I'm testing."*

**Save and check**

```bash
npm test
```

- **1 passed** in the new file, and everything from Lessons 17–18 still green.
- Change `"Loaded Fries"` to `"Fries"` and watch it fail. Read the output — Testing Library
  prints the **entire rendered DOM** when a query finds nothing, which is long, and is the
  fastest way to see that you asserted text that was never there. Put it back.

---

## 4. `getByRole`, `getByText`, and `queryBy…`

**Prefer `getByRole`.** A role is what an element *is* to the browser and to a screen reader —
a button, a link, a heading. Text is what it happens to say today.

```tsx
screen.getByRole("button")                       // the ⋮ toggle — it has no text at all
screen.getByRole("link", { name: "Edit" })       // an <a>, found by what it announces as
screen.getByText("Loaded Fries")                 // fine for plain content
```

The ⋮ dropdown toggle makes the argument by itself: it contains an SVG icon and **no text
whatsoever**, so there's nothing for `getByText` to match — but it's a real `<button>`, so
`getByRole("button")` finds it immediately. A query that works because the element is a button
keeps working when the icon changes.

**And `get` vs `query`** — the difference is what happens when nothing matches:

| | Finds nothing | Use it to assert |
|---|---|---|
| `getByText(…)` | **throws** immediately | something **is** there |
| `queryByText(…)` | returns `null` | something **is not** there |

`expect(screen.getByText("Nope")).not.toBeInTheDocument()` can never pass — `getByText` throws
before `expect` ever runs. Absence is always `queryBy…`. You'll want it in the next section.

---

## 5. ▶ Code along — one interaction

The card's Edit and Delete live inside a dropdown that starts closed. So: check they're absent,
click the toggle, check they appeared.

```tsx title="src/menuItems/MenuItemCard.test.tsx"
import userEvent from "@testing-library/user-event";

  it("reveals Edit and Delete when the ⋮ menu is opened", async () => {
    const user = userEvent.setup();
    render(
      <MemoryRouter>
        <MenuItemCard menuItem={menuItem} onRemove={() => {}} />
      </MemoryRouter>
    );

    expect(screen.queryByText("Edit")).not.toBeInTheDocument();

    await user.click(screen.getByRole("button"));

    expect(screen.getByText("Edit")).toBeInTheDocument();
    expect(screen.getByText("Delete")).toBeInTheDocument();
  });
```

- **`userEvent.setup()` first**, then `user.click(...)`. `user-event` fires the full sequence a
  real click produces — hover, mouse down, focus, mouse up, click — which is why dropdowns and
  form controls behave the way they do in the browser.
- **`await` every interaction**, and the test is `async`. Same discipline as Lesson 18: forget
  the `await` and you assert against the screen as it was *before* the click.
- **The first assertion is the one that gives the test meaning.** Without it, the test would
  pass on a card that showed Edit and Delete permanently. You're testing that the click changed
  something, so you have to establish what it was like before.

**Save and check**

- **2 passed** in this file.
- Delete the `await` and watch it fail — this time the failure is real and immediate, because
  the menu genuinely isn't open yet.

---

## 6. What this lesson deliberately does not test

Click **Delete** on that card and it calls `confirm()`, then `menuItemAPI.delete(id)`, which is
a real `fetch` at a real API. In a test, that means either standing up a server or **replacing
`fetch` with a fake** — `vi.mock`, or a library like MSW.

**That's out of scope for this course, and it's a boundary rather than an omission.** Mocking is
a whole topic: what to fake, how much, and how to avoid tests that pass against a fake that
stopped resembling the real thing years ago. It deserves more room than a nineteenth lesson has.

So the rule to leave with: **test components that take props and render them, plus interactions
that don't leave the component.** That's `MenuItemCard`'s dropdown opening. It isn't
`MenuItemList` fetching its data.

That's not a small category. Cards, rows, badges, headers, form fields, empty states, anything
conditional on a prop — those are most of the components in this app, they're where the visual
bugs live, and they need nothing you haven't got.

---

## The General Pattern (what to take away)

- A component test asks **what's on the screen**, given these props and after this click.
  Nothing about state, hooks, or internals.
- **jsdom is the browser stand-in**, switched on **per file** by the files that need it — your
  pure-function tests stay in Node and stay fast.
- `render()` mounts it, `screen` queries it the way a person would look at it.
- **Prefer `getByRole`** — it's what the element *is*, not what it currently says. An
  icon-only button has no text and is still findable.
- **`getBy…` throws when absent; `queryBy…` returns `null`.** Asserting absence needs `queryBy`.
- **`await user.click(...)`**, always — and assert the before state, or you haven't shown the
  click did anything.
- **A component that throws in a test but works in the app is usually missing context** — a
  router, a provider.
- **Fetching components are out of scope**, on purpose. Props in, DOM out, plus a local
  interaction, covers most of what you'd want to pin down.

---

## Build Steps

1. `npm i -D jsdom @testing-library/react @testing-library/user-event @testing-library/jest-dom`
2. Create `vitest.setup.ts` importing `@testing-library/jest-dom/vitest`.
3. Add `test: { setupFiles: "./vitest.setup.ts" }` to `vite.config.ts`, with the
   `/// <reference types="vitest" />` line above the imports.
4. Run `npm test` and confirm **Lessons 17–18 still pass**.
5. Create `src/menuItems/MenuItemCard.test.tsx` — `.tsx`, with the
   `@vitest-environment jsdom` docblock at the top.
6. Build a `menuItem` object at module level; render inside `<MemoryRouter>` with a no-op
   `onRemove`.
7. Assert the name, price, and category are on screen.
8. Break one assertion, read the printed DOM, and restore it.
9. Add the interaction test: assert Edit is **absent**, `await user.click` the toggle found by
   `getByRole("button")`, then assert Edit and Delete are present.
10. Delete an `await` to see it fail, and put it back.
