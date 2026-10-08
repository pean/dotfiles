set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8

set -x VISUAL "nvim"
set -x EDITOR $VISUAL

set fish_greeting

# macOS defaults to 256 open files. The tmux server inherits this and needs
# one fd per pane, so raise it before anything starts a server.
set -l _nofile (ulimit -n)
if string match -qr '^\d+$' -- $_nofile; and test $_nofile -lt 10240
  ulimit -n 10240
end

eval "$(/opt/homebrew/bin/brew shellenv)"

set -g fish_user_paths "/Users/peter/src/getdreams/dreams-cli/target/release" $fish_user_paths
fish_add_path ~/go/bin
set -g fish_user_path "$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools" $fish_user_paths

starship init fish | source
mise activate fish | source
fzf --fish | source
zoxide init fish | source
atuin init fish  --disable-up-arrow | source

if status is-interactive
  # Workaround for Homebrew tmuxinator issue
  # https://github.com/Homebrew/homebrew-core/issues/59484
  # https://discourse.brew.sh/t/why-does-tmuxinator-sets-gem-home/7296
  set -e GEM_HOME

  # Re-apply the active Catppuccin flavor's fish colors on every shell
  # startup, so stale universal fish_color_* vars (e.g. from a past
  # `fish_config theme choose`) never shadow the current theme.
  set -l _theme_flavor (cat ~/.config/theme 2>/dev/null; or echo mocha)
  functions -q "_theme_apply_fish_$_theme_flavor"; and _theme_apply_fish_$_theme_flavor
end

# Twine aliases
alias tw='twine worktree'
alias ts='twine session'
alias tk='twine kill'
