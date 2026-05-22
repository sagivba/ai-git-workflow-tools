# Workflow: Inspect Git State

## Purpose

Create a compact snapshot of the current Git repository state before making decisions.

## When to use

- Before commit.
- Before PR creation.
- Before merge or cleanup.
- Before creating a tag.
- After manual edits or generated ZIP extraction.
- After an AI assistant changes files.

## Preconditions

- The current directory is inside a Git repository.

## Syntax

```bash
agw_inspect_git_state [--run|-r]
```

## Parameters

- `--run`: Execute the inspection commands.
- `-r`: Short form for `--run`.
- `--help`: Show function help.

## Dry-run example

```bash
agw_inspect_git_state
```

## `--run` example

```bash
agw_inspect_git_state --run
```

## `-r` example

```bash
agw_inspect_git_state -r
```

## Expected output / behavior

In dry-run mode, the function prints these inspection commands:

```bash
git branch --show-current
git status --short
git log --oneline --decorate -5
git diff --stat
git diff --name-only
```

In run mode, it executes them and prints the current branch, short status, recent commits, diff stat, and changed file list.

## Safety notes

- This workflow is inspection-oriented, but the function still follows the global dry-run convention.
- It does not intentionally change repository state.
- Review deleted and untracked files carefully before committing.

## Related functions

- `agw_status`
- `agw_review_output`
- `agw_commit_controlled_change`
