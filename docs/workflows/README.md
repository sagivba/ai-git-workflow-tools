# Workflow Overview

This document describes the high-level workflow supported by `ai-git-workflow-tools`.

The goal is to turn repeated Git, GitHub, ChatGPT-generated ZIP, manually applied task, and AI-assisted working patterns into documented, reusable, and testable workflows.

## Core principles

1. Work from a clean and updated `main`.
2. Use a dedicated branch for every meaningful task.
3. Move generated ZIP files out of the repository before starting a branch.
4. Inspect Git state before making decisions.
5. Keep implementation, review, commit, PR, merge, documentation, cleanup, and tagging as separate stages.
6. Prefer explicit commands over memory.
7. Prefer dry-run by default for state-changing helper functions.
8. Execute state-changing helpers only with `--run` or `-r`.
9. Use `agw_version` and `agw_status` to confirm where the tool was loaded from and which repository is active.
10. Record what was validated and what was not validated.
11. Create release tags only after documentation and metadata review.

## High-level lifecycle

```text
Prepare clean repository
  -> Move generated ZIP files to /tmp/agw-zips
  -> Load agw functions
  -> Confirm tool and repository status
  -> Start task branch
  -> Apply task ZIP or make manual changes
  -> Review output
  -> Run validation
  -> Commit controlled change
  -> Push and prepare PR
  -> Merge through GitHub
  -> Sync local main
  -> Clean up local and remote branches
  -> Review docs and metadata
  -> Create and verify tag
```

## Workflow map

### 1. Identify loaded tool and active repository

Use:

```bash
agw_version
agw_status
```

Detailed documentation:

```text
docs/workflows/version.md
docs/workflows/status.md
```

### 2. Start task branch

Use this before applying a task ZIP or making a meaningful change.

Detailed documentation:

```text
docs/workflows/start-task.md
```

Legacy Codex branch-start documentation remains available only for compatibility:

```text
docs/workflows/start-codex-task.md
```

### 3. Inspect Git state

Use this before commit, PR, cleanup, tag, or after generated output changes files.

Detailed documentation:

```text
docs/workflows/inspect-git-state.md
```

### 4. Review output

Use this after manual edits, ChatGPT-guided edits, ZIP extraction, or other assisted work.

Detailed documentation:

```text
docs/workflows/review-output.md
```

Legacy Codex review documentation remains available only for compatibility:

```text
docs/workflows/review-codex-output.md
```

### 5. Commit controlled change

Use this after reviewing the diff and deciding which explicit files belong in the commit.

Detailed documentation:

```text
docs/workflows/commit-controlled-change.md
```

### 6. Push and prepare PR

Use this after a controlled commit exists on a task branch.

Detailed documentation:

```text
docs/workflows/push-and-pr.md
```

### 7. Sync local main after merge

Use this after a PR has been merged through GitHub.

Detailed documentation:

```text
docs/workflows/post-merge-sync.md
```

### 8. Clean up branches

Use this after merge and local `main` sync.

Detailed documentation:

```text
docs/workflows/cleanup-branches.md
```

### 9. Review documentation and metadata before tag

Use this before every release or milestone tag.

Detailed documentation:

```text
docs/workflows/pre-tag-docs-review.md
```

### 10. Create and verify release tag

Use this after documentation review and stable `main` sync.

Detailed documentation:

```text
docs/workflows/create-and-verify-tag.md
```

## Function naming convention

All Bash workflow functions use the `agw_` prefix.

`agw` means:

```text
AI Git Workflow
```

## Main functions

```bash
agw_help
agw_version
agw_status
agw_inspect_git_state
agw_start_task
agw_review_output
agw_commit_controlled_change
agw_push_and_pr
agw_post_merge_sync
agw_cleanup_branches
agw_pre_tag_docs_review
agw_create_tag
```

## Legacy compatibility functions

```bash
agw_start_codex_task
agw_review_codex_output
```

These functions remain for existing Codex-specific workflows. New work should prefer:

```bash
agw_start_task
agw_review_output
```

## Execution model

State-changing functions default to dry-run. Real execution requires:

```bash
--run
```

or:

```bash
-r
```

Read-only functions do not require `--run`:

```bash
agw_help
agw_version
agw_status
agw_pre_tag_docs_review
```

## Documentation model

The intended documentation model is:

```text
Bash function metadata and help output
  -> generated Markdown command/help sections
  -> manually written workflow explanations
```

Current `tools/generate_docs.py` checks that metadata references existing docs files. It does not yet rewrite AUTO-GENERATED sections.

## Validation model

Every task should distinguish:

```text
Validation run
Validation not run
Reason
Confidence impact
```

This is especially important for AI-assisted work, where generated changes can look plausible while hiding unrelated scope or missing checks.

## Safety rules

1. Do not work directly on `main` for implementation tasks.
2. Do not start a branch from a dirty working tree.
3. Do not leave generated ZIP files in the repository root before branching.
4. Do not commit unrelated files.
5. Do not use blind `git add .` when explicit files are safer.
6. Do not push directly from `main`.
7. Do not delete unmerged branches.
8. Do not delete remote branches without checking merge state.
9. Do not create duplicate tags.
10. Do not tag before documentation and metadata review.
11. Do not hide not-run validation.

## Definition of done for this overview

This overview is complete when it explains the full lifecycle, lists all current workflows, separates read-only from state-changing functions, explains ZIP handling, and links to detailed workflow documents.
