set -xg VISUAL "nvim"
set -xg EDITOR $VISUAL

if which rbenv
  set -xg PATH $HOME/.rbenv/bin
  eval (rbenv init -)
end
