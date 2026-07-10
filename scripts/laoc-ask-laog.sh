#!/usr/bin/env bash
set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/laoc-ask-laog.sh PROMPT_FILE OUTPUT_DIR

Runs the configured LaoG review CLI and writes:
  OUTPUT_DIR/response.md        only after a successful non-empty response
  OUTPUT_DIR/response.stderr    provider stderr
  OUTPUT_DIR/run.log            provider, timing, and final status
  OUTPUT_DIR/health/health.tsv  preflight result

Environment:
  LAOG_PROVIDER       agy (default), kimi, or custom
  LAOG_CMD            executable name/path for LAOG_PROVIDER=custom
  LAOG_PREFLIGHT      1 (default) or 0 for an explicit diagnostic run
  LAOG_TIMEOUT        review timeout seconds; default 420
  LAOG_TIMEOUT_BIN    timeout/gtimeout path; auto-detected when omitted
  LAOG_AGY_CWD        scratch cwd for agy; default /tmp/laoc-laog-agy
  LAOG_PRINT_TIMEOUT  agy print timeout; default ${LAOG_TIMEOUT}s

The custom command contract is: COMMAND "PROMPT", with review text on stdout.
LAOG_CMD must be one executable, not a shell fragment. The script never evals it.
USAGE
}

if [[ $# -eq 1 && ( "${1:-}" == "-h" || "${1:-}" == "--help" ) ]]; then
  usage
  exit 0
fi

if [[ $# -ne 2 ]]; then
  usage >&2
  exit 2
fi

prompt_file="$1"
output_dir="$2"
provider="${LAOG_PROVIDER:-agy}"
preflight="${LAOG_PREFLIGHT:-1}"
timeout_secs="${LAOG_TIMEOUT:-420}"
timeout_bin="${LAOG_TIMEOUT_BIN:-$(command -v timeout || command -v gtimeout || true)}"
agy_cwd="${LAOG_AGY_CWD:-${TMPDIR:-/tmp}/laoc-laog-agy}"
print_timeout="${LAOG_PRINT_TIMEOUT:-${timeout_secs}s}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -s "$prompt_file" ]]; then
  echo "Prompt file is missing or empty: $prompt_file" >&2
  exit 1
fi

mkdir -p "$output_dir"
response_tmp="$output_dir/response.md.tmp"
response_file="$output_dir/response.md"
response_stderr="$output_dir/response.stderr"
run_log="$output_dir/run.log"
rm -f "$response_tmp" "$response_file"
: >"$response_stderr"

started_at="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
{
  printf 'provider=%s\n' "$provider"
  printf 'prompt_file=%s\n' "$prompt_file"
  printf 'started_at=%s\n' "$started_at"
  printf 'preflight=%s\n' "$preflight"
  printf 'timeout=%s\n' "$timeout_secs"
  printf 'initial_status=starting\n'
} >"$run_log"

finish() {
  local final_status="$1"
  local exit_code="$2"
  {
    printf 'finished_at=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    printf 'status=%s\n' "$final_status"
    printf 'exit_code=%s\n' "$exit_code"
  } >>"$run_log"
}

run_with_timeout() {
  local seconds="$1"
  shift
  if [[ -n "$timeout_bin" && "$seconds" != "0" ]]; then
    "$timeout_bin" "$seconds" "$@"
  else
    "$@"
  fi
}

custom_command_available() {
  local command_name="${LAOG_CMD:-}"
  [[ -n "$command_name" ]] || return 1
  if [[ "$command_name" == */* ]]; then
    [[ -x "$command_name" ]]
  else
    command -v "$command_name" >/dev/null 2>&1
  fi
}

run_provider() {
  local prompt="$1"
  case "$provider" in
    agy)
      command -v agy >/dev/null 2>&1 || return 127
      mkdir -p "$agy_cwd"
      (cd "$agy_cwd" && run_with_timeout "$timeout_secs" \
        agy --print-timeout "$print_timeout" --print "$prompt")
      ;;
    kimi)
      command -v kimi-cli >/dev/null 2>&1 || return 127
      run_with_timeout "$timeout_secs" kimi-cli --quiet -p "$prompt"
      ;;
    custom)
      custom_command_available || return 127
      run_with_timeout "$timeout_secs" "${LAOG_CMD}" "$prompt"
      ;;
    *)
      printf 'Unsupported LAOG_PROVIDER: %s\n' "$provider" >&2
      return 64
      ;;
  esac
}

if [[ "$preflight" != "0" ]]; then
  health_dir="$output_dir/health"
  if ! LAOG_PROVIDER="$provider" \
    LAOG_CMD="${LAOG_CMD:-}" \
    LAOG_TIMEOUT_BIN="$timeout_bin" \
    LAOG_AGY_CWD="$agy_cwd" \
    "$script_dir/check-laog-health.sh" "$health_dir"; then
    finish "preflight_failed" 1
    echo "LaoG preflight failed. See $health_dir/health.tsv" >&2
    exit 1
  fi
fi

prompt="$(<"$prompt_file")"
set +e
run_provider "$prompt" >"$response_tmp" 2>"$response_stderr"
status="$?"
set -e

if [[ "$status" == "0" ]] && grep -q '[^[:space:]]' "$response_tmp"; then
  mv "$response_tmp" "$response_file"
  finish "ok" 0
  echo "LaoG review complete: $response_file"
  exit 0
fi

rm -f "$response_tmp" "$response_file"
if [[ "$status" == "0" ]]; then
  final_status="empty_output"
else
  final_status="provider_failed"
fi
finish "$final_status" "$status"
echo "LaoG review failed with status $status. See $run_log and $response_stderr" >&2
exit 1
