# Install ai-git-workflow-tools

## Purpose

Install the workflow functions once and load them from any Git repository.

This project is currently distributed as a Git repository, not as a package manager artifact.

## Recommended layout

Use a stable local clone path:

```bash
mkdir -p ~/src
git clone https://github.com/sagivba/ai-git-workflow-tools.git ~/src/ai-git-workflow-tools
```

If the repository already exists:

```bash
cd ~/src/ai-git-workflow-tools
git switch main
git pull --ff-only origin main
git tag --list
```

## Load for one shell session

From any repository:

```bash
source ~/src/ai-git-workflow-tools/scripts/load-agw.sh
agw_help
```

Verify that the functions are available:

```bash
type agw_start_task
type agw_review_output
type agw_commit_controlled_change
```

## Persistent shell setup

Add this block to `~/.bashrc`:

```bash
if [[ -f "$HOME/src/ai-git-workflow-tools/scripts/load-agw.sh" ]]; then
  source "$HOME/src/ai-git-workflow-tools/scripts/load-agw.sh"
fi
```

Then reload the shell:

```bash
source ~/.bashrc
```

## Version pinning

For conservative use, pin the tools repository to a known tag:

```bash
cd ~/src/ai-git-workflow-tools
git fetch --prune origin
git checkout v0.5.0
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
```

Then open a new shell or source the loader again:

```bash
source ~/src/ai-git-workflow-tools/scripts/load-agw.sh
```

## Uninstall

Remove the clone:

```bash
rm -rf ~/src/ai-git-workflow-tools
```

Also remove any `source .../load-agw.sh` block from `~/.bashrc`.
