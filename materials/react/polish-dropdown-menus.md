# Optional polish — the ⋮ menu's orange ring and caret

**Optional — not required for the capstone.** Nothing is broken without this; it's a
cosmetic fix that brings the three-dots menus in your React app back in line with the
static design pages you built in the HTML/CSS pass.

You can apply it any time after Lesson 6, once you have at least one ⋮ menu on screen.

## What you're seeing

Every ⋮ (three-dots) menu you've built — on the Orders row, the Staff card, the Menu Item
card, the Category card — has two small differences from the static design:

- **An orange halo** around the button when the menu opens or the button takes focus.
- **A ▾ caret** sitting next to the three dots.

Neither is something you typed. They come from react-bootstrap, and they have two
different causes.

**The orange halo.** `Dropdown.Toggle` renders a Bootstrap button, and its `variant`
defaults to `"primary"`. So react-bootstrap puts `btn-primary` on the button *in addition
to* the `btn btn-light` you wrote. `btn-light` wins the background — that's why the button
still looks light grey — but the focus ring is set by this rule in your `App.css`:

```css
.btn-primary {
  --bs-btn-focus-shadow-rgb: 255, 122, 0;
}
```

That rule is doing exactly its job on the orange **Add** buttons. The ⋮ button just
shouldn't have been in `btn-primary`'s blast radius in the first place.

**The caret.** react-bootstrap always adds the `dropdown-toggle` class to a
`Dropdown.Toggle`, and Bootstrap draws the ▾ with `.dropdown-toggle::after`. Your static
`menuitems.html` never put that class on the ⋮ buttons, which is why the caret is new here
and didn't exist in the HTML/CSS pass. Your header's user menu *does* carry the class in
the static design — that caret is intentional and stays.

## 1. Add the caret opt-out to `App.css`

```diff title="src/App.css"
  .skeleton { /* … Lesson 6 … */ }
  .skeleton-text { /* … Lesson 6 … */ }

+ /* react-bootstrap always adds .dropdown-toggle (and its caret) to a
+    Dropdown.Toggle. The card/row "three dots" menus show the icon only. */
+ .dropdown-toggle.no-caret::after {
+   display: none;
+ }
```

Note what this rule does **not** say. A blanket `.dropdown-toggle::after { display: none }`
would work on the ⋮ buttons — and would also strip the caret from the user menu in your
`Header`, where the design wants it. Opting out per button keeps the choice explicit.

## 2. Fix both issues on one ⋮ menu

One line changes:

```diff title="src/menuItems/MenuItemCard.tsx"
    <Dropdown className="d-inline">
-     <Dropdown.Toggle className="btn btn-light" style={{ background: "none" }}>
+     <Dropdown.Toggle variant="light" className="no-caret" style={{ background: "none" }}>
        <svg className="bi pe-none me-2" width={20} height={20} fill="#007AFF">
```

`variant="light"` is what removes `btn-primary`, and with it the orange ring.

This is worth pausing on, because it's a react-bootstrap habit that pays off elsewhere.
Writing `className="btn btn-light"` never could have fixed it: react-bootstrap appends its
own variant class no matter what you put in `className`, so hand-writing the class just
left you with **both** `btn-primary` and `btn-light` on one button. When a react-bootstrap
component has a prop for something, set the prop — don't hand-write the Bootstrap class it
generates.

**Save and check**

- Open `/menuitems` and click a ⋮ button — the menu opens with **no orange halo** around
  the button.
- Look at the button itself — **just the three dots**, no ▾ beside them.
- Press `Tab` until a ⋮ button has focus — the ring is **grey, not orange**.

## 3. Repeat on the rest of the app

!!! warning "Your turn — every ⋮ menu, not just Menu Items"

    Any menu you skip keeps its orange ring and caret, so the app looks half-converted.

    - [ ] `src/menuItems/MenuItemCard.tsx` (done above)
    - [ ] `src/staff/StaffCard.tsx`
    - [ ] `src/orders/OrderRow.tsx`
    - [ ] `src/categories/CategoryCard.tsx`

    Make the same one-line change in each: replace `className="btn btn-light"` with
    `variant="light"` and `className="no-caret"`, and leave
    `style={{ background: "none" }}` alone.

    Check each one the same way you just checked Menu Items — open the page, click the ⋮,
    and confirm the halo and the caret are both gone.

    **Leave `src/Header.tsx` alone.** It already uses `variant="light"`, so it never had
    the orange ring, and its caret is intentional — the static design's header carries
    `dropdown-toggle` on purpose. If you removed that caret, the header no longer matches
    the design.

## The same fix on your PRS capstone

Your PRS front end has the identical pattern, since you build it from the same components:
the `App.css` rule plus `ProductCard`, `RequestRow`, `UserCard`, and `VendorCard` — and the
same "leave the `Header` caret alone" exception.

## The general pattern

Two transferable ideas, worth more than the cosmetic fix itself:

- **A component library's props and its CSS classes are not interchangeable.** Setting
  `variant` and writing `className="btn btn-light"` look equivalent and aren't — one
  replaces the generated class, the other stacks on top of it. Reach for the prop first.
- **Scope an override to what you actually mean.** `.dropdown-toggle.no-caret::after` and
  `.dropdown-toggle::after` both make your ⋮ buttons look right in that moment; only one of
  them leaves the header's caret intact. When a fix works by removing something globally,
  check what else it removes.
