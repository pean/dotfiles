set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8

set -x VISUAL "nvim"
set -x EDITOR $VISUAL

if [ (which rbenv) ]
  set -x PATH $HOME/.rbenv/shims $PATH
  rbenv init - | source
end

if test -d $HOME/hemnet/src/hemnet-terminal-command
  set -x PATH $HOME/hemnet/src/hemnet-terminal-command/bin $PATH
end
