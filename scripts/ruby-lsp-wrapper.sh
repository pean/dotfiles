#!/usr/bin/env fish
# Ruby LSP wrapper for mise compatibility with fish shell

# Ensure mise is in the path
set -x PATH $HOME/.local/bin $PATH

# Let mise handle Ruby version selection  
mise activate fish | source

# Disable Ruby LSP custom bundle creation
set -x RUBY_LSP_DISABLE_BUNDLE_SETUP 1
set -x RUBY_LSP_BUNDLE false

# Force RuboCop usage over StandardRB
set -x RUBY_LSP_LINTERS rubocop
set -x RUBY_LSP_FORMATTER rubocop
set -x STANDARDRB_DISABLE 1

# Run ruby-lsp with the current directory's Ruby version
exec ruby-lsp $argv
