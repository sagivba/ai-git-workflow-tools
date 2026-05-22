# Workflow: Review Output

## Purpose

Review manual, ChatGPT-guided, generated ZIP, or other AI-assisted output before staging and committing changes.

## When to use

- After extracting a task ZIP into the working tree.
- After manual edits.
- After an AI assistant changes files.
- Before staging files for commit.
- Before accepting a generated implementation or documentation change.

## Preconditions

- The task objective is known.
- The expected scope is known.
- The repository contains changes to review.
- The current branch is the intended task branch.

## Syntax

```bash
agw_review_output [--run|-r]
```

## Parameters

- `--run`: Execute review commands.
- `-r`: Short form for `--run`.
- `--help`: Show function help.

## Dry-run example

```bash
agw_review_output
```

## `--run` example

```bash
agw_review_output --run
```

## `-r` example

```bash
agw_review_output -r
```

## Expected output / behavior

In dry-run mode, the function prints the review commands.

In run mode, it executes:

```bash
git branch --show-current
git status --short
git diff --stat
git diff --name-status
git diff --check
```

Use the output to decide whether the ZIP or edits match the intended task scope.

## Safety notes

- Generated ZIP files can contain unexpected files.
- AI output may include unrelated cleanup or refactoring.
- Validation may be claimed but not actually run.
- Do not commit until changed files and validation status are understood.

## Related functions

- `agw_inspect_git_state`
- `agw_commit_controlled_change`
- `agw_review_codex_output` legacy compatibility only
