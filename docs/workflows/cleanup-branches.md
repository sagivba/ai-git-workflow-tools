# Workflow: Cleanup Branches

## Purpose

Identify and remove branches that are already merged, while preserving unmerged work.

## When to use

- After PR merge and local `main` sync.
- During repository maintenance.
- Before starting a new batch of tasks.

## Preconditions

- Local `main` is synced with `origin/main`.
- The user understands which branch or branches are safe to delete.
- No unmerged branch should be deleted unless explicitly intended.

## Commands

<!-- AUTO-GENERATED:START workflow=cleanup-branches -->
The generated command/help block for this workflow should be inserted here by `tools/generate_docs.py`.
<!-- AUTO-GENERATED:END -->

### Command sequence

```bash
git branch --merged main | cat
```
List local branches merged into `main`.

```bash
git branch --no-merged main | cat
```
List local branches not merged into `main`.

```bash
git branch -r --merged origin/main | cat
```
List remote branches merged into `origin/main`.

```bash
git branch -r --no-merged origin/main | cat
```
List remote branches not merged into `origin/main`.

```bash
git branch --delete <branch>
```
Delete a safe local merged branch.

```bash
git push origin --delete <branch>
```
Delete a safe remote merged branch.

## Function usage

```bash
Planned function: agw_cleanup_branches --branch <branch> [--remote] [--run|-r]
```

## Parameters

- `--branch NAME`: Branch to delete.
- `--remote`: Also delete remote branch from `origin`.
- `--run`, `-r`: Execute commands. Without this flag, commands are printed only.
- `--help`: Show function help.

## Risks

- Deleting an unmerged branch can lose work.
- Local and remote merge status can differ.
- Remote deletion should not be performed from memory.

## Definition of done

- Merged and unmerged branches were reviewed.
- Only confirmed safe branches were deleted.
- Branch lists are rechecked after cleanup.
