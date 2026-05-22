# Workflow: Review Codex Output

## Purpose

Review Codex or Codex CLI output before staging and committing changes.

This workflow is retained for legacy compatibility only.

New generic/manual/ChatGPT ZIP workflows should use:

```bash
agw_review_output
```

## When to use

- Only when maintaining an existing Codex-specific workflow.
- Only when an existing script or document still calls `agw_review_codex_output`.

For manual edits, ChatGPT-guided edits, generated ZIP extraction, or general AI-assisted work, prefer `docs/workflows/review-output.md`.

## Preconditions

- The task objective is known.
- The expected scope is known.
- The repository contains changes to review.

## Syntax

```bash
agw_review_codex_output [--run|-r]
```

## Parameters

- `--run`: Execute review commands.
- `-r`: Short form for `--run`.
- `--help`: Show function help.

## Dry-run example

```bash
agw_review_codex_output
```

## `--run` example

```bash
agw_review_codex_output --run
```

## `-r` example

```bash
agw_review_codex_output -r
```

## Expected output / behavior

This function delegates to the generic review behavior used by `agw_review_output`.

## Safety notes

- This function exists only for compatibility.
- Prefer `agw_review_output` for new workflows.
- Do not commit generated changes until file scope and validation status are understood.

## Related functions

- `agw_review_output`
- `agw_start_codex_task`
