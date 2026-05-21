#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash -n scripts/ai-git-workflows.sh
bash -n tests/test_help.sh
bash -n tests/test_dry_run.sh
bash -n tests/run.sh

tests/test_help.sh
tests/test_dry_run.sh
python3 -m unittest discover -s tests -p "test_*.py" -v
python3 tools/generate_docs.py --check
