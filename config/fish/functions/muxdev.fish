function muxdev
  if git rev-parse --git-dir >/dev/null 2>&1
    set reponame (basename (git rev-parse --show-toplevel) | sed 's/^\.//')
    echo "Starting tmuxinator for $reponame in $pwd"
    tmuxinator start -n $reponame dev $argv
  else
    echo "Not a repo"
  end
end
