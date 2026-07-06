# Lesson 1 Lab — DevTools & Insomnia Exploration

Put the concepts from the guide into practice by **observing** real HTTP traffic and
**sending** your own requests — no C#, no project. You'll watch a real site talk to its
back end, then drive a public API yourself in Insomnia. Refer back to the guide and the
two cheat sheets ([HTTP/REST/status](../reference/http-rest-status-codes.md),
[Insomnia](../reference/insomnia-quickstart.md)) as needed.

---

## Part A — XHR scavenger hunt (browser DevTools)

1. Open a data-heavy website (a store, a news feed, a weather page — anything that loads
   content as you scroll or search).
2. Open **DevTools** (F12) → **Network** tab → click the **Fetch/XHR** filter.
3. Interact with the page until a few requests appear. Pick **three** and for each note:
   - the **verb** (GET, POST, …)
   - the **URL** (domain + resource path)
   - the **status code**
   - whether the **response body is JSON**
4. Find at least one request whose response is a block of **JSON** — that's the same
   shape of data your API will return.

---

## Part B — drive a public API in Insomnia

Install **Insomnia** ([insomnia.rest](https://insomnia.rest)) and use the free live API
at `https://jsonplaceholder.typicode.com`:

5. **GET one item** — `GET https://jsonplaceholder.typicode.com/todos/1` → Send →
   confirm **`200 OK`** and a JSON object.
6. **GET a collection** — `GET .../users` → Send → confirm **`200 OK`** and a JSON
   **array**.
7. **Create** — `POST .../posts` with a JSON body like
   `{ "title": "hello", "body": "world", "userId": 1 }` (Body tab → JSON) → Send →
   note the status code the server returns for a create.
8. **Trigger a 404** — request something that doesn't exist (e.g. `.../todos/99999999`
   or a nonsense path) → Send → confirm a **`404`** (or an empty result), and connect
   that back to the "client error" family.

For each request, read the **status code first**, then the body — the habit you'll use
to verify every TableServe endpoint.

---

## Part C — map REST in your head

Without sending anything, **write down** the verb + URL you'd use for each operation on
a `posts` resource (use the REST rules from the guide):

| Operation | Your answer |
|---|---|
| List all posts | `___ /posts` |
| Get post 5 | `___ /posts/5` |
| Create a post | `___ /posts` |
| Update post 5 | `___ /posts/5` |
| Delete post 5 | `___ /posts/5` |

(Answers: GET, GET, POST, PUT, DELETE.) This is the exact mapping every controller you
build next follows.

---

## Verify

You've "verified" this lab by observing, not running code:

1. You can point at a real request in the **Network** tab and name its verb, URL, status
   code, and whether it's JSON.
2. In **Insomnia** you produced a **`200`**, a create, and a **`404`**, reading the
   status code each time.
3. You can fill in Part C's table from memory.

Next lesson you build the API that answers requests like these — and verify it in
Insomnia exactly the way you just practiced.

---

## Stretch challenges

Optional — for when you finish early. Not needed for the capstone.
**[Reinforce]** builds on what you just did; **[Reach]** goes past the guide and needs
some research.

- **Filter with a query string** — [Reinforce] — send
  `GET .../todos?userId=1` and confirm you get back only that user's todos. This is the
  same shape as the `?status=` filter you'll build on Orders later.
- **Every verb, every code** — [Reinforce] — against `.../posts/1`, try `PUT` (with a
  JSON body) and `DELETE`, and note the status code each returns. Line them up against
  the 2xx table in the cheat sheet.
- **Read the headers** — [Reinforce] — in Insomnia's response, open the **Headers** tab
  and find `Content-Type: application/json`. That header is how the client knows the
  body is JSON.
- **Spot a code in the wild** — [Reach] — back in the browser Network tab, hunt for a
  status code that *isn't* 200 — a `3xx` redirect, a `304 Not Modified`, or a `429`.
  Look up what it means. Reference:
  [HTTP response status codes (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status).

Finished these and want more? See
[stretch-api-challenges.md](stretch-api-challenges.md) for bigger challenges that span
the whole API pass.
