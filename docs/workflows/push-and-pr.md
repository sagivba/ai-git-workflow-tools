# Workflow: Push and Prepare PR

## Purpose

Push a task branch and prepare a Pull Request through GitHub CLI or GitHub Web.

## When to use

- After a controlled commit is created.
- When the task branch is ready for review.
- When a PR should be opened or updated.

## Preconditions

- The current branch is not `main`.
- The working tree is clean or any remaining changes are intentional.
- The branch has at least one commit to push.
- The PR title and scope are known.

## Commands

<!-- AUTO-GENERATED:START workflow=push-and-pr -->
The generated command/help block for this workflow should be inserted here by `tools/generate_docs.py`.
<!-- AUTO-GENERATED:END -->

### Command sequence

```bash
git branch --show-current | cat
```
Verify the current branch.

```bash
git status --short | cat
```
Verify working tree state.

```bash
git push -u origin HEAD
```
Push the current branch and set upstream.

```bash
gh pr create --base main --head "$(git branch --show-current)" --title "<title>" --body "<body>"
```
Optional CLI path for PR creation.

## Function usage

```bash
Planned function: agw_push_branch [--run|-r]
```

## Parameters

- `--run`, `-r`: Execute commands. Without this flag, commands are printed only.
- `--help`: Show function help.

## Risks

- Pushing from the wrong branch can create a confusing PR.
- A weak PR body loses validation and scope information.
- CLI and Web PR creation paths can diverge unless the PR content is reviewed.

## Definition of done

- The branch is pushed to `origin`.
- A PR exists or a clear decision was made to create it through GitHub Web.
- The PR body documents summary, scope, validation, not-run checks, and risks.
