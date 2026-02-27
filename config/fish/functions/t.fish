function t --description 'Switch to tmux session for Dreams repo'
    set base_dir ~/src/getdreams
    set names dreams-$argv $argv

    # Check if any sessions exist
    if tmux has-session >/dev/null 2>&1
        for name in $names
            if tmux list-sessions | grep -q "^$name:" 2>/dev/null
                ta $name
                return
            end
        end
    end

    # Check if this is a Dreams repository
    for name in $names
        if test -d $base_dir/$name
            fish -c "cd $base_dir/$name ; muxdev false"
            ta $name
            return
        end
    end

    # Create normal session
    ta $names[2]
end
