function tw --description 'Switch to tmux session for a worktree'
    set base_dir ~/src/getdreams

    if test (count $argv) -lt 1
        echo "Usage: tw <repo> [worktree]"
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

    # Interactive worktree selection with fzf if not provided
    if test (count $argv) -lt 2
        if not command -v fzf >/dev/null
            echo "Error: fzf required for interactive selection"
            return 1
        end

        set worktree (git -C $repo_path worktree list --porcelain 2>/dev/null | \
            grep '^worktree ' | \
            sed 's|^worktree '"$repo_path"'/||' | \
            fzf --height=40% --prompt="Select worktree for $repo: ")

        if test -z "$worktree"
            return 1
        end
    else
        set worktree $argv[2]
    end

    set worktree_path $repo_path/$worktree
    set session_name "$repo/$worktree"

    # Verify worktree exists
    if not test -d $worktree_path
        echo "Error: Worktree '$worktree' not found"
        return 1
    end

    # Switch to existing session or create new one
    if tmux list-sessions 2>/dev/null | grep -q "^$session_name:"
        if set -q TMUX
            tmux switch-client -t $session_name
        else
            tmux attach -t $session_name
        end
    else
        cd $worktree_path
        tmuxinator start -n $session_name dev false

        if set -q TMUX
            tmux switch-client -t $session_name
        else
            tmux attach -t $session_name
        end
    end
end
