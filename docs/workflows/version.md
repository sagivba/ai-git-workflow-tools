# Workflow: Show Tool Version

## Purpose

Show which `ai-git-workflow-tools` version is loaded and where it was loaded from.

This is useful when the tool is copied into another project or loaded from a central clone.

## When to use

- After sourcing `scripts/load-agw.sh`.
- Before debugging behavior differences between projects.
- Before reporting an issue or sharing workflow output.
- After upgrading or copying tool files.

## Function usage

```bash
agw_version
```

## Output

The command prints:

```text
ai-git-workflow-tools
version: <tool-version>
script: <loaded script path>
tool_root: <tool root path>
tool_git_ref: <git tag/commit when available>
```

## Notes

`tool_git_ref` is available when the tool files are inside a Git repository.

If the tool was copied into a project without its `.git` metadata, the Git ref may be unavailable. In that case, use the version field and project documentation to track the copied version.
