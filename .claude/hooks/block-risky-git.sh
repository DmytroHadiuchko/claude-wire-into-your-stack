#!/usr/bin/env bash
# PreToolUse guard for Bash: blocks commands that rewrite shared history or
# delete files recursively. Exit 2 blocks the call; stderr is shown to Claude.

cmd=$(jq -r '.tool_input.command // empty')

block() {
  echo "Blocked by project hook: $1. Ask the user to run it themselves if it is really intended." >&2
  exit 2
}

if echo "$cmd" | grep -Eq 'git[[:space:]]+push.*(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$))'; then
  block "force-push rewrites shared history"
fi

if echo "$cmd" | grep -Eq 'git[[:space:]]+push([[:space:]]+[^[:space:]]+)*[[:space:]]+(main|master)([[:space:]]|$)'; then
  block "push straight to main/master; push a branch and open a PR"
fi

if echo "$cmd" | grep -Eq 'git[[:space:]]+reset[[:space:]]+.*--hard'; then
  block "git reset --hard discards uncommitted work"
fi

if echo "$cmd" | grep -Eq 'rm[[:space:]]+-[a-zA-Z]*(r[a-zA-Z]*f|f[a-zA-Z]*r)'; then
  block "rm -rf deletes recursively without confirmation"
fi

exit 0
