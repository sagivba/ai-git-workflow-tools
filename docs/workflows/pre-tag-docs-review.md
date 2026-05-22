# Workflow: Pre-Tag Documentation Review

## Purpose

Review documentation, metadata, validation status, and release notes before creating a tag.

## When to use

- Before every release or milestone tag.
- After a meaningful PR or stage is merged.
- Before starting a risky next stage.

## Preconditions

- Relevant PRs are merged.
- Local `main` is synced.
- The intended tag version is known.
- The release note is known.

## Syntax

```bash
agw_pre_tag_docs_review
```

## Parameters

- `--help`: Show function help.

No `--run` flag is needed. This function is read-only.

## Dry-run example

Not applicable. The function is already read-only and executes directly.

## Expected output / behavior

The function prints a checklist for documentation and metadata review:

- README reflects current state.
- TODO or status source is updated.
- Stage or goal report is updated, when relevant.
- Validation run/not-run is documented.
- Known risks and limitations are documented.
- No unrelated local changes exist.
- The intended tag message is clear.

## Safety notes

- Does not change Git state.
- Does not require `--run` or `-r`.
- This checklist should be completed before `agw_create_tag --run`.

## Related functions

- `agw_create_tag`
- `agw_status`
- `agw_post_merge_sync`
