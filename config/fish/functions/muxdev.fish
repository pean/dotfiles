function muxdev
  if git rev-parse --git-dir >/dev/null 2>&1
    set reponame (basename -s .git (git config --get remote.origin.url))
    tmuxinator start -n $reponame dev
  else
    echo "Not a repo"
  end
end
