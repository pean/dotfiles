return {
  -- Mason LSP server installer
  {
    "williamboman/mason.nvim",
    opts = {}
  },

  -- Mason LSP config bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "ts_ls",           -- TypeScript/JavaScript
        "ruby_lsp",        -- Ruby
        "cssls",           -- CSS
        "html",            -- HTML
        "jsonls",          -- JSON
        "yamlls",          -- YAML
      }
    }
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = { 
      "williamboman/mason-lspconfig.nvim"
    },
    config = function()
      local lspconfig = require('lspconfig')

      -- LSP servers configuration
      local servers = {
        ts_ls = {
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
        },
        ruby_lsp = {
          cmd = { vim.fn.expand("~/.dotfiles/scripts/ruby-lsp-wrapper.sh") },
          filetypes = { "ruby" },
          root_dir = function(fname)
            return require('lspconfig').util.root_pattern("Gemfile", ".git", ".ruby-version", ".mise.toml")(fname)
          end,
          settings = {
            rubyLsp = {
              formatter = "rubocop",
              enabledFeatures = {
                "documentHighlights",
                "documentSymbols", 
                "foldingRanges",
                "selectionRanges",
                "semanticHighlighting",
                "formatting",
                "codeActions"
              }
            }
          }
        },
        cssls = {},
        html = {},
        jsonls = {},
        yamlls = {}
      }

      -- Setup each server
      for server, config in pairs(servers) do
        lspconfig[server].setup(config)
      end

      -- LSP keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })

      -- Configure diagnostics display
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Define diagnostic signs with nice icons
      local signs = {
        Error = "󰅚 ",
        Warn = "󰀪 ",
        Hint = "󰌶 ",
        Info = " "
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end
  },


  -- none-ls for additional linting/formatting (including rubocop)
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      
      -- Helper function to determine rubocop command based on project
      local function get_rubocop_command()
        -- Check for bundle exec first (Rails/Bundler projects)
        if vim.fn.filereadable("Gemfile") == 1 then
          return "bundle"
        end
        -- Check if mise is available and has rubocop
        if vim.fn.executable("mise") == 1 then
          return "mise"
        end
        -- Fallback to system rubocop
        return "rubocop"
      end

      local function get_rubocop_args(base_args)
        local cmd = get_rubocop_command()
        if cmd == "bundle" then
          return vim.list_extend({ "exec", "rubocop" }, base_args or {})
        elseif cmd == "mise" then
          return vim.list_extend({ "exec", "--", "rubocop" }, base_args or {})
        else
          return base_args or {}
        end
      end
      
      null_ls.setup({
        sources = {
          -- Ruby diagnostics with version-aware rubocop
          null_ls.builtins.diagnostics.rubocop.with({
            command = get_rubocop_command(),
            args = get_rubocop_args(null_ls.builtins.diagnostics.rubocop._opts.args),
            condition = function()
              -- Only run if we have a Ruby project with rubocop available
              local has_ruby_files = vim.fn.filereadable("Gemfile") == 1 or 
                                   vim.fn.filereadable(".ruby-version") == 1 or
                                   vim.fn.filereadable(".mise.toml") == 1 or
                                   vim.fn.glob("*.rb") ~= ""
              
              if not has_ruby_files then return false end
              
              local cmd = get_rubocop_command()
              if cmd == "bundle" then
                return vim.fn.filereadable("Gemfile") == 1
              elseif cmd == "mise" then
                return vim.fn.executable("mise") == 1
              else
                return vim.fn.executable("rubocop") == 1
              end
            end,
          }),
          
          -- Ruby formatting with version-aware rubocop
          null_ls.builtins.formatting.rubocop.with({
            command = get_rubocop_command(),
            args = get_rubocop_args(null_ls.builtins.formatting.rubocop._opts.args),
            condition = function()
              -- Same condition logic as diagnostics
              local has_ruby_files = vim.fn.filereadable("Gemfile") == 1 or 
                                   vim.fn.filereadable(".ruby-version") == 1 or
                                   vim.fn.filereadable(".mise.toml") == 1 or
                                   vim.fn.glob("*.rb") ~= ""
              
              if not has_ruby_files then return false end
              
              local cmd = get_rubocop_command()
              if cmd == "bundle" then
                return vim.fn.filereadable("Gemfile") == 1
              elseif cmd == "mise" then
                return vim.fn.executable("mise") == 1
              else
                return vim.fn.executable("rubocop") == 1
              end
            end,
          }),
        },
      })
    end
  }
}