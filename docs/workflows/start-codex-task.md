# Workflow: Start Codex Task Branch

## Purpose

Start a Codex-style task branch from a clean and updated `main` branch.

This workflow is retained for legacy compatibility only.

New generic/manual/ChatGPT ZIP work should use:

```bash
agw_start_task
```

## When to use

- Only when maintaining an existing workflow that still uses `agw_start_codex_task`.
- Only when the branch prefix must remain `codex-cli/` for compatibility.

For new work, prefer `docs/workflows/start-task.md`.

## Preconditions

- The current directory is inside the target Git repository.
- The repository has a remote named `origin`.
- `main` is the intended integration branch.
- The working tree is clean.
- The target branch name is known.

## Syntax

```bash
agw_start_codex_task --branch codex-cli/<task-name> [--run|-r]
```

## Parameters

- `--branch NAME`: Required branch name. Required prefix: `codex-cli/`.
- `--run`: Execute commands.
- `-r`: Short form for `--run`.
- `--help`: Show function help.

## Dry-run example

```bash
agw_start_codex_task --branch codex-cli/T001-existing-workflow
```

## `--run` example

```bash
agw_start_codex_task --branch codex-cli/T001-existing-workflow --run
```

## `-r` example

```bash
agw_start_codex_task --branch codex-cli/T001-existing-workflow -r
```

## Expected output / behavior

In dry-run mode, the function prints the Git commands that would run.

In run mode, it starts from updated `main` and creates the requested `codex-cli/` branch.

## Safety notes

- Default mode is dry-run.
- Real execution requires `--run` or `-r`.
- In run mode, the working tree must be clean.
- This function exists only for compatibility. Prefer `agw_start_task` for new tasks.

## Related functions

- `agw_start_task`
- `agw_review_codex_output`
- `agw_review_output`
