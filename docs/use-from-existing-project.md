# Use from an existing project

## Purpose

Use `ai-git-workflow-tools` from another Git repository without working directly in the tools repository.

The recommended model is:

```text
one central clone of ai-git-workflow-tools
  -> source scripts/load-agw.sh from a project
  -> run agw_* functions inside that current project
```

## Preconditions

- The current directory is a Git repository.
- The project has `origin` configured.
- The integration branch is `main`.
- `ai-git-workflow-tools` is available through a central clone, copied tool path, or submodule.

## Load inside a project

```bash
cd ~/src/some-existing-project
source ~/src/ai-git-workflow-tools/scripts/load-agw.sh
agw_version
agw_status
```

Use `agw_status` before any important operation to confirm the tool is operating on the intended project.

## Working with a ZIP in the repository root

A ChatGPT-generated task ZIP may be placed in the project root by the user. Before opening a task branch, move it out of the repository so that the working tree is clean.

```bash
mkdir -p /tmp/agw-zips
if ls *.zip >/dev/null 2>&1; then
  mv ./*.zip /tmp/agw-zips/
fi
git status --short | cat
```

The branch should be created only after `git status --short` is clean.

## Start a task branch

Dry-run:

```bash
agw_start_task --task T008 --slug complete-documentation-iteration
```

Full execution:

```bash
agw_start_task --task T008 --slug complete-documentation-iteration --run
```

Short execution:

```bash
agw_start_task --task T008 --slug complete-documentation-iteration -r
```

Expected branch:

```text
manual/T008-complete-documentation-iteration
```

## Apply the ZIP

```bash
unzip -o /tmp/agw-zips/T008-complete-documentation-iteration.zip -d .
```

## Review changes

Dry-run:

```bash
agw_review_output
```

Full execution:

```bash
agw_review_output --run
```

Short execution:

```bash
agw_review_output -r
```

## Validate

Use the host project validation commands. For this repository:

```bash
make test
make check-docs
git diff --check | cat
```

## Commit controlled changes

Dry-run:

```bash
agw_commit_controlled_change \
  --message "Complete documentation iteration" \
  --files "README.md docs/install.md"
```

Full execution:

```bash
agw_commit_controlled_change \
  --message "Complete documentation iteration" \
  --files "README.md docs/install.md" \
  --run
```

Short execution:

```bash
agw_commit_controlled_change \
  --message "Complete documentation iteration" \
  --files "README.md docs/install.md" \
  -r
```

## Push and prepare PR

Create a PR body:

```bash
cat > /tmp/task-pr-body.md <<'EOF_PR'
## Summary

- Describe the change.

## Validation

- `make test`
EOF_PR
```

Dry-run:

```bash
agw_push_and_pr --title "Complete documentation iteration" --body-file /tmp/task-pr-body.md
```

Full execution:

```bash
agw_push_and_pr --title "Complete documentation iteration" --body-file /tmp/task-pr-body.md --run
```

Short execution:

```bash
agw_push_and_pr --title "Complete documentation iteration" --body-file /tmp/task-pr-body.md -r
```

## After merge

```bash
agw_post_merge_sync --run
agw_cleanup_branches --branch manual/T008-complete-documentation-iteration --run
agw_cleanup_branches --branch manual/T008-complete-documentation-iteration --remote --run
```

## Safety expectations

The helpers intentionally refuse common unsafe operations in `--run` mode:

- starting a task when the working tree is dirty
- committing directly on `main`
- pushing directly from `main`
- deleting protected branches
- deleting unmerged branches
- creating duplicate tags

If a command refuses to run, inspect the message and fix the repository state first.

## Related functions

- `agw_version`
- `agw_status`
- `agw_start_task`
- `agw_review_output`
- `agw_commit_controlled_change`
- `agw_push_and_pr`
- `agw_post_merge_sync`
- `agw_cleanup_branches`
