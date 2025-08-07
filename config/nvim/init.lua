vim.g.mapleader = ","

vim.keymap.set("n", "<leader>n", ":noh<CR>")
vim.keymap.set("n", "<leader>cn", ":cnext<CR>")
vim.keymap.set("n", "<leader>bd", ":%bd!<CR>")

vim.opt.clipboard = "unnamed" -- interact with system clipboard
vim.opt.colorcolumn = { 80, 100, 120 }

-- Indentation settings (Treesitter handles smart indentation)
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.tabstop = 2 -- tab width
vim.opt.softtabstop = 2 -- number of spaces tab counts for while editing
vim.opt.shiftwidth = 2 -- indentation level
vim.opt.autoindent = true -- copy indent from current line when starting new line
vim.opt.shiftround = true -- round indent to multiple of shiftwidth
-- Note: smartindent and cindent disabled to avoid conflicts with Treesitter

vim.opt.list = true -- show whitespace and some special characters
vim.opt.listchars = { tab = ">-", trail = "-", extends = ">" }
vim.opt.number = true -- show line numbers
vim.opt.whichwrap:append("<,>,h,l,[,]")
vim.opt.wrap = false -- do not wrap lines

vim.api.nvim_set_hl(0, "ColorColumn", { link = "StatusLine" })

vim.opt.termguicolors = true

-- Enable filetype detection and plugins for proper indentation
vim.cmd("filetype plugin indent on")

require("config.code-stats")
require("config.cursorline")

require("config.lazy")

vim.cmd.colorscheme("catppuccin")
