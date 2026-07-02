#!/usr/bin/env bash
set -euo pipefail

check() {
  local name="$1"
  local required="$2"
  if command -v "$name" >/dev/null 2>&1; then
    printf '[ok]   %-12s %s\n' "$name" "$(command -v "$name")"
  elif [ "$required" = "required" ]; then
    printf '[miss] %-12s required\n' "$name"
    return 1
  else
    printf '[skip] %-12s optional\n' "$name"
  fi
}

status=0
check git required || status=1
check rg optional || true
check python3 required || status=1
check node optional || true
check gh optional || true
check external_review optional || true
check graphify optional || true

echo
echo "MCP note: provider-specific MCPs are not checked unless Pengge explicitly enables them."
echo "If External review CLI uses a different command name, set LAOG_CMD in the local shell/profile."

exit "$status"
