# ai-git-workflow-tools

Reusable Git, GitHub, and AI-assisted workflow tools.

This repository contains:

- Bash functions for recurring Git and GitHub workflows.
- Generic helpers for manual and AI-assisted task work.
- Compatibility helpers for older Codex-specific workflows.
- Markdown documentation for each workflow.
- A documentation generation mechanism.
- Tests for safe dry-run behavior and safety guards.
- GitHub Actions checks.

## Core idea

The Bash functions are the technical source of truth.

Markdown documentation explains the workflows and can be synchronized from Bash metadata and help output.

## Safe execution model

All workflow functions default to dry-run mode.

Use `--run` or `-r` to execute commands.

In `--run` mode, safety guards prevent common mistakes such as committing directly on `main`, creating branches from a dirty working tree, deleting unmerged branches, or creating duplicate tags.

## Primary workflows

1. Start a generic task branch.
2. Inspect Git state.
3. Review output.
4. Commit a controlled change.
5. Push and prepare PR.
6. Sync after merge.
7. Clean up branches.
8. Review documentation before tag.
9. Create and verify release tag.

Codex-specific helpers remain available for backward compatibility, but new workflows should prefer the generic function names.

## Quick start

```bash
source scripts/ai-git-workflows.sh
agw_help
agw_inspect_git_state --help
```

Dry-run examples:

```bash
agw_start_task --task T005 --slug generic-review-output-alias
agw_review_output
```

Run example:

```bash
agw_start_task --task T005 --slug generic-review-output-alias --run
```

## Compatibility helpers

The following legacy names are still supported:

```bash
agw_start_codex_task
agw_review_codex_output
```

Prefer these generic names for new work:

```bash
agw_start_task
agw_review_output
```

## Test

```bash
make test
```

## Generate or check docs

```bash
make docs
make check-docs
```
