return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter.configs")
    treesitter.setup({
      ensure_installed = {
        "bash",
        "css",
        "csv", 
        "diff",
        "dockerfile",
        "fish",
        "git_config",
        "git_rebase",
        "gitcommit",
        "gitignore",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "ruby",
        "rust",
        "scss",
        "sql",
        "ssh_config",
        "tmux",
        "toml",
        "tsx",
        "typescript",
        "typescriptreact",
        "yaml",
      },
      auto_install = true,
      sync_install = false,
      ignore_install = {},
      
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false, -- Better to disable for performance
      },
      
      indent = {
        enable = true,
        -- Disable indentation for languages that don't work well with treesitter indent
        disable = {},
      },
      
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn", 
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
    })
  end,
}
