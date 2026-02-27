function __tw_complete_repos
    # Show existing tmux sessions (extract repo name from "repo/worktree" format)
    if tmux has-session >/dev/null 2>&1
        tmux list-sessions -F '#S' | grep '/' | sed 's|/.*||' | sort -u
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
    end
end

function __tw_complete_branches
    set base_dir ~/src/getdreams
    set repo (commandline -opc)[2]
    set repo_path ""

    if test -z "$repo"
        return
    end

    # Strip .git suffix
    set repo (string replace -r '\.git$' '' $repo)

    # Auto-detect: prefer .git suffix (bare repo), fall back to regular repo
    if test -d $base_dir/$repo.git
        set repo_path $base_dir/$repo.git
    else if test -d $base_dir/$repo
        set repo_path $base_dir/$repo
    else
        return
    end

    # Get existing worktrees (exclude bare repo root)
    set existing_worktrees (git -C $repo_path worktree list --porcelain 2>/dev/null | \
        grep '^worktree ' | \
        sed 's|^worktree '"$repo_path"'/\{0,1\}||' | \
        grep -v '^\s*$')

    # Get remote branches (works for both bare and regular repos now)
    set remote_branches (git -C $repo_path branch -r 2>/dev/null | \
        sed 's|^[* ]*origin/||' | \
        grep -v '^HEAD')

    # Output existing worktrees with label
    for wt in $existing_worktrees
        echo -e "$wt\tworktree"
    end

    # Output remote branches (excluding those with worktrees) with label
    for branch in $remote_branches
        if not contains $branch $existing_worktrees
            echo -e "$branch\tremote"
        end
    end
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
    --arguments "(__tw_complete_branches)"
