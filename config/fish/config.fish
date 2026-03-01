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

# Twig config
# Base directories to search for repositories
set -gx TWINE_BASE_DIRS ~/src/getdreams ~/src/pean

# Tmuxinator layout to use (if tmuxinator is installed)
set -gx TWINE_TMUXINATOR_LAYOUT dev

# Session name prefix (e.g., "work-" for "work-repo/branch")
set -gx TWINE_SESSION_PREFIX ""

# Control tmuxinator usage: auto (default), true, or false
set -gx TWINE_USE_TMUXINATOR auto

# Load Twine plugin from local directory (for testing)
set -l twine_dir ~/src/pean/twine
if test -d $twine_dir
    set -p fish_function_path $twine_dir/functions
    set fish_complete_path $twine_dir/completions $fish_complete_path
    source $twine_dir/conf.d/twine.fish
end
