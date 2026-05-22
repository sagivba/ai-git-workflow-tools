# Workflow: Show Tool Version

## Purpose

Show which `ai-git-workflow-tools` version is loaded and where it was loaded from.

This is useful when the tool is loaded from a central clone, copied into another project, or used as a submodule.

## When to use

- After sourcing `scripts/load-agw.sh` or `scripts/ai-git-workflows.sh`.
- Before debugging behavior differences between projects.
- Before asking another person or AI assistant to reason about the current setup.
- After upgrading, copying, or pinning tool files.

## Preconditions

None. This command does not require the current directory to be inside a Git repository.

## Syntax

```bash
agw_version
```

## Parameters

- `--help`: Show function help.

No `--run` flag is needed. This function is read-only.

## Dry-run example

Not applicable. The function is already read-only and executes directly.

## Expected output / behavior

The command prints:

```text
ai-git-workflow-tools
version: <tool-version>
script: <loaded script path>
tool_root: <tool root path>
tool_git_ref: <git tag/commit when available>
```

`tool_git_ref` is available when the tool files are inside a Git repository. If the tool was copied without `.git` metadata, the Git ref may be unavailable.

## Safety notes

- Does not change Git state.
- Does not require `--run` or `-r`.
- Use this command before `agw_status` when debugging loaded tool path issues.

## Related functions

- `agw_status`
- `agw_help`
