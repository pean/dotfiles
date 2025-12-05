return {
  -- Copilot
  { "github/copilot.vim" },

  -- Code stats
  -- Create `~/.config/nvim/secrets.lua` with `vim.g.codestats_api_key = "your-api-key"`
  { url = "https://gitlab.com/code-stats/code-stats-vim.git" },

  -- Git Gutter
  {
    "airblade/vim-gitgutter",
    init = function()
      vim.opt.signcolumn = "yes"
    end
  },

  --- Tmux navigator
  {
    "christoomey/vim-tmux-navigator",
    init = function()
      vim.g.tmux_navigator_disable_when_zoomed = 1
    end,
  },

  -- Obisidan
  {
    "epwalsh/obsidian.nvim",
    dependencies = { "nvim-lua/plenary.nvim", lazy = true },
    opts = {
      workspaces = {
        {
          name = "dreams",
          path = "~/obsidian/dreams",
        },
      },
    },
    init = function()
      vim.keymap.set("n", "<leader>of", function()
        vim.cmd("ObsidianSearch")
      end)
      vim.keymap.set("n", "<leader>on", function()
        vim.cmd("ObsidianNew")
      end)
    end,
  },

  -- NERDTree
  {
    "preservim/nerdtree",
    init = function()
      vim.keymap.set("n", "<leader>d", function()
        vim.cmd("NERDTreeToggle " .. vim.fn.getcwd())
      end)

      vim.keymap.set("n", "<leader>df", function()
        vim.cmd("NERDTreeFind")
      end)

      vim.g.NERDTreeShowHidden = 1
    end,
  },


  -- tslime
  {
    -- Used to use my own fork with some changes, but my PR changes are inclued in main
    -- https://github.com/jgdavey/tslime.vim/pull/30
    -- "pean/tslime.vim",
    "jgdavey/tslime.vim",
    init = function()
      vim.g.tslime_always_current_session = 1
      vim.g.tslime_always_current_window = 1 -- fixed pane (otherwise select)
      -- vim.g.tslime_autoset_pane = 1 -- select largest pane
      vim.g.tslime_pre_command = "C-c"
    end,
  },

  -- vim-test
  {
    "vim-test/vim-test",
    init = function()
      vim.g["test#strategy"] = "tslime"
      vim.keymap.set("n", "<leader>su", ":TestSuite<CR>")
      vim.keymap.set("n", "<leader>sa", ":TestFile<CR>")
      vim.keymap.set("n", "<leader>ss", ":TestNearest<CR>")
      vim.keymap.set("n", "<leader>sl", ":TestLast<CR>")
      vim.keymap.set("n", "<leader>sof", ":TestSuite --only-failures<CR>")
      vim.keymap.set("n", "<leader>sfn", ":TestSuite --next-failure<CR>")
      vim.keymap.set("n", "<leader>sff", ":TestSuite --fail-fast<CR>")
    end,
  },

  -- vim-rails
  { "tpope/vim-rails" },


  -- vim-fugitive
  { "tpope/vim-fugitive" },

  -- rhubarb.vim - for GBrowse through fugitive
  {
    "tpope/vim-rhubarb",
    dependencies = { "tpope/vim-fugitive" },
  },


  -- color preview
  {
    "brenoprata10/nvim-highlight-colors",
    opts = {
      enable_tailwind = true,
    }
  },
  {
    "NightsPaladin/sops.nvim",
    config = function()
      require("sops").setup({
        -- Configuration options
      })
    end,
  },
  {
    'numToStr/Comment.nvim',
    opts = {
      -- gcc to toggle line comment
      -- gbc to toggle block comment
      -- gc in visual mode to toggle selection
    }
  }
}
