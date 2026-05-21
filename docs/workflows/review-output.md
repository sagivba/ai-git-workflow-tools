# Workflow: Review Output

## Purpose

Review manual, ChatGPT-guided, generated ZIP, Codex, Codex CLI, or other AI-assisted output before staging and committing changes.

## When to use

- After an AI assistant changes files.
- After extracting a task ZIP into the working tree.
- After a manual editing session.
- Before staging files for commit.
- Before accepting a generated implementation.

## Preconditions

- The task objective is known.
- The expected scope is known.
- The repository contains unstaged or staged changes to review.

## Commands

<!-- AUTO-GENERATED:START workflow=review-output -->
The generated command/help block for this workflow should be inserted here by `tools/generate_docs.py`.
<!-- AUTO-GENERATED:END -->

### Command sequence

```bash
git branch --show-current | cat
```
Confirm which branch is being reviewed.

```bash
git status --short | cat
```
Identify changed, deleted, staged, and untracked files.

```bash
git diff --stat | cat
```
Review the scale and distribution of changes.

```bash
git diff --name-status | cat
```
Review the exact file list and whether each file was modified, added, deleted, or renamed.

```bash
git diff --check | cat
```
Detect whitespace errors and common patch issues.

## Function usage

```bash
agw_review_output [--run|-r]
```

## Parameters

- `--run`, `-r`: Execute commands. Without this flag, commands are printed only.
- `--help`: Show function help.

## Compatibility

For existing Codex-specific workflows, the legacy function remains available:

```bash
agw_review_codex_output [--run|-r]
```

New workflows should prefer:

```bash
agw_review_output [--run|-r]
```

## Risks

- AI output may include unrelated cleanup or refactoring.
- Generated code may pass a superficial review but fail scope review.
- Validation may be claimed but not actually run.
- Extracted ZIP files may include unexpected files if the task scope was too broad.

## Definition of done

- Changed files match the task scope.
- No unrelated changes are present or they are explicitly split out.
- Validation run/not-run is documented.
- The change is ready for controlled staging or requires a fix.
