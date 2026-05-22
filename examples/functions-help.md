# Function help reference

This file collects the help text for the public `agw_*` functions.

It is intended as a quick reference for users and AI assistants that need to understand the available commands without opening `scripts/ai-git-workflows.sh`.

Baseline: `v0.7.0`.

## Function list

Read-only functions:

```text
agw_help
agw_version
agw_status
agw_pre_tag_docs_review
```

Dry-run by default functions:

```text
agw_inspect_git_state
agw_start_task
agw_start_codex_task
agw_review_output
agw_review_codex_output
agw_commit_controlled_change
agw_push_and_pr
agw_post_merge_sync
agw_cleanup_branches
agw_create_tag
```

Legacy compatibility functions:

```text
agw_start_codex_task
agw_review_codex_output
```

New generic workflows should prefer:

```text
agw_start_task
agw_review_output
```

## agw_help

```text
ai-git-workflow-tools

Purpose:
  Reusable Bash helpers for safe Git/GitHub workflows, ChatGPT-generated ZIP tasks,
  controlled commits, PR preparation, merge sync, branch cleanup, and release tags.

Recommended lifecycle:
  clean main
    -> move generated ZIP files to /tmp/agw-zips
    -> source the tool
    -> agw_version / agw_status
    -> agw_start_task
    -> unzip task output into the task branch
    -> agw_review_output
    -> tests and docs checks
    -> agw_commit_controlled_change
    -> agw_push_and_pr
    -> merge through GitHub
    -> agw_post_merge_sync
    -> agw_cleanup_branches
    -> agw_pre_tag_docs_review
    -> agw_create_tag

Read-only functions; no --run needed:
  agw_help
  agw_version
  agw_status
  agw_pre_tag_docs_review

Dry-run by default functions:
  agw_inspect_git_state
  agw_start_task
  agw_start_codex_task        legacy compatibility
  agw_review_output
  agw_review_codex_output     legacy compatibility
  agw_commit_controlled_change
  agw_push_and_pr
  agw_post_merge_sync
  agw_cleanup_branches
  agw_create_tag

Execution convention:
  Default mode is dry-run.
  Use --run or -r to execute commands.

Examples: identify current setup
  agw_version
  agw_status

Examples: start task branch
  agw_start_task --task T008 --slug complete-documentation-iteration
  agw_start_task --task T008 --slug complete-documentation-iteration --run
  agw_start_task --task T008 --slug complete-documentation-iteration -r

Examples: review output
  agw_review_output
  agw_review_output --run
  agw_review_output -r

Examples: commit controlled change
  agw_commit_controlled_change --message "Complete documentation iteration" --files "README.md docs/install.md"
  agw_commit_controlled_change --message "Complete documentation iteration" --files "README.md docs/install.md" --run
  agw_commit_controlled_change --message "Complete documentation iteration" --files "README.md docs/install.md" -r

Examples: push and prepare PR
  agw_push_and_pr --title "T008 Complete documentation iteration" --body-file /tmp/T008-pr-body.md
  agw_push_and_pr --title "T008 Complete documentation iteration" --body-file /tmp/T008-pr-body.md --run
  agw_push_and_pr --title "T008 Complete documentation iteration" --body-file /tmp/T008-pr-body.md -r

Examples: post-merge cleanup
  agw_post_merge_sync --run
  agw_cleanup_branches --branch manual/T008-complete-documentation-iteration --run
  agw_cleanup_branches --branch manual/T008-complete-documentation-iteration --remote --run

Examples: tag
  agw_pre_tag_docs_review
  agw_create_tag --tag v0.7.0 --note "Complete documentation iteration"
  agw_create_tag --tag v0.7.0 --note "Complete documentation iteration" --run
  agw_create_tag --tag v0.7.0 --note "Complete documentation iteration" -r

ZIP handling before branch creation:
  mkdir -p /tmp/agw-zips
  if ls *.zip >/dev/null 2>&1; then mv ./*.zip /tmp/agw-zips/; fi
  git status --short | cat

Legacy compatibility:
  agw_start_codex_task and agw_review_codex_output remain available for existing workflows.
  New generic workflows should prefer agw_start_task and agw_review_output.
```

## agw_version --help

```text
agw_version

Purpose:
  Show the loaded ai-git-workflow-tools version and source path.

Usage:
  agw_version

Options:
  --help   Show this help.

Notes:
  This function is read-only. It does not require --run or -r.

Output:
  tool version
  loaded script path
  tool root
  tool git ref, when available

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/version.md
```

## agw_status --help

```text
agw_status

Purpose:
  Show loaded tool information and current repository state.

Usage:
  agw_status

Options:
  --help   Show this help.

Notes:
  This function is read-only. It does not require --run or -r.

Output:
  agw_version output
  current repository root
  current branch
  current HEAD
  short Git status

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/status.md
```

## agw_inspect_git_state --help

```text
agw_inspect_git_state

Purpose:
  Inspect the current Git repository state before making decisions.

Usage:
  agw_inspect_git_state [--run|-r]

Options:
  --run, -r   Execute commands. Without this flag, commands are printed only.
  --help      Show this help.

Commands:
  git branch --show-current
  git status --short
  git log --oneline --decorate -5
  git diff --stat
  git diff --name-only

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/inspect-git-state.md
```

## agw_start_task --help

```text
agw_start_task

Purpose:
  Start a new manual task branch from updated main.

Usage:
  agw_start_task --task T003 --slug short-task-name [--run|-r]
  agw_start_task --branch manual/T003-short-task-name [--run|-r]

Options:
  --task ID       Task identifier, for example T003.
  --slug TEXT     Short lowercase branch slug, for example improve-task-start-workflow.
  --branch NAME   Explicit branch name to create. Required prefix: manual/
  --run, -r       Execute commands. Without this flag, commands are printed only.
  --help          Show this help.

Rules:
  --branch cannot be combined with --task or --slug.
  --task and --slug must be provided together.
  The derived branch format is manual/<task>-<slug>.
  In --run mode, the working tree must be clean.

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/start-task.md
```

## agw_start_codex_task --help

```text
agw_start_codex_task

Purpose:
  Start a new Codex-style task branch from updated main.

Usage:
  agw_start_codex_task --branch codex-cli/<task-name> [--run|-r]

Options:
  --branch NAME   Branch name to create. Required prefix: codex-cli/
  --run, -r       Execute commands. Without this flag, commands are printed only.
  --help          Show this help.

Compatibility:
  This function is retained for existing Codex-specific workflows.
  Prefer agw_start_task for new generic/manual/ChatGPT ZIP task branches.

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/start-codex-task.md
```

## agw_review_output --help

```text
agw_review_output

Purpose:
  Review repository changes after manual, ChatGPT ZIP, or AI-assisted work.

Usage:
  agw_review_output [--run|-r]

Options:
  --run, -r   Execute commands. Without this flag, commands are printed only.
  --help      Show this help.

Commands:
  git branch --show-current
  git status --short
  git diff --stat
  git diff --name-status
  git diff --check

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/review-output.md
```

## agw_review_codex_output --help

```text
agw_review_codex_output

Purpose:
  Review repository changes after Codex or Codex CLI work.

Usage:
  agw_review_codex_output [--run|-r]

Options:
  --run, -r   Execute commands. Without this flag, commands are printed only.
  --help      Show this help.

Compatibility:
  This function is retained for existing Codex-specific workflows.
  Prefer agw_review_output for new generic/manual/ChatGPT ZIP workflows.

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/review-codex-output.md
```

## agw_commit_controlled_change --help

```text
agw_commit_controlled_change

Purpose:
  Stage explicit files, inspect the cached diff, and create a commit.

Usage:
  agw_commit_controlled_change --message "Commit message" --files "file1 file2" [--run|-r]

Options:
  --message TEXT   Required commit message.
  --files TEXT     Space-separated file list to stage.
  --run, -r        Execute commands. Without this flag, commands are printed only.
  --help           Show this help.

Rules:
  In --run mode, this function refuses to commit directly on main.

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/commit-controlled-change.md
```

## agw_push_and_pr --help

```text
agw_push_and_pr

Purpose:
  Push the current branch and prepare or create a Pull Request.

Usage:
  agw_push_and_pr [--title "PR title"] [--body-file path] [--run|-r]

Options:
  --title TEXT       Optional PR title.
  --body-file PATH   Optional PR body file.
  --run, -r          Execute commands. Without this flag, commands are printed only.
  --help             Show this help.

Rules:
  In --run mode, this function refuses to push main directly.
  When PR creation is requested, --body-file must point to an existing file and gh must be available.

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/push-and-pr.md
```

## agw_post_merge_sync --help

```text
agw_post_merge_sync

Purpose:
  Sync local main after a PR was merged.

Usage:
  agw_post_merge_sync [--run|-r]

Options:
  --run, -r   Execute commands. Without this flag, commands are printed only.
  --help      Show this help.

Rules:
  In --run mode, the working tree must be clean before switching to main.

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/post-merge-sync.md
```

## agw_cleanup_branches --help

```text
agw_cleanup_branches

Purpose:
  Inspect branches and optionally delete a branch after merge.

Usage:
  agw_cleanup_branches [--branch name] [--remote] [--run|-r]

Options:
  --branch NAME   Branch to delete.
  --remote        Delete remote branch on origin instead of local branch.
  --run, -r       Execute commands. Without this flag, commands are printed only.
  --help          Show this help.

Rules:
  In --run mode, this function refuses to delete main or master.
  Local branch deletion requires the branch to be merged into main.
  Remote branch deletion requires origin/<branch> to be merged into origin/main.

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/cleanup-branches.md
```

## agw_pre_tag_docs_review --help

```text
agw_pre_tag_docs_review

Purpose:
  Print the required documentation and metadata checklist before creating a release tag.

Usage:
  agw_pre_tag_docs_review

Options:
  --help   Show this help.

Notes:
  This function is read-only. It does not require --run or -r.

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/pre-tag-docs-review.md
```

## agw_create_tag --help

```text
agw_create_tag

Purpose:
  Create an annotated release tag and verify it locally and remotely.

Usage:
  agw_create_tag --tag vX.Y.Z --note "Release note" [--run|-r]

Options:
  --tag TAG     Release tag. Must match vX.Y.Z.
  --note TEXT   Required release note for the annotated tag message.
  --run, -r     Execute commands. Without this flag, commands are printed only.
  --help        Show this help.

Rules:
  In --run mode, the working tree must be clean.
  In --run mode, the tag must not already exist locally or on origin.

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/create-and-verify-tag.md
```

## Regenerate this file manually

From the repository root, the current help text can be inspected with:

```bash
source scripts/ai-git-workflows.sh

agw_help
agw_version --help
agw_status --help
agw_inspect_git_state --help
agw_start_task --help
agw_start_codex_task --help
agw_review_output --help
agw_review_codex_output --help
agw_commit_controlled_change --help
agw_push_and_pr --help
agw_post_merge_sync --help
agw_cleanup_branches --help
agw_pre_tag_docs_review --help
agw_create_tag --help
```

If the Bash help text changes, update this reference in the same task.
