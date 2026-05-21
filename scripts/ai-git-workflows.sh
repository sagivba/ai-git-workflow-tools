#!/usr/bin/env bash
# ai-git-workflow-tools
# Reusable Bash functions for AI-assisted Git and GitHub workflows.

set -o pipefail

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
  local first=1
  printf '+'
  local arg
  for arg in "$@"; do
    if [[ "$first" == "1" ]]; then
      printf ' %q' "$arg"
      first=0
    else
      printf ' %q' "$arg"
    fi
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

agw__start_task_branch() {
  local branch="$1"
  local required_prefix="$2"
  local run_mode="$3"

  if [[ -z "$branch" ]]; then
    echo "Error: branch name is required." >&2
    return 1
  fi

  case "$branch" in
    "$required_prefix"*)
      ;;
    *)
      echo "Error: branch must start with ${required_prefix}." >&2
      return 1
      ;;
  esac

  agw__run_cmd "$run_mode" git fetch --prune origin
  agw__run_cmd "$run_mode" git switch main
  agw__run_cmd "$run_mode" git pull --ff-only origin main
  agw__run_cmd "$run_mode" git status --short
  agw__run_cmd "$run_mode" git log --oneline --decorate -5
  agw__run_cmd "$run_mode" git switch -c "$branch"
}

agw_help() {
  cat <<'EOF_HELP'
ai-git-workflow-tools

Available functions:

  agw_inspect_git_state
  agw_start_task
  agw_start_codex_task
  agw_review_codex_output
  agw_commit_controlled_change
  agw_push_and_pr
  agw_post_merge_sync
  agw_cleanup_branches
  agw_pre_tag_docs_review
  agw_create_tag

Global convention:

  Default mode is dry-run.
  Use --run or -r to execute commands.

Examples:

  agw_inspect_git_state
  agw_inspect_git_state --run

  agw_start_task --task T003 --slug improve-task-start-workflow
  agw_start_task --task T003 --slug improve-task-start-workflow --run

  agw_start_codex_task --branch codex-cli/my-task
  agw_start_codex_task --branch codex-cli/my-task --run

  agw_create_tag --tag v1.0.0 --note "Initial stable workflow baseline" --run
EOF_HELP
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
  if agw__is_run_mode "$@"; then
    run_mode=1
  fi

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

Commands:
  git fetch --prune origin
  git switch main
  git pull --ff-only origin main
  git status --short
  git log --oneline --decorate -5
  git switch -c <branch>

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/start-task.md
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1

  local branch=""
  local task=""
  local slug=""
  local run_mode=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch)
        branch="${2:-}"
        shift 2
        ;;
      --task)
        task="${2:-}"
        shift 2
        ;;
      --slug)
        slug="${2:-}"
        shift 2
        ;;
      --run|-r)
        run_mode=1
        shift
        ;;
      *)
        echo "Error: unknown argument: $1" >&2
        return 1
        ;;
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
# @summary Start from updated main and create a codex-cli task branch.
# @usage agw_start_codex_task --branch codex-cli/<task-name> [--run|-r]
# @safe-default dry-run
# @requires git
agw_start_codex_task() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
agw_start_codex_task

Purpose:
  Start a new Codex task branch from updated main.

Usage:
  agw_start_codex_task --branch codex-cli/<task-name> [--run|-r]

Options:
  --branch NAME   Branch name to create. Required prefix: codex-cli/
  --run, -r       Execute commands. Without this flag, commands are printed only.
  --help          Show this help.

Commands:
  git fetch --prune origin
  git switch main
  git pull --ff-only origin main
  git status --short
  git log --oneline --decorate -5
  git switch -c <branch>

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/start-codex-task.md
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1

  local branch=""
  local run_mode=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch)
        branch="${2:-}"
        shift 2
        ;;
      --run|-r)
        run_mode=1
        shift
        ;;
      *)
        echo "Error: unknown argument: $1" >&2
        return 1
        ;;
    esac
  done

  if [[ -z "$branch" ]]; then
    echo "Error: --branch is required." >&2
    return 1
  fi

  agw__start_task_branch "$branch" "codex-cli/" "$run_mode"
}

# @workflow review-codex-output
# @title Review Codex output
# @doc docs/workflows/review-codex-output.md
# @summary Inspect repository state after Codex work and prepare for review.
# @usage agw_review_codex_output [--run|-r]
# @safe-default dry-run
# @requires git
agw_review_codex_output() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
agw_review_codex_output

Purpose:
  Review the repository after Codex has made changes.

Usage:
  agw_review_codex_output [--run|-r]

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
  ${AGW_DOC_BASE_URL}/docs/workflows/review-codex-output.md
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1

  local run_mode=0
  if agw__is_run_mode "$@"; then
    run_mode=1
  fi

  agw__run_cmd "$run_mode" git branch --show-current
  agw__run_cmd "$run_mode" git status --short
  agw__run_cmd "$run_mode" git diff --stat
  agw__run_cmd "$run_mode" git diff --name-status
  agw__run_cmd "$run_mode" git diff --check
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

Commands:
  git add <files>
  git diff --cached --stat
  git diff --cached --check
  git commit -m <message>

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/commit-controlled-change.md
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1

  local message=""
  local files=""
  local run_mode=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --message)
        message="${2:-}"
        shift 2
        ;;
      --files)
        files="${2:-}"
        shift 2
        ;;
      --run|-r)
        run_mode=1
        shift
        ;;
      *)
        echo "Error: unknown argument: $1" >&2
        return 1
        ;;
    esac
  done

  if [[ -z "$message" ]]; then
    echo "Error: --message is required." >&2
    return 1
  fi

  if [[ -z "$files" ]]; then
    echo "Error: --files is required." >&2
    return 1
  fi

  # shellcheck disable=SC2086
  agw__run_cmd "$run_mode" git add $files
  agw__run_cmd "$run_mode" git diff --cached --stat
  agw__run_cmd "$run_mode" git diff --cached --check
  agw__run_cmd "$run_mode" git commit -m "$message"
}

# @workflow push-and-pr
# @title Push and prepare PR
# @doc docs/workflows/push-and-pr.md
# @summary Push current branch and optionally provide PR creation guidance.
# @usage agw_push_and_pr [--title "PR title"] [--body-file path] [--run|-r]
# @safe-default dry-run
# @requires git
# @requires optional:gh
agw_push_and_pr() {
  if [[ "${1:-}" == "--help" ]]; then
    cat <<EOF_HELP
agw_push_and_pr

Purpose:
  Push the current branch and prepare a Pull Request path.

Usage:
  agw_push_and_pr [--title "PR title"] [--body-file path] [--run|-r]

Options:
  --title TEXT       Optional PR title.
  --body-file PATH   Optional PR body file.
  --run, -r          Execute commands. Without this flag, commands are printed only.
  --help             Show this help.

Commands:
  git branch --show-current
  git status --short
  git push -u origin HEAD
  gh pr create --base main --head <current-branch> --title <title> --body-file <body-file>

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/push-and-pr.md
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1

  local title=""
  local body_file=""
  local run_mode=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --title)
        title="${2:-}"
        shift 2
        ;;
      --body-file)
        body_file="${2:-}"
        shift 2
        ;;
      --run|-r)
        run_mode=1
        shift
        ;;
      *)
        echo "Error: unknown argument: $1" >&2
        return 1
        ;;
    esac
  done

  local branch
  branch="$(git branch --show-current)" || return 1

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

Commands:
  git fetch --prune origin
  git switch main
  git pull --ff-only origin main
  git status --short
  git log --oneline --decorate -5

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/post-merge-sync.md
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1

  local run_mode=0
  if agw__is_run_mode "$@"; then
    run_mode=1
  fi

  agw__run_cmd "$run_mode" git fetch --prune origin
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

Commands:
  git fetch --prune origin
  git branch --merged main
  git branch --no-merged main
  git branch -r --merged origin/main
  git branch -r --no-merged origin/main
  git branch --delete <branch>
  git push origin --delete <branch>

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/cleanup-branches.md
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1

  local branch=""
  local remote=0
  local run_mode=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch)
        branch="${2:-}"
        shift 2
        ;;
      --remote)
        remote=1
        shift
        ;;
      --run|-r)
        run_mode=1
        shift
        ;;
      *)
        echo "Error: unknown argument: $1" >&2
        return 1
        ;;
    esac
  done

  agw__run_cmd "$run_mode" git fetch --prune origin
  agw__run_cmd "$run_mode" git branch --merged main
  agw__run_cmd "$run_mode" git branch --no-merged main
  agw__run_cmd "$run_mode" git branch -r --merged origin/main
  agw__run_cmd "$run_mode" git branch -r --no-merged origin/main

  if [[ -n "$branch" ]]; then
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

Checklist:
  1. README reflects the current state.
  2. TODO or status source is updated.
  3. Stage or goal report is updated.
  4. Validation run/not-run is documented.
  5. Known risks and limitations are documented.
  6. No unrelated local changes exist.
  7. The intended tag message is clear.

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/pre-tag-docs-review.md
EOF_HELP
    return 0
  fi

  cat <<'EOF_HELP'
Pre-tag documentation review checklist:

[ ] README reflects the current state.
[ ] TODO or status source is updated.
[ ] Stage or goal report is updated.
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

Commands:
  git fetch --prune origin
  git switch main
  git pull --ff-only origin main
  git status --short
  git log --oneline --decorate -5
  git tag --list <tag>
  git ls-remote --tags origin <tag>
  git tag -a <tag> -m "<tag> - <note>"
  git push origin <tag>
  git tag --points-at HEAD
  git show --no-patch --decorate <tag>
  git ls-remote --tags origin <tag>

Docs:
  ${AGW_DOC_BASE_URL}/docs/workflows/create-and-verify-tag.md
EOF_HELP
    return 0
  fi

  agw__require_git_repo || return 1

  local tag=""
  local note=""
  local run_mode=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --tag)
        tag="${2:-}"
        shift 2
        ;;
      --note)
        note="${2:-}"
        shift 2
        ;;
      --run|-r)
        run_mode=1
        shift
        ;;
      *)
        echo "Error: unknown argument: $1" >&2
        return 1
        ;;
    esac
  done

  if [[ -z "$tag" ]]; then
    echo "Error: --tag is required." >&2
    return 1
  fi

  if [[ -z "$note" ]]; then
    echo "Error: --note is required." >&2
    return 1
  fi

  if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: tag must match vX.Y.Z, for example v1.2.0." >&2
    return 1
  fi

  agw__run_cmd "$run_mode" git fetch --prune origin
  agw__run_cmd "$run_mode" git switch main
  agw__run_cmd "$run_mode" git pull --ff-only origin main
  agw__run_cmd "$run_mode" git status --short
  agw__run_cmd "$run_mode" git log --oneline --decorate -5
  agw__run_cmd "$run_mode" git tag --list "$tag"
  agw__run_cmd "$run_mode" git ls-remote --tags origin "$tag"
  agw__run_cmd "$run_mode" git tag -a "$tag" -m "$tag - $note"
  agw__run_cmd "$run_mode" git push origin "$tag"
  agw__run_cmd "$run_mode" git tag --points-at HEAD
  agw__run_cmd "$run_mode" git show --no-patch --decorate "$tag"
  agw__run_cmd "$run_mode" git ls-remote --tags origin "$tag"
}
