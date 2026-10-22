# NOTES — wiring Claude into the course API

## Server (MCP)

`.mcp.json` connects the **fetch** server at project scope, run as `docker run -i --rm mcp/fetch` (Docker because Node/uv aren't assumed on every machine; no credentials needed). It's useful here because routes and tests are built on Express, supertest and `node:test` — Claude can pull the current reference instead of guessing. `.claude/settings.json` allows only `mcp__fetch__fetch`, the one read-only tool, not the whole `mcp__fetch` server. I did not set `enableAllProjectMcpServers`, so each clone approves the server once on first `claude` run — deliberate, a committed file shouldn't silently start processes. Used it headless to read the Express Router docs (`expressjs.com/en/4x/api/router/`), which confirmed the `express.Router()` + `app.use('/base', router)` pattern this repo follows.

## Skill

`.claude/skills/add-endpoint/` captures how every endpoint is built here: store helper in `db/store.js` → route in `routes/<resource>.js` → mount in `server.js` → 400/404/201 with `{ "error": "..." }` → supertest test with `store.reset()` → `docs/api.md`. The description says what it covers ("add or change an HTTP endpoint… routes/*.js"), gives three example requests, and states what it is not for (Claude setup, CI, docs-only edits). Verified headless: "I need a DELETE /users/:id endpoint" loaded the skill first without naming it; a question about the CI Node version did not.

## Command

`/review [base]` (`.claude/commands/review.md`) reviews the branch diff against the `CLAUDE.md` checklist and says whether it's ready for a PR. It's the prompt I'd otherwise retype before every PR, and `allowed-tools` limits it to `git diff/log/status`, Read, Grep, Glob, so it can only report, never edit. On its first run it caught that `.idea/` wasn't ignored — now fixed in `.gitignore`.

## Hook

A **PreToolUse** hook on **Bash** (`.claude/hooks/block-risky-git.sh`) — it *prevents* rather than reacts. It blocks force-push, pushing straight to `main`/`master`, `git reset --hard` and `rm -rf`, exiting 2 with a reason Claude sees ("ask the user to run it themselves"). Triggered on purpose with `git push --force --dry-run …` and it was blocked; normal commands pass. Needs `jq`.

Known limits: it matches the whole command text, so a quoted string containing one of these commands (e.g. in a commit message) is blocked too; and a plain `git push` while on `main`, or anything wrapped in `bash -c`, is not caught. It's a guard against accidents, not a security boundary.

## Headless

```
claude -p "Summarise what changed on this branch vs main: list each file and what it adds, in under 10 lines. Do not modify anything." \
  --allowedTools "Bash(git diff:*)" "Bash(git log:*)" "Read"
```

A read-only task, so it gets read-only tools: git diff/log and Read. No Edit/Write and no general Bash, so with nobody watching it can't change files, commit or push — any other call has no one to approve it and fails. It listed all six changed files correctly and left the working tree clean.

## Not run locally

Node isn't installed on this machine, so `npm run lint` / `npm test` weren't run here; they run in GitHub CI. This branch changes no application code.
