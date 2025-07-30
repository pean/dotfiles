#!/bin/bash

# =============================================================================
# Neovim LSP Setup Script
# =============================================================================
# This script installs the minimal dependencies needed for a full LSP setup:
# - nvim-lspconfig plugin (the only required plugin)
# - Common language servers for popular programming languages
#
# After running this script, restart Neovim and LSP features will be available
# =============================================================================

echo "Setting up Neovim LSP with minimal dependencies..."

# =============================================================================
# Plugin Installation
# =============================================================================
# Create plugin directory using Neovim's built-in package management
mkdir -p ~/.config/nvim/pack/plugins/start

# Install nvim-lspconfig (the only plugin we need)
# This provides pre-configured setups for various language servers
if [ ! -d ~/.config/nvim/pack/plugins/start/nvim-lspconfig ]; then
    echo "Installing nvim-lspconfig..."
    git clone https://github.com/neovim/nvim-lspconfig ~/.config/nvim/pack/plugins/start/nvim-lspconfig
else
    echo "nvim-lspconfig already installed"
fi

echo ""
echo "============================================================================="
echo "Language Server Installation"
echo "============================================================================="
echo "Installing language servers for common programming languages..."
echo ""

# =============================================================================
# JavaScript/TypeScript Language Servers
# =============================================================================
# Check if npm is available for JS/TS servers
if command -v npm &> /dev/null; then
    echo "Installing TypeScript/JavaScript LSP servers..."
    npm install -g typescript typescript-language-server
    
    echo "Installing additional language servers..."
    npm install -g vscode-langservers-extracted  # for JSON, HTML, CSS, ESLint
    npm install -g pyright  # Python
else
    echo "npm not found. To install JS/TS LSP servers, run:"
    echo "  npm install -g typescript typescript-language-server"
    echo "  npm install -g vscode-langservers-extracted"
    echo "  npm install -g pyright"
fi

# Check if gem is available for Ruby
if command -v gem &> /dev/null; then
    echo "Installing Ruby LSP server..."
    gem install solargraph
else
    echo "gem not found. To install Ruby LSP server, run:"
    echo "  gem install solargraph"
fi

# Check if brew is available for Lua
if command -v brew &> /dev/null; then
    echo "Installing Lua LSP server..."
    brew install lua-language-server
else
    echo "brew not found. To install Lua LSP server:"
    echo "  brew install lua-language-server"
    echo "  or download from: https://github.com/LuaLS/lua-language-server"
fi

echo ""
echo "Setup complete! Restart Neovim and LSP should work."
echo ""
echo "Key bindings:"
echo "  gd      - Go to definition"
echo "  K       - Show hover information"
echo "  <space>rn - Rename symbol"
echo "  <space>ca - Code actions"
echo "  gr      - Show references"
echo "  <space>f - Format document"
echo "  [d      - Previous diagnostic"
echo "  ]d      - Next diagnostic"
