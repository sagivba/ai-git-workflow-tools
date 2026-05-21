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

## Commands

<!-- AUTO-GENERATED:START workflow=create-and-verify-tag -->
The generated command/help block for this workflow should be inserted here by `tools/generate_docs.py`.
<!-- AUTO-GENERATED:END -->

### Command sequence

```bash
git fetch --prune origin
```
Refresh remote refs before tagging.

```bash
git switch main
```
Ensure the tag is created on the integration branch.

```bash
git pull --ff-only origin main
```
Ensure local `main` matches `origin/main`.

```bash
git status --short | cat
```
Verify no local changes exist.

```bash
git log --oneline --decorate -5 | cat
```
Verify HEAD is the intended release commit.

```bash
git tag --list "vX.Y.Z" | cat
```
Check whether the tag already exists locally.

```bash
git ls-remote --tags origin "vX.Y.Z" | cat
```
Check whether the tag already exists remotely.

```bash
git tag -a "vX.Y.Z" -m "vX.Y.Z - <note>"
```
Create an annotated release tag.

```bash
git push origin "vX.Y.Z"
```
Push the tag to origin.

```bash
git tag --points-at HEAD | cat
```
Verify the tag points at local HEAD.

```bash
git show --no-patch --decorate "vX.Y.Z" | cat
```
Inspect the tag metadata.

```bash
git ls-remote --tags origin "vX.Y.Z" | cat
```
Verify the tag exists on origin.

## Function usage

```bash
agw_create_tag --tag vX.Y.Z --note "Release note" [--run|-r]
```

## Parameters

- `--tag TAG`: Required. Release tag. Must match `vX.Y.Z`, for example `v1.2.0`.
- `--note TEXT`: Required. Human-readable note for the annotated tag message.
- `--run`, `-r`: Execute commands. Without this flag, commands are printed only.
- `--help`: Show function help.

## Risks

- Creating a tag on the wrong commit creates a misleading release point.
- Reusing an existing tag name causes conflicts.
- Lightweight tags lose useful release metadata.
- Tagging without a note makes future audit harder.

## Definition of done

- The tag exists locally.
- The tag exists on `origin`.
- The tag points to the intended `main` commit.
- The annotated message is clear.
- The release documentation reflects the tagged state.
