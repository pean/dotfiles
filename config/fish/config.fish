set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8

set -x VISUAL "nvim"
set -x EDITOR $VISUAL

if test -d $HOME/src/hemnet/hemnet-terminal-command
  set -x PATH $HOME/src/hemnet/hemnet-terminal-command/bin $PATH
end
set -g fish_user_paths "/usr/local/opt/curl/bin" $fish_user_paths

export PATH="/usr/local/opt/python/libexec/bin:$PATH"
set -g fish_user_paths "/usr/local/opt/postgresql@9.6/bin" $fish_user_paths

export KP_USER_EMAIL=peter.andersson@hemnet.se
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

export GPG_TTY=(tty)

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

set -g fish_user_paths "/usr/local/opt/openssl/bin" $fish_user_paths
set -gx LDFLAGS "-L/usr/local/opt/openssl/lib"
set -gx CPPFLAGS "-I/usr/local/opt/openssl/include"
set -gx PKG_CONFIG_PATH "/usr/local/opt/openssl/lib/pkgconfig"

source (brew --prefix asdf)/libexec/asdf.fish

set fish_greeting

starship init fish | source
