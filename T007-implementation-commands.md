# T007 implementation commands

Run these commands from the repository root.

## 1. Move the ZIP outside the working tree

```bash
mkdir -p /tmp/agw-zips
mv T007-version-status-commands.zip /tmp/agw-zips/
git status --short | cat
```

Expected output: empty.

## 2. Start the task branch

```bash
source scripts/load-agw.sh
agw_start_task --task T007 --slug version-status-commands --run
```

Expected branch:

```text
manual/T007-version-status-commands
```

## 3. Extract the ZIP

```bash
unzip -o /tmp/agw-zips/T007-version-status-commands.zip -d .
chmod +x scripts/ai-git-workflows.sh scripts/load-agw.sh tests/test_help.sh tests/test_load.sh
```

## 4. Reload and validate

```bash
source scripts/load-agw.sh

agw_version
agw_status

git status --short | cat
git diff --stat | cat

make test
bash -n scripts/ai-git-workflows.sh
bash -n scripts/load-agw.sh
bash -n tests/test_help.sh
bash -n tests/test_load.sh
python3 tools/generate_docs.py --check
```

## 5. Commit

```bash
agw_commit_controlled_change \
  --message "Add version and status commands" \
  --files "scripts/ai-git-workflows.sh scripts/load-agw.sh tests/test_help.sh tests/test_load.sh docs/workflows/version.md docs/workflows/status.md T007-implementation-commands.md" \
  --run
```

## 6. Create PR

```bash
cat > /tmp/T007-pr-body.md <<'EOF'
## Summary

- Add `agw_version` to show loaded tool version and source path.
- Add `agw_status` to show loaded tool info and current repository state.
- Update loader to export `AGW_TOOL_ROOT`.
- Add workflow docs for version/status commands.
- Add tests for help output, loader behavior, and version output.

## Validation

- `make test`
- `bash -n scripts/ai-git-workflows.sh`
- `bash -n scripts/load-agw.sh`
- `bash -n tests/test_help.sh`
- `bash -n tests/test_load.sh`
- `python3 tools/generate_docs.py --check`
EOF

agw_push_and_pr \
  --title "T007 Add version and status commands" \
  --body-file /tmp/T007-pr-body.md \
  --run
```

## 7. After merge

```bash
agw_post_merge_sync --run

agw_cleanup_branches --branch manual/T007-version-status-commands --run
agw_cleanup_branches --branch manual/T007-version-status-commands --remote --run

git status --short | cat
git branch --list | cat
git branch -r | cat
git log --oneline --decorate -5 | cat
```

## 8. Tag

```bash
agw_create_tag --tag v0.6.0 --note "Add version and status commands" --run

git tag --list | cat
git log --oneline --decorate -5 | cat
git ls-remote --tags origin v0.6.0 | cat
```
