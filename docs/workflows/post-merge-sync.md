# Workflow: Post-Merge Sync

## Purpose

Synchronize local `main` after a PR has been merged through GitHub.

## When to use

- After merging a PR in GitHub Web.
- Before starting a new task after a merge.
- Before creating a release tag.
- Before branch cleanup.

## Preconditions

- The PR has been merged.
- `main` is the integration branch.
- No local changes should block switching branches.

## Syntax

```bash
agw_post_merge_sync [--run|-r]
```

## Parameters

- `--run`: Execute commands.
- `-r`: Short form for `--run`.
- `--help`: Show function help.

## Dry-run example

```bash
agw_post_merge_sync
```

## `--run` example

```bash
agw_post_merge_sync --run
```

## `-r` example

```bash
agw_post_merge_sync -r
```

## Expected output / behavior

In dry-run mode, the function prints the commands that would run.

In run mode, it:

1. fetches latest refs from `origin`
2. verifies the working tree is clean before switching
3. switches to `main`
4. pulls `origin/main` with `--ff-only`
5. prints short status and recent log

## Safety notes

- Default mode is dry-run.
- Real execution requires `--run` or `-r`.
- In run mode, the working tree must be clean before switching to `main`.
- Use before tagging or cleanup.

## Related functions

- `agw_push_and_pr`
- `agw_cleanup_branches`
- `agw_create_tag`
