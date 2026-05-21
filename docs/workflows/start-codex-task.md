# Workflow: Start Codex Task Branch

## Purpose

Start a new task branch from a clean and updated `main` branch.

## When to use

- Before starting a Codex or ChatGPT-guided implementation task.
- Before starting a meaningful manual task that should not be done directly on `main`.
- When a task needs a clear branch name for review, PR, and audit.

## Preconditions

- The repository has a remote named `origin`.
- `main` is the intended integration branch.
- There are no local changes that should be preserved before switching branches.
- The target branch name is known.

## Commands

<!-- AUTO-GENERATED:START workflow=start-codex-task -->
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

```bash
agw_start_codex_task --branch codex-cli/<task-name> [--run|-r]
```

## Parameters

- `--branch NAME`: Required. Branch name to create. Recommended prefix: `codex-cli/`.
- `--run`, `-r`: Execute commands. Without this flag, commands are printed only.
- `--help`: Show function help.

## Risks

- Starting from a stale `main` may create unnecessary conflicts later.
- Creating a branch while local changes exist can mix unrelated work into the task.
- Using an unclear branch name makes later audit and cleanup harder.

## Definition of done

- The current branch is the new task branch.
- The branch starts from updated `main`.
- The working tree state is understood.
- The task can proceed without changing `main` directly.
