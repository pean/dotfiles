return {
  "nvim-treesitter/nvim-treesitter",
  config = function()
    local treesitter = require("nvim-treesitter.configs")
    treesitter.setup({
      -- Language parsers to install automatically
      ensure_installed = {
        "bash",              -- Shell scripts
        "css",               -- CSS styling
        "csv",               -- CSV data files
        "diff",              -- Git diffs
        "dockerfile",        -- Docker files
        "fish",              -- Fish shell scripts
        "git_config",        -- Git configuration
        "git_rebase",        -- Git rebase files
        "gitcommit",         -- Git commit messages
        "gitignore",         -- .gitignore files
        "html",              -- HTML markup
        "javascript",        -- JavaScript
        "json",              -- JSON data
        "lua",               -- Lua (Neovim config)
        "make",              -- Makefiles
        "markdown",          -- Markdown documentation
        "markdown_inline",   -- Inline markdown
        "python",            -- Python scripts
        "regex",             -- Regular expressions
        "ruby",              -- Ruby language
        "rust",              -- Rust language
        "sql",               -- SQL queries
        "ssh_config",        -- SSH configuration
        "tmux",              -- Tmux configuration
        "toml",              -- TOML config files
        "tsx",               -- TypeScript React (TSX)
        "typescript",        -- TypeScript
        "yaml",              -- YAML configuration
      },
      auto_install = true,   -- Automatically install parsers for opened files
      
      highlight = {
        enable = true,        -- Enable treesitter-based syntax highlighting
        additional_vim_regex_highlighting = false, -- Disable vim regex highlighting for better performance
      },
      
      indent = {
        enable = true,        -- Enable treesitter-based indentation (used selectively)
      },
      
      incremental_selection = {
        enable = true,        -- Enable smart text selection expansion
        keymaps = {
          init_selection = "gnn",    -- Start selection
          node_incremental = "grn",  -- Expand selection to next node
          scope_incremental = "grc", -- Expand selection to next scope
          node_decremental = "grm",  -- Shrink selection
        },
      },
    })
  end,
}
