# Workflow: Commit Controlled Change

## Purpose

Stage explicit files and create a clear commit after reviewing the staged diff.

## When to use

- After Git state inspection.
- After reviewing generated ZIP or manual output.
- After deciding that a specific file set is ready to become a commit.

## Preconditions

- The current branch is not `main`.
- The changed files have been reviewed.
- The commit scope is clear.
- The commit message is known.
- Validation status is known.

## Syntax

```bash
agw_commit_controlled_change --message "Commit message" --files "file1 file2" [--run|-r]
```

## Parameters

- `--message TEXT`: Required commit message.
- `--files TEXT`: Required space-separated list of files to stage.
- `--run`: Execute commands.
- `-r`: Short form for `--run`.
- `--help`: Show function help.

## Dry-run example

```bash
agw_commit_controlled_change \
  --message "Complete documentation iteration" \
  --files "README.md docs/install.md"
```

## `--run` example

```bash
agw_commit_controlled_change \
  --message "Complete documentation iteration" \
  --files "README.md docs/install.md" \
  --run
```

## `-r` example

```bash
agw_commit_controlled_change \
  --message "Complete documentation iteration" \
  --files "README.md docs/install.md" \
  -r
```

## Expected output / behavior

In dry-run mode, the function prints the commands that would stage files, inspect the cached diff, and commit.

In run mode, it:

1. refuses to commit directly on `main`
2. stages the explicit files
3. prints cached diff stat
4. runs cached diff whitespace checks
5. creates the commit

## Safety notes

- Default mode is dry-run.
- Real execution requires `--run` or `-r`.
- The function refuses to commit on `main` in run mode.
- Prefer explicit file lists over `git add .`.
- The `--files` value is space-separated; avoid file names with spaces.

## Related functions

- `agw_review_output`
- `agw_push_and_pr`
- `agw_inspect_git_state`
