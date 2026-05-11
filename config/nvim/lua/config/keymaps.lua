vim.g.mapleader = ","

vim.keymap.set("n", "<leader>n", vim.cmd.nohlsearch)
vim.keymap.set("n", "<leader>cn", vim.cmd.cnext)
vim.keymap.set("n", "<leader>bd", function() vim.cmd("%bd!") end)