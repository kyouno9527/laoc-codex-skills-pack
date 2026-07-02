#!/usr/bin/env bash
set -euo pipefail

QUESTION="${*:-}"
if [ -z "$QUESTION" ]; then
  echo "usage: tools/laoc-memory-ask.sh \"关于 X 有哪些规则\"" >&2
  exit 2
fi

ROOT="${LAOC_WORKSPACE:-$(pwd)}"
GRAPH_JSON="$ROOT/graphify-out/graph.json"
BUDGET="${GRAPHIFY_BUDGET:-2000}"

if command -v graphify >/dev/null 2>&1 && [ -f "$GRAPH_JSON" ]; then
  if graphify query "$QUESTION" --graph "$GRAPH_JSON" --budget "$BUDGET" 2>/tmp/laoc-graphify-error.$$; then
    rm -f /tmp/laoc-graphify-error.$$
    exit 0
  fi
  echo "[laoc-memory-ask] graphify query failed, falling back to text search" >&2
  sed -n '1,80p' /tmp/laoc-graphify-error.$$ >&2 || true
  rm -f /tmp/laoc-graphify-error.$$
fi

SEARCH_DIRS=()
for dir in memory cases docs skills library/notes library/topics; do
  if [ -d "$ROOT/$dir" ]; then
    SEARCH_DIRS+=("$ROOT/$dir")
  fi
done
if [ -f "$ROOT/AGENTS.md" ]; then
  SEARCH_DIRS+=("$ROOT/AGENTS.md")
fi

if [ "${#SEARCH_DIRS[@]}" -eq 0 ]; then
  echo "[laoc-memory-ask] no memory/search directories found under $ROOT" >&2
  exit 1
fi

echo "[laoc-memory-ask] text-search fallback under: $ROOT"
echo "[laoc-memory-ask] question: $QUESTION"
echo

if command -v rg >/dev/null 2>&1; then
  rg -n -i --glob '*.md' --glob '*.txt' --glob '*.html' "$QUESTION|$(printf '%s' "$QUESTION" | tr ' ' '|')" "${SEARCH_DIRS[@]}" | head -80 || true
else
  grep -RInE "$QUESTION" "${SEARCH_DIRS[@]}" | head -80 || true
fi
