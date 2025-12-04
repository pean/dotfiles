function overmind --description 'Overmind wrapper that uses Procfile.dev for start command if it exists'
    set -l procfile_dev "Procfile.dev"
    set -l has_f_flag 0
    set -l is_start_command 0

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

    # If it's start command, no -f flag provided, and Procfile.dev exists, use it
    if test $is_start_command -eq 1 -a $has_f_flag -eq 0 -a -f $procfile_dev
        echo "🔧 Using Procfile.dev (overmind wrapper active)"
        command overmind $argv -f $procfile_dev
    else
        # Pass through all arguments unchanged to actual overmind
        command overmind $argv
    end
end