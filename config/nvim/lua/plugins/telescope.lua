return {
  -- plenary required for telescope
  { "nvim-lua/plenary.nvim" },

  -- fzf extension for find files (and others)
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    lazy = true,
  },

  -- telescope
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        layout_strategy = "vertical",
        layout_config = {
          width = 0.95,
          height = 0.95,
        },
        vimgrep_arguments = {
          "rg",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },
      },
      pickers = {
        buffers = {
          initial_mode = "normal",
          sort_lastused = true,
          mappings = {
            n = {
              ["d"] = "delete_buffer",
            },
          },
        },
        grep_string = {
          word_match = "-w",
          disable_devicons = true,
        },
        live_grep = {
          disable_devicons = true,
        },
        git_status = {
          initial_mode = "normal",
        },
        find_files = {
          disable_devicons = true,
        },
      },
      extensions = { "fzf" },
    },

    init = function()
      require("telescope").load_extension("fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>fw", builtin.grep_string)
      vim.keymap.set("n", "<leader>fb", builtin.buffers)
      vim.keymap.set("n", "<leader>fh", builtin.help_tags)
      vim.keymap.set("n", "<leader>fs", builtin.git_status)
      vim.keymap.set("n", "<leader>fr", builtin.lsp_references)
      vim.keymap.set("n", "<leader>fd", builtin.lsp_definitions)
      -- vim.keymap.set("n", "<leader>ft", builtin.tag)
    end,
  },
}
