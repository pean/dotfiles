#!/opt/homebrew/bin/fish
# Ruby LSP wrapper with compatibility handling

# Ensure mise is available
set -x PATH $HOME/.local/bin $PATH

# Use the project's Ruby version
mise activate fish | source

# Configure Ruby LSP to skip problematic gems that require newer Ruby versions
set -x RUBY_LSP_EXPERIMENTAL_FEATURES "false"

# Debug output
echo "LSP using Ruby: "(which ruby) >&2
echo "LSP Ruby version: "(ruby -v) >&2

# Run ruby-lsp and let it handle bundle conflicts gracefully
exec ruby-lsp $argv
