vim.opt.clipboard = "unnamed"

vim.opt.updatetime = 300
vim.opt.timeoutlen = 500

-- https://blog.glyph.im/2025/08/the-best-line-length.html
vim.opt.colorcolumn = { 88 }

vim.opt.textwidth = 0
vim.opt.formatoptions = "jqrol"

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.shiftround = true

vim.opt.list = true
vim.opt.listchars = { tab = ">-", trail = "-", extends = ">" }
vim.opt.number = true
vim.opt.whichwrap:append("<,>,h,l,[,]")
vim.opt.wrap = false

vim.opt.termguicolors = true
vim.api.nvim_set_hl(0, "ColorColumn", { link = "StatusLine" })