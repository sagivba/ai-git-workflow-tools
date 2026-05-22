# Workflow: Cleanup Branches

## Purpose

Inspect merged and unmerged branches and optionally delete a confirmed safe local or remote branch.

## When to use

- After PR merge and local `main` sync.
- During repository maintenance.
- Before starting a new batch of tasks.

## Preconditions

- Local `main` is synced with `origin/main`.
- The user understands which branch is safe to delete.
- No unmerged branch should be deleted unless that is intentional and handled outside this helper.

## Syntax

```bash
agw_cleanup_branches [--branch name] [--remote] [--run|-r]
```

## Parameters

- `--branch NAME`: Branch to delete.
- `--remote`: Delete the remote branch on `origin` instead of the local branch.
- `--run`: Execute commands.
- `-r`: Short form for `--run`.
- `--help`: Show function help.

## Dry-run example

```bash
agw_cleanup_branches --branch manual/T008-complete-documentation-iteration
```

## `--run` example

```bash
agw_cleanup_branches --branch manual/T008-complete-documentation-iteration --run
```

Remote deletion with `--run`:

```bash
agw_cleanup_branches --branch manual/T008-complete-documentation-iteration --remote --run
```

## `-r` example

```bash
agw_cleanup_branches --branch manual/T008-complete-documentation-iteration -r
```

Remote deletion with `-r`:

```bash
agw_cleanup_branches --branch manual/T008-complete-documentation-iteration --remote -r
```

## Expected output / behavior

In dry-run mode, the function prints branch inspection commands and the deletion command that would run.

In run mode, it:

1. fetches latest refs
2. prints merged and unmerged local branches
3. prints merged and unmerged remote branches
4. refuses to delete protected branches
5. refuses to delete a local branch not merged into `main`
6. refuses to delete a remote branch not merged into `origin/main`
7. deletes the requested branch only after safety checks pass

## Safety notes

- Default mode is dry-run.
- Real execution requires `--run` or `-r`.
- The function refuses to delete `main` or `master`.
- Local deletion requires merge into `main`.
- Remote deletion requires merge into `origin/main`.

## Related functions

- `agw_post_merge_sync`
- `agw_start_task`
