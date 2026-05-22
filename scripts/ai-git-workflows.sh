#!/usr/bin/env bash
# ai-git-workflow-tools
# Reusable Bash functions for AI-assisted Git and GitHub workflows.

set -o pipefail

AGW_TOOL_VERSION="${AGW_TOOL_VERSION:-v0.6.0-dev}"
AGW_DOC_BASE_URL="${AGW_DOC_BASE_URL:-https://github.com/sagivba/ai-git-workflow-tools/blob/main}"

agw__is_run_mode() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      --run|-r)
        return 0
        ;;
    esac
  done
  return 1
}

agw__print_cmd() {
  printf '++'
  local arg
  for arg in "$@"; do
    printf ' %q' "$arg"
  done
  printf '\n'
}

agw__run_cmd() {
  local run_mode="$1"
  shift
  agw__print_cmd "$@"
  if [[ "$run_mode" == "1" ]]; then
    "$@"
  fi
}

agw__require_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "Error: not inside a Git repository." >&2
    return 1
  }
}

agw__current_branch() {
  git branch --show-current
}

agw__tool_root() {
  if [[ -n "${AGW_TOOL_ROOT:-}" ]]; then
    printf '%s\n' "$AGW_TOOL_ROOT"
    return 0
  fi

  local script_path="${BASH_SOURCE[0]}"
  local script_dir
  script_dir="$(cd "$(dirname "$script_path")" && pwd)" || return 1
  cd "$script_dir/.." && pwd
}

agw__tool_git_ref() {
  local root="$1"
  if [[ -d "$root/.git" || -f "$root/.git" ]]; then
    git -C "$root" describe --tags --always --dirty 2>/dev/null || true
  fi
}

agw__require_clean_worktree() {
  local status
  status="$(git status --short)" || return 1
  if [[ -n "$status" ]]; then
    echo "Error: working tree must be clean before this operation." >&2
    printf '%s\n' "$status" >&2
    return 1
  fi
}

agw__require_not_on_main() {
  local branch
  branch="$(agw__current_branch)" || return 1
  if [[ "$branch" == "main" ]]; then
    echo "Error: refusing to modify main directly." >&2
    return 1
  fi
}

agw__require_not_protected_branch() {
  local branch="$1"
  case "$branch" in
    main|master)
      echo "Error: refusing to delete protected branch: $branch" >&2
      return 1
      ;;
  esac
}

agw__require_branch_absent() {
  local branch="$1"
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "Error: local branch already exists: $branch" >&2
    return 1
  fi
  if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    echo "Error: remote branch already exists: origin/$branch" >&2
    return 1
  fi
}

agw__require_local_branch_merged() {
  local branch="$1"
  if ! git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "Error: local branch does not exist: $branch" >&2
    return 1
  fi
  if ! git branch --merged main --format='%(refname:short)' | grep -Fxq "$branch"; then
    echo "Error: refusing to delete local branch that is not merged into main: $branch" >&2
    return 1
  fi
}

agw__require_remote_branch_merged() {
  local branch="$1"
  local remote_branch="origin/$branch"
  if ! git show-ref --verify --quiet "refs/remotes/$remote_branch"; then
    echo "Error: remote branch does not exist: $remote_branch" >&2
    return 1
  fi
  if ! git branch -r --merged origin/main --format='%(refname:short)' | grep -Fxq "$remote_branch"; then
    echo "Error: refusing to delete remote branch that is not merged into origin/main: $remote_branch" >&2
    return 1
  fi
}

agw__require_tag_absent() {
  local tag="$1"
  if git tag --list "$tag" | grep -Fxq "$tag"; then
    echo "Error: tag already exists locally: $tag" >&2
    return 1
  fi
  if git ls-remote --tags origin "$tag" | grep -q "refs/tags/$tag"; then
    echo "Error: tag already exists on origin: $tag" >&2
    return 1
  fi
}

agw__require_command() {
  local command_name="$1"
  command -v "$command_name" >/dev/null 2>&1 || {
    echo "Error: required command not found: $command_name" >&2
    return 1
  }
}

agw__start_task_branch() {
  local branch="$1"
  local required_prefix="$2"
  local run_mode="$3"

  if [[ -z "$branch" ]]; then
    echo "Error: branch name is required." >&2
    return 1
  fi

  case "$branch" in
    "$required_prefix"*) ;;
    *)
      echo "Error: branch must start with ${required_prefix}." >&2
      return 1
      ;;
  esac

  agw__run_cmd "$run_mode" git fetch --prune origin

  if [[ "$run_mode" == "1" ]]; then
    agw__require_clean_worktree || return 1
    agw__require_branch_absent "$branch" || return 1
  fi

  agw__run_cmd "$run_mode" git switch main
  agw__run_cmd "$run_mode" git pull --ff-only origin main
  agw__run_cmd "$run_mode" git status --short
  agw__run_cmd "$run_mode" git log --oneline --decorate -5

  if [[ "$run_mode" == "1" ]]; then
    agw__require_clean_worktree || return 1
    agw__require_branch_absent "$branch" || return 1
  fi

  agw__run_cmd "$run_mode" git switch -c "$branch"
}

agw__review_output_commands() {
  local run_mode="$1"
  agw__run_cmd "$run_mode" git branch --show-current
  agw__run_cmd "$run_mode" git status --short
  agw__run_cmd "$run_mode" git diff --stat
  agw__run_cmd "$run_mode" git diff --name-status
  agw__run_cmd "$run_mode" git diff --check
}

agw_help() {
  cat <<'EOF_HELP'
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
EOF_HELP
}

# @workflow version
# @title Show tool version
# @doc docs/workflows/version.md
# @summary Show loaded ai-git-workflow-tools version and source path.
# @usage agw_version [--help]
# @safe-default read-only
# @requires none
agw_version() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi

  local root
  root="$(agw__tool_root)" || return 1
  local ref
  ref="$(agw__tool_git_ref "$root")"

  echo "ai-git-workflow-tools"
  echo "version: ${AGW_TOOL_VERSION}"
  echo "script: ${BASH_SOURCE[0]}"
  echo "tool_root: ${root}"
  if [[ -n "$ref" ]]; then
    echo "tool_git_ref: ${ref}"
  else
    echo "tool_git_ref: unavailable"
  fi
}

# @workflow status
# @title Show workflow status
# @doc docs/workflows/status.md
# @summary Show loaded tool information and current repository state.
# @usage agw_status [--help]
# @safe-default read-only
# @requires git
agw_status() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1
  agw_version
  echo
  echo "current_repository: $(git rev-parse --show-toplevel)"
  echo "current_branch: $(git branch --show-current)"
  echo "current_head: $(git rev-parse --short HEAD)"
  echo "current_status:"
  git status --short
}

# @workflow inspect-git-state
# @title Inspect Git state
# @doc docs/workflows/inspect-git-state.md
# @summary Inspect current branch, status, recent log, and diff summary.
# @usage agw_inspect_git_state [--run|-r]
# @safe-default dry-run
# @requires git
agw_inspect_git_state() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi
  agw__require_git_repo || return 1
  local run_mode=0
  if agw__is_run_mode "$@"; then run_mode=1; fi
  agw__run_cmd "$run_mode" git branch --show-current
  agw__run_cmd "$run_mode" git status --short
  agw__run_cmd "$run_mode" git log --oneline --decorate -5
  agw__run_cmd "$run_mode" git diff --stat
  agw__run_cmd "$run_mode" git diff --name-only
}

# @workflow start-task
# @title Start task branch
# @doc docs/workflows/start-task.md
# @summary Start from updated main and create a manual task branch.
# @usage agw_start_task --task T003 --slug short-task-name [--run|-r]
# @safe-default dry-run
# @requires git
agw_start_task() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1
  local branch="" task="" slug="" run_mode=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch) branch="${2:-}"; shift 2 ;;
      --task) task="${2:-}"; shift 2 ;;
      --slug) slug="${2:-}"; shift 2 ;;
      --run|-r) run_mode=1; shift ;;
      *) echo "Error: unknown argument: $1" >&2; return 1 ;;
    esac
  done

  if [[ -n "$branch" && ( -n "$task" || -n "$slug" ) ]]; then
    echo "Error: --branch cannot be combined with --task or --slug." >&2
    return 1
  fi
  if [[ -z "$branch" ]]; then
    if [[ -z "$task" || -z "$slug" ]]; then
      echo "Error: provide either --branch or both --task and --slug." >&2
      return 1
    fi
    if [[ ! "$task" =~ ^T[0-9]+$ ]]; then
      echo "Error: --task must match T<number>, for example T003." >&2
      return 1
    fi
    if [[ ! "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
      echo "Error: --slug must use lowercase letters, digits, and hyphens." >&2
      return 1
    fi
    branch="manual/${task}-${slug}"
  fi
  agw__start_task_branch "$branch" "manual/" "$run_mode"
}

# @workflow start-codex-task
# @title Start Codex task branch
# @doc docs/workflows/start-codex-task.md
# @summary Legacy compatibility wrapper for creating codex-cli task branches; prefer agw_start_task for new workflows.
# @usage agw_start_codex_task --branch codex-cli/<task-name> [--run|-r]
# @safe-default dry-run
# @requires git
agw_start_codex_task() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1
  local branch="" run_mode=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch) branch="${2:-}"; shift 2 ;;
      --run|-r) run_mode=1; shift ;;
      *) echo "Error: unknown argument: $1" >&2; return 1 ;;
    esac
  done
  if [[ -z "$branch" ]]; then
    echo "Error: --branch is required." >&2
    return 1
  fi
  agw__start_task_branch "$branch" "codex-cli/" "$run_mode"
}

# @workflow review-output
# @title Review output
# @doc docs/workflows/review-output.md
# @summary Inspect repository state after manual or AI-assisted work and prepare for review.
# @usage agw_review_output [--run|-r]
# @safe-default dry-run
# @requires git
agw_review_output() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi
  agw__require_git_repo || return 1
  local run_mode=0
  if agw__is_run_mode "$@"; then run_mode=1; fi
  agw__review_output_commands "$run_mode"
}

# @workflow review-codex-output
# @title Review Codex output
# @doc docs/workflows/review-codex-output.md
# @summary Compatibility wrapper for reviewing Codex output; prefer agw_review_output for new workflows.
# @usage agw_review_codex_output [--run|-r]
# @safe-default dry-run
# @requires git
agw_review_codex_output() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi
  agw_review_output "$@"
}

# @workflow commit-controlled-change
# @title Commit controlled change
# @doc docs/workflows/commit-controlled-change.md
# @summary Stage explicit files and create a clear commit after cached-diff checks.
# @usage agw_commit_controlled_change --message "Commit message" --files "file1 file2" [--run|-r]
# @safe-default dry-run
# @requires git
agw_commit_controlled_change() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1
  local message="" files="" run_mode=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --message) message="${2:-}"; shift 2 ;;
      --files) files="${2:-}"; shift 2 ;;
      --run|-r) run_mode=1; shift ;;
      *) echo "Error: unknown argument: $1" >&2; return 1 ;;
    esac
  done
  if [[ -z "$message" ]]; then echo "Error: --message is required." >&2; return 1; fi
  if [[ -z "$files" ]]; then echo "Error: --files is required." >&2; return 1; fi
  if [[ "$run_mode" == "1" ]]; then agw__require_not_on_main || return 1; fi
  # shellcheck disable=SC2086
  agw__run_cmd "$run_mode" git add $files
  agw__run_cmd "$run_mode" git diff --cached --stat
  agw__run_cmd "$run_mode" git diff --cached --check
  agw__run_cmd "$run_mode" git commit -m "$message"
}

# @workflow push-and-pr
# @title Push and prepare PR
# @doc docs/workflows/push-and-pr.md
# @summary Push current branch and optionally create a PR through GitHub CLI.
# @usage agw_push_and_pr [--title "PR title"] [--body-file path] [--run|-r]
# @safe-default dry-run
# @requires git
# @requires optional:gh
agw_push_and_pr() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1
  local title="" body_file="" run_mode=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --title) title="${2:-}"; shift 2 ;;
      --body-file) body_file="${2:-}"; shift 2 ;;
      --run|-r) run_mode=1; shift ;;
      *) echo "Error: unknown argument: $1" >&2; return 1 ;;
    esac
  done
  local branch
  branch="$(git branch --show-current)" || return 1
  if [[ "$run_mode" == "1" ]]; then
    agw__require_not_on_main || return 1
    if [[ -n "$body_file" && ! -f "$body_file" ]]; then
      echo "Error: --body-file does not exist: $body_file" >&2
      return 1
    fi
    if [[ -n "$title" && -n "$body_file" ]]; then
      agw__require_command gh || return 1
    fi
  fi
  agw__run_cmd "$run_mode" git branch --show-current
  agw__run_cmd "$run_mode" git status --short
  agw__run_cmd "$run_mode" git push -u origin HEAD
  if [[ -n "$title" && -n "$body_file" ]]; then
    agw__run_cmd "$run_mode" gh pr create --base main --head "$branch" --title "$title" --body-file "$body_file"
  else
    echo "PR creation not executed because --title and --body-file were not both provided."
    echo "You may create the PR in the GitHub Web UI."
  fi
}

# @workflow post-merge-sync
# @title Post merge sync
# @doc docs/workflows/post-merge-sync.md
# @summary Return to main after merge, pull fast-forward updates, and inspect state.
# @usage agw_post_merge_sync [--run|-r]
# @safe-default dry-run
# @requires git
agw_post_merge_sync() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi
  agw__require_git_repo || return 1
  local run_mode=0
  if agw__is_run_mode "$@"; then run_mode=1; fi
  agw__run_cmd "$run_mode" git fetch --prune origin
  if [[ "$run_mode" == "1" ]]; then agw__require_clean_worktree || return 1; fi
  agw__run_cmd "$run_mode" git switch main
  agw__run_cmd "$run_mode" git pull --ff-only origin main
  agw__run_cmd "$run_mode" git status --short
  agw__run_cmd "$run_mode" git log --oneline --decorate -5
}

# @workflow cleanup-branches
# @title Cleanup branches
# @doc docs/workflows/cleanup-branches.md
# @summary Inspect merged/unmerged branches and optionally delete one branch.
# @usage agw_cleanup_branches [--branch name] [--remote] [--run|-r]
# @safe-default dry-run
# @requires git
agw_cleanup_branches() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1
  local branch="" remote=0 run_mode=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch) branch="${2:-}"; shift 2 ;;
      --remote) remote=1; shift ;;
      --run|-r) run_mode=1; shift ;;
      *) echo "Error: unknown argument: $1" >&2; return 1 ;;
    esac
  done
  agw__run_cmd "$run_mode" git fetch --prune origin
  agw__run_cmd "$run_mode" git branch --merged main
  agw__run_cmd "$run_mode" git branch --no-merged main
  agw__run_cmd "$run_mode" git branch -r --merged origin/main
  agw__run_cmd "$run_mode" git branch -r --no-merged origin/main
  if [[ -n "$branch" ]]; then
    if [[ "$run_mode" == "1" ]]; then
      agw__require_not_protected_branch "$branch" || return 1
      if [[ "$remote" == "1" ]]; then
        agw__require_remote_branch_merged "$branch" || return 1
      else
        agw__require_local_branch_merged "$branch" || return 1
      fi
    fi
    if [[ "$remote" == "1" ]]; then
      agw__run_cmd "$run_mode" git push origin --delete "$branch"
    else
      agw__run_cmd "$run_mode" git branch --delete "$branch"
    fi
  fi
}

# @workflow pre-tag-docs-review
# @title Pre-tag documentation review
# @doc docs/workflows/pre-tag-docs-review.md
# @summary Review documentation and project metadata before creating a release tag.
# @usage agw_pre_tag_docs_review [--help]
# @safe-default read-only
# @requires none
agw_pre_tag_docs_review() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi
  cat <<'EOF_HELP'
Pre-tag documentation review checklist:

[ ] README reflects the current state.
[ ] TODO or status source is updated.
[ ] Stage or goal report is updated when relevant.
[ ] Validation run/not-run is documented.
[ ] Known risks and limitations are documented.
[ ] No unrelated local changes exist.
[ ] The intended tag message is clear.
EOF_HELP
}

# @workflow create-and-verify-tag
# @title Create and verify release tag
# @doc docs/workflows/create-and-verify-tag.md
# @summary Create an annotated vX.Y.Z tag, push it, and verify it locally and remotely.
# @usage agw_create_tag --tag vX.Y.Z --note "Release note" [--run|-r]
# @safe-default dry-run
# @requires git
agw_create_tag() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
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
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1
  local tag="" note="" run_mode=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --tag) tag="${2:-}"; shift 2 ;;
      --note) note="${2:-}"; shift 2 ;;
      --run|-r) run_mode=1; shift ;;
      *) echo "Error: unknown argument: $1" >&2; return 1 ;;
    esac
  done
  if [[ -z "$tag" ]]; then echo "Error: --tag is required." >&2; return 1; fi
  if [[ -z "$note" ]]; then echo "Error: --note is required." >&2; return 1; fi
  if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: tag must match vX.Y.Z, for example v1.2.0." >&2
    return 1
  fi
  agw__run_cmd "$run_mode" git fetch --prune origin
  if [[ "$run_mode" == "1" ]]; then agw__require_clean_worktree || return 1; fi
  agw__run_cmd "$run_mode" git switch main
  agw__run_cmd "$run_mode" git pull --ff-only origin main
  agw__run_cmd "$run_mode" git status --short
  agw__run_cmd "$run_mode" git log --oneline --decorate -5
  agw__run_cmd "$run_mode" git tag --list "$tag"
  agw__run_cmd "$run_mode" git ls-remote --tags origin "$tag"
  if [[ "$run_mode" == "1" ]]; then
    agw__require_clean_worktree || return 1
    agw__require_tag_absent "$tag" || return 1
  fi
  agw__run_cmd "$run_mode" git tag -a "$tag" -m "$tag - $note"
  agw__run_cmd "$run_mode" git push origin "$tag"
  agw__run_cmd "$run_mode" git tag --points-at HEAD
  agw__run_cmd "$run_mode" git show --no-patch --decorate "$tag"
  agw__run_cmd "$run_mode" git ls-remote --tags origin "$tag"
}
