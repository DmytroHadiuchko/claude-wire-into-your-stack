---
description: Review this branch's diff against the project's conventions (read-only)
argument-hint: "[base-branch, default main]"
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git status:*), Read, Grep, Glob
---

Review the changes on the current branch against base branch `$ARGUMENTS` (if that is empty, use `main`). Do not edit any files — this is a read-only review.

1. Run `git log --oneline <base>..HEAD` and `git diff <base>...HEAD`, plus `git status --short` for uncommitted work.
2. Check every changed file against this project's checklist (from `CLAUDE.md`):
   - one route file per resource in `routes/`, and any new resource is mounted in `server.js`
   - routes hold no state; all data access goes through `db/store.js`
   - input is validated in the route: `400` on bad input, `404` when a record is missing, `201` on create
   - every error response is JSON `{ "error": "message" }`
   - each new or changed endpoint has tests in `tests/` covering its success and error statuses, with `store.reset()` in `beforeEach`
   - `docs/api.md` describes each new or changed endpoint
   - no secrets, `.env` files, or machine-local files (`.claude/settings.local.json`, `.idea/`) in the diff
3. Report findings as a list, most severe first, each with `file:line`, what is wrong and the fix. Skip checklist items the diff does not touch. If nothing is wrong, say so in one line.
4. End with one line: whether the branch is ready for a PR.
