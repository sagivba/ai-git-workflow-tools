# Integration: Use in an existing project

## Purpose

Document supported ways to use `ai-git-workflow-tools` inside or alongside another Git repository.

This document is for projects that want repeatable Git/GitHub/ZIP workflow commands without making `ai-git-workflow-tools` the main repository.

## Integration modes

Supported modes:

1. Central clone outside the project.
2. Copied tool files inside the project.
3. Git submodule inside the project.

## Mode 1: central clone

Recommended for personal use across multiple repositories.

```bash
mkdir -p ~/src
git clone https://github.com/sagivba/ai-git-workflow-tools.git ~/src/ai-git-workflow-tools
cd /path/to/host-project
source ~/src/ai-git-workflow-tools/scripts/load-agw.sh
agw_version
agw_status
```

Advantages:

- One tool installation.
- Easy upgrade.
- No tool files committed to every host repository.

Tradeoff:

- The host project depends on a local path outside the repository.

## Mode 2: copied tool files

Recommended when the host project should carry the tool version it uses.

Expected layout:

```text
host-project/
  tools/
    ai-git-workflow-tools/
      scripts/
        ai-git-workflows.sh
        load-agw.sh
```

Load from the host project root:

```bash
source tools/ai-git-workflow-tools/scripts/load-agw.sh
agw_version
agw_status
```

If `load-agw.sh` is unavailable:

```bash
source tools/ai-git-workflow-tools/scripts/ai-git-workflows.sh
agw_version
agw_status
```

Expected behavior:

- `tool_root` points to `tools/ai-git-workflow-tools`.
- `current_repository` points to the host project root.

## Mode 3: Git submodule

Recommended when the host project wants explicit tool version control without copying files manually.

```bash
git submodule add https://github.com/sagivba/ai-git-workflow-tools.git tools/ai-git-workflow-tools
git submodule update --init --recursive
source tools/ai-git-workflow-tools/scripts/load-agw.sh
agw_version
agw_status
```

Pin or update the submodule using normal Git submodule workflows.

## Sanity checks after loading

Always run:

```bash
agw_version
agw_status
```

Check that:

- `script` points to the intended tool path.
- `tool_root` points to the intended tool copy/clone/submodule.
- `current_repository` points to the host project.
- `current_branch` is the expected branch.
- `current_status` does not contain unexpected files.

## ZIP workflow in an integrated project

When a generated ZIP is placed in the host project root, move it outside the repository before creating the task branch:

```bash
mkdir -p /tmp/agw-zips
if ls *.zip >/dev/null 2>&1; then
  mv ./*.zip /tmp/agw-zips/
fi
git status --short | cat
```

Then start the task branch:

```bash
agw_start_task --task T008 --slug complete-documentation-iteration --run
```

Apply the ZIP after branch creation:

```bash
unzip -o /tmp/agw-zips/T008-complete-documentation-iteration.zip -d .
```

## Safety notes

- The functions operate on the current Git repository, not necessarily on the tool repository.
- `agw_status` is the primary check for confirming the current repository.
- Do not start a task while generated ZIP files are still untracked in the repository root.
- Prefer task branches under `manual/<task>-<slug>` for ChatGPT ZIP work.

## Related functions

- `agw_version`
- `agw_status`
- `agw_start_task`
- `agw_review_output`
