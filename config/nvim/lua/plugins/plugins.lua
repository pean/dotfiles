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
    depedencies = { "nvim-lua/plenary.nvim", lazy = true },
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

  -- ALE
  {
    "dense-analysis/ale",
    config = function()
      vim.g.ale_linters_ignore = {
        ruby = { "standardrb" },
      }
      vim.g.ale_ruby_rubocop_executable = "bundle"
    end,
  },

  -- tslime
  {
    "pean/tslime.vim",
    init = function()
      vim.g.tslime_always_current_session = 1
      -- vim.g.tslime_always_current_window = 1 -- fixed pane (otherwise select)
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

  -- gutentags
  {
    "ludovicchabant/vim-gutentags",
    -- dependencies = { "skywind3000/gutentags_plus" },
    init = function()
      -- Disable Gutentags for specific filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "diff", "gitcommit", "gitrebase" },
        callback = function()
          vim.g.gutentags_enabled = 0
        end,
      })

      -- vim.g.gutentags_modules = { "ctags", "gtags_cscope" }
      vim.g.gutentags_modules = { "ctags" }

      -- Set Gutentags cache directory
      vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/tags")

      -- Define the ctags executable (avoiding Xcode ctags)
      vim.g.gutentags_ctags_executable = "/opt/homebrew/bin/ctags"
    end,
  },
}
