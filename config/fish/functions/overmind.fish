# Wrapper around overmind that adds two conveniences:
# 1. Automatically uses Procfile.dev (instead of the default Procfile) when running
#    `overmind start` (or `overmind s`), unless a -f/--procfile flag is already given.
# 2. Auto-loads environment variables from the nearest .overmind.env file found by
#    walking up the directory tree to the git root, exporting each KEY=VALUE pair
#    before delegating to the real overmind binary.
# 3. When inside a git worktree, also loads Rails-style env files from the bare
#    repo root (.env, .env.development, .env.local, .env.development.local).
function overmind --description 'Overmind wrapper that uses Procfile.dev for start command if it exists'
    set -l procfile_dev "Procfile.dev"
    set -l has_f_flag 0
    set -l is_start_command 0
    set -l env_file ""
    set -l debug 0

    # Strip --debug flag before processing
    set -l filtered_argv
    for arg in $argv
        if test "$arg" = "--debug"
            set debug 1
        else
            set filtered_argv $filtered_argv $arg
        end
    end
    set argv $filtered_argv

    # Check if first argument is "start" (or "s")
    if test (count $argv) -gt 0
        if test "$argv[1]" = "start" -o "$argv[1]" = "s"
            set is_start_command 1
        end
    end

    # Check if -f or --procfile flag is already provided
    for arg in $argv
        if test "$arg" = "-f" -o "$arg" = "--procfile"
            set has_f_flag 1
            break
        end
    end

    # Look for .overmind.env by traversing upward until we find it or hit a git root.
    # In a worktree, .git is a file (not a dir) — detect this to find the bare repo root.
    set env_file ""
    set bare_root ""
    set search_dir (pwd)

    test $debug -eq 1; and echo "[overmind debug] pwd: $search_dir"

    while test "$search_dir" != "/"
        test $debug -eq 1; and echo "[overmind debug] checking: $search_dir"

        if test -f $search_dir/.overmind.env
            set env_file $search_dir/.overmind.env
            test $debug -eq 1; and echo "[overmind debug] found .overmind.env: $env_file"
            break
        end

        # Stop at a regular git root (.git directory)
        if test -d $search_dir/.git
            test $debug -eq 1; and echo "[overmind debug] hit .git dir (regular repo root), stopping"
            break
        end

        # In a worktree, .git is a file pointing to the bare repo — use git to find root
        if test -f $search_dir/.git
            set bare_root (git -C $search_dir rev-parse --git-common-dir)
            test $debug -eq 1; and echo "[overmind debug] hit .git file (worktree root), bare root: $bare_root"
            if test -f $bare_root/.overmind.env
                set env_file $bare_root/.overmind.env
                test $debug -eq 1; and echo "[overmind debug] found .overmind.env in bare root: $env_file"
            end
            break
        end

        # Move up one directory
        set search_dir (dirname $search_dir)
    end

    # Load environment variables from .overmind.env if found
    if test -n "$env_file"
        test $debug -eq 1; and echo "[overmind debug] loading .overmind.env: $env_file"
        for line in (cat $env_file)
            # Skip empty lines and comments
            if test -n "$line" -a (string sub -l 1 -- $line) != "#"
                test $debug -eq 1; and echo "[overmind debug]   export: $line"
                set -gx (string split -m 1 "=" -- $line)
            end
        end
    else
        test $debug -eq 1; and echo "[overmind debug] no .overmind.env found"
    end

    # When in a worktree, load Rails-style env files from the bare repo root.
    # Load in ascending priority order so higher-priority files win.
    if test -n "$bare_root"
        test $debug -eq 1; and echo "[overmind debug] checking bare root for Rails env files: $bare_root"
        for rails_env in $bare_root/.env $bare_root/.env.development \
                         $bare_root/.env.local $bare_root/.env.development.local
            if test -f $rails_env
                test $debug -eq 1; and echo "[overmind debug] loading: $rails_env"
                for line in (cat $rails_env)
                    if test -n "$line" -a (string sub -l 1 -- $line) != "#"
                        test $debug -eq 1; and echo "[overmind debug]   export: $line"
                        set -gx (string split -m 1 "=" -- $line)
                    end
                end
            else
                test $debug -eq 1; and echo "[overmind debug] not found: $rails_env"
            end
        end
    else
        test $debug -eq 1; and echo "[overmind debug] not in a worktree, skipping Rails env files"
    end

    # If it's start command, no -f flag provided, and Procfile.dev exists, use it
    if test $is_start_command -eq 1 -a $has_f_flag -eq 0 -a -f $procfile_dev
        echo "🔧 Using Procfile.dev (overmind wrapper active)"
        command overmind $argv -f $procfile_dev
    else
        # Pass through all arguments unchanged to actual overmind
        command overmind $argv
    end
end