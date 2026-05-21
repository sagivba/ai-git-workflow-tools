# Workflow: Commit Controlled Change

## Purpose

Stage and commit reviewed changes in a controlled and auditable way.

## When to use

- After Git state inspection.
- After reviewing the diff.
- After deciding that the change is ready to become a commit.

## Preconditions

- The changed files have been reviewed.
- The commit scope is clear.
- The commit message is known.
- Validation status is known.

## Commands

<!-- AUTO-GENERATED:START workflow=commit-controlled-change -->
The generated command/help block for this workflow should be inserted here by `tools/generate_docs.py`.
<!-- AUTO-GENERATED:END -->

### Command sequence

```bash
git add <files>
```
Stage explicit files. Prefer this over blind `git add .` when possible.

```bash
git diff --cached --stat | cat
```
Review the staged change summary.

```bash
git diff --cached --check | cat
```
Detect whitespace or patch issues in staged changes.

```bash
git status --short | cat
```
Verify staged and unstaged state before committing.

```bash
git commit -m "<clear imperative message>"
```
Create the commit with a clear message.

## Function usage

```bash
Planned function: agw_commit_controlled_change --message "..." --files <files...> [--run|-r]
```

## Parameters

- `--message TEXT`: Commit message.
- `--files FILE...`: Files to stage.
- `--run`, `-r`: Execute commands. Without this flag, commands are printed only.
- `--help`: Show function help.

## Risks

- `git add .` can stage unrelated files.
- A vague commit message reduces future audit value.
- Committing without staged diff review can include accidental changes.

## Definition of done

- Only intended files are staged.
- The staged diff has been checked.
- The commit message is clear.
- A commit exists for the controlled change.
