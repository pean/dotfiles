vim.pack.add({
  'https://github.com/github/copilot.vim',
  'https://gitlab.com/code-stats/code-stats-vim.git',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/christoomey/vim-tmux-navigator',
  'https://github.com/epwalsh/obsidian.nvim',
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/jgdavey/tslime.vim',
  'https://github.com/vim-test/vim-test',
  'https://github.com/brenoprata10/nvim-highlight-colors',
})

-- gitsigns
local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')
if gitsigns_ok then gitsigns.setup() end

-- tmux navigator
vim.g.tmux_navigator_disable_when_zoomed = 1

-- obsidian
local obsidian_ok, obsidian = pcall(require, 'obsidian')
if obsidian_ok then
  obsidian.setup({
    workspaces = {
      {
        name = "dreams",
        path = "~/obsidian/dreams",
      },
    },
  })
  vim.keymap.set("n", "<leader>of", function()
    vim.cmd("ObsidianSearch")
  end)
  vim.keymap.set("n", "<leader>on", function()
    vim.cmd("ObsidianNew")
  end)
end

-- nvim-tree
local nvimtree_ok, nvimtree = pcall(require, 'nvim-tree')
if nvimtree_ok then
  nvimtree.setup({
    filters = { dotfiles = false },
    update_focused_file = { enable = true },
    hijack_directories = { auto_open = false },
  })
  vim.keymap.set("n", "<leader>d", "<cmd>NvimTreeToggle<CR>")
  vim.keymap.set("n", "<leader>df", "<cmd>NvimTreeFindFile<CR>")
end

-- tslime
vim.g.tslime_always_current_session = 1
vim.g.tslime_always_current_window = 1
vim.g.tslime_pre_command = "C-c"

-- vim-test
vim.g["test#strategy"] = "tslime"
vim.keymap.set("n", "<leader>su", ":TestSuite<CR>")
vim.keymap.set("n", "<leader>sa", ":TestFile<CR>")
vim.keymap.set("n", "<leader>ss", ":TestNearest<CR>")
vim.keymap.set("n", "<leader>sl", ":TestLast<CR>")
vim.keymap.set("n", "<leader>sof", ":TestSuite --only-failures<CR>")
vim.keymap.set("n", "<leader>sfn", ":TestSuite --next-failure<CR>")
vim.keymap.set("n", "<leader>sff", ":TestSuite --fail-fast<CR>")

-- highlight colors
local colors_ok, colors = pcall(require, 'nvim-highlight-colors')
if colors_ok then colors.setup({ enable_tailwind = true }) end
