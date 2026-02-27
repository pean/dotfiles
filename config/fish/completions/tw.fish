function __tw_complete_repos
    set -l results

    # Show existing tmux sessions (extract repo name from "repo/worktree" format)
    if tmux has-session >/dev/null 2>&1
        tmux list-sessions -F '#S' | grep '/' | sed 's|/.*||'
    end

    # Add directories from ~/src/getdreams that end with .git
    if test -d ~/src/getdreams
        for dir in ~/src/getdreams/*.git/
            if test -d $dir
                set name (basename $dir)
                # Remove .git suffix for completion
                string replace '.git' '' $name
            end
        end
    end | sort -u
end

function __tw_complete_worktrees
    set base_dir ~/src/getdreams
    set repo (commandline -opc)[2]
    set repo_path ""

    if test -z "$repo"
        return
    end

    # Auto-detect: prefer .git suffix (bare repo), fall back to regular repo
    if test -d $base_dir/$repo.git
        set repo_path $base_dir/$repo.git
    else if test -d $base_dir/$repo
        set repo_path $base_dir/$repo
    else
        return
    end

    # Get actual worktrees using git worktree list
    git -C $repo_path worktree list --porcelain 2>/dev/null | \
        grep '^worktree ' | \
        sed 's|^worktree '"$repo_path"'/||'
end

complete \
    --keep-order \
    --no-files \
    --command tw \
    --condition "test (count (commandline -opc)) -eq 1" \
    --arguments "(__tw_complete_repos)"

complete \
    --keep-order \
    --no-files \
    --command tw \
    --condition "test (count (commandline -opc)) -eq 2" \
    --arguments "(__tw_complete_worktrees)"
