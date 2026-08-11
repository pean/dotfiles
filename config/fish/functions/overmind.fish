# Wrapper around overmind that adds conveniences:
# 1. Automatically uses Procfile.dev (instead of the default Procfile) when running
#    `overmind start` (or `overmind s`), unless a -f/--procfile flag is already given.
#    Traverses up the directory tree to find Procfile.dev; falls back to local Procfile
#    only if no Procfile.dev was found anywhere.
# 2. Auto-loads environment variables from the nearest .overmind.env file found by
#    walking up the directory tree to the git root, exporting each KEY=VALUE pair
#    before delegating to the real overmind binary. Always prints which file(s) are loaded.
# 3. When inside a git worktree, also loads Rails-style env files from the bare
#    repo root (.env, .env.development, .env.local, .env.development.local).
function overmind --description 'Overmind wrapper that uses Procfile.dev for start command if it exists'
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

    # Traverse up the directory tree to find .overmind.env and (when starting) Procfile.dev.
    # .overmind.env search stops at the git root. Procfile.dev search continues past it.
    # In a worktree, .git is a file (not a dir) — detect this to find the bare repo root.
    set env_file ""
    set bare_root ""
    set procfile_dev_path ""
    set search_dir (pwd)
    set git_root_found 0

    test $debug -eq 1; and echo "[overmind debug] pwd: $search_dir"

    while test "$search_dir" != "/"
        test $debug -eq 1; and echo "[overmind debug] checking: $search_dir"

        if test $git_root_found -eq 0 -a -z "$env_file" -a -f $search_dir/.overmind.env
            set env_file $search_dir/.overmind.env
            test $debug -eq 1; and echo "[overmind debug] found .overmind.env: $env_file"
        end

        if test $is_start_command -eq 1 -a -z "$procfile_dev_path" -a -f $search_dir/Procfile.dev
            set procfile_dev_path $search_dir/Procfile.dev
            test $debug -eq 1; and echo "[overmind debug] found Procfile.dev: $procfile_dev_path"
        end

        # Track git root for .overmind.env boundary, but keep walking for Procfile.dev
        if test $git_root_found -eq 0 -a -d $search_dir/.git
            test $debug -eq 1; and echo "[overmind debug] hit .git dir (regular repo root)"
            set git_root_found 1
        end

        if test $git_root_found -eq 0 -a -f $search_dir/.git
            set bare_root (git -C $search_dir rev-parse --git-common-dir)
            test $debug -eq 1; and echo "[overmind debug] hit .git file (worktree root), bare root: $bare_root"
            if test -f $bare_root/.overmind.env
                set env_file $bare_root/.overmind.env
                test $debug -eq 1; and echo "[overmind debug] found .overmind.env in bare root: $env_file"
            end
            set git_root_found 1
        end

        # Stop once we've found Procfile.dev (env search already bounded by git_root_found)
        if test -n "$procfile_dev_path"
            break
        end

        # Move up one directory
        set search_dir (dirname $search_dir)
    end

    # Load environment variables from .overmind.env if found
    if test -n "$env_file"
        echo "[overmind] Loading env from $env_file"
        for line in (cat $env_file)
            # Skip empty lines and comments
            if test -n "$line" -a (string sub -l 1 -- $line) != "#"
                set -l key (string split -m 1 "=" -- $line)[1]
                echo "[overmind]   $key"
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
                echo "[overmind] Loading env from $rails_env"
                for line in (cat $rails_env)
                    if test -n "$line" -a (string sub -l 1 -- $line) != "#"
                        and string match -q "*=*" -- $line
                        set -l parts (string split -m 1 "=" -- $line)
                        set -l key (string trim -- $parts[1])
                        echo "[overmind]   $key"
                        set -gx $key $parts[2]
                    end
                end
            else
                test $debug -eq 1; and echo "[overmind debug] not found: $rails_env"
            end
        end
    else
        test $debug -eq 1; and echo "[overmind debug] not in a worktree, skipping Rails env files"
    end

    # If it's a start command with no explicit -f flag, pick the best Procfile
    if test $is_start_command -eq 1 -a $has_f_flag -eq 0
        if test -n "$procfile_dev_path"
            echo "[overmind] Using $procfile_dev_path"
            command overmind $argv -f $procfile_dev_path -d (pwd)
        else
            # No Procfile.dev found anywhere — let overmind use its default (Procfile)
            command overmind $argv
        end
    else
        command overmind $argv
    end
end