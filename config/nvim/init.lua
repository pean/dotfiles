vim.g.mapleader = ","

vim.keymap.set("n", "<leader>n", ":noh<CR>")
vim.keymap.set("n", "<leader>cn", ":cnext<CR>")
vim.keymap.set("n", "<leader>bd", ":%bd!<CR>")

vim.opt.clipboard = "unnamed" -- interact with system clipboard

-- https://blog.glyph.im/2025/08/the-best-line-length.html
-- Visual guide at 88 columns but no automatic wrapping
vim.opt.colorcolumn = { 88 }

-- Disable automatic text wrapping, let LSP handle formatting
vim.opt.textwidth = 0 -- Disable textwidth-based wrapping
vim.opt.formatoptions = "jqrol" -- Keep comment continuation and long line behavior
-- j: remove comment leader when joining lines
-- q: allow formatting with gq
-- r: continue comments when pressing Enter
-- o: continue comments with o and O
-- l: don't break lines that are already long

-- Indentation settings (Treesitter handles smart indentation)
vim.opt.expandtab = true  -- use spaces instead of tabs
vim.opt.tabstop = 2       -- tab width
vim.opt.softtabstop = 2   -- number of spaces tab counts for while editing
vim.opt.shiftwidth = 2    -- indentation level
vim.opt.autoindent = true -- copy indent from current line when starting new line
vim.opt.shiftround = true -- round indent to multiple of shiftwidth
-- Note: smartindent and cindent disabled to avoid conflicts with Treesitter

vim.opt.list = true   -- show whitespace and some special characters
vim.opt.listchars = { tab = ">-", trail = "-", extends = ">" }
vim.opt.number = true -- show line numbers
vim.opt.whichwrap:append("<,>,h,l,[,]")
vim.opt.wrap = false  -- do not wrap lines

vim.api.nvim_set_hl(0, "ColorColumn", { link = "StatusLine" })

vim.opt.termguicolors = true

-- Enable filetype detection and plugins for proper indentation
vim.cmd("filetype plugin indent on")

require("config.code-stats")
require("config.cursorline")

require("config.lazy")

vim.cmd.colorscheme("catppuccin")
