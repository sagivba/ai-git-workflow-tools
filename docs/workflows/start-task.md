# Workflow: Start Task Branch

## Purpose

Start a new manual task branch from a clean and updated `main` branch.

This is the preferred branch-start workflow for manual work and ChatGPT-generated ZIP tasks.

## When to use

- Before starting a meaningful task that should not be done directly on `main`.
- Before applying a generated task ZIP.
- When a task needs a clear branch name for review, PR, cleanup, and audit.

## Preconditions

- The current directory is inside the target Git repository.
- The repository has a remote named `origin`.
- `main` is the intended integration branch.
- The working tree is clean.
- Generated ZIP files have been moved out of the repository root, for example to `/tmp/agw-zips`.
- The task identifier and slug are known, or a full branch name is known.

## Syntax

```bash
agw_start_task --task T008 --slug complete-documentation-iteration [--run|-r]
agw_start_task --branch manual/T008-complete-documentation-iteration [--run|-r]
```

## Parameters

- `--task ID`: Task identifier. Must match `T<number>`, for example `T008`.
- `--slug TEXT`: Short lowercase branch slug. Use lowercase letters, digits, and hyphens.
- `--branch NAME`: Explicit branch name to create. Required prefix: `manual/`.
- `--run`: Execute commands.
- `-r`: Short form for `--run`.
- `--help`: Show function help.

## Dry-run example

```bash
agw_start_task --task T008 --slug complete-documentation-iteration
```

## `--run` example

```bash
agw_start_task --task T008 --slug complete-documentation-iteration --run
```

## `-r` example

```bash
agw_start_task --task T008 --slug complete-documentation-iteration -r
```

## Expected output / behavior

In dry-run mode, the function prints the Git commands that would run.

In run mode, it:

1. fetches from `origin`
2. verifies the working tree is clean
3. switches to `main`
4. pulls `origin/main` using `--ff-only`
5. prints status and recent log
6. creates the task branch

Expected branch from task/slug form:

```text
manual/T008-complete-documentation-iteration
```

## Safety notes

- Default mode is dry-run.
- Real execution requires `--run` or `-r`.
- In run mode, the function refuses to continue if the working tree is dirty.
- In run mode, the function refuses to create a branch that already exists locally or on `origin`.
- Do not leave generated ZIP files in the repository root before starting the branch.

## Related functions

- `agw_status`
- `agw_inspect_git_state`
- `agw_review_output`
- `agw_start_codex_task` legacy compatibility only
