#!/bin/sh
# lstack SessionStart: `lyralink context` for this repo. In Claude Code the
# lyra-mode entry lives in the forced output style. Codex has no output
# styles, so under Codex (no CLAUDE_PROJECT_DIR) the style's body prints here
# first. The hook event arrives on stdin and passes straight through, so
# `lyralink context` registers the session with the local relay. Session
# start must never fail or wait on the LyraLink API, so every lyralink error
# is dropped and the hook always exits 0.

launcher="${SKILLSHARE_HOME:-$HOME}/.skillshare/bin/lyralink-context"
style="${CLAUDE_PLUGIN_ROOT:-${PLUGIN_ROOT:-}}/output-styles/lyra-mode.md"
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
  cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
elif [ -f "$style" ]; then
  awk 'NR == 1 && $0 == "---" { front = 1; next } front && $0 == "---" { front = 0; next } !front' "$style"
  printf '\n'
fi
context=""
if [ -x "$launcher" ]; then
  context=$("$launcher" 2>/dev/null)
elif command -v lyralink >/dev/null 2>&1; then
  context=$(lyralink context --cwd . 2>/dev/null)
fi
if [ -n "$context" ]; then
  printf '%s\n' "$context"
fi
exit 0
