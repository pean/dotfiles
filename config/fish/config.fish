set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8

set -x VISUAL "nvim"
set -x EDITOR $VISUAL

set fish_greeting

eval "$(/opt/homebrew/bin/brew shellenv)"

set -g fish_user_paths "/Users/peter/src/getdreams/dreams-cli/target/release" $fish_user_paths
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
end

alias claude="/Users/peter/.claude/local/claude"
