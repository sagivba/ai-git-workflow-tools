#!/usr/bin/env python3
"""Generate workflow documentation from Bash metadata.

Initial skeleton version:
- Parses metadata blocks from scripts/ai-git-workflows.sh.
- Verifies that referenced docs files exist.
- In future versions, this file will update AUTO-GENERATED sections.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "ai-git-workflows.sh"


@dataclass(frozen=True)
class WorkflowMeta:
    workflow: str
    title: str | None = None
    doc: str | None = None
    summary: str | None = None
    usage: str | None = None


def parse_metadata(script_path: Path) -> list[WorkflowMeta]:
    metas: list[WorkflowMeta] = []
    current: dict[str, str] = {}

    for line in script_path.read_text(encoding="utf-8").splitlines():
        if line.startswith("# @"):
            key_value = line[3:].strip()
            if " " not in key_value:
                continue
            key, value = key_value.split(" ", 1)
            key = key.strip()
            value = value.strip()
            if key == "workflow" and current:
                metas.append(WorkflowMeta(**current))
                current = {}
            current[key.replace("-", "_")] = value
        elif current and line and not line.startswith("#"):
            metas.append(WorkflowMeta(**current))
            current = {}

    if current:
        metas.append(WorkflowMeta(**current))

    return metas


def check_docs(metas: list[WorkflowMeta]) -> list[str]:
    errors: list[str] = []
    for meta in metas:
        if not meta.doc:
            errors.append(f"{meta.workflow}: missing @doc")
            continue
        doc_path = ROOT / meta.doc
        if not doc_path.exists():
            errors.append(f"{meta.workflow}: missing docs file {meta.doc}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="Check docs without modifying files.")
    args = parser.parse_args()

    metas = parse_metadata(SCRIPT)
    errors = check_docs(metas)

    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1

    if args.check:
        print(f"Docs check passed for {len(metas)} workflows.")
        return 0

    print("Discovered workflows:")
    for meta in metas:
        print(f"- {meta.workflow}: {meta.doc}")
    print("TODO: implement auto-generation of Markdown sections.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
