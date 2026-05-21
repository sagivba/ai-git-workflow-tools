# Workflow: Show Workflow Status

## Purpose

Show both the loaded tool information and the current Git repository state.

This is a quick sanity check before using workflow commands inside a project.

## When to use

- After sourcing the tool in a project.
- Before starting a task branch.
- Before asking for help with tool behavior.
- When confirming the tool is operating on the intended repository.

## Function usage

```bash
agw_status
```

## Output

The command prints:

- `agw_version` output
- current repository root
- current branch
- current short commit hash
- `git status --short`

## Safety

This command is read-only.

It does not change Git state and does not require `--run`.
