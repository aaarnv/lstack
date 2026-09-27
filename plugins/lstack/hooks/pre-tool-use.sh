#!/bin/sh
# The CLI emits JSON only for an enabled exact verification command.
# No network, pressure probes or jobs run in the hook process.
case "${LYRALINK_RELAY_JOB:-}${LYRALINK_RELAY_FORK:-}${LYRALINK_OFFLOAD_ACTIVE:-}" in
  ''|000) ;;
  *) exit 0 ;;
esac
if command -v lyralink >/dev/null 2>&1; then
  lyralink relay offload hook 2>/dev/null || true
fi
exit 0
