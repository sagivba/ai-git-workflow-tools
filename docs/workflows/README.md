# Workflow Overview

This document describes the high-level AI-assisted Git and GitHub workflow used by this repository.

The goal is to turn repeated Git, GitHub, ChatGPT, manually applied task ZIPs, and other AI-assisted working patterns into documented, reusable, and testable workflows.

## Core principles

1. Work from a clean and updated `main`.
2. Use a dedicated branch for every meaningful task.
3. Inspect Git state before making decisions.
4. Keep implementation, review, commit, PR, merge, documentation, and tagging as separate workflow stages.
5. Prefer explicit commands over memory.
6. Prefer dry-run by default for helper functions.
7. Execute commands only with `--run` or `-r`.
8. Keep GitHub as the source of truth.
9. Record what was validated and what was not validated.
10. Create release tags only after documentation and metadata review.

## High-level lifecycle

The complete workflow is:

```text
Plan task
  -> Start task branch
  -> Inspect Git state
  -> Implement or edit
  -> Review output
  -> Commit controlled change
  -> Push and prepare PR
  -> Merge through GitHub
  -> Sync local main
  -> Review docs and metadata
  -> Create and verify tag
  -> Clean up branches
```

Not every small change requires every step, but every meaningful change should follow this structure.

## Workflow map

### 1. Plan task

Define the goal before touching files.

The task should answer:

- What is the objective?
- What is in scope?
- What is out of scope?
- Which files or areas are expected to change?
- What validation is required?
- Is this manual work, ChatGPT-guided work, Codex/Codex CLI work, or another assisted workflow?

This repository does not currently provide a Bash function for planning, because planning is a reasoning step.

### 2. Start task branch

Use this workflow when starting a new implementation, documentation, or workflow task.

Expected branch patterns:

```text
manual/<task-id>-<short-name>
codex-cli/<task-id>-<short-name>
docs/<short-name>
fix/<short-name>
```

The main recommended pattern for manually applied task ZIP work is:

```text
manual/<task-id>-<short-name>
```

Detailed documentation:

```text
docs/workflows/start-task.md
```

Legacy Codex-specific branch-start documentation remains available for compatibility:

```text
docs/workflows/start-codex-task.md
```

### 3. Inspect Git state

Use this workflow before any important action:

- before commit
- before PR
- before merge
- before cleanup
- before tag
- after a tool or AI assistant changed files

Detailed documentation:

```text
docs/workflows/inspect-git-state.md
```

### 4. Review output

Use this workflow after manual edits, ChatGPT-guided edits, generated ZIP extraction, Codex/Codex CLI work, or other assisted work.

The review checks:

- Did the changed files match the task?
- Are there unrelated changes?
- Are there deleted files?
- Are there unexpected dependency changes?
- Were tests or checks run?
- Are not-run checks documented?
- Is documentation updated when needed?

Detailed documentation:

```text
docs/workflows/review-output.md
```

Legacy Codex-specific review documentation remains available for compatibility:

```text
docs/workflows/review-codex-output.md
```

### 5. Commit controlled change

Use this workflow after reviewing the diff and deciding that the change is ready to commit.

Preferred approach:

- avoid blind `git add .` when possible
- stage explicit files
- inspect staged diff
- use a clear commit message

Detailed documentation:

```text
docs/workflows/commit-controlled-change.md
```

### 6. Push and prepare PR

Use this workflow after committing a task branch.

PR creation can happen either through GitHub Web or GitHub CLI.

Detailed documentation:

```text
docs/workflows/push-and-pr.md
```

### 7. Merge through GitHub

Merging is usually done through GitHub Web for convenience.

Before merge, verify:

- PR title is clear.
- PR body documents scope.
- Changed files match the task.
- Validation is documented.
- Not-run validation is documented.
- There is no unrelated scope creep.

This repository does not currently provide an automatic merge function.

Reason:

Merge decisions should remain explicit and review-driven.

### 8. Sync local main after merge

Use this workflow after a PR has been merged through GitHub.

Detailed documentation:

```text
docs/workflows/post-merge-sync.md
```

### 9. Review documentation and metadata before tag

Use this workflow before creating a release tag.

This is a mandatory review step before tagging.

Detailed documentation:

```text
docs/workflows/pre-tag-docs-review.md
```

### 10. Create and verify release tag

Use this workflow after a stable milestone, stage, or goal has been merged into `main`.

Supported tag format:

```text
vX.Y.Z
```

Detailed documentation:

```text
docs/workflows/create-and-verify-tag.md
```

### 11. Clean up branches

Use this workflow after merge and local `main` sync.

Cleanup should be conservative.

Never delete an unmerged branch unless that is intentional and explicitly verified.

Detailed documentation:

```text
docs/workflows/cleanup-branches.md
```

## Function naming convention

All Bash workflow functions use the `agw_` prefix.

`agw` means:

```text
AI Git Workflow
```

Examples:

```bash
agw_help
agw_inspect_git_state
agw_start_task
agw_review_output
agw_pre_tag_docs_review
agw_create_tag
```

Legacy compatibility functions remain available:

```bash
agw_start_codex_task
agw_review_codex_output
```

## Execution model

All functions that can modify Git state must default to dry-run.

Dry-run means:

- print the commands
- do not execute them
- do not change repository state

Execution requires:

```bash
--run
```

or:

```bash
-r
```

## Documentation model

The intended documentation model is:

```text
Bash function metadata and help output
  -> generated Markdown command/help sections
  -> manually written workflow explanations
```

Each detailed workflow document should contain:

- Purpose
- When to use
- Preconditions
- Commands
- Function usage
- Explanation of parameters
- Risks
- Definition of done

Auto-generated sections should be bounded by markers:

```markdown
<!-- AUTO-GENERATED:START workflow=<workflow-name> -->
...
<!-- AUTO-GENERATED:END -->
```

The generator should update only these marked sections.

## Validation model

Every workflow should distinguish:

```text
Validation run
Validation not run
Reason
Confidence impact
```

This is especially important for AI-assisted work, where false confidence is a recurring risk.

## Safety rules

1. Do not run destructive commands automatically.
2. Do not force push unless explicitly approved.
3. Do not delete remote branches without checking merge state.
4. Do not create tags without checking whether they already exist.
5. Do not tag before documentation and metadata review.
6. Do not hide not-run validation.
7. Do not work directly on `main` for implementation tasks.
8. Do not commit unrelated files.
9. Do not let generated documentation overwrite manual content outside generated markers.

## Recommended first stable workflow set

The first useful version of this repository should cover:

1. `agw_inspect_git_state`
2. `agw_start_task`
3. `agw_review_output`
4. `agw_commit_controlled_change`
5. `agw_push_and_pr`
6. `agw_post_merge_sync`
7. `agw_cleanup_branches`
8. `agw_pre_tag_docs_review`
9. `agw_create_tag`

Compatibility helpers such as `agw_start_codex_task` and `agw_review_codex_output` should continue to work, but they are not the primary API for new workflows.

## Definition of done for this overview

This overview is complete when:

- It explains the full lifecycle.
- It lists all first-version workflows.
- It separates local Git work from GitHub Web work.
- It explains the dry-run execution model.
- It explains the documentation generation model.
- It defines tagging as a formal workflow stage.
- It defines documentation review as a pre-tag requirement.
