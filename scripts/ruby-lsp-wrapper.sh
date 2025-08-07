#!/bin/bash

# Ruby LSP wrapper script that handles different Ruby versions via mise
# This ensures the LSP uses the correct Ruby version for each project

set -e

# Get the current working directory (where Neovim is running)
PROJECT_DIR="${PWD}"

# Change to project directory to ensure mise picks up the right versions
cd "${PROJECT_DIR}"

# Check if we have a Gemfile and try bundle exec first
if [ -f "Gemfile" ] && [ -f "Gemfile.lock" ]; then
    if grep -q "ruby-lsp" Gemfile.lock 2>/dev/null; then
        exec bundle exec ruby-lsp "$@"
    fi
fi

# Fall back to mise exec (which respects .ruby-version, .mise.toml, etc.)
if command -v mise >/dev/null 2>&1; then
    # Check if ruby-lsp gem is available in the project's ruby version
    if mise exec -- ruby -e "require 'ruby-lsp'" 2>/dev/null; then
        exec mise exec -- ruby-lsp "$@"
    else
        # Try to install ruby-lsp if it's missing
        echo "ruby-lsp gem not found, attempting to install..." >&2
        mise exec -- gem install ruby-lsp --no-document 2>/dev/null || true
        exec mise exec -- ruby-lsp "$@"
    fi
fi

# Final fallback to system ruby-lsp
if command -v ruby-lsp >/dev/null 2>&1; then
    exec ruby-lsp "$@"
else
    echo "Error: ruby-lsp not found. Please install ruby-lsp gem." >&2
    exit 1
fi