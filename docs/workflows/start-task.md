# Workflow: Start Task Branch

## Purpose

Start a new manual task branch from a clean and updated `main` branch.

This workflow is the preferred branch-start workflow for this repository when work is performed manually or through ChatGPT-generated ZIP files that are later reviewed and applied locally.

## When to use

- Before starting a meaningful manual task that should not be done directly on `main`.
- Before applying a task ZIP that contains files to add or replace.
- When a task needs a clear branch name for review, PR, and audit.
- When Git operations can be performed through the reusable helper instead of being typed manually.

## Preconditions

- The repository has a remote named `origin`.
- `main` is the intended integration branch.
- There are no local changes that should be preserved before switching branches.
- The task identifier and slug are known, or the full branch name is known.

## Commands

<!-- AUTO-GENERATED:START workflow=start-task -->
The generated command/help block for this workflow should be inserted here by `tools/generate_docs.py`.
<!-- AUTO-GENERATED:END -->

### Command sequence

```bash
git fetch --prune origin
```

Fetch latest remote refs from `origin` and remove stale remote-tracking branches.

```bash
git switch main
```

Switch to the integration branch.

```bash
git pull --ff-only origin main
```

Update local `main` from `origin/main` without creating a merge commit.

```bash
git status --short | cat
```

Verify that the working tree is clean and produce stable output.

```bash
git log --oneline --decorate -5 | cat
```

Show the latest commits and refs before branching.

```bash
git switch -c <branch>
```

Create and switch to the new task branch.

## Function usage

Preferred task/slug form:

```bash
agw_start_task --task T003 --slug improve-task-start-workflow [--run|-r]
```

Explicit branch form:

```bash
agw_start_task --branch manual/T003-improve-task-start-workflow [--run|-r]
```

## Parameters

- `--task ID`: Task identifier. Must match `T<number>`, for example `T003`.
- `--slug TEXT`: Short lowercase branch slug. Use lowercase letters, digits, and hyphens.
- `--branch NAME`: Explicit branch name to create. Required prefix: `manual/`.
- `--run`, `-r`: Execute commands. Without this flag, commands are printed only.
- `--help`: Show function help.

## Branch naming

The task/slug form derives the branch name as:

```text
manual/<task>-<slug>
```

Example:

```bash
agw_start_task --task T003 --slug improve-task-start-workflow
```

Derived branch:

```text
manual/T003-improve-task-start-workflow
```

## Rules

- `--branch` cannot be combined with `--task` or `--slug`.
- `--task` and `--slug` must be provided together.
- Derived branches always use the `manual/` prefix.
- The default mode is dry-run.
- Real execution requires `--run` or `-r`.

## Risks

- Starting from a stale `main` may create unnecessary conflicts later.
- Creating a branch while local changes exist can mix unrelated work into the task.
- Using an unclear branch name makes later audit and cleanup harder.
- Applying a task ZIP on the wrong branch can mix unrelated work into a PR.

## Definition of done

- The current branch is the new manual task branch.
- The branch starts from updated `main`.
- The working tree state is understood.
- The task ZIP can be applied without changing `main` directly.
