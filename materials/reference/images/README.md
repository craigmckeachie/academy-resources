# Reference Images — Manifest

Diagrams, infographics, and cheat sheets available to the materials. Some are embedded
by a specific doc today; others are **provided for reference or possible later use** —
many cover concepts students met earlier in the program.

**Naming convention:** cheat sheets are `{topic}-cheat-sheet.png`; diagrams/infographics
are descriptive kebab-case. An image must be referenced by its exact filename or the
embed won't resolve.

---

## In use (embedded by a doc)

| Filename | What it is | Embedded by |
|---|---|---|
| `http-request-response-anatomy.png` | Hand-drawn HTTP request/response anatomy (GET `…/todos/5` → `200 OK` + JSON) | `http-rest-status-codes.md`, API Lesson 1 guide |
| `status-codes-comic.png` | 3-panel comic: 200 "all went well" / 400 "your fault" / 500 "server's fault" | `http-rest-status-codes.md` |
| `http-status-codes-infographic.png` | "HTTP Status Codes" infographic (200/201/204/404/401/500 + 1xx–5xx families) | `http-rest-status-codes.md` |
| `api-status-codes-cheat-sheet.png` | "API Status Codes Cheat Sheet" (mailbox metaphor, CRUD verbs) | `http-rest-status-codes.md` |
| `insomnia-cheat-sheet.png` | "Insomnia Cheat Sheet" (why Insomnia, CRUD operations, tips) | `insomnia-quickstart.md` |
| `application-ui-patterns.png` | Wireframe map of the CRUD page types — list (rows / card grid) / detail / create / edit / delete-confirm, linked by navigation | HTML/CSS Lesson 3 guide |
| `github-pr-compare-and-pull-request.png` | GitHub's yellow "recently pushed branch" banner with the **Compare & pull request** button | `git-collaboration-quickstart.md` |
| `github-pr-files-changed-tab.png` | The pull request tab bar with **Files changed** selected | `git-collaboration-quickstart.md` |
| `github-pr-line-comment-icon.png` | Hovering a diff line reveals the blue **+** gutter button for a line comment | `git-collaboration-quickstart.md` |
| `github-pr-review-changes-button.png` | The **Review changes** button and the Comment / Approve / Request changes options | `git-collaboration-quickstart.md` |

> **The four `github-pr-*.png` files are from [GitHub Docs](https://docs.github.com) and are
> used under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)** (the `github/docs`
> repository licenses its content and assets under CC-BY-4.0; only its code is MIT). The
> attribution line lives at the end of the *Pull requests* section of
> `git-collaboration-quickstart.md`. They were downloaded rather than hotlinked because
> GitHub's asset URLs are content-hashed and change. **GitHub's UI moves** — when a
> screenshot stops matching, re-download from the matching docs page rather than editing the
> image, and keep the prose describing button *labels* so the text survives a UI change even
> when the picture doesn't.

---

## Provided for reference / possible later use (not embedded yet)

Concepts students learned earlier, or that a later lesson may pull in. Kept here so
they're ready to drop into a guide when useful.

| Filename | What it is | Relates to |
|---|---|---|
| `client-server-history.png` | "The History of Client-Server Architecture" (Codey) — thin/thick client evolution: mainframe → PCs → web (ASP.NET/JSP/PHP) → REST APIs (SPA) → AI | **API Lesson 1** — architecture context (available to embed) |
| `web-architecture-overview.png` | Hand-drawn full-stack architecture (client/network/server/DB + common tech stacks) | **API Lesson 1** — architecture context (available to embed) |
| `spa-architecture-diagram.png` | "Single-page web application architecture" (browser shell + AJAX/JSON ↔ Web API) | **React pass** — SPA/CSR architecture (available to embed) |
| `swagger-openapi-cheat-sheet.png` | "Swagger / OpenAPI Cheat Sheet" (Codey) — auto-generated API docs; integrations incl. **.NET Swashbuckle** | **API pass** — OpenAPI/Swagger is enabled in project setup |
| `sql-select-cheat-sheet.png` | "The SQL SELECT Statement" (Codey) — SELECT/FROM/JOIN/WHERE/GROUP BY/HAVING/ORDER BY, execution order, F-W-G-H-S mnemonic | **SQL / database** — seed data, prerequisite concept |
| `bash-commands-cheat-sheet.png` | "Basic Bash Commands" (Attack on Titan themed) — `cd`, `ls`, `cp`, `mv`, `rm`/`rmdir`, `cat`, `sh` | Command-line prerequisite |
| `git-commands-cheat-sheet.png` | "Basic Git Commands" (Pokémon themed) — `clone`, `add`, `commit`, `push`, `pull`, `status` | Version-control prerequisite |
| `pair-programming-cheat-sheet.png` | "Pair Programming" (Attack on Titan themed) — driver/navigator roles + a git workflow | Collaboration practice |
| `meet-codey-the-developer.png` | "Meet Codey the Developer" persona comic — the mascot used across several Codey cheat sheets | Optional flavor / mascot intro |

> The mascot **theme** on several sheets (Codey, Attack on Titan, Pokémon) is purely
> stylistic — the technical content is what matters.

---

## Caveat callouts

Some images include concepts this course deliberately excludes. The docs that embed them
carry a caveat note; if you later embed one of the "reference" images, add the same kind
of note.

- `http-status-codes-infographic.png` — labels the server "Spring Boot" (ours is
  ASP.NET Core) and shows `401 Unauthorized` (no auth in this course).
- `api-status-codes-cheat-sheet.png` — includes a `401` panel (no auth in this course).
- `insomnia-cheat-sheet.png` — its "Authentication Testing" section shows JWT/Bearer
  tokens (this course has no JWT/tokens).
- `swagger-openapi-cheat-sheet.png` — its code sample uses Spring's `@GetMapping`; our
  stack is **ASP.NET Core** (the relevant integration on the sheet is **.NET
  Swashbuckle**).
