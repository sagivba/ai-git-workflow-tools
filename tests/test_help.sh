#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"
# shellcheck source=scripts/ai-git-workflows.sh
source "$ROOT/scripts/ai-git-workflows.sh"

functions=(
  agw_version
  agw_status
  agw_inspect_git_state
  agw_start_task
  agw_start_codex_task
  agw_review_output
  agw_review_codex_output
  agw_commit_controlled_change
  agw_push_and_pr
  agw_post_merge_sync
  agw_cleanup_branches
  agw_pre_tag_docs_review
  agw_create_tag
)

for fn in "${functions[@]}"; do
  output="$($fn --help)"
  assert_contains "$output" "Purpose:"
  assert_contains "$output" "Usage:"
  assert_contains "$output" "Docs:"
done

output="$(agw_help)"
assert_contains "$output" "agw_version"
assert_contains "$output" "agw_status"
assert_contains "$output" "agw_review_output"
assert_contains "$output" "agw_review_codex_output"
assert_contains "$output" "New generic workflows should prefer"

output="$(agw_version)"
assert_contains "$output" "ai-git-workflow-tools"
assert_contains "$output" "version:"
assert_contains "$output" "tool_root:"

output="$(agw_review_codex_output --help)"
assert_contains "$output" "Prefer agw_review_output"

output="$(agw_create_tag --help)"
assert_contains "$output" "--run, -r"
assert_contains "$output" "--note"
assert_contains "$output" "vX.Y.Z"
