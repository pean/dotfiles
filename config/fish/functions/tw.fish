function tw --description 'Switch to tmux session for a worktree (creates worktree if needed)'
    set base_dir ~/src/getdreams

    if test (count $argv) -lt 1
        echo "Usage: tw <repo> [branch]"
        echo "Creates worktree from remote branch if it doesn't exist"
        return 1
    end

    # Strip .git suffix if provided
    set repo (string replace -r '\.git$' '' $argv[1])

    # Find repo path (.git bare repo or regular repo)
    if test -d $base_dir/$repo.git
        set repo_path $base_dir/$repo.git
    else if test -d $base_dir/$repo
        set repo_path $base_dir/$repo
    else
        echo "Error: Repository '$repo' not found"
        return 1
    end

    # Interactive branch/worktree selection with fzf if not provided
    if test (count $argv) -lt 2
        if not command -v fzf >/dev/null
            echo "Error: fzf required for interactive selection"
            return 1
        end

        # Get existing worktrees (exclude bare repo root)
        set existing_worktrees (git -C $repo_path worktree list --porcelain 2>/dev/null | \
            grep '^worktree ' | \
            sed 's|^worktree '"$repo_path"'/\{0,1\}||' | \
            grep -v '^\s*$')

        # Fetch latest branches with spinner
        echo -n "Fetching branches..."
        git -C $repo_path fetch --quiet 2>/dev/null &
        set fetch_pid $last_pid

        # Show spinner while fetching
        while kill -0 $fetch_pid 2>/dev/null
            echo -n "."
            sleep 0.2
        end
        echo " ✓"

        # Get remote branches
        set remote_branches (git -C $repo_path branch -r 2>/dev/null | \
            sed 's|^[* ]*origin/||' | \
            grep -v '^HEAD')

        # Combine and show in fzf
        set selection (begin
            echo $existing_worktrees | tr ' ' '\n' | sed 's|$| (worktree)|'
            echo $remote_branches | tr ' ' '\n' | sed 's|$| (remote)|'
        end | sort -u | fzf --height=40% --prompt="Select branch for $repo: ")

        if test -z "$selection"
            return 1
        end

        # Remove the label
        set branch (string replace -r ' \(.*\)$' '' $selection)
    else
        set branch $argv[2]
    end

    set worktree_path $repo_path/$branch
    set session_name "$repo/$branch"

    # Create worktree if it doesn't exist
    if not test -d $worktree_path
        echo "Worktree '$branch' doesn't exist, checking for branch..."

        # Check if branch exists on remote
        if git -C $repo_path branch -r 2>/dev/null | grep -q "origin/$branch\$"
            echo "Creating worktree from origin/$branch..."

            # Check if local branch already exists
            if git -C $repo_path branch --list $branch | grep -q "."
                # Local branch exists, use it
                if git -C $repo_path worktree add $branch $branch 2>&1
                    echo "✓ Worktree created: $branch"
                else
                    echo "✗ Failed to create worktree"
                    return 1
                end
            else
                # Local branch doesn't exist, create tracking branch
                if git -C $repo_path worktree add -b $branch $branch origin/$branch 2>&1
                    echo "✓ Worktree created: $branch"
                else
                    echo "✗ Failed to create worktree"
                    return 1
                end
            end
        else
            echo "Error: Branch '$branch' not found on remote"
            echo ""
            echo "Available remote branches:"
            git -C $repo_path branch -r | sed 's|^[* ]*origin/||' | grep -v '^HEAD' | head -10
            return 1
        end
    end

    # Switch to existing session or create new one
    if tmux list-sessions 2>/dev/null | grep -q "^$session_name:"
        if set -q TMUX
            tmux switch-client -t $session_name
        else
            tmux attach -t $session_name
        end
    else
        echo "Creating tmux session: $session_name"
        fish -c "cd $worktree_path && tmuxinator start -n $session_name dev false"

        if set -q TMUX
            tmux switch-client -t $session_name
        else
            tmux attach -t $session_name
        end
    end
end
