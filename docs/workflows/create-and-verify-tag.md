# Workflow: Create and Verify Release Tag

## Purpose

Create an annotated release tag, push it, and verify that it exists locally and remotely.

## When to use

- After a stable milestone, stage, or goal has been merged into `main`.
- After documentation and metadata review is complete.
- Before starting the next major or risky stage.

## Preconditions

- Local `main` is synced with `origin/main`.
- The working tree is clean.
- Documentation and metadata review is complete.
- The tag matches `vX.Y.Z`.
- A meaningful tag note is available.
- The tag does not already exist locally or remotely.

## Syntax

```bash
agw_create_tag --tag vX.Y.Z --note "Release note" [--run|-r]
```

## Parameters

- `--tag TAG`: Required release tag. Must match `vX.Y.Z`, for example `v0.7.0`.
- `--note TEXT`: Required human-readable note for the annotated tag message.
- `--run`: Execute commands.
- `-r`: Short form for `--run`.
- `--help`: Show function help.

## Dry-run example

```bash
agw_create_tag --tag v0.7.0 --note "Complete documentation iteration"
```

## `--run` example

```bash
agw_create_tag --tag v0.7.0 --note "Complete documentation iteration" --run
```

## `-r` example

```bash
agw_create_tag --tag v0.7.0 --note "Complete documentation iteration" -r
```

## Expected output / behavior

In dry-run mode, the function prints the commands that would run.

In run mode, it:

1. fetches latest refs
2. verifies the working tree is clean
3. switches to `main`
4. pulls `origin/main` with `--ff-only`
5. prints short status and recent log
6. checks for duplicate local and remote tags
7. creates an annotated tag
8. pushes the tag
9. verifies local and remote tag state

## Safety notes

- Default mode is dry-run.
- Real execution requires `--run` or `-r`.
- In run mode, the working tree must be clean.
- In run mode, duplicate local or remote tags are refused.
- Do not run before `agw_pre_tag_docs_review`.

## Related functions

- `agw_pre_tag_docs_review`
- `agw_post_merge_sync`
- `agw_status`
