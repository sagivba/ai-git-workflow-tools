# ai-git-workflow-tools

Reusable Git, GitHub, ChatGPT, and Codex workflow tools.

This repository contains:

- Bash functions for recurring AI-assisted Git workflows.
- Markdown documentation for each workflow.
- A documentation generation mechanism.
- Tests for safe dry-run behavior.
- GitHub Actions checks.

## Core idea

The Bash functions are the technical source of truth.

Markdown documentation explains the workflows and can be synchronized from Bash metadata and help output.

## Safe execution model

All workflow functions default to dry-run mode.

Use `--run` or `-r` to execute commands.

## Initial workflows

1. Start a Codex task branch.
2. Inspect Git state.
3. Review Codex output.
4. Commit a controlled change.
5. Push and prepare PR.
6. Sync after merge.
7. Clean up branches.
8. Review documentation before tag.
9. Create and verify release tag.

## Quick start

```bash
source scripts/ai-git-workflows.sh
agw_help
agw_inspect_git_state --help
```

Dry-run example:

```bash
agw_start_codex_task --branch codex-cli/example-task
```

Run example:

```bash
agw_start_codex_task --branch codex-cli/example-task --run
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
