vim.g.mapleader = ","

vim.keymap.set("n", "<leader>n", ":noh<CR>")
vim.keymap.set("n", "<leader>cn", ":cnext<CR>")
vim.keymap.set("n", "<leader>bd", ":%bd!<CR>")

vim.opt.clipboard = "unnamed" -- interact with system clipboard
vim.opt.colorcolumn = { 80, 100, 120 }
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.list = true -- show whitespace and some special characters
vim.opt.listchars = { tab = ">-", trail = "-", extends = ">" }
vim.opt.number = true -- show line numbers
vim.opt.shiftwidth = 2 -- indentation level
vim.opt.tabstop = 2 -- tab width
vim.opt.whichwrap:append("<,>,h,l,[,]")
vim.opt.wrap = false -- do not wrap lines

vim.api.nvim_set_hl(0, "ColorColumn", { link = "StatusLine" })

vim.opt.termguicolors = true

-- vim.opt.cmdheight = 0

require("config.code-stats")
require("config.cursorline")

require("config.lazy")

-- vim.cmd.colorscheme(dracula_pro")
vim.cmd.colorscheme("catppuccin")

-- =============================================================================
-- LSP Configuration
-- =============================================================================

-- LSP On-Attach Function - sets up keybindings when LSP attaches to buffer
local function on_attach(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  
  -- Core LSP keybindings
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)           -- Go to definition
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                  -- Show hover info
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)        -- Go to implementation
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)     -- Show signature
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)          -- Rename symbol
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)     -- Show code actions
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)             -- Show references
  vim.keymap.set('n', '<space>f', function()                          -- Format document
    vim.lsp.buf.format { async = true }
  end, opts)
  
  -- Diagnostic navigation
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)    -- Show diagnostic
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)           -- Previous diagnostic
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)           -- Next diagnostic
  
  -- Auto-format on save (if enabled)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        if vim.g.autoformat_enabled then
          vim.lsp.buf.format { async = false }
        end
      end,
    })
  end
end

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Custom diagnostic signs
local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "»" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- LSP server setup (requires nvim-lspconfig)
local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
if not lspconfig_ok then
  print("nvim-lspconfig not found. Run ./setup-lsp.sh to install.")
  return
end

-- Language servers
lspconfig.tsserver.setup({ on_attach = on_attach })  -- TypeScript/JavaScript
lspconfig.solargraph.setup({ on_attach = on_attach }) -- Ruby
lspconfig.pyright.setup({ on_attach = on_attach })    -- Python
lspconfig.lua_ls.setup({                               -- Lua
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = {'vim'} },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    },
  },
})

-- LSP completion and formatting
vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'
vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { noremap = true })

-- Auto-format toggle
vim.g.autoformat_enabled = true
vim.keymap.set('n', '<leader>af', function()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  print("Auto-format on save: " .. (vim.g.autoformat_enabled and "enabled" or "disabled"))
end, { noremap = true })
