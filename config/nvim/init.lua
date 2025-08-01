vim.g.mapleader = ","

vim.keymap.set("n", "<leader>n", ":noh<CR>")
vim.keymap.set("n", "<leader>cn", ":cnext<CR>")
vim.keymap.set("n", "<leader>bd", ":%bd!<CR>")

vim.opt.clipboard = "unnamed" -- interact with system clipboard
vim.opt.colorcolumn = { 80, 100, 120 }

-- Indentation settings
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.tabstop = 2 -- tab width
vim.opt.softtabstop = 2 -- number of spaces tab counts for while editing
vim.opt.shiftwidth = 2 -- indentation level
vim.opt.autoindent = true -- copy indent from current line when starting new line
vim.opt.smartindent = true -- do smart autoindenting when starting new line
vim.opt.cindent = true -- enables automatic C program indenting
vim.opt.shiftround = true -- round indent to multiple of shiftwidth

vim.opt.list = true -- show whitespace and some special characters
vim.opt.listchars = { tab = ">-", trail = "-", extends = ">" }
vim.opt.number = true -- show line numbers
vim.opt.whichwrap:append("<,>,h,l,[,]")
vim.opt.wrap = false -- do not wrap lines

vim.api.nvim_set_hl(0, "ColorColumn", { link = "StatusLine" })

vim.opt.termguicolors = true

-- Enable filetype detection and plugins for proper indentation
vim.cmd("filetype plugin indent on")

-- vim.opt.cmdheight = 0

require("config.code-stats")
require("config.cursorline")
require("config.indentation")

require("config.lazy")

-- vim.cmd.colorscheme(dracula_pro")
vim.cmd.colorscheme("catppuccin")
