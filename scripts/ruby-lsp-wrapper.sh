#!/usr/bin/env fish
# Ruby LSP wrapper for mise compatibility

# Let mise handle Ruby version selection  
mise activate fish | source

# Run ruby-lsp with the current directory's Ruby version
exec ruby-lsp $argv
