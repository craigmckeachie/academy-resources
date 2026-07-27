# Anatomy of TypeScript Code — Quiz

Name every numbered token below. This is the blank version of the
[Anatomy of TypeScript Code](anatomy-of-typescript-code.md) reference — match each token to a term
from the word bank, then check yourself against that sheet.

You can print this and fill it in by hand, or copy the
[electronic version](#prefer-to-type-your-answers) at the bottom into your own file and type
your answers. All three specimens are the **Staff** feature — the real code you write in
Lessons 3–4.

---

## Word bank — match each numbered token to one of these

> named import · named export · default export · interface · property · union type ·
> type annotation · primitive type · array type · type argument (generic) · constant ·
> object · method · function · function component · arrow function · function call ·
> method call · parameter · argument · local variable · hook · JSX element

*(A term may be used more than once, and not every term is necessarily used.)*

---

## Specimen A — a model interface (`staff/IStaff.ts`)

```ts
// src/staff/IStaff.ts
export interface IStaff {          // ① ②
  id: number | undefined;          // ③ ④
  firstName: string;               // ⑤
  lastName: string;
  username: string;
  isManager: boolean;              // ⑥
  isAdmin: boolean;
}
```

| # | Token | What it is — write the matching term here |
|---|---|---|
| ① | `export` | |
| ② | `IStaff` | |
| ③ | `id` | |
| ④ | `number \| undefined` | |
| ⑤ | `string` | |
| ⑥ | `boolean` | |

---

## Specimen B — an API module (`staff/StaffAPI.ts`)

```ts
// src/staff/StaffAPI.ts
import { IStaff } from "./IStaff";                          // ①
const url = "http://localhost:5556/api/staff";             // ②

export const staffAPI = {                                  // ③ ④
  list(): Promise<IStaff[]> {                              // ⑤ ⑥
    return fetch(url).then((response) => response.json()); // ⑦ ⑧ ⑨ ⑩
  },
};
```

| # | Token | What it is — write the matching term here |
|---|---|---|
| ① | `import { IStaff } …` | |
| ② | `url` | |
| ③ | `staffAPI` | |
| ④ | `list` | |
| ⑤ | `Promise<IStaff[]>` | |
| ⑥ | `IStaff[]` | |
| ⑦ | `fetch(url)` | |
| ⑧ | `url` (in `fetch(url)`) | |
| ⑨ | `.then(…)` | |
| ⑩ | `(response) => …` | |

---

## Specimen C — a list component (`staff/StaffPage.tsx`)

```tsx
// src/staff/StaffPage.tsx
import { useEffect, useState } from "react";        // ①
import { IStaff } from "./IStaff";
import { staffAPI } from "./StaffAPI";

function StaffPage() {                               // ②
  const [staff, setStaff] = useState<IStaff[]>([]);  // ③ ④

  async function loadStaff() {                       // ⑤
    const data = await staffAPI.list();              // ⑥ ⑦
    setStaff(data);                                  // ⑧
  }

  useEffect(() => {                                  // ⑨
    loadStaff();
  }, []);

  return (
    <section className="list">
      {/* ⑩ = <section>, ⑪ = .map, ⑫ = staffMember */}
      {staff.map((staffMember) => (
        <div className="card" key={staffMember.id}>
          {staffMember.firstName} {staffMember.lastName}
        </div>
      ))}
    </section>
  );
}

export default StaffPage;                            // ⑬
```

| # | Token | What it is — write the matching term here |
|---|---|---|
| ① | `import { useEffect, useState } …` | |
| ② | `StaffPage` | |
| ③ | `useState<IStaff[]>([])` | |
| ④ | `<IStaff[]>` | |
| ⑤ | `loadStaff` | |
| ⑥ | `data` | |
| ⑦ | `staffAPI.list()` | |
| ⑧ | `setStaff(data)` | |
| ⑨ | `useEffect(() => {…}, [])` | |
| ⑩ | `<section>` | |
| ⑪ | `staff.map(…)` | |
| ⑫ | `staffMember` | |
| ⑬ | `export default StaffPage` | |

---

## Prefer to type your answers?

Copy everything in the box below into a new file (e.g. `my-anatomy-answers.md`), keep this
page open to see the code, and fill in the last column. This is the same three tables plus
the word bank, as raw Markdown.

````markdown
Word bank: named import · named export · default export · interface · property ·
union type · type annotation · primitive type · array type · type argument (generic) ·
constant · object · method · function · function component · arrow function ·
function call · method call · parameter · argument · local variable · hook · JSX element

### Specimen A — staff/IStaff.ts

| # | Token | What it is |
|---|---|---|
| ① | `export` | |
| ② | `IStaff` | |
| ③ | `id` | |
| ④ | `number | undefined` | |
| ⑤ | `string` | |
| ⑥ | `boolean` | |

### Specimen B — staff/StaffAPI.ts

| # | Token | What it is |
|---|---|---|
| ① | `import { IStaff }` | |
| ② | `url` | |
| ③ | `staffAPI` | |
| ④ | `list` | |
| ⑤ | `Promise<IStaff[]>` | |
| ⑥ | `IStaff[]` | |
| ⑦ | `fetch(url)` | |
| ⑧ | `url` (in fetch(url)) | |
| ⑨ | `.then(...)` | |
| ⑩ | `(response) => ...` | |

### Specimen C — staff/StaffPage.tsx

| # | Token | What it is |
|---|---|---|
| ① | `import { useEffect, useState }` | |
| ② | `StaffPage` | |
| ③ | `useState<IStaff[]>([])` | |
| ④ | `<IStaff[]>` | |
| ⑤ | `loadStaff` | |
| ⑥ | `data` | |
| ⑦ | `staffAPI.list()` | |
| ⑧ | `setStaff(data)` | |
| ⑨ | `useEffect(() => {...}, [])` | |
| ⑩ | `<section>` | |
| ⑪ | `staff.map(...)` | |
| ⑫ | `staffMember` | |
| ⑬ | `export default StaffPage` | |
````

---

## Stretch questions

Not from the word bank — explain in your own words:

1. `staff` (from `useState`) and `data` (in `loadStaff`) both hold staff data. Which one
   **survives across re-renders**, and which is gone the instant its function returns? Why
   does changing `staff` update the screen but reassigning `data` wouldn't?
2. `IStaff` and `staff` look related but are different *kinds* of thing. Which is a **type**
   and which is a **value** — and what happens to each when the code actually runs in the
   browser?
3. You never write `new IStaff()`, yet the app clearly works with staff **objects**. Where do
   those objects actually come from in these three files?
4. `staffMember` (⑫) and `data` (in `setStaff(data)`) are both "things passed around a
   function." Which is a **parameter** and which is an **argument**? What's the difference?

Answers are all on the [reference sheet](anatomy-of-typescript-code.md).

---

## In the capstone: annotate your own code

The best version of this exercise is on code *you* wrote. Once your PRS front end is underway,
open your own `UserAPI.ts` and `UsersPage.tsx`, pick out the same parts — interface, property,
object, method, function, function call, hook, parameter, argument, local variable, JSX
element — and name each one. If you can label your own component, you understand what you
built; if a token stumps you, that's the thing to go look up.
