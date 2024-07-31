function muxdev
  if git rev-parse --git-dir >/dev/null 2>&1
    set reponame (basename (git rev-parse --show-toplevel) | sed 's/^\.//')
    tmuxinator start -n $reponame dev
  else
    echo "Not a repo"
  end
end
