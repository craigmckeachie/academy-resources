# Assessment Review Checklist — HTML, CSS & JavaScript

**About the assessment:** 11 multiple-choice / true-false questions (10 regular + 1 bonus),
10 points each. The material spans **HTML, CSS, and JavaScript**, so review all three. Work
through the checklist first; the detailed section below gives an example and a reference for
each item.

## ✅ Quick checklist

**HTML**

- [ ] **Global attributes** (usable on *any* element) vs. **element-specific attributes** (only on certain tags)
- [ ] **Void / self-closing elements** — know that *not* every tag needs a closing tag

**CSS**

- [ ] The **`display`** property and the **several ways to put elements side-by-side** (`inline`, `inline-block`, `flex`)
- [ ] Making an element (e.g. a table) **fill the page width**
- [ ] Which CSS **property** turns text *italic* (the property, not the value)

**JavaScript**

- [ ] The **core data types** — and which common type is *not* one of them
- [ ] **`==` vs `===`** — loose vs. strict equality and type coercion
- [ ] The **loops**: classic `for`, `for...of`, `for...in`, and the `Array.forEach` method (and how they differ)
- [ ] **Functions**: anonymous vs. named; function declaration vs. expression vs. arrow
- [ ] Reading/writing an **`<input>`'s data** with `.value` (vs. `innerText` / `innerHTML`)

---

## 📘 Detailed review — examples & references

### HTML

**1. Global vs. element-specific attributes**
Global attributes work on *any* element: `id`, `class`, `style`, `title`, `hidden`, `lang`,
`tabindex`, `data-*`, `contenteditable`. Element-specific attributes only work on certain
tags: `href` (on `<a>`), `src`/`alt` (on `<img>`), `type`/`value`/`placeholder` (on
`<input>`), `for` (on `<label>`).
```html
<p id="intro" class="lead" style="color:red">Global attrs work anywhere</p>
<a href="/home">href only makes sense on a link</a>
```
🔗 [MDN — Global attributes](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes)

**2. Void (self-closing) elements — not every tag has a closing tag**
Most elements wrap content and need a closing tag (`<p>…</p>`), but **void elements** have no
content and no closing tag: `<img>`, `<br>`, `<hr>`, `<input>`, `<meta>`, `<link>`,
`<source>`, `<area>`. So "every HTML element requires a closing tag" is **false**.
```html
<img src="logo.png" alt="Logo">   <!-- no </img> -->
<br>  <hr>  <input type="text">
```
🔗 [MDN — Void element](https://developer.mozilla.org/en-US/docs/Glossary/Void_element)

### CSS

**3. `display` — putting elements side-by-side (several ways)**
Block elements like `<div>` stack vertically by default. There are **several ways** to get
them onto the same line — the right one depends on whether you need to control the boxes'
size:

- **`display: inline`** — flows elements in a row like words in a sentence, **but ignores
  `width`/`height` and top/bottom margins/padding**. Good for text-like spans, not for sizing
  boxes.
- **`display: inline-block`** — side-by-side **and** respects `width`/`height` and all
  margins/padding. The usual pick for two `<div>` boxes you want to size.
- **`display: flex`** (on the *parent*) — the modern, most flexible approach; add `gap` for
  spacing and control alignment/wrapping.
- **`float: left`** — the legacy approach (pre-flexbox), still seen in older code.

So both **`inline`** and **`inline-block`** place elements side-by-side — `inline-block` is
preferred when the boxes need a set width/height. (There is no `display: side-by-side` or
`two-wide`.)
```css
.a   { display: inline; }        /* side by side, but width/height ignored */
.b   { display: inline-block; }  /* side by side, width/height respected  */
.row { display: flex; gap: 1rem; }   /* modern: flex the parent */
```
🔗 [MDN — display](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/display)

**4. Filling the page width**
Block elements already fill their parent, but **tables shrink to their content** — set
`width: 100%` to make a table span the full page/container. There is no `width: full` or
`width: page`.
```css
table { width: 100%; }
```
🔗 [MDN — width](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/width)

**5. Italic text — the `font-style` property**
`font-style: italic;` makes text italic. Don't confuse the **property** (`font-style`) with
the **value** (`italic`). Related but different: `font-weight` (bold), `font-family`
(typeface), `text-decoration` (underline). There is no `font-italic` property.
```css
em, .note { font-style: italic; }
```
🔗 [MDN — font-style](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/font-style)

### JavaScript

**6. Core data types**
JavaScript's primitive types are **`number`, `string`, `boolean`, `null`, `undefined`,
`bigint`, `symbol`** (plus `object`). There is **no `decimal` type** — `number` covers both
whole numbers and decimals. (`decimal` is a C#/database type, not JS.)
```js
typeof 42        // "number"  (also 3.14 — no separate decimal)
typeof "hi"      // "string"
typeof true      // "boolean"
```
🔗 [MDN — JavaScript data types](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Data_structures)

**7. `==` vs. `===`**
`==` (loose) converts types before comparing — **type coercion**. `===` (strict) compares
**value *and* type**, with no coercion. So yes, `===` *does* take the operands' types into
account. Put in words: `===` returns true when both operands have the **same type and the
same value**.
```js
1 == "1"           // true   (string coerced to number)
1 === "1"          // false  (different types)
0 == false         // true
0 === false        // false
null == undefined  // true
null === undefined // false
```
🔗 [MDN — Strict equality (`===`)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Strict_equality)
· [Equality comparisons overview](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Equality_comparisons_and_sameness)

**8. Loops — know all four and how they differ**
```js
// classic for — full control with an index counter
for (let i = 0; i < arr.length; i++) { console.log(arr[i]); }

// for...of — the VALUES of an iterable (arrays, strings)
for (const item of arr) { console.log(item); }

// for...in — the KEYS / indexes / property names (usually for objects)
for (const key in obj) { console.log(key, obj[key]); }

// Array.forEach — a method that runs a callback per element
arr.forEach((item, index) => { console.log(index, item); });
```
Two gotchas the assessment probes: **JavaScript has no `foreach` keyword** —
`foreach(var i in collection)` is C#/VB syntax, *not* JS. And `for...of` iterates **values**,
while `for...in` iterates **keys/indexes**.
🔗 [MDN — Loops and iteration](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Loops_and_iteration)
· [`for...of`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for...of)
· [`Array.forEach`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach)

**9. Functions — anonymous vs. named**
An **anonymous** function has no name — commonly a function expression or arrow function used
as a callback. A function with a name after the `function` keyword (`function greet() {}`) is
a **named function declaration**, *not* anonymous.
```js
function()  { /* .. */ }        // anonymous (expression)
function(a) { /* .. */ }        // anonymous, takes a parameter
() => { /* .. */ }              // arrow — also anonymous
function greet() { /* .. */ }   // NAMED — not anonymous
```
🔗 [MDN — Arrow functions](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions)

**10. Reading/writing `<input>` data with `.value`**
Form controls (`<input>`, `<textarea>`, `<select>`) hold their data in the **`.value`**
property. `innerText` and `innerHTML` are for the *content* of regular elements (`<p>`,
`<div>`) — they don't read or set what a user typed into a field.
```js
const email = document.getElementById("email");
console.log(email.value);   // read what the user typed
email.value = "hi@x.com";   // set the field's contents
```
🔗 [MDN — HTMLInputElement.value](https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement/value)
