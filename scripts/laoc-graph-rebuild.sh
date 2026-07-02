#!/usr/bin/env bash
set -euo pipefail

ROOT="${LAOC_WORKSPACE:-$(pwd)}"
cd "$ROOT"

if command -v graphify >/dev/null 2>&1; then
  echo "[laoc-graph] graphify found: $(command -v graphify)"
  graphify .
  echo "[laoc-graph] graph rebuilt under $ROOT/graphify-out"
  exit 0
fi

echo "[laoc-graph] graphify is not installed; writing lightweight memory index"
mkdir -p memory
{
  echo "# Graph Index Fallback"
  echo
  echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
  echo
  echo "Install graphifyy for full graph mode:"
  echo
  echo '```bash'
  echo "uv tool install graphifyy"
  echo "graphify install --project --platform codex"
  echo "graphify ."
  echo '```'
  echo
  echo "## Indexed Files"
  echo
  find AGENTS.md memory cases docs skills library -type f \( -name '*.md' -o -name '*.txt' -o -name '*.html' \) 2>/dev/null | sort | sed 's#^#- #' || true
} > memory/GRAPH_INDEX.md

echo "[laoc-graph] wrote $ROOT/memory/GRAPH_INDEX.md"
