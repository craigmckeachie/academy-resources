# Assessment Review Checklist — React

**About the assessment:** 11 multiple-choice questions (10 regular + 1 bonus), 10 points
each. Everything is **React** — the concepts you used to build TableServe and PRS. Work
through the checklist first; the detailed section below gives an example and a reference for
each item.

## ✅ Quick checklist

**React fundamentals**

- [ ] What **React** is (and what it isn't — not a CSS framework, not a language)
- [ ] What a **component** is — a function that returns JSX
- [ ] **Naming a component** — the casing React requires
- [ ] How a React app gets **rendered to the DOM** — both the older `ReactDOM.render` style
  the assessment asks about and the current `createRoot` style you wrote

**Props and rendering**

- [ ] Passing data to a child component with **props**
- [ ] **Conditional rendering** — what works *inside* JSX and what doesn't
- [ ] The purpose of **`key`** in a list

**Hooks**

- [ ] The **`useState`** syntax — array destructuring, not object destructuring
- [ ] **`useEffect`** and its dependency array — especially the **empty** array

**Forms**

- [ ] **Controlled vs. uncontrolled** components — `value`/`onChange` vs. a `ref`
- [ ] What **React Hook Form's `useForm`** returns

---

## 📘 Detailed review — examples & references

### React fundamentals

**1. What React is**
React is a **JavaScript library for building user interfaces**. It isn't a CSS framework
(that's Bootstrap), a database, or a server-side language (that's your C# Web API). Your
React app runs in the **browser** and talks to the API over HTTP.
🔗 [react.dev — Quick start](https://react.dev/learn)

**2. Naming a function component — PascalCase**
Component names use **PascalCase** (`MenuItemCard`, `StaffList`), and this is a rule, not a
style preference: JSX treats a **lowercase** tag as a built-in HTML element and a
**capitalized** tag as your component. `<menuItemCard />` would be looked up as an HTML tag
and render nothing.

```tsx
function MenuItemCard() { /* ... */ }   // PascalCase — component
const menuItems = [];                    // camelCase — variable
```

🔗 [react.dev — Your first component](https://react.dev/learn/your-first-component)
· [TypeScript / React naming conventions](typescript-naming-conventions.md)

**3. What a component is**
A component is **a function (or, in older code, a class) that returns JSX** to be rendered.
It's not a CSS file, a query, or a library — it's a function whose return value describes UI.

```tsx
function MenuItemCard({ menuItem }: IMenuItemCardProps) {
  return <Card>{menuItem.name}</Card>;   // returns JSX
}
```

🔗 [react.dev — Your first component](https://react.dev/learn/your-first-component)
· first built in [React Lesson 3](../react/lesson-03-guide-components-jsx-typescript.md)

**4. Rendering a React app to the DOM — the old style and the new**
Every React app has exactly **one** line that puts the whole component tree on the page, and
it lives in the entry file. Which line it is depends on the React version, and **you need
both**: the assessment's answer is the older `ReactDOM.render()`, while the line you actually
wrote in `main.tsx` is the newer `createRoot`. Know them as a pair.

**The old style (React 17 and earlier)** — the assessment's answer. In a file usually called
`index.js`; one call, two arguments: *what* to render and *where*.

```tsx
import ReactDOM from "react-dom";

ReactDOM.render(<App />, document.getElementById("root"));
```

**The current style (React 18+)** — what's in your `main.tsx`. Two steps: create a **root**
for a DOM element, then render into it. Note the import path picks up `/client`.

```tsx
import ReactDOM from "react-dom/client";

ReactDOM.createRoot(document.getElementById("root")!).render(<App />);
```

| | React 17 and earlier | React 18+ |
|---|---|---|
| Import from | `react-dom` | `react-dom/client` |
| The call | `ReactDOM.render(element, container)` | `ReactDOM.createRoot(container).render(element)` |
| The container | the second argument | the argument to `createRoot` |

So: **`ReactDOM.render()` is the answer to pick on the assessment**, and it's what you'll see
in older tutorials — but it was **deprecated in React 18 and removed in React 19**, so never
write it in your own code. Recognize the old one; use the new one.

Two more details:

- The container is a **DOM element, not a CSS selector** —
  `document.getElementById("root")`, not `"#root"`.
- react.dev writes it as a named import — `import { createRoot } from "react-dom/client"`,
  then `createRoot(container).render(...)`. Same function; either style is correct.

And on the wrong answers: `React.renderComponent()` and `React.renderDOM()` don't exist at
all. `React.createElement()` *is* real — it's what JSX compiles down to — but it only
**creates** an element; it doesn't put it on the page.
🔗 [react.dev — `createRoot`](https://react.dev/reference/react-dom/client/createRoot)
· [legacy `render`](https://react.dev/reference/react-dom/render)

### Props and rendering

**5. Passing data to a child component — `props`**
Data flows **down** from parent to child through **props**, which arrive as a single object
argument to the child function. `state` is a component's *own* data, and `context` is for
values shared across many components without passing them down by hand (your `UserContext`)
— neither is how you hand a menu item to a card.

```tsx
// parent
<MenuItemCard menuItem={menuItem} onRemove={removeMenuItem} />

// child — props destructured out of the single argument
interface IMenuItemCardProps {
  menuItem: IMenuItem;
  onRemove: (menuItem: IMenuItem) => void;
}
function MenuItemCard({ menuItem, onRemove }: IMenuItemCardProps) { /* ... */ }
```

🔗 [react.dev — Passing props to a component](https://react.dev/learn/passing-props-to-a-component)

**6. Conditional rendering**
Inside JSX you use a **ternary** (`condition ? a : b`) or the `&&` short-circuit — because
JSX slots hold **expressions**, and an `if` statement is a *statement*, so it can't go inside
the braces. (You can absolutely use `if` in the function body *before* the `return` — that's
just not "inside JSX.")

```tsx
{loading && menuItemCardSkeletons}                    // && — render or nothing
{user ? <SignOutButton /> : <Link to="/signin">Sign in</Link>}   // ternary — one or the other
```

🔗 [react.dev — Conditional rendering](https://react.dev/learn/conditional-rendering)
· first built in [React Lesson 6](../react/lesson-06-guide-conditional-rendering-skeletons.md)

**7. The purpose of `key` in a list**
`key` gives each list item a **unique identity** so React can tell which items changed, were
added, or were removed between renders. It isn't for encryption, click tracking, or binding.
Use a stable id from your data — not the array index, when the list can reorder or have items
removed.

```tsx
{menuItems.map((menuItem) => (
  <MenuItemCard key={menuItem.id} menuItem={menuItem} onRemove={removeMenuItem} />
))}
```

🔗 [react.dev — Rendering lists](https://react.dev/learn/rendering-lists)

### Hooks

**8. `useState` syntax**
`useState` returns an **array of two things** — the current value and its setter — so you
read it with **array destructuring (square brackets)**, and you name both halves yourself.
Object destructuring (`const { error, setError } = ...`) is wrong: the returned array has no
properties by those names. `.value` is wrong for the same reason.

```tsx
const [error, setError] = useState(undefined);       // ✅ array destructuring
const [menuItems, setMenuItems] = useState<IMenuItem[]>([]);
const [loading, setLoading] = useState(false);
```

Calling `useState()` with no argument is also legal JavaScript — the keyed answer is the one
that passes an explicit initial value. The thing being tested is the **`[value, setValue]`**
shape.
🔗 [react.dev — `useState`](https://react.dev/reference/react/useState)

**9. `useEffect` and the dependency array**
An **empty** dependency array (`[]`) means the effect has nothing to watch, so it runs
**once, after the initial render** — which is exactly why it's how you load data when a page
first appears. The three variants:

| Dependency array | When the effect runs |
|---|---|
| `[]` | once, after the initial render |
| `[id]` | after the initial render, and again whenever `id` changes |
| omitted entirely | after **every** render |

```tsx
useEffect(() => {
  loadMenuItems();
}, []);            // runs once, when the list page mounts
```

🔗 [react.dev — `useEffect`](https://react.dev/reference/react/useEffect)
· [Synchronizing with effects](https://react.dev/learn/synchronizing-with-effects)
· first built in [React Lesson 4](../react/lesson-04-guide-hooks-data-fetching.md)

### Forms

**10. Controlled vs. uncontrolled components**
The difference is **where the input's current value lives**:

- **Controlled** — React holds the value in state and hands it back to the input. The
  syntax marker is a **`value` prop plus an `onChange` handler**.
- **Uncontrolled** — the DOM keeps the value, and you reach for it through a **`ref`**
  (from the `useRef()` hook) only when you need it.

```tsx
// controlled — value + onChange
<input value={name} onChange={(e) => setName(e.target.value)} />

// uncontrolled — the DOM holds it; read it through the ref
const nameRef = useRef<HTMLInputElement>(null);
<input ref={nameRef} />
```

Worth knowing for the next question: **React Hook Form's `register` is the uncontrolled
approach** — that's why your forms have no `value`/`onChange` on every field, and why they
don't re-render on every keystroke.
🔗 [react.dev — `<input>`](https://react.dev/reference/react-dom/components/input)
· [`useRef`](https://react.dev/reference/react/useRef)

**11. (Bonus) What `useForm` returns**
Pick the option built from the names you actually use in every form you've written —
**`register`**, **`handleSubmit`**, **`formState`**, and **`errors`**. Everything in the
other options (`validateForm`, `createField`, `handleInput`, `submitForm`…) is invented.

Those last two go together: `errors` isn't a top-level return value — it lives **inside
`formState`**, which is why you destructure it in two steps. `useForm` also returns `reset`,
`watch`, `setValue`, and `control`, among others.

```tsx
const {
  register,
  handleSubmit,
  formState: { errors },
} = useForm<IStaff>();
```

🔗 [React Hook Form — `useForm`](https://react-hook-form.com/docs/useform)
· first built in [React Lesson 7](../react/lesson-07-guide-forms-react-hook-form.md)
