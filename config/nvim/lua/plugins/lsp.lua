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
        "lua_ls",          -- Lua
        "rust_analyzer",   -- Rust
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
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              diagnostics = {
                globals = { 'vim' },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = { 
                allFeatures = true,
                loadOutDirsFromCheck = true,
              },
              procMacro = { enable = true },
              checkOnSave = { 
                command = "clippy",
                allTargets = false,
              },
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
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          vim.notify('No LSP clients attached to current buffer', vim.log.levels.WARN)
          return
        end
        
        -- Check if any client supports textDocument/definition
        local supporting_client = nil
        for _, client in ipairs(clients) do
          if client.server_capabilities.definitionProvider then
            supporting_client = client
            break
          end
        end
        
        if not supporting_client then
          vim.notify('Go to definition not supported for this file type', vim.log.levels.INFO)
          return
        end
        
        local params = vim.lsp.util.make_position_params(0, supporting_client.offset_encoding)
        
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
            vim.lsp.util.show_document(result[1], supporting_client.offset_encoding, { focus = true })
          else
            -- Check if all results point to the same location (duplicates)
            local first = result[1]
            local all_same = true
            for i = 2, #result do
              if result[i].uri ~= first.uri or 
                 not result[i].range or not first.range or
                 result[i].range.start.line ~= first.range.start.line or
                 result[i].range.start.character ~= first.range.start.character then
                all_same = false
                break
              end
            end
            
            if all_same then
              -- All results are the same, just go to the first one
              vim.lsp.util.show_document(first, supporting_client.offset_encoding, { focus = true })
            else
              -- Multiple different locations, use quickfix
              vim.lsp.util.set_qflist(vim.lsp.util.locations_to_items(result, supporting_client.offset_encoding))
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
          vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gr', function()
            require('telescope.builtin').lsp_references()
          end, opts)
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


}
