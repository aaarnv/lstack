#!/bin/sh
# lstack PostToolUse and PostToolUseFailure: `lyralink rescue`. On the first
# failure with a new error, it searches the team's Feed posts, decisions,
# practice cards and skills and prints a "LyraLink rescue" block. The hook
# event arrives on stdin and passes straight through. A tool call must never
# fail or wait long on LyraLink, so every error is dropped and it exits 0.
# Relay jobs, forks and offloaded runs skip it, as pre-tool-use.sh does.
case "${LYRALINK_RELAY_JOB:-}${LYRALINK_RELAY_FORK:-}${LYRALINK_OFFLOAD_ACTIVE:-}" in
  ''|000) ;;
  *) exit 0 ;;
esac
launcher="${SKILLSHARE_HOME:-$HOME}/.skillshare/bin/lyralink-rescue"
if [ -x "$launcher" ]; then
  "$launcher" 2>/dev/null
elif command -v lyralink >/dev/null 2>&1; then
  lyralink rescue 2>/dev/null
fi
exit 0
