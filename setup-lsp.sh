#!/bin/bash

# =============================================================================
# Neovim LSP Setup Script with Mason
# =============================================================================
# This script sets up a modern LSP configuration using Mason for automatic
# language server management. Mason will handle downloading and installing
# language servers automatically.
#
# Setup includes:
# - Mason + mason-lspconfig + nvim-lspconfig (via lazy.nvim)
# - Automatic installation of TypeScript, Ruby, Python, and Lua servers
# - No manual server installation required!
# =============================================================================

echo "Setting up Neovim LSP with Mason (modern automatic setup)..."

echo ""
echo "============================================================================="
echo "Setup Instructions"
echo "============================================================================="
echo ""
echo "1. The LSP configuration is now managed through lazy.nvim plugins"
echo "2. Mason will automatically install language servers when you start Neovim"
echo "3. No manual installation required!"
echo ""
echo "To complete setup:"
echo "  1. Start Neovim"
echo "  2. Run :Lazy sync    (to install/update plugins)"
echo "  3. Run :Mason        (to see installed servers)"
echo ""
echo "Language servers that will be auto-installed:"
echo "  - ts_ls        (TypeScript/JavaScript)"
echo "  - ruby_lsp     (Ruby)"
echo "  - lua_ls       (Lua)"
echo "  - rust_analyzer (Rust)"
echo "  - cssls        (CSS)"
echo "  - html         (HTML)"
echo "  - jsonls       (JSON)"
echo "  - yamlls       (YAML)"
echo ""
echo "============================================================================="
echo "LSP Key Bindings"
echo "============================================================================="
echo "  gd         - Go to definition"
echo "  K          - Show hover information"
echo "  gi         - Go to implementation"
echo "  <C-k>      - Show signature help"
echo "  <space>rn  - Rename symbol"
echo "  <space>ca  - Code actions"
echo "  gr         - Show references"
echo "  <space>f   - Format document"
echo "  <space>e   - Show diagnostic"
echo "  [d         - Previous diagnostic"
echo "  ]d         - Next diagnostic"
echo "  <leader>af - Toggle auto-format on save"
echo "  <C-Space>  - Trigger completion (insert mode)"
echo ""
echo "============================================================================="
echo "Manual Installation (if auto-install fails)"
echo "============================================================================="
echo "If Mason fails to install servers, you can install manually:"
echo ""
echo "TypeScript/JavaScript:"
echo "  npm install -g typescript typescript-language-server"
echo ""
echo "Ruby:"
echo "  gem install ruby-lsp"
echo ""
echo "Lua:"
echo "  brew install lua-language-server"
echo ""
echo "Rust:"
echo "  rustup component add rust-analyzer"
echo ""
echo "Web languages (CSS, HTML, JSON):"
echo "  npm install -g vscode-langservers-extracted"
echo ""
echo "YAML:"
echo "  npm install -g yaml-language-server"
echo ""
echo "Setup complete! Start Neovim to begin using LSP features."
