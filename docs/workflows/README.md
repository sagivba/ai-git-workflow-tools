# Workflow Overview

This document describes the high-level AI-assisted Git workflow.

## High-level lifecycle

1. Plan the task.
2. Start from updated `main`.
3. Create a dedicated `codex-cli/...` branch.
4. Run Codex or perform manual changes.
5. Inspect Git state.
6. Review diff and scope.
7. Commit controlled changes.
8. Push and open or update a PR.
9. Merge through GitHub.
10. Sync local `main`.
11. Review documentation and metadata.
12. Create and verify a release tag.
13. Clean up branches.

## Source of truth

- GitHub is the project source of truth.
- `main` is the integration line.
- Workflow functions are the command source of truth.
- Markdown docs explain the workflows and are generated or synchronized from Bash metadata.

## Safety principles

- Default to dry-run.
- Execute only with `--run` or `-r`.
- Do not work directly on `main` for implementation.
- Do not commit unrelated files.
- Do not tag before documentation and metadata review.
- Always distinguish validation that was run from validation that was not run.

## Workflow list

| Workflow | Function | Documentation |
|---|---|---|
| Start Codex Task Branch | `agw_start_codex_task` | `docs/workflows/start-codex-task.md` |
| Inspect Git State | `agw_inspect_git_state` | `docs/workflows/inspect-git-state.md` |
| Review Codex Output | `agw_review_codex_output` | `docs/workflows/review-codex-output.md` |
| Commit Controlled Change | `agw_commit_controlled_change` | `docs/workflows/commit-controlled-change.md` |
| Push And Prepare PR | `agw_push_and_pr` | `docs/workflows/push-and-pr.md` |
| Post Merge Sync | `agw_post_merge_sync` | `docs/workflows/post-merge-sync.md` |
| Cleanup Branches | `agw_cleanup_branches` | `docs/workflows/cleanup-branches.md` |
| Pre Tag Documentation Review | `agw_pre_tag_docs_review` | `docs/workflows/pre-tag-docs-review.md` |
| Create And Verify Release Tag | `agw_create_tag` | `docs/workflows/create-and-verify-tag.md` |
