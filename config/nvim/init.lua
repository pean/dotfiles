vim.g.mapleader = ","

-- Key mappings
vim.keymap.set("n", "<leader>n", ":noh<CR>") -- Clear search highlighting
vim.keymap.set("n", "<leader>cn", ":cnext<CR>") -- Next quickfix item
vim.keymap.set("n", "<leader>bd", ":%bd!<CR>") -- Close all buffers

-- Basic editor settings
vim.opt.clipboard = "unnamed" -- interact with system clipboard
vim.opt.colorcolumn = { 80, 100, 120 } -- Show vertical lines at these columns
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.list = true -- show whitespace and some special characters
vim.opt.listchars = { tab = ">-", trail = "-", extends = ">" } -- How to display whitespace
vim.opt.number = true -- show line numbers
vim.opt.shiftwidth = 2 -- indentation level (spaces per indent)
vim.opt.tabstop = 2 -- tab width (spaces per tab character)
vim.opt.whichwrap:append("<,>,h,l,[,]") -- Allow cursor to wrap around lines
vim.opt.wrap = false -- do not wrap long lines

-- Better indentation behavior
vim.opt.autoindent = true -- maintain indent of current line when creating new line
vim.opt.smartindent = true -- smart autoindenting when starting new line
vim.opt.cindent = true -- C-style indenting for better brace handling

-- Ruby-specific real-time indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby" },
  callback = function()
    vim.bo.cindent = true -- Enable C-style indenting for Ruby
    -- Keys that trigger re-indentation: braces, parens, brackets, #, and "end" keyword
    vim.bo.cinkeys = "0{,0},0),0],0#,!^F,o,O,e,0=end"
  end,
})

-- Visual settings
vim.api.nvim_set_hl(0, "ColorColumn", { link = "StatusLine" }) -- Style for column guides
vim.opt.termguicolors = true -- Enable 24-bit RGB colors

-- Load configuration modules
require("config.code-stats") -- Code statistics tracking
require("config.cursorline") -- Cursor line highlighting
require("config.lazy") -- Lazy.nvim plugin manager

-- Set color scheme
vim.cmd.colorscheme("catppuccin")
