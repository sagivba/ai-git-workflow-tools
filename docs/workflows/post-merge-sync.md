# Workflow: Post-Merge Sync

## Purpose

Synchronize local `main` after a PR has been merged through GitHub.

## When to use

- After merging a PR in GitHub Web.
- Before starting a new task after a merge.
- Before creating a release tag.

## Preconditions

- The PR has been merged.
- `main` is the integration branch.
- There are no local changes that should block switching branches.

## Commands

<!-- AUTO-GENERATED:START workflow=post-merge-sync -->
The generated command/help block for this workflow should be inserted here by `tools/generate_docs.py`.
<!-- AUTO-GENERATED:END -->

### Command sequence

```bash
git switch main
```
Switch to the integration branch.

```bash
git pull --ff-only origin main
```
Synchronize local `main` with `origin/main` without creating a merge commit.

```bash
git status --short | cat
```
Verify local state is clean.

```bash
git log --oneline --decorate -5 | cat
```
Verify the latest commits and refs.

## Function usage

```bash
Planned function: agw_post_merge_sync [--run|-r]
```

## Parameters

- `--run`, `-r`: Execute commands. Without this flag, commands are printed only.
- `--help`: Show function help.

## Risks

- Starting a new task before syncing `main` can base work on stale code.
- Using plain `git pull` can create an unintended merge commit.
- Uncommitted local changes can block or complicate branch switching.

## Definition of done

- Local `main` is current with `origin/main`.
- The working tree is clean.
- The latest merge is visible in the local log.
