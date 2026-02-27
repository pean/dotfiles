function overmind --description 'Overmind wrapper that uses Procfile.dev for start command if it exists'
    set -l procfile_dev "Procfile.dev"
    set -l has_f_flag 0
    set -l is_start_command 0
    set -l env_file ""

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

    # Look for .overmind.env by traversing upward until we find it or hit a .git directory
    set env_file ""
    set search_dir (pwd)

    while test "$search_dir" != "/"
        if test -f $search_dir/.overmind.env
            set env_file $search_dir/.overmind.env
            break
        end

        # Stop if we hit a .git directory (bare repo root)
        if test -d $search_dir/.git
            break
        end

        # Move up one directory
        set search_dir (dirname $search_dir)
    end

    # Load environment variables from .overmind.env if found
    if test -n "$env_file"
        for line in (cat $env_file)
            # Skip empty lines and comments
            if test -n "$line" -a (string sub -l 1 -- $line) != "#"
                # Export the variable
                set -gx (string split -m 1 "=" -- $line)
            end
        end
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