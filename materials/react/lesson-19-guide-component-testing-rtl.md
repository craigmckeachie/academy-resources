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

!!! note "This lesson is optional, and it carries its own setup"

    Lesson 17 installed one package and needed no configuration; Lesson 18 added one more for
    coverage. This lesson needs **four packages, a new setup file, and a change to
    `vite.config.ts`** — because rendering a component means giving Node something that
    pretends to be a browser, and that doesn't come for free.

    All of it lives here and nowhere earlier, which is what makes "optional" real: **skip this
    lesson and nothing you already have breaks.** Lessons 17–18 keep running in plain Node,
    untouched.

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

That isn't a house rule — it's the library's stated reason for existing:

> The more your tests resemble the way your software is used, the more confidence they can
> give you.
>
> — **Kent C. Dodds**, [Testing Library's guiding principle](https://testing-library.com/docs/)

Which is why its queries are the ones a *person* would use — find the text, find the button —
and why there's no API for reaching inside a component. Nobody using TableServe knows what your
state variables are called; a test that knows is testing something your users can't experience,
and it'll break on a refactor that changed nothing they'd notice.

It has a second payoff you get for free: because those queries lean on **roles and accessible
names**, they're the same handles a screen reader uses — so writing tests this way quietly
pushes your markup toward being usable by people who can't see it. Section 4 shows where that
bites on this card.

That goes for the **names** too — Lesson 17's rule with a different subject. The `it` finishes
a sentence about what a user sees: *renders the price*, *shows the Manager badge for a
manager*, *reveals Edit and Delete when the menu is opened*. Never *sets `showMenu` to true*.

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

```diff title="TableServe.Web/vite.config.ts"
+ /// <reference types="vitest" />
  import { defineConfig } from "vite";
  import react from "@vitejs/plugin-react";

  // https://vitejs.dev/config/
  export default defineConfig({
    plugins: [react()],
+   test: {
+     setupFiles: "./vitest.setup.ts",
+   },
  });
```

Two insertions, and the first one is easy to miss: the `/// <reference types="vitest" />` line
goes **above the imports**. Without it TypeScript doesn't know `defineConfig` accepts a `test`
key and will flag it, even though the config works.

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

!!! tip "Run one test at a time from here on"

    A failing component test dumps the whole rendered DOM, so two failures at once bury the
    one you're reading. Use the **`Run`** link above the individual `it` — Lesson 17,
    section 6 — and you get one component's markup instead of several.

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

!!! tip "Your tests and your screen-reader users are asking the same question"

    Roles and accessible names aren't a testing invention — they're what assistive technology
    navigates by. A screen reader announces *"Edit, link"* because the element is an `<a>` with
    the text "Edit"; `getByRole("link", { name: "Edit" })` finds it for exactly the same reason.

    Which turns test friction into a useful signal. **If there's no sensible role or name to
    query by, someone using a screen reader has the same problem you do.** The ⋮ toggle is the
    example on this very card: it works as `getByRole("button")` only because there happens to
    be one button here. Give it an `aria-label="Menu item actions"` and it becomes queryable by
    name *and* announced as something other than "button, blank".

    One change, two wins — and that's not a coincidence, it's the guiding principle from
    section 1 doing its job. Tests written the way software is used push you toward software
    that's usable.

**And `get` vs `query`** — the difference is what happens when nothing matches:

| | Finds nothing | Use it to assert |
|---|---|---|
| `getByText(…)` | **throws** immediately | something **is** there |
| `queryByText(…)` | returns `null` | something **is not** there |

`expect(screen.getByText("Nope")).not.toBeInTheDocument()` can never pass — `getByText` throws
before `expect` ever runs. Absence is always `queryBy…`. You'll want it in the next section.

### ▶ Don't guess the query — ask the playground

When a query isn't matching, you have three ways to see what actually rendered:

```tsx
screen.debug();                     // prints the rendered DOM in your terminal
screen.logTestingPlaygroundURL();   // prints a URL that opens that DOM in a tool
```

…and the **`Debug`** link the Vitest Runner extension puts above each `it` (Lesson 17,
section 6), which runs that one test with the debugger attached — so a breakpoint inside the
component stops with the props sitting in front of you.

The first two are print statements: they go in while you're stuck and come out before you
commit. Try the second one now — add it to your first test, right after `render(...)`:

1. **Run just that test** — the `Run` link above the `it` (Lesson 17, section 6). Otherwise
   you'll be hunting for the URL among several DOM dumps.
2. **Copy the URL** from the output and open it.
   [testing-playground.com](https://testing-playground.com/) loads with your card in it.

You get four panes: your **markup** top-left, the **rendered result** top-right, a **query
editor** bottom-left, and **suggestions** bottom-right.

3. **Click an element in the rendered pane** — the item name, the badge, the ⋮ button.
4. Read the green **suggested query** box, which has a copy button:

    ```js
    getByRole('button', { name: /submit/i })
    ```

    It often adds a note — *"you could make the query a bit more specific by adding the name
    option"* — which is real advice, not filler.

5. Look underneath it, at the numbered breakdown. **This is the part worth the detour:**

    | | | What it shows |
    |---|---|---|
    | **1.** | Queries Accessible to Everyone | Role, LabelText, PlaceholderText, Text |
    | **2.** | Semantic Queries | AltText, Title |
    | **3.** | Test IDs | TestId |

    That numbering **is** the priority order from earlier in this section, and each row shows
    what that query would actually be for the element you clicked — or `n/a` if it isn't
    available. Seeing `Role: button` filled in and `TestId: n/a` beneath it teaches the
    hierarchy faster than being told it.

6. Type your own attempt in the **query editor** and watch the matched element appear at the
   bottom of that pane. That's the fastest way to find out why a query you wrote isn't matching.
7. Paste the query you settled on into your test, and **delete the
   `logTestingPlaygroundURL()` line.** It's a print statement, not an assertion.

Click the ⋮ toggle while you're in there. Its accessible-name row comes back empty — the
playground can't suggest a `name` option for a button that doesn't announce anything, which is
section 4's accessibility point showing up as a blank field.

You can scope it to one element rather than the whole card:

```tsx
screen.logTestingPlaygroundURL(screen.getByRole("button"));
```

!!! note "You'll need this less than you expect"

    It's a learning tool, and it works by making you fluent enough not to need it. After a
    dozen components you'll be guessing the same query it would have suggested. Keep it for the
    times you're stuck on markup someone else wrote.

    One judgement call worth naming: it puts your rendered markup into a URL on a third-party
    site. TableServe is sample data, so it doesn't matter here — on a real product, check what
    your team's policy is before pasting a screen full of customer information into anything.

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
- **A hard query is an accessibility signal.** Roles and accessible names are what screen
  readers navigate by, so markup that's awkward to test is usually markup that's awkward to
  hear. Fixing one fixes both.
- **`getBy…` throws when absent; `queryBy…` returns `null`.** Asserting absence needs `queryBy`.
- **`screen.logTestingPlaygroundURL()` when you're unsure** — click an element and its
  suggestion panel lists the query types in priority order, filled in or `n/a`. You learn the
  hierarchy by using it. Delete the line before you commit.
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
9. Add `screen.logTestingPlaygroundURL()` after `render(...)`, run that one test, and open the
   URL. Click the category badge and then the ⋮ button, and compare their suggestion panels —
   one has a role *and* a name, the other doesn't. Delete the line afterwards.
10. Add the interaction test: assert Edit is **absent**, `await user.click` the toggle found by
    `getByRole("button")`, then assert Edit and Delete are present.
10. Delete an `await` to see it fail, and put it back.
