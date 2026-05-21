# Use from an existing project

## Purpose

Use `ai-git-workflow-tools` from another Git repository without copying the tool files into that repository.

The recommended model is:

```text
one central clone of ai-git-workflow-tools
  -> source scripts/load-agw.sh from any project
  -> run agw_* functions inside the current project
```

## One-time setup

```bash
mkdir -p ~/src
git clone https://github.com/sagivba/ai-git-workflow-tools.git ~/src/ai-git-workflow-tools
```

## Load inside a project

```bash
cd ~/src/some-existing-project
source ~/src/ai-git-workflow-tools/scripts/load-agw.sh
```

Verify:

```bash
agw_help
agw_inspect_git_state
```

## Start a task branch

Always start with dry-run first:

```bash
agw_start_task --task T001 --slug first-safe-task
```

If the commands look correct:

```bash
agw_start_task --task T001 --slug first-safe-task --run
```

This creates:

```text
manual/T001-first-safe-task
```

## Review changes

After editing files:

```bash
agw_review_output
```

Run the review commands:

```bash
agw_review_output --run
```

## Commit controlled changes

Stage explicit files only:

```bash
agw_commit_controlled_change \
  --message "Describe the change" \
  --files "path/to/file1 path/to/file2"
```

If the dry-run output is correct:

```bash
agw_commit_controlled_change \
  --message "Describe the change" \
  --files "path/to/file1 path/to/file2" \
  --run
```

## Push and prepare PR

Create a PR body:

```bash
cat > /tmp/task-pr-body.md <<'EOF'
## Summary

- Describe the change.

## Validation

- `make test`
EOF
```

Push and create a PR:

```bash
agw_push_and_pr \
  --title "Describe the change" \
  --body-file /tmp/task-pr-body.md \
  --run
```

## After merge

```bash
agw_post_merge_sync --run
agw_cleanup_branches --branch manual/T001-first-safe-task --run
agw_cleanup_branches --branch manual/T001-first-safe-task --remote --run
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
