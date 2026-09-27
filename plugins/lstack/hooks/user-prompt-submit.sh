#!/bin/sh
# lstack UserPromptSubmit: `lyralink prompt` matches the prompt against the
# team's recorded decisions on this machine and prints the ones that apply.
# The hook event arrives on stdin and passes straight through. A prompt must
# never fail or wait on LyraLink, so every error is dropped and it exits 0.

launcher="${SKILLSHARE_HOME:-$HOME}/.skillshare/bin/lyralink-prompt"
if [ -x "$launcher" ]; then
  "$launcher" 2>/dev/null
elif command -v lyralink >/dev/null 2>&1; then
  lyralink prompt 2>/dev/null
fi
exit 0
