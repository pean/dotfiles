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

      -- Custom go-to-definition that avoids quickfix for single/duplicate results
      local function goto_definition()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, config)
          if err then
            vim.notify('Error getting definition: ' .. err.message, vim.log.levels.ERROR)
            return
          end
          
          if not result or vim.tbl_isempty(result) then
            vim.notify('No definition found', vim.log.levels.INFO)
            return
          end
          
          -- If single result or multiple identical results, go directly
          if #result == 1 then
            vim.lsp.util.jump_to_location(result[1], 'utf-8')
          else
            -- Check if all results point to the same location (duplicates)
            local first = result[1]
            local all_same = true
            for i = 2, #result do
              if result[i].uri ~= first.uri or 
                 result[i].range.start.line ~= first.range.start.line or
                 result[i].range.start.character ~= first.range.start.character then
                all_same = false
                break
              end
            end
            
            if all_same then
              -- All results are the same, just go to the first one
              vim.lsp.util.jump_to_location(first, 'utf-8')
            else
              -- Multiple different locations, use quickfix
              vim.lsp.util.set_qflist(vim.lsp.util.locations_to_items(result, 'utf-8'))
              vim.cmd('copen')
            end
          end
        end)
      end

      -- LSP keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gd', goto_definition, opts)
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

      -- Configure diagnostics display with signs
      vim.diagnostic.config({
        virtual_text = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "!!",
            [vim.diagnostic.severity.WARN] = ">>",
            [vim.diagnostic.severity.HINT] = "??",
            [vim.diagnostic.severity.INFO] = "--"
          }
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Define diagnostic sign highlights
      vim.api.nvim_set_hl(0, 'DiagnosticSignError', { fg = '#f38ba8' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignWarn', { fg = '#fab387' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignHint', { fg = '#89dceb' })
      vim.api.nvim_set_hl(0, 'DiagnosticSignInfo', { fg = '#89b4fa' })
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