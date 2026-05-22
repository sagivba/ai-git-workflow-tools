# ai-git-workflow-tools

Reusable Git, GitHub, ChatGPT ZIP, and AI-assisted workflow tools.

This repository provides a personal but reusable command layer for recurring development workflows around Git, GitHub, task branches, generated ZIP files, reviews, commits, pull requests, merges, cleanup, and release tags.

The tool is intentionally small: it is a Bash script with documented functions, Markdown workflow documentation, tests, and a documentation metadata checker.

## What this tool does

`ai-git-workflow-tools` helps standardize a safe task workflow:

```text
clean main
  -> start task branch
  -> apply changes, often from a ChatGPT-generated ZIP
  -> inspect and review output
  -> run tests
  -> commit explicit files
  -> push branch and open PR
  -> merge through GitHub
  -> sync local main
  -> clean up branches
  -> review docs/metadata
  -> create release tag
```

The functions are designed to reduce mistakes such as working directly on `main`, committing unrelated files, deleting unmerged branches, or creating duplicate tags.

## Safe execution model

Most workflow functions default to dry-run mode.

Dry-run mode prints the commands that would run, but does not change repository state.

Real execution requires one of:

```bash
--run
```

or the short form:

```bash
-r
```

Read-only functions do not require `--run`:

```bash
agw_help
agw_version
agw_status
agw_pre_tag_docs_review
```

## Load inside this repository

From the root of this repository:

```bash
source scripts/ai-git-workflows.sh
agw_help
agw_version
agw_status
```

Start a task branch with dry-run first:

```bash
agw_start_task --task T008 --slug complete-documentation-iteration
```

Execute it after reviewing the printed commands:

```bash
agw_start_task --task T008 --slug complete-documentation-iteration --run
```

Short execution form:

```bash
agw_start_task --task T008 --slug complete-documentation-iteration -r
```

## Load from another repository

A common setup is one central clone of this repository and sourcing its loader from any other Git repository.

```bash
mkdir -p ~/src
git clone https://github.com/sagivba/ai-git-workflow-tools.git ~/src/ai-git-workflow-tools
```

From another project:

```bash
cd ~/src/some-existing-project
source ~/src/ai-git-workflow-tools/scripts/load-agw.sh
agw_version
agw_status
```

`agw_version` shows where the tool was loaded from. `agw_status` shows the current project repository, branch, commit, and short Git status.

## Use when copied into another project

The tool can also be copied into another project under:

```text
tools/ai-git-workflow-tools/scripts/
```

From that project root:

```bash
source tools/ai-git-workflow-tools/scripts/load-agw.sh
agw_version
agw_status
```

If `load-agw.sh` is not copied, source the main script directly:

```bash
source tools/ai-git-workflow-tools/scripts/ai-git-workflows.sh
agw_version
agw_status
```

## Use as a submodule

The same path can be used for a Git submodule:

```bash
git submodule add https://github.com/sagivba/ai-git-workflow-tools.git tools/ai-git-workflow-tools
git submodule update --init --recursive
source tools/ai-git-workflow-tools/scripts/load-agw.sh
agw_status
```

## Working with a ChatGPT-generated ZIP

In this project workflow, ChatGPT generates a ZIP for each task. You place the ZIP in the repository root, but the working tree must be clean before opening a branch.

Move ZIP files out before starting the branch:

```bash
mkdir -p /tmp/agw-zips
if ls *.zip >/dev/null 2>&1; then
  mv ./*.zip /tmp/agw-zips/
fi
git status --short | cat
```

Start the task branch:

```bash
agw_start_task --task T008 --slug complete-documentation-iteration --run
```

Extract the ZIP into the task branch:

```bash
unzip -o /tmp/agw-zips/T008-complete-documentation-iteration.zip -d .
```

Review and validate:

```bash
agw_review_output --run
make test
make check-docs
git diff --check | cat
```

## Recommended task cycle

```bash
source scripts/ai-git-workflows.sh

agw_status

agw_start_task --task T008 --slug complete-documentation-iteration
agw_start_task --task T008 --slug complete-documentation-iteration --run

unzip -o /tmp/agw-zips/T008-complete-documentation-iteration.zip -d .

agw_review_output
agw_review_output --run

make test
make check-docs

git diff --stat | cat
git diff --name-status | cat
git diff --check | cat

agw_commit_controlled_change \
  --message "Complete documentation iteration" \
  --files "README.md docs/install.md docs/use-from-existing-project.md docs/integration/use-in-existing-project.md docs/workflows/README.md docs/workflows/version.md docs/workflows/status.md docs/workflows/start-task.md docs/workflows/start-codex-task.md docs/workflows/inspect-git-state.md docs/workflows/review-output.md docs/workflows/review-codex-output.md docs/workflows/commit-controlled-change.md docs/workflows/push-and-pr.md docs/workflows/post-merge-sync.md docs/workflows/cleanup-branches.md docs/workflows/pre-tag-docs-review.md docs/workflows/create-and-verify-tag.md scripts/ai-git-workflows.sh" \
  --run
```

## Documentation map

Installation:

```text
docs/install.md
```

Use from another project:

```text
docs/use-from-existing-project.md
```

Integration options for copied tools and submodules:

```text
docs/integration/use-in-existing-project.md
```

Workflow index:

```text
docs/workflows/README.md
```

Individual workflow documents are under:

```text
docs/workflows/*.md
```

## Main functions

```bash
agw_help
agw_version
agw_status
agw_inspect_git_state
agw_start_task
agw_review_output
agw_commit_controlled_change
agw_push_and_pr
agw_post_merge_sync
agw_cleanup_branches
agw_pre_tag_docs_review
agw_create_tag
```

Legacy compatibility functions remain available:

```bash
agw_start_codex_task
agw_review_codex_output
```

Prefer the generic names for new work:

```bash
agw_start_task
agw_review_output
```

## Test

```bash
make test
```

## Check documentation metadata

```bash
make check-docs
```

## Generate documentation metadata report

```bash
make docs
```

Current `tools/generate_docs.py` checks metadata and referenced documentation files. It does not yet rewrite generated Markdown blocks.
