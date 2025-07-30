-- =============================================================================
-- Neovim Configuration with Built-in LSP
-- =============================================================================
-- This configuration provides a complete LSP setup using mostly standard
-- Neovim features with minimal external dependencies. Only requires nvim-lspconfig.
-- 
-- Features included:
-- - Built-in LSP client with comprehensive language support
-- - Auto-formatting on save (toggleable)
-- - Diagnostic display with custom signs
-- - Code completion using built-in omnifunc
-- - File exploration using built-in netrw
-- =============================================================================

-- Basic Editor Settings
-- =============================================================================
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smarttab = true
vim.opt.shiftround = true
vim.opt.autoindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.showmatch = true
vim.opt.hidden = true
vim.opt.nowrap = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.colorcolumn = '100'
vim.opt.list = true
vim.opt.listchars = { tab = '>.', trail = '.', extends = '#', nbsp = '.' }
vim.opt.laststatus = 2

-- Leader Key Configuration
-- =============================================================================
vim.g.mapleader = ','

-- LSP Configuration
-- =============================================================================
local lsp = vim.lsp
local api = vim.api

-- LSP On-Attach Function
-- =============================================================================
-- This function is called whenever an LSP server attaches to a buffer.
-- It sets up all the keybindings and auto-formatting for that buffer.
-- =============================================================================
local function on_attach(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  
  -- Core LSP Navigation and Information Keybindings
  -- These provide the main IDE-like features
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)           -- Go to definition
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                  -- Show hover information
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)        -- Go to implementation
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)     -- Show function signature
  
  -- Workspace Management (for multi-root projects)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)    -- Add workspace folder
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts) -- Remove workspace folder
  vim.keymap.set('n', '<space>wl', function()                                 -- List workspace folders
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  
  -- Code Intelligence and Refactoring
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)  -- Go to type definition
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)          -- Rename symbol
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)     -- Show code actions
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)             -- Show references
  vim.keymap.set('n', '<space>f', function()                          -- Format document
    vim.lsp.buf.format { async = true }
  end, opts)
  
  -- Diagnostic Navigation and Display
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)    -- Show diagnostic in floating window
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)           -- Go to previous diagnostic
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)           -- Go to next diagnostic
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)    -- Add diagnostics to location list
  
  -- Auto-format on Save Configuration
  -- Only enable if the language server supports formatting and auto-format is enabled
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        if vim.g.autoformat_enabled then
          vim.lsp.buf.format { async = false }  -- Synchronous to ensure formatting before save
        end
      end,
    })
  end
end

-- Diagnostic Display Configuration
-- =============================================================================
vim.diagnostic.config({
  virtual_text = true,        -- Show diagnostics as virtual text at end of line
  signs = true,              -- Show diagnostic signs in the sign column
  underline = true,          -- Underline diagnostic text
  update_in_insert = false,  -- Don't update diagnostics while in insert mode
  severity_sort = false,     -- Don't sort diagnostics by severity
})

-- Custom Diagnostic Signs
-- Replace default diagnostic signs with custom icons for better visibility
local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "»" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- LSP Server Installation and Configuration
-- =============================================================================
-- Check if nvim-lspconfig is installed, show helpful message if not
local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
if not lspconfig_ok then
  print("nvim-lspconfig not found. Install with: git clone https://github.com/neovim/nvim-lspconfig ~/.config/nvim/pack/plugins/start/nvim-lspconfig")
  return
end

-- Language Server Configurations
-- =============================================================================

-- TypeScript/JavaScript Language Server
-- Provides IntelliSense, error checking, and refactoring for JS/TS projects
lspconfig.tsserver.setup({
  on_attach = on_attach,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
})

-- Ruby Language Server (Solargraph)
-- Provides code completion, documentation, and type checking for Ruby
lspconfig.solargraph.setup({
  on_attach = on_attach,
})

-- Python Language Server (Pyright)
-- Microsoft's Python language server with excellent type checking
lspconfig.pyright.setup({
  on_attach = on_attach,
})

-- Lua Language Server
-- Specially configured for Neovim development with vim globals recognized
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',  -- Use LuaJIT for Neovim
      },
      diagnostics = {
        globals = {'vim'},   -- Recognize 'vim' global for Neovim config
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),  -- Include Neovim runtime files
      },
      telemetry = {
        enable = false,      -- Disable telemetry for privacy
      },
    },
  },
})

-- Completion Configuration
-- =============================================================================
-- Set up built-in completion to work with LSP
vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'  -- Use LSP for omni-completion

-- Trigger completion with Ctrl+Space in insert mode
vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { noremap = true })

-- File Explorer Configuration (Built-in Netrw)
-- =============================================================================
-- Configure netrw to work like a modern file explorer
vim.g.netrw_banner = 0        -- Disable banner for cleaner look
vim.g.netrw_liststyle = 3     -- Tree view
vim.g.netrw_browse_split = 4  -- Open files in previous window
vim.g.netrw_altv = 1          -- Open splits to the right
vim.g.netrw_winsize = 25      -- Set width to 25% of screen
vim.keymap.set('n', '<Leader>d', ':Lexplore<CR>', { noremap = true })  -- Toggle file explorer

-- Basic Search and File Navigation
-- =============================================================================
vim.keymap.set('n', '<Leader>f', ':find ', { noremap = true })    -- Find files
vim.keymap.set('n', '<Leader>g', ':grep -r ', { noremap = true }) -- Grep search

-- Advanced Formatting Configuration
-- =============================================================================

-- Auto-format Toggle
-- Enable auto-formatting by default, but allow users to toggle it
vim.g.autoformat_enabled = true
vim.keymap.set('n', '<leader>af', function()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  print("Auto-format on save: " .. (vim.g.autoformat_enabled and "enabled" or "disabled"))
end, { noremap = true, desc = "Toggle auto-format on save" })

-- Visual Mode Formatting
-- Allow formatting of selected text in visual mode
vim.keymap.set('v', '<space>f', function()
  vim.lsp.buf.format { async = true }
end, { noremap = true })

-- Built-in Auto-Indentation
-- Configure Neovim's built-in indentation features for better code formatting
vim.opt.autoindent = true   -- Copy indent from current line when starting new line
vim.opt.smartindent = true  -- Smart autoindenting for C-like languages
vim.opt.cindent = true      -- Stricter rules for C-style indentation
