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

-- Better indentation behavior
vim.opt.autoindent = true -- maintain indent of current line
vim.opt.smartindent = true -- smart autoindenting when starting new line
vim.opt.cindent = true -- C-style indenting for better brace handling

-- Simple filetype indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby" },
  callback = function()
    vim.bo.cindent = true
    vim.bo.cinkeys = "0{,0},0),0],0#,!^F,o,O,e,0=end"
  end,
})

vim.api.nvim_set_hl(0, "ColorColumn", { link = "StatusLine" })

vim.opt.termguicolors = true

-- vim.opt.cmdheight = 0

require("config.code-stats")
require("config.cursorline")

require("config.lazy")

-- vim.cmd.colorscheme(dracula_pro")
vim.cmd.colorscheme("catppuccin")
