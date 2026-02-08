#!/bin/bash
# Shared library for git hooks
# Provides common functions used by multiple hooks

# Function: resolve_path
# Purpose: Resolve symbolic links to their true path (portable for macOS and Linux)
# Strategy: Follow symlink chain with depth limit to prevent infinite loops
# Returns: The resolved absolute path
resolve_path() {
  local target="$1"
  local dir
  local depth=0
  local max_depth=10
  
  while [ -L "$target" ] && [ $depth -lt $max_depth ]; do
    depth=$((depth + 1))
    dir=$(dirname -- "$target")
    target=$(readlink -- "$target")
    [ "${target#/}" = "$target" ] && target="$dir/$target"
  done
  
  # Check if we hit the depth limit while still a symlink
  if [ -L "$target" ]; then
    echo "Error: Maximum symlink depth reached for $1" >&2
    return 1
  fi
  
  # Normalize to absolute path
  if [ -e "$target" ]; then
    echo "$(cd "$(dirname -- "$target")" && pwd)/$(basename -- "$target")"
  else
    echo "$target"
  fi
}

# Function: get_repo_root
# Purpose: Determine the ollama-git-tools repository root directory
# Strategy: 
#   1. Prioritize symbolic link resolution (supports cross-project invocation)
#   2. Fallback to git rev-parse (works when directly in a git repository)
# Returns: 0 on success, 1 on failure
# Output: REPO_ROOT variable set to the repository root path

get_repo_root() {
  local hook_dir="${1:-$(dirname -- "$(resolve_path "$0")")}"
  REPO_ROOT="$(cd "$hook_dir/.." && pwd)"
  
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
