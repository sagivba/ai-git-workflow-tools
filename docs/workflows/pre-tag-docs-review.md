# Workflow: Pre-Tag Documentation Review

## Purpose

Review documentation, metadata, validation status, and release notes before creating a tag.

## When to use

- Before every release or milestone tag.
- After a meaningful PR or stage is merged.
- Before starting a risky next stage.

## Preconditions

- The relevant PRs are merged.
- Local `main` is synced.
- The intended tag version is known.
- The release note is known.

## Commands

<!-- AUTO-GENERATED:START workflow=pre-tag-docs-review -->
The generated command/help block for this workflow should be inserted here by `tools/generate_docs.py`.
<!-- AUTO-GENERATED:END -->

### Command sequence

```bash
agw_pre_tag_docs_review
```
Print the documentation and metadata checklist.

```bash
git status --short | cat
```
Verify no unexplained local changes exist.

```bash
git log --oneline --decorate -5 | cat
```
Verify the intended commit is at HEAD.

```bash
git tag --points-at HEAD | cat
```
Check whether HEAD is already tagged.

## Function usage

```bash
agw_pre_tag_docs_review
```

## Parameters

- `--help`: Show function help.

## Risks

- Tagging before documentation review creates a misleading release checkpoint.
- TODO or status files can drift from actual repository state.
- Validation gaps can be forgotten after tagging.

## Definition of done

- README reflects current state.
- TODO or status source is updated.
- Workflow or stage documentation is updated.
- Validation run/not-run is documented.
- Known risks and limitations are documented.
- The intended tag note is clear.
