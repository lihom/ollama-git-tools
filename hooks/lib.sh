#!/bin/bash
# Shared library for git hooks
# Provides common functions used by multiple hooks

# Function: get_repo_root
# Purpose: Determine the ollama-git-tools repository root directory
# Strategy: 
#   1. Prioritize symbolic link resolution (supports cross-project invocation)
#   2. Fallback to git rev-parse (works when directly in a git repository)
# Returns: 0 on success, 1 on failure
# Output: REPO_ROOT variable set to the repository root path

get_repo_root() {
  local hook_file_real
  
  # Step 1: Try symbolic link resolution
  # This works regardless of which project is calling the hook
  hook_file_real="$(readlink -f "$0")"
  REPO_ROOT="$(dirname "$(dirname "$hook_file_real")")"
  
  # Verify the scripts directory exists
  if [[ -n "$REPO_ROOT" ]] && [[ -d "$REPO_ROOT/scripts" ]]; then
    return 0
  fi
  
  # Step 2: Fallback to git rev-parse
  # This only works if executed directly within a git repository
  REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
  
  if [[ -n "$REPO_ROOT" ]] && [[ -d "$REPO_ROOT/scripts" ]]; then
    return 0
  fi
  
  # Step 3: Error - could not determine repository root
  echo "❌ Error: Cannot find ollama-git-tools repository root" >&2
  echo "   Attempted REPO_ROOT=$REPO_ROOT" >&2
  echo "   hook_file_real=$hook_file_real" >&2
  return 1
}
