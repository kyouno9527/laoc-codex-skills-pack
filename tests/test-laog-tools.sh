#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp"
}
trap cleanup EXIT

mkdir -p "$tmp/bin" "$tmp/project"

cat >"$tmp/bin/agy" <<'FAKE_AGY'
#!/usr/bin/env bash
if [[ "${FAKE_AGY_FAIL:-0}" == "1" ]]; then
  echo "fake provider failure" >&2
  exit 42
fi
prompt="${!#}"
if [[ "$prompt" == *"OK_LAOG_HEALTH"* ]]; then
  echo "OK_LAOG_HEALTH"
else
  echo "FAKE REVIEW: $prompt"
fi
FAKE_AGY
chmod +x "$tmp/bin/agy"

PATH="$tmp/bin:$PATH" \
  "$repo_root/scripts/check-laog-health.sh" "$tmp/health"
grep -q $'agy\tok\t' "$tmp/health/health.tsv"

printf '%s\n' 'review this plan' >"$tmp/prompt.md"
PATH="$tmp/bin:$PATH" \
  "$repo_root/scripts/laoc-ask-laog.sh" "$tmp/prompt.md" "$tmp/review"
grep -q 'FAKE REVIEW: review this plan' "$tmp/review/response.md"
grep -q '^status=ok$' "$tmp/review/run.log"

FAKE_AGY_FAIL=1 LAOG_PREFLIGHT=0 PATH="$tmp/bin:$PATH" \
  "$repo_root/scripts/laoc-ask-laog.sh" "$tmp/prompt.md" "$tmp/review" >/dev/null 2>&1 && {
    echo "failing provider unexpectedly passed" >&2
    exit 1
  }
test ! -e "$tmp/review/response.md"
grep -q '^status=provider_failed$' "$tmp/review/run.log"

cat >"$tmp/bin/custom-review" <<'FAKE_CUSTOM'
#!/usr/bin/env bash
if [[ "$1" == *"OK_LAOG_HEALTH"* ]]; then
  echo "OK_LAOG_HEALTH"
else
  echo "CUSTOM REVIEW: $1"
fi
FAKE_CUSTOM
chmod +x "$tmp/bin/custom-review"

LAOG_PROVIDER=custom LAOG_CMD="$tmp/bin/custom-review" \
  "$repo_root/scripts/laoc-ask-laog.sh" "$tmp/prompt.md" "$tmp/custom-review"
grep -q 'CUSTOM REVIEW: review this plan' "$tmp/custom-review/response.md"

LAOG_PROVIDER=custom LAOG_CMD="$tmp/bin/missing" \
  "$repo_root/scripts/check-laog-health.sh" "$tmp/missing" >/dev/null 2>&1 && {
    echo "missing custom provider unexpectedly passed" >&2
    exit 1
  }
grep -q $'custom\tdegraded\tmissing_or_unexecutable_command' "$tmp/missing/health.tsv"

"$repo_root/scripts/install-laoc-workflow.sh" "$tmp/project" >/dev/null
test -x "$tmp/project/tools/check-laog-health.sh"
test -x "$tmp/project/tools/laoc-ask-laog.sh"

echo "test-laog-tools: PASS"
