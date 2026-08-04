# Optional polish — a loading splash while the bundle downloads

**Optional — not required for the capstone.** This one is short, and it teaches something
about how a React app actually starts up that's easy to miss when `npm run dev` is fast.

You can apply it any time after Lesson 3, once you have an app that runs.

## What you're fixing

Load your app on a slow connection and you get a **blank white page** — for a moment on
your laptop, for a lot longer on a phone. Nothing is wrong; there is simply nothing to
paint yet. Your `index.html` ships this:

```html
<div id="root"></div>
```

An empty div. The browser renders it — correctly, as nothing — and waits. Only after the
JavaScript bundle downloads, parses, and React's first render runs does anything appear.

## The one idea

Whatever you put **inside** `#root` is painted immediately, because it's ordinary HTML in
the document — no JavaScript involved.

And you don't have to clean it up. Look at the last lines of your `main.tsx`:

```tsx
ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);
```

(Read this — nothing to change.) `render()` **replaces** everything inside `#root`. So the
splash markup is gone the instant React paints, with no state, no effect, and no
"hide the splash" code. The thing you're removing lives inside the thing that gets
replaced.

## 1. Put something in `#root`

Start with the smallest version that proves the idea. `index.html` is at the **project
root**, next to `package.json` — not in `src/`.

```diff title="index.html"
    <body>
-     <div id="root"></div>
+     <div id="root">
+       <h1>Application Loading</h1>
+     </div>
      <script type="module" src="/src/main.tsx"></script>
    </body>
```

**Save and check**

- Reload the page normally — you'll probably see **nothing**. The dev server is on
  localhost and the bundle arrives in milliseconds.
- Open DevTools, go to the **Network** tab, set the throttling dropdown from *No throttling*
  to **Slow 4G**, and reload — **"Application Loading"** sits on screen for a second or two.
- Keep watching — it's **replaced by your app**, and you never wrote a line of code to
  remove it.

Leave throttling on for the rest of this page, and turn it off when you're done.

## 2. Why the styles can't live in `App.css`

Now make it look like something. But not in `App.css` — and the reason is the whole point
of the exercise.

`App.css` and Bootstrap are **imported by `main.tsx`**. They are part of the bundle. If the
splash's styles lived there, they'd arrive at the same moment the app does, and the user
would stare at unstyled markup right up until the instant it's replaced. The splash would
be styled only when it's no longer needed.

So the splash's CSS goes in a `<style>` block in `<head>`, inline in `index.html`, where
it's parsed as part of the first paint.

One more decision worth copying: put the background on the **splash container**, not on
`body`. A background on `body` would outlive React's first render and you'd have to strip
it by hand. On the container, it disappears along with the markup.

## 3. Style the container

```diff title="index.html"
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>TableServe</title>
+     <style>
+       body {
+         margin: 0;
+         font-family: "Raleway", system-ui, -apple-system, "Segoe UI", sans-serif;
+         color: #212529;
+       }
+
+       .app-loading {
+         min-height: 100vh;
+         min-height: 100dvh; /* avoids the mobile browser-chrome jump */
+         display: flex;
+         flex-direction: column;
+         justify-content: center;
+         align-items: center;
+         gap: 1.5rem;
+         /* the Sign In page's warm radial tint, from App.css */
+         background: rgb(255, 243, 230);
+         background: radial-gradient(
+           ellipse at center,
+           rgba(255, 243, 230, 1) 0%,
+           rgba(255, 250, 245, 0.5) 70%,
+           rgba(255, 255, 255, 1) 100%
+         );
+       }
+     </style>
    </head>
```

Then wrap the text in that container:

```diff title="index.html"
      <div id="root">
-       <h1>Application Loading</h1>
+       <div class="app-loading" role="status" aria-live="polite">
+         Application Loading
+       </div>
      </div>
```

**`class`, not `className`.** This is an HTML file, not JSX — the conversion rules you
learned in Lesson 5 run the other way here. Same for the SVG in the next section: it's
plain HTML, so no `xlinkHref`, and no `import` of the icon sprite.

**Save and check:** reload with throttling on — the loading text is **centered on the warm
gradient**, the same background as your Sign In page.

## 4. Add the brand mark

The logo is the same SVG you converted for the `Header` in Lesson 5, back in its original
HTML form:

```diff title="index.html"
      <div class="app-loading" role="status" aria-live="polite">
-       Application Loading
+       <div class="app-loading__brand">
+         <svg
+           xmlns="http://www.w3.org/2000/svg"
+           width="98"
+           height="40"
+           viewBox="0 0 78 32"
+           fill="none"
+           aria-hidden="true"
+         >
+           <path d="M55.5 0H77.5L58.5 32H36.5L55.5 0Z" fill="#FF7A00" />
+           <path d="M35.5 0H51.5L32.5 32H16.5L35.5 0Z" fill="#FF9736" />
+           <path d="M19.5 0H31.5L12.5 32H0.5L19.5 0Z" fill="#FFBC7D" />
+         </svg>
+         <span class="app-loading__name">TableServe</span>
+       </div>
      </div>
```

And the styles for it, inside the same `<style>` block:

```diff title="index.html"
      .app-loading { /* … section 3 … */ }

+     .app-loading__brand {
+       display: flex;
+       flex-direction: column;
+       align-items: center;
+       gap: 1rem;
+       animation: app-loading-pulse 1.6s ease-in-out infinite;
+     }
+
+     .app-loading__name {
+       font-size: 1.125rem;
+       font-weight: 600;
+       color: #ff7a00;
+     }
+
+     @keyframes app-loading-pulse {
+       0%,
+       100% {
+         opacity: 1;
+       }
+       50% {
+         opacity: 0.55;
+       }
+     }
```

**Save and check:** reload with throttling on — the **orange logo and "TableServe"** are
centered and **fading gently in and out**.

## 5. Add the progress bar, and make it accessible

The bar is decoration — it doesn't track real progress, it just signals *working on it*.

```diff title="index.html"
        <div class="app-loading__brand">
          ...
        </div>
+       <div class="app-loading__bar" aria-hidden="true"></div>
+       <span class="app-loading__status">Loading the application…</span>
      </div>
```

```diff title="index.html"
      .app-loading__name { /* … section 4 … */ }

+     .app-loading__bar {
+       width: 12rem;
+       height: 0.25rem;
+       border-radius: 999px;
+       background: rgba(255, 122, 0, 0.15);
+       overflow: hidden;
+     }
+
+     .app-loading__bar::before {
+       content: "";
+       display: block;
+       width: 40%;
+       height: 100%;
+       border-radius: 999px;
+       background: #ff7a00;
+       animation: app-loading-slide 1.3s ease-in-out infinite;
+     }
+
+     @keyframes app-loading-slide {
+       0% {
+         transform: translateX(-100%);
+       }
+       100% {
+         transform: translateX(250%);
+       }
+     }
+
+     /* Motion is decoration here — the screen still reads fine without it. */
+     @media (prefers-reduced-motion: reduce) {
+       .app-loading__brand {
+         animation: none;
+       }
+       .app-loading__bar::before {
+         animation: none;
+         width: 100%;
+         opacity: 0.6;
+       }
+     }
+
+     /* Visible to screen readers only. */
+     .app-loading__status {
+       position: absolute;
+       width: 1px;
+       height: 1px;
+       overflow: hidden;
+       clip: rect(0 0 0 0);
+       clip-path: inset(50%);
+       white-space: nowrap;
+     }
```

Three accessibility details, all of them small and all of them deliberate:

- **`role="status"` with `aria-live="polite"`** on the container tells a screen reader this
  region is worth announcing when it appears, without interrupting.
- **`aria-hidden="true"`** on the bar and the logo. They carry no information a screen
  reader can use, so they're skipped.
- **`.app-loading__status`** is the text that actually gets announced. It's positioned off
  in a 1px box rather than `display: none`, because `display: none` would hide it from
  screen readers too — which would leave nothing to announce at all.

**Save and check**

- Reload with throttling on — an **orange bar slides back and forth** under the logo.
- Let the app finish loading — the whole splash is **gone**, gradient and all, with no
  flicker of leftover background.
- Turn throttling **off** and reload — you're back to the app appearing more or less
  instantly.

## Your turn — the PRS capstone

Your PRS front end has the same empty `<div id="root"></div>`, and it benefits more: the
capstone app is the one your reviewers will load cold. Repeat the same change in the PRS
`index.html` with the PRS brand and colors.

## The general pattern

- **The root element's contents are your "before JavaScript" UI.** Every SPA has this gap
  between the first paint and the framework booting. Most apps leave it blank because the
  empty div in the scaffold looks like a placeholder you shouldn't touch. It isn't.
- **Cleanup is free when the thing you're removing lives inside the thing that gets
  replaced.** Compare that to a splash you'd have to hide with state and an effect — same
  result, more code, and one more thing to get wrong.
- **Critical CSS can't travel with the bundle it's covering for.** Anything that has to
  look right *before* the app loads has to arrive before the app does.
