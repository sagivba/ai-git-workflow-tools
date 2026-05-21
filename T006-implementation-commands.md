# T006 implementation commands

Run these commands from the repository root.

## 1. Move the ZIP outside the working tree

```bash
mkdir -p /tmp/agw-zips
mv T006-install-use-from-existing-project-with-commands.zip /tmp/agw-zips/
git status --short | cat
```

Expected output: empty.

## 2. Load the current tool and start the task branch

```bash
source scripts/ai-git-workflows.sh
agw_start_task --task T006 --slug install-use-from-existing-project --run
```

Expected branch:

```text
manual/T006-install-use-from-existing-project
```

## 3. Extract the ZIP

```bash
unzip -o /tmp/agw-zips/T006-install-use-from-existing-project-with-commands.zip -d .
chmod +x scripts/load-agw.sh tests/test_load.sh tests/run.sh
```

## 4. Reload through the new loader

```bash
source scripts/load-agw.sh
type agw_start_task
type agw_review_output
```

## 5. Review and validate

```bash
git status --short | cat
git diff --stat | cat

make test
bash -n scripts/load-agw.sh
bash -n tests/test_load.sh
bash -n tests/run.sh
```

## 6. Commit

```bash
agw_commit_controlled_change \
  --message "Add install and external project usage support" \
  --files "README.md scripts/load-agw.sh tests/run.sh tests/test_load.sh docs/install.md docs/use-from-existing-project.md T006-implementation-commands.md" \
  --run
```

## 7. Create PR

```bash
cat > /tmp/T006-pr-body.md <<'EOF'
## Summary

- Add `scripts/load-agw.sh` for loading workflow functions from any repository.
- Add installation documentation.
- Add usage documentation for existing external projects.
- Update README with external-project quickstart.
- Add loader tests and wire them into the test runner.
- Add T006 implementation command reference.

## Validation

- `make test`
- `bash -n scripts/load-agw.sh`
- `bash -n tests/test_load.sh`
- `bash -n tests/run.sh`
EOF

agw_push_and_pr \
  --title "T006 Add install and external project usage support" \
  --body-file /tmp/T006-pr-body.md \
  --run
```

## 8. After merge

```bash
agw_post_merge_sync --run

agw_cleanup_branches --branch manual/T006-install-use-from-existing-project --run
agw_cleanup_branches --branch manual/T006-install-use-from-existing-project --remote --run

git status --short | cat
git branch --list | cat
git branch -r | cat
git log --oneline --decorate -5 | cat
```

## 9. Tag

```bash
agw_create_tag --tag v0.5.0 --note "Add install and external project usage support" --run

git tag --list | cat
git log --oneline --decorate -5 | cat
git ls-remote --tags origin v0.5.0 | cat
```
