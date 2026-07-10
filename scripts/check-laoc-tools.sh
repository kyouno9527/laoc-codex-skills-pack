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
check graphify optional || true

laog_provider="${LAOG_PROVIDER:-agy}"
case "$laog_provider" in
  agy)
    check agy optional || true
    ;;
  kimi)
    check kimi-cli optional || true
    ;;
  custom)
    if [ -n "${LAOG_CMD:-}" ]; then
      check "$LAOG_CMD" optional || true
    else
      printf '[skip] %-12s %s\n' 'laog' 'LAOG_CMD is not set for custom provider'
    fi
    ;;
  *)
    printf '[skip] %-12s unsupported provider: %s\n' 'laog' "$laog_provider"
    ;;
esac

echo
echo "MCP note: provider-specific MCPs are not checked unless Pengge explicitly enables them."
echo "LaoG provider: $laog_provider"
echo "Run tools/check-laog-health.sh <output-dir> before a formal review."

exit "$status"
