#!/usr/bin/env fish
# Ruby LSP wrapper for mise compatibility with fish shell
# This script ensures Ruby LSP uses the correct Ruby version managed by mise

# Ensure mise is in the PATH (sometimes needed in non-interactive shells)
set -x PATH $HOME/.local/bin $PATH

# Let mise handle Ruby version selection based on project's .ruby-version or .mise.toml
mise activate fish | source

# Disable Ruby LSP custom bundle creation (prevents conflicts with mise-managed gems)
set -x RUBY_LSP_DISABLE_BUNDLE_SETUP 1
set -x RUBY_LSP_BUNDLE false

# Force RuboCop usage over StandardRB for consistent linting/formatting
set -x RUBY_LSP_LINTERS rubocop
set -x RUBY_LSP_FORMATTER rubocop
set -x STANDARDRB_DISABLE 1

# Run ruby-lsp with the current directory's Ruby version and pass all arguments
exec ruby-lsp $argv
