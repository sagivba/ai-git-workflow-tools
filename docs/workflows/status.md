# Workflow: Show Workflow Status

## Purpose

Show both loaded tool information and the current Git repository state.

This is the main sanity check before using workflow commands inside a project.

## When to use

- After sourcing the tool in a project.
- Before starting a task branch.
- Before applying a generated ZIP.
- Before asking for help with tool behavior.
- When confirming the tool is operating on the intended repository.

## Preconditions

- The current directory must be inside a Git repository.

## Syntax

```bash
agw_status
```

## Parameters

- `--help`: Show function help.

No `--run` flag is needed. This function is read-only.

## Dry-run example

Not applicable. The function is already read-only and executes directly.

## Expected output / behavior

The command prints:

- `agw_version` output
- current repository root
- current branch
- current short commit hash
- `git status --short`

## Safety notes

- Does not change Git state.
- Does not require `--run` or `-r`.
- Use `current_repository` to confirm whether commands will operate on the tool repository or a host project repository.

## Related functions

- `agw_version`
- `agw_inspect_git_state`
- `agw_start_task`
