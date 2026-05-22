# Workflow: Push and Prepare PR

## Purpose

Push the current task branch and optionally create a Pull Request through GitHub CLI.

## When to use

- After a controlled commit is created.
- When the task branch is ready for review.
- When a PR should be opened or prepared.

## Preconditions

- The current branch is not `main`.
- The branch has at least one commit to push.
- The working tree is clean or any remaining changes are intentional.
- The PR title and scope are known.
- If creating the PR through CLI, `gh` is installed and authenticated.

## Syntax

```bash
agw_push_and_pr [--title "PR title"] [--body-file path] [--run|-r]
```

## Parameters

- `--title TEXT`: Optional PR title.
- `--body-file PATH`: Optional PR body file. If provided with `--title`, `gh pr create` is used.
- `--run`: Execute commands.
- `-r`: Short form for `--run`.
- `--help`: Show function help.

## Dry-run example

```bash
agw_push_and_pr --title "T008 Complete documentation iteration" --body-file /tmp/T008-pr-body.md
```

## `--run` example

```bash
agw_push_and_pr --title "T008 Complete documentation iteration" --body-file /tmp/T008-pr-body.md --run
```

## `-r` example

```bash
agw_push_and_pr --title "T008 Complete documentation iteration" --body-file /tmp/T008-pr-body.md -r
```

## Expected output / behavior

In dry-run mode, the function prints the branch/status/push commands and PR command when title and body file are supplied.

In run mode, it:

1. refuses to push directly from `main`
2. checks the PR body file when provided
3. checks for `gh` when PR creation is requested
4. pushes the current branch with upstream tracking
5. creates a PR if both `--title` and `--body-file` are provided

If PR creation arguments are not both provided, it pushes the branch and prints guidance to create the PR through GitHub Web.

## Safety notes

- Default mode is dry-run.
- Real execution requires `--run` or `-r`.
- The function refuses to push from `main` in run mode.
- Review the PR body before running with `--run`.

## Related functions

- `agw_commit_controlled_change`
- `agw_post_merge_sync`
