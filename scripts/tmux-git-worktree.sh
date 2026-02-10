#!/bin/bash
# Display git worktree information for tmux status bar

cd "$1" 2>/dev/null || exit 0

# Check if we're in a git repo
git rev-parse --git-dir > /dev/null 2>&1 || exit 0

# Get common git dir (where the actual .git directory is)
common_dir=$(git rev-parse --git-common-dir 2>/dev/null)

# If common dir is just .git, we're in the main worktree
if [ "$common_dir" = ".git" ] || [ "$common_dir" = "$(git rev-parse --git-dir)" ]; then
    # Main repository - show git icon
    echo "[M] "
    exit 0
fi

# We're in a worktree - get relative path
worktree_path=$(git rev-parse --show-toplevel)
main_repo_path=$(cd "$common_dir/../.." && pwd)
worktree_name=$(basename "$worktree_path")

# Calculate relative path from main repo to worktree
if command -v python3 > /dev/null 2>&1; then
    rel_path=$(python3 -c "import os.path; print(os.path.relpath('$worktree_path', '$main_repo_path'))")
else
    # Fallback to just showing the worktree name
    rel_path="$worktree_name"
fi

# Output with code fork icon
echo "[WT] $rel_path"
