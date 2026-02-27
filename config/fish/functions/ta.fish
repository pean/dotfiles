function ta --description 'Attach or switch to tmux session'
    if not tmux list-sessions | grep -q "^$argv:" 2>/dev/null
        echo "Creating new session $argv"
        tmux new-session -d -s $argv
    end

    if set -q TMUX
        echo "Switching to $argv"
        tmux switch-client -t $argv
    else
        echo "Attaching to $argv"
        tmux attach -t $argv
    end
end
