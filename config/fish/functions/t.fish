function ta
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

function t
  set base_dir ~/src/getdreams
  set names dreams-$argv $argv

  # Check if any of the sessions exist
  if tmux has-session >/dev/null 2>&1
    for name in $names
      echo "Checking $name"
      if tmux list-sessions | grep -q "^$name:" 2>/dev/null
        echo "Attaching/Switching existing to $name"
        ta $name
        return
      else
        echo "No session found with name $name"
      end
    end
  else
    echo "No tmux server found"
  end

  # Check if this is a dreams repository
  for name in $names
    if test -d $base_dir/$name
      echo "Creating muxdev to for $name"
      fish -c "cd $base_dir/$name ; muxdev false"

      # Attach or switching session
      echo "Attaching/Switching to $name"
      ta $name
      return
    else
      echo "No directory found for $name"
    end
  end

  echo "Trying normal session for $names[2]"
  ta $names[2]
end
