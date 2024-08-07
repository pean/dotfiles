set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8

set -x VISUAL "nvim"
set -x EDITOR $VISUAL

set -g fish_user_paths "/usr/local/opt/curl/bin" $fish_user_paths
set -g fish_user_paths "/opt/homebrew/bin" $fish_user_paths
set -g fish_user_paths "/opt/homebrew/sbin" $fish_user_paths
set -g fish_user_paths "/opt/homebrew/opt/make/libexec/gnubin" $fish_user_paths

export PATH="/usr/local/opt/python/libexec/bin:$PATH"

export GPG_TTY=(tty)

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

set -g fish_user_paths "/usr/local/opt/openssl/bin" $fish_user_paths
set -gx LDFLAGS "-L/usr/local/opt/openssl/lib"
set -gx CPPFLAGS "-I/usr/local/opt/openssl/include"
set -gx PKG_CONFIG_PATH "/usr/local/opt/openssl/lib/pkgconfig"

# source (brew --prefix asdf)/libexec/asdf.fish

set fish_greeting

starship init fish | source
mise activate fish | source
fzf --fish | source

if status is-interactive
  # Workaround for Homebrew tmuxinator issue
  # https://github.com/Homebrew/homebrew-core/issues/59484
  # https://discourse.brew.sh/t/why-does-tmuxinator-sets-gem-home/7296
  set -e GEM_HOME
end
