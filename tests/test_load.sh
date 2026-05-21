#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"

output="$(bash "$ROOT/scripts/load-agw.sh" 2>&1 || true)"
assert_contains "$output" "must be sourced"

# shellcheck source=scripts/load-agw.sh
source "$ROOT/scripts/load-agw.sh"

type agw_help >/dev/null
type agw_start_task >/dev/null
type agw_review_output >/dev/null

help_output="$(agw_help)"
assert_contains "$help_output" "agw_start_task"
assert_contains "$help_output" "agw_review_output"
