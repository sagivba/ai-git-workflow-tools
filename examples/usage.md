# Usage examples

## Load functions

```bash
source scripts/ai-git-workflows.sh
```

## Show help

```bash
agw_help
agw_start_codex_task --help
```

## Start a Codex task in dry-run mode

```bash
agw_start_codex_task --branch codex-cli/example-task
```

## Start a Codex task for real

```bash
agw_start_codex_task --branch codex-cli/example-task --run
```

## Create a tag in dry-run mode

```bash
agw_create_tag --tag v1.0.0 --note "Initial stable workflow baseline"
```

## Create a tag for real

```bash
agw_create_tag --tag v1.0.0 --note "Initial stable workflow baseline" --run
```
