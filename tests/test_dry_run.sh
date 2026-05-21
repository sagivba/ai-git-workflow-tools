#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"
# shellcheck source=scripts/ai-git-workflows.sh
source "$ROOT/scripts/ai-git-workflows.sh"

assert_fails_with() {
  local expected="$1"
  shift

  local output=""
  local status=0
  output="$("$@" 2>&1)" || status=$?

  if [[ "$status" == "0" ]]; then
    echo "Expected command to fail, but it succeeded." >&2
    exit 1
  fi

  assert_contains "$output" "$expected"
}

tmpdir="$(mktemp -d /tmp/agw-test-XXXXXX)"
trap 'rm -rf "$tmpdir"' EXIT

workdir="$tmpdir/work"
mkdir -p "$workdir"
cd "$workdir"
git init --initial-branch=main >/dev/null
git config user.name "AGW Test"
git config user.email "agw-test@example.com"
echo "# Test" > README.md
git add README.md
git commit -m "Initial commit" >/dev/null
git init --bare --initial-branch=main "$tmpdir/origin.git" >/dev/null
git remote add origin "$tmpdir/origin.git"
git push -u origin main >/dev/null

output="$(agw_start_task --task T003 --slug improve-task-start-workflow)"
assert_contains "$output" "+ git fetch --prune origin"
assert_contains "$output" "+ git switch main"
assert_contains "$output" "+ git switch -c manual/T003-improve-task-start-workflow"

if printf '%s\n' "$output" | grep -Fq "git+ fetch"; then
  echo "Dry-run output contains unreadable plus-separated command text." >&2
  exit 1
fi

if git branch --list manual/T003-improve-task-start-workflow | grep -q manual/T003-improve-task-start-workflow; then
  echo "Dry-run created a manual task branch unexpectedly." >&2
  exit 1
fi

output="$(agw_start_task --branch manual/T003-explicit-branch)"
assert_contains "$output" "+ git switch -c manual/T003-explicit-branch"

if git branch --list manual/T003-explicit-branch | grep -q manual/T003-explicit-branch; then
  echo "Dry-run created an explicit manual task branch unexpectedly." >&2
  exit 1
fi

assert_fails_with "Error: --branch cannot be combined with --task or --slug." \
  agw_start_task --branch manual/T003-mixed --task T003 --slug mixed

assert_fails_with "Error: provide either --branch or both --task and --slug." \
  agw_start_task --task T003

assert_fails_with "Error: --task must match T<number>, for example T003." \
  agw_start_task --task task-003 --slug invalid-task

assert_fails_with "Error: --slug must use lowercase letters, digits, and hyphens." \
  agw_start_task --task T003 --slug Invalid_Slug

output="$(agw_start_codex_task --branch codex-cli/dry-run-test)"
assert_contains "$output" "+ git fetch --prune origin"
assert_contains "$output" "+ git switch main"

if printf '%s\n' "$output" | grep -Fq "git+ fetch"; then
  echo "Dry-run output contains unreadable plus-separated command text." >&2
  exit 1
fi

if git branch --list codex-cli/dry-run-test | grep -q codex-cli/dry-run-test; then
  echo "Dry-run created a codex task branch unexpectedly." >&2
  exit 1
fi

output="$(agw_create_tag --tag v0.1.0 --note "Dry run tag")"
assert_contains "$output" "+ git tag -a v0.1.0"

if printf '%s\n' "$output" | grep -Fq "git+ tag"; then
  echo "Dry-run output contains unreadable plus-separated tag command text." >&2
  exit 1
fi

if git tag --list v0.1.0 | grep -q v0.1.0; then
  echo "Dry-run created a tag unexpectedly." >&2
  exit 1
fi

echo "dirty" > dirty.txt
assert_fails_with "Error: working tree must be clean before this operation." \
  agw_start_task --task T004 --slug dirty-tree-check --run
rm dirty.txt

assert_fails_with "Error: refusing to modify main directly." \
  agw_commit_controlled_change --message "No direct main commit" --files README.md --run

assert_fails_with "Error: refusing to modify main directly." \
  agw_push_and_pr --run

git tag -a v0.1.0 -m "v0.1.0 - existing local tag" >/dev/null
assert_fails_with "Error: tag already exists locally: v0.1.0" \
  agw_create_tag --tag v0.1.0 --note "Duplicate tag" --run

git switch -c manual/T004-unmerged-cleanup >/dev/null
echo "unmerged" > unmerged.txt
git add unmerged.txt
git commit -m "Unmerged cleanup test" >/dev/null
git push -u origin manual/T004-unmerged-cleanup >/dev/null
git switch main >/dev/null

assert_fails_with "Error: refusing to delete remote branch that is not merged into origin/main: origin/manual/T004-unmerged-cleanup" \
  agw_cleanup_branches --branch manual/T004-unmerged-cleanup --remote --run
