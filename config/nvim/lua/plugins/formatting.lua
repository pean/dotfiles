return {
  -- Conform.nvim: Modern formatter with great React/Next.js support
  {
    "stevearc/conform.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = { "BufWritePre" },    -- Load when about to save file
    cmd = { "ConformInfo" },      -- Load when running ConformInfo command
    config = function()
      require("conform").setup({
        -- Map of filetype to formatters
        formatters_by_ft = {
          -- Web development
          javascript = { "prettier" },      -- JavaScript files
          javascriptreact = { "prettier" },  -- JSX files
          typescript = { "prettier" },      -- TypeScript files
          typescriptreact = { "prettier" }, -- TSX files
          json = { "prettier" },            -- JSON files
          css = { "prettier" },             -- CSS files
          html = { "prettier" },            -- HTML files
          yaml = { "prettier" },            -- YAML files
          markdown = { "prettier" },        -- Markdown files
          
          -- Other languages
          lua = { "stylua" },               -- Lua formatter
          rust = { "rustfmt" },             -- Rust formatter
          ruby = { "rubocop" },             -- Ruby formatter/linter
        },
        
        -- Prettier will automatically use repository's own configuration
        -- (.prettierrc, package.json, etc.) - no need to specify options here
        
        -- Format on save configuration
        format_on_save = function(bufnr)
          -- Check if auto-formatting is disabled globally or for this buffer
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          
          return {
            timeout_ms = 500,   -- Max time to wait for formatting
            -- lsp_fallback = true is the default
          }
        end,
      })
      
      -- Create commands to disable/enable auto-formatting
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          -- FormatDisable will disable formatting globally
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true, -- Allow FormatDisable! syntax
      })
      
      vim.api.nvim_create_user_command("FormatEnable", function()
        -- Re-enable auto-formatting both globally and for current buffer
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })
      
      -- Manual formatting keymap (alternative to <space>f from LSP)
      vim.keymap.set({ "n", "v" }, "<leader>mp", function()
        require("conform").format({
          -- lsp_fallback = true, -- Default behavior
          -- async = false,       -- Default behavior
          timeout_ms = 1000,   -- Max time to wait
        })
      end, { desc = "Format file or range (in visual mode)" })
    end,
  },

  -- Mason tool installer for formatters
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettier",    -- JS/TS/React formatter (also handles JSON, CSS, HTML, YAML, Markdown)
          "stylua",      -- Lua formatter (fast and configurable)
          "rustfmt",     -- Rust formatter (usually comes with rust toolchain)
          "rubocop",     -- Ruby formatter/linter (handles both formatting and linting)
        },
        auto_update = false,  -- Don't automatically update tools (prevents breaking changes)
        run_on_start = true,  -- Install missing tools when Neovim starts
      })
    end,
  },
}
