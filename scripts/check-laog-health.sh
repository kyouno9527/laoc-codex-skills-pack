#!/usr/bin/env bash
set -uo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/check-laog-health.sh OUTPUT_DIR

Checks the configured LaoG review CLI with a harmless smoke prompt and writes:
  OUTPUT_DIR/health.tsv
  OUTPUT_DIR/laog.out
  OUTPUT_DIR/laog.stderr

Environment:
  LAOG_PROVIDER        agy (default), kimi, or custom
  LAOG_CMD             executable name/path for LAOG_PROVIDER=custom
  LAOG_HEALTH_TIMEOUT  timeout seconds; default 90
  LAOG_TIMEOUT_BIN     timeout/gtimeout path; auto-detected when omitted
  LAOG_AGY_CWD         scratch cwd for agy; default /tmp/laoc-laog-agy
  LAOG_PRINT_TIMEOUT   agy print timeout; default ${LAOG_HEALTH_TIMEOUT}s

The custom command contract is: COMMAND "PROMPT", with review text on stdout.
LAOG_CMD must be one executable, not a shell fragment. The script never evals it.
USAGE
}

if [[ $# -eq 1 && ( "${1:-}" == "-h" || "${1:-}" == "--help" ) ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 2
fi

output_dir="$1"
provider="${LAOG_PROVIDER:-agy}"
timeout_secs="${LAOG_HEALTH_TIMEOUT:-90}"
timeout_bin="${LAOG_TIMEOUT_BIN:-$(command -v timeout || command -v gtimeout || true)}"
agy_cwd="${LAOG_AGY_CWD:-${TMPDIR:-/tmp}/laoc-laog-agy}"
print_timeout="${LAOG_PRINT_TIMEOUT:-${timeout_secs}s}"
expected="OK_LAOG_HEALTH"

mkdir -p "$output_dir"
out="$output_dir/laog.out"
err="$output_dir/laog.stderr"
health_tsv="$output_dir/health.tsv"
: >"$out"
: >"$err"
printf 'provider\tstatus\tdetail\n' >"$health_tsv"

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

set +e
run_provider "只输出 $expected" >"$out" 2>"$err"
status="$?"
set -e

if [[ "$status" == "0" ]] && grep -q "$expected" "$out"; then
  printf '%s\tok\tmatched:%s\n' "$provider" "$expected" >>"$health_tsv"
  cat "$health_tsv"
  exit 0
fi

if [[ "$status" == "124" ]]; then
  detail="timeout:${timeout_secs}s"
elif [[ "$status" == "127" ]]; then
  detail="missing_or_unexecutable_command"
elif [[ "$status" == "64" ]]; then
  detail="unsupported_provider"
elif [[ ! -s "$out" ]]; then
  detail="exit:$status empty_output"
else
  detail="exit:$status unexpected_output"
fi

printf '%s\tdegraded\t%s\n' "$provider" "$detail" >>"$health_tsv"
cat "$health_tsv"
echo "LaoG health check failed. See $health_tsv and $err" >&2
exit 1
