#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=tests/lib/assert.sh
source "$ROOT/tests/lib/assert.sh"
# shellcheck source=scripts/ai-git-workflows.sh
source "$ROOT/scripts/ai-git-workflows.sh"

tmpdir="$(mktemp -d /tmp/agw-test-XXXXXX)"
trap 'rm -rf "$tmpdir"' EXIT

cd "$tmpdir"
git init -b main >/dev/null
git config user.name "AGW Test"
git config user.email "agw-test@example.com"
echo "# Test" > README.md
git add README.md
git commit -m "Initial commit" >/dev/null
git init --bare origin.git >/dev/null
git remote add origin "$tmpdir/origin.git"
git push -u origin main >/dev/null

output="$(agw_start_codex_task --branch codex-cli/dry-run-test)"
assert_contains "$output" "git"

if git branch --list codex-cli/dry-run-test | grep -q codex-cli/dry-run-test; then
  echo "Dry-run created a branch unexpectedly." >&2
  exit 1
fi

output="$(agw_create_tag --tag v0.1.0 --note "Dry run tag")"
assert_contains "$output" "git"

if git tag --list v0.1.0 | grep -q v0.1.0; then
  echo "Dry-run created a tag unexpectedly." >&2
  exit 1
fi
