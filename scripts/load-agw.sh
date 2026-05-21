#!/usr/bin/env bash
# Load ai-git-workflow-tools functions into the current shell.
#
# Usage:
#   source /path/to/ai-git-workflow-tools/scripts/load-agw.sh
#
# This file is intentionally a thin loader. It must be sourced, not executed,
# because Bash functions need to be loaded into the caller's shell.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "Error: load-agw.sh must be sourced, not executed." >&2
  echo "Usage: source /path/to/ai-git-workflow-tools/scripts/load-agw.sh" >&2
  exit 2
fi

_agw_loader_path="${BASH_SOURCE[0]}"
_agw_scripts_dir="$(cd "$(dirname "$_agw_loader_path")" && pwd)"
_agw_main_script="$_agw_scripts_dir/ai-git-workflows.sh"
_agw_tool_root="$(cd "$_agw_scripts_dir/.." && pwd)"

if [[ ! -f "$_agw_main_script" ]]; then
  echo "Error: ai-git-workflows.sh not found next to load-agw.sh." >&2
  return 1
fi

export AGW_TOOL_ROOT="$_agw_tool_root"

# shellcheck source=scripts/ai-git-workflows.sh
source "$_agw_main_script"

unset _agw_loader_path
unset _agw_scripts_dir
unset _agw_main_script
unset _agw_tool_root
