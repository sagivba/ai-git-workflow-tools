# Workflow: Review Codex Output

## Purpose

Review manual, ChatGPT-guided, Codex, or Codex CLI output before staging and committing changes.

## When to use

- After an AI assistant changes files.
- After a manual editing session.
- Before staging files for commit.
- Before accepting a generated implementation.

## Preconditions

- The task objective is known.
- The expected scope is known.
- The repository contains unstaged or staged changes to review.

## Commands

<!-- AUTO-GENERATED:START workflow=review-codex-output -->
The generated command/help block for this workflow should be inserted here by `tools/generate_docs.py`.
<!-- AUTO-GENERATED:END -->

### Command sequence

```bash
git status --short | cat
```
Identify changed, deleted, staged, and untracked files.

```bash
git diff --stat | cat
```
Review the scale and distribution of changes.

```bash
git diff --name-only | cat
```
Review the exact file list.

```bash
git diff --check | cat
```
Detect whitespace errors and common patch issues.

```bash
git diff | cat
```
Review the full unstaged diff when needed.

## Function usage

```bash
Planned function: agw_review_output [--run|-r]
```

## Parameters

- `--run`, `-r`: Execute commands. Without this flag, commands are printed only.
- `--help`: Show function help.

## Risks

- AI output may include unrelated cleanup or refactoring.
- Generated code may pass a superficial review but fail scope review.
- Validation may be claimed but not actually run.

## Definition of done

- Changed files match the task scope.
- No unrelated changes are present or they are explicitly split out.
- Validation run/not-run is documented.
- The change is ready for controlled staging or requires a fix.
