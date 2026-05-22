# Install ai-git-workflow-tools

## Purpose

Install `ai-git-workflow-tools` once and load its `agw_*` functions from this repository or from any other Git repository.

The project is distributed as a Git repository, not as a package manager artifact.

## Recommended central clone layout

```bash
mkdir -p ~/src
git clone https://github.com/sagivba/ai-git-workflow-tools.git ~/src/ai-git-workflow-tools
```

If the clone already exists:

```bash
cd ~/src/ai-git-workflow-tools
git switch main
git pull --ff-only origin main
git tag --list | cat
```

## Load for one shell session

From any Git repository:

```bash
source ~/src/ai-git-workflow-tools/scripts/load-agw.sh
agw_version
agw_status
```

Expected behavior:

- `agw_version` shows the loaded tool version, script path, tool root, and Git ref when available.
- `agw_status` shows the current repository root, current branch, current HEAD, and short Git status.

## Persistent shell setup

Add this block to `~/.bashrc`:

```bash
if [[ -f "$HOME/src/ai-git-workflow-tools/scripts/load-agw.sh" ]]; then
  source "$HOME/src/ai-git-workflow-tools/scripts/load-agw.sh"
fi
```

Reload the shell:

```bash
source ~/.bashrc
agw_version
```

## Version pinning

For conservative use, pin the tools repository to a known stable tag:

```bash
cd ~/src/ai-git-workflow-tools
git fetch --prune origin --tags
git checkout v0.6.0
agw_version
```

To return to active development:

```bash
git switch main
git pull --ff-only origin main
```

## Upgrade

```bash
cd ~/src/ai-git-workflow-tools
git switch main
git pull --ff-only origin main
make test
make check-docs
```

Then source the loader again:

```bash
source ~/src/ai-git-workflow-tools/scripts/load-agw.sh
agw_version
```

## Use when copied into a project

If the tool is copied into another repository, use this layout:

```text
tools/ai-git-workflow-tools/scripts/
```

From the host project root:

```bash
source tools/ai-git-workflow-tools/scripts/load-agw.sh
agw_version
agw_status
```

If only the main script is available:

```bash
source tools/ai-git-workflow-tools/scripts/ai-git-workflows.sh
agw_version
agw_status
```

## Use as a submodule

```bash
git submodule add https://github.com/sagivba/ai-git-workflow-tools.git tools/ai-git-workflow-tools
git submodule update --init --recursive
source tools/ai-git-workflow-tools/scripts/load-agw.sh
agw_status
```

## Uninstall

Remove the central clone:

```bash
rm -rf ~/src/ai-git-workflow-tools
```

Also remove any `source .../load-agw.sh` block from `~/.bashrc`.

## Related documents

- `docs/use-from-existing-project.md`
- `docs/integration/use-in-existing-project.md`
- `docs/workflows/README.md`
