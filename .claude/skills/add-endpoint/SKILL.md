---
name: add-endpoint
description: How to add or change an HTTP endpoint in this Express API — a new route, a new resource, or a new method/status on an existing one in routes/*.js. Use whenever the request is to add, extend or modify an API endpoint (e.g. "add DELETE /users/:id", "add a /products resource", "make POST /users validate email"). Not for questions about Claude setup, CI, or docs-only edits.
---

# Adding or changing an endpoint

This API has one shape for every endpoint. Follow it so a new route reads like `routes/users.js` and is tested like `tests/users.test.js` — open both before writing.

## 1. Data first — `db/store.js`

- Routes never hold state. If the endpoint needs a new read or write, add a small helper in `db/store.js` (like `getUser`, `updateUser`) and export it.
- A helper that looks up a missing record returns `undefined`; the route turns that into a 404.
- New collections get seed data inside `seed()` so `store.reset()` restores them for tests.

## 2. The route — `routes/<resource>.js`

- One file per resource, exporting an `express.Router()`. A new resource gets a new file.
- Put a one-line comment above each handler: `// METHOD /path — what it does.`
- Parse ids with `Number(req.params.id)`.
- Validate input in the route, before calling the store:
  - bad or missing input → `400`
  - record not found → `404`
  - created → `201` with the created record
- Every error is JSON `{ "error": "message" }` — e.g. `res.status(404).json({ error: 'User not found' })`. Never send plain text or another shape.
- Use `return res...` on early exits so a handler sends one response.

## 3. Mounting — `server.js`

A new resource file is mounted in `server.js` under its base path: `app.use('/<resource>', <resource>Router);`. Existing resources are already mounted.

## 4. Tests — `tests/<resource>.test.js`

- `node:test` + `node:assert` + `supertest`, importing `app` from `../server` (no port is opened).
- `test.beforeEach(() => store.reset());` so each test starts from the seed.
- Cover the happy path and every error status the handler can return (400, 404).

## 5. Docs — `docs/api.md`

Add or update the endpoint's section: method and path, body fields, and each status it returns.

## Checks

Node may not be installed locally; `npm run lint` and `npm test` run in GitHub CI (`.github/workflows/ci.yml`). Run them locally when Node is available, otherwise say they were not run.
