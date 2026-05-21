# Workflow: Inspect Git State

## Purpose

Create a compact snapshot of the current Git repository state before making decisions.

## When to use

- Before commit.
- Before PR creation.
- Before merge or cleanup.
- Before creating a tag.
- After manual edits or AI-generated changes.

## Preconditions

- The current directory is inside a Git repository.

## Commands

<!-- AUTO-GENERATED:START workflow=inspect-git-state -->
The generated command/help block for this workflow should be inserted here by `tools/generate_docs.py`.
<!-- AUTO-GENERATED:END -->

### Command sequence

```bash
git branch --show-current | cat
```
Show the current branch name.

```bash
git status --short | cat
```
Show modified, deleted, staged, and untracked files in compact form.

```bash
git log --oneline --decorate -5 | cat
```
Show recent commits and refs.

```bash
git diff --stat | cat
```
Show a high-level summary of unstaged changes.

```bash
git diff --name-only | cat
```
Show the list of changed files.

## Function usage

```bash
agw_inspect_git_state [--run|-r]
```

## Parameters

- `--run`, `-r`: Execute commands. Without this flag, commands are printed only.
- `--help`: Show function help.

## Risks

- Skipping inspection can lead to committing unrelated files.
- Deleted files can be missed if `status` is not reviewed.
- AI tools may change files outside the expected scope.

## Definition of done

- The current branch is known.
- The changed file list is known.
- Unexpected files are identified before further action.
- The user can decide whether to continue, fix, split, stash, or restore.
