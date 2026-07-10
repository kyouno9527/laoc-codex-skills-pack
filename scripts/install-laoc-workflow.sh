#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="${1:-$(pwd)}"

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "[laoc-install] project root does not exist: $PROJECT_ROOT" >&2
  exit 1
fi

mkdir -p \
  "$PROJECT_ROOT/skills" \
  "$PROJECT_ROOT/tools" \
  "$PROJECT_ROOT/mcp" \
  "$PROJECT_ROOT/memory" \
  "$PROJECT_ROOT/cases" \
  "$PROJECT_ROOT/library/notes" \
  "$PROJECT_ROOT/library/topics"

cp -R "$PACKAGE_DIR/skills/"* "$PROJECT_ROOT/skills/"
cp -R "$PACKAGE_DIR/mcp/"* "$PROJECT_ROOT/mcp/"
cp "$PACKAGE_DIR/scripts/laoc-memory-ask.sh" "$PROJECT_ROOT/tools/laoc-memory-ask.sh"
cp "$PACKAGE_DIR/scripts/laoc-graph-rebuild.sh" "$PROJECT_ROOT/tools/laoc-graph-rebuild.sh"
cp "$PACKAGE_DIR/scripts/check-laoc-tools.sh" "$PROJECT_ROOT/tools/check-laoc-tools.sh"
cp "$PACKAGE_DIR/scripts/check-laog-health.sh" "$PROJECT_ROOT/tools/check-laog-health.sh"
cp "$PACKAGE_DIR/scripts/laoc-ask-laog.sh" "$PROJECT_ROOT/tools/laoc-ask-laog.sh"
chmod +x \
  "$PROJECT_ROOT/tools/laoc-memory-ask.sh" \
  "$PROJECT_ROOT/tools/laoc-graph-rebuild.sh" \
  "$PROJECT_ROOT/tools/check-laoc-tools.sh" \
  "$PROJECT_ROOT/tools/check-laog-health.sh" \
  "$PROJECT_ROOT/tools/laoc-ask-laog.sh"

touch "$PROJECT_ROOT/memory/PROJECT_MEMORY.md"
touch "$PROJECT_ROOT/memory/SOURCE_MAP.md"
touch "$PROJECT_ROOT/memory/LESSONS_DIGEST.md"

AGENTS="$PROJECT_ROOT/AGENTS.md"
if [ ! -f "$AGENTS" ]; then
  cp "$PACKAGE_DIR/AGENTS_LAOC_SNIPPET.md" "$AGENTS"
elif grep -q "LAOC_WORKFLOW_BEGIN" "$AGENTS"; then
  echo "[laoc-install] AGENTS.md already contains LAOC workflow block"
else
  {
    printf "\n\n"
    cat "$PACKAGE_DIR/AGENTS_LAOC_SNIPPET.md"
  } >> "$AGENTS"
fi

cat > "$PROJECT_ROOT/memory/PROJECT_MEMORY.md.tmp" <<'EOF'
# Project Memory

本文件记录鹏哥项目的长期事实、入口、账号状态摘要、服务地址、稳定规则和恢复方式。

不要写入密钥、cookie、token、私密账号材料或浏览器 profile 正文。
EOF

if [ ! -s "$PROJECT_ROOT/memory/PROJECT_MEMORY.md" ]; then
  mv "$PROJECT_ROOT/memory/PROJECT_MEMORY.md.tmp" "$PROJECT_ROOT/memory/PROJECT_MEMORY.md"
else
  rm "$PROJECT_ROOT/memory/PROJECT_MEMORY.md.tmp"
fi

echo "[laoc-install] installed into: $PROJECT_ROOT"
echo "[laoc-install] next checks:"
echo "  test -d '$PROJECT_ROOT/skills/laoc-shikagami'"
echo "  cd '$PROJECT_ROOT'"
echo "  tools/check-laoc-tools.sh"
echo "  tools/check-laog-health.sh cases/laog-health"
echo "  tools/laoc-memory-ask.sh '老C应该怎么验收'"
