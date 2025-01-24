function __t_complete_t
  if tmux has-session >/dev/null 2>&1
    tmux list-sessions -F '#S'
  else
  end

  # Add directories from ~/src/getdreams
  if test -d ~/src/getdreams
    for dir in ~/src/getdreams/*/
      echo (basename $dir)
    end
  end
end

complete \
  --keep-order \
  --no-files \
  --command t \
  --arguments "(__t_complete_t)"
