# Adding ai-git-workflow-tools to an Existing Project

This document describes two supported ways to include `ai-git-workflow-tools` in an existing Git project.

The tool provides reusable Bash functions for Git/GitHub workflows, including:

- inspecting Git state
- starting task branches
- reviewing output
- committing controlled changes
- pushing and creating PRs
- syncing after merge
- cleaning branches
- creating release tags

## Important behavior

The tool always operates on the Git repository of the current working directory.

That means:

```bash
cd /path/to/my-project
source tools/ai-git-workflow-tools/scripts/load-agw.sh
agw_inspect_git_state
```

The command inspects `/path/to/my-project`, not the `ai-git-workflow-tools` repository.

Most functions default to dry-run mode.  
Use `--run` or `-r` only after reviewing the printed commands.

---

# Option 1: Add as a Git submodule

This is the recommended option when you want a traceable link to the original tool repository and a clean upgrade path.

## Add the submodule

From the root of the target project:

```bash
git submodule add https://github.com/sagivba/ai-git-workflow-tools.git tools/ai-git-workflow-tools
git submodule update --init --recursive
```

## Pin to a stable version

```bash
cd tools/ai-git-workflow-tools
git checkout v0.5.0
cd ../..
```

## Load the tool

From the root of the target project:

```bash
source tools/ai-git-workflow-tools/scripts/load-agw.sh
```

## Verify

```bash
agw_help
type agw_start_task
type agw_review_output
agw_inspect_git_state
```

## Commit the submodule reference

```bash
git status --short | cat

git add .gitmodules tools/ai-git-workflow-tools
git commit -m "Add ai-git-workflow-tools submodule"
```

## Daily usage

From the target project root:

```bash
source tools/ai-git-workflow-tools/scripts/load-agw.sh

agw_inspect_git_state
agw_start_task --task T001 --slug first-task
```

When the dry-run output looks correct:

```bash
agw_start_task --task T001 --slug first-task --run
```

## Updating the submodule later

```bash
cd tools/ai-git-workflow-tools
git fetch --tags origin
git checkout v0.5.0
cd ../..

git status --short | cat
git add tools/ai-git-workflow-tools
git commit -m "Update ai-git-workflow-tools version"
```

Replace `v0.5.0` with the newer tag when available.

## Pros

- Clean version tracking.
- Easy to see which tool version the project uses.
- Easier upgrades.
- Does not copy tool implementation into the main project history.

## Cons

- Requires developers to understand and initialize submodules.
- Clone users need:

```bash
git submodule update --init --recursive
```

---

# Option 2: Copy the tool files into the project

This is the simplest option when you want the tool physically inside the project and do not need automatic upgrade tracking.

## Copy the scripts

From the root of the target project:

```bash
mkdir -p tools/ai-git-workflow-tools/scripts

cp ~/src/ai-git-workflow-tools/scripts/ai-git-workflows.sh    tools/ai-git-workflow-tools/scripts/

cp ~/src/ai-git-workflow-tools/scripts/load-agw.sh    tools/ai-git-workflow-tools/scripts/
```

## Load the tool

```bash
source tools/ai-git-workflow-tools/scripts/load-agw.sh
```

## Verify

```bash
agw_help
type agw_start_task
type agw_review_output
agw_inspect_git_state
```

## Commit the copied files

```bash
git status --short | cat

git add tools/ai-git-workflow-tools/scripts/ai-git-workflows.sh         tools/ai-git-workflow-tools/scripts/load-agw.sh

git commit -m "Add local AI Git workflow tools"
```

## Daily usage

From the target project root:

```bash
source tools/ai-git-workflow-tools/scripts/load-agw.sh

agw_inspect_git_state
agw_start_task --task T001 --slug first-task
```

When the dry-run output looks correct:

```bash
agw_start_task --task T001 --slug first-task --run
```

## Updating copied files later

From the target project root:

```bash
cp ~/src/ai-git-workflow-tools/scripts/ai-git-workflows.sh    tools/ai-git-workflow-tools/scripts/

cp ~/src/ai-git-workflow-tools/scripts/load-agw.sh    tools/ai-git-workflow-tools/scripts/

git status --short | cat
git diff --stat | cat

git add tools/ai-git-workflow-tools/scripts/ai-git-workflows.sh         tools/ai-git-workflow-tools/scripts/load-agw.sh

git commit -m "Update local AI Git workflow tools"
```

## Pros

- Very simple.
- No submodule knowledge required.
- The target project is self-contained.

## Cons

- No automatic link to the source repository version.
- Updates are manual.
- Harder to know which original tag/version the copied files came from unless documented.

Recommended mitigation: add a small note near the copied files or in project docs:

```text
ai-git-workflow-tools copied from v0.5.0
Source: https://github.com/sagivba/ai-git-workflow-tools
```

---

# Recommended choice

For short-term personal use:

```text
Option 2: copy the tool files
```

For longer-term project usage or team usage:

```text
Option 1: Git submodule
```

If the goal is to move quickly and test the workflow in a real project, start with copied files.  
If the tool becomes part of the standard project workflow, migrate to a submodule later.

---

# Safety checklist before first real use

After loading the tool in the target project:

```bash
agw_inspect_git_state
```

Before creating a branch:

```bash
git status --short | cat
```

Expected output should be empty.

Start with dry-run:

```bash
agw_start_task --task T001 --slug first-task
```

Only then run:

```bash
agw_start_task --task T001 --slug first-task --run
```

Do not use `--run` unless the printed command sequence matches the intended operation.
