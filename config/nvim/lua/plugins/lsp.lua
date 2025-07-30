return {
  -- Mason: Modern LSP server manager
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  -- Mason-LSPConfig: Bridge between Mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- Automatically install these language servers
        ensure_installed = {
          "ts_ls",        -- TypeScript/JavaScript
          "ruby_lsp",     -- Ruby
          "lua_ls",       -- Lua
          "rust_analyzer", -- Rust
          "cssls",        -- CSS
          "html",         -- HTML
          "jsonls",       -- JSON
          "yamlls",       -- YAML
        },
        automatic_installation = true,
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = { 
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim"
    },
    config = function()
      local lspconfig = require("lspconfig")
      
      -- LSP On-Attach Function - sets up keybindings when LSP attaches to buffer
      local function on_attach(client, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }
        
        -- Core LSP keybindings
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)           -- Go to definition
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                  -- Show hover info
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)        -- Go to implementation
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)     -- Show signature
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)          -- Rename symbol
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)     -- Show code actions
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)             -- Show references
        vim.keymap.set('n', '<space>f', function()                          -- Format document
          vim.lsp.buf.format { async = true }
        end, opts)
        
        -- Diagnostic navigation
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)    -- Show diagnostic
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)           -- Previous diagnostic
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)           -- Next diagnostic
        
        -- Auto-format on save (if enabled)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              if vim.g.autoformat_enabled then
                vim.lsp.buf.format { async = false }
              end
            end,
          })
        end
      end

      -- Diagnostic configuration
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
      })

      -- Custom diagnostic signs
      local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "»" }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Setup language servers with Mason-lspconfig
      require("mason-lspconfig").setup_handlers({
        -- Default handler for all servers
        function(server_name)
          lspconfig[server_name].setup({
            on_attach = on_attach,
          })
        end,
        
        -- Custom configurations for specific servers
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            on_attach = on_attach,
            settings = {
              Lua = {
                runtime = { version = 'LuaJIT' },
                diagnostics = { globals = {'vim'} },
                workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                telemetry = { enable = false },
              },
            },
          })
        end,
        
        ["ruby_lsp"] = function()
          lspconfig.ruby_lsp.setup({
            on_attach = on_attach,
            cmd = { "ruby-lsp" },
            filetypes = { "ruby" },
            root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
          })
        end,
        
        ["rust_analyzer"] = function()
          lspconfig.rust_analyzer.setup({
            on_attach = on_attach,
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  allFeatures = true,
                },
                checkOnSave = {
                  command = "cargo clippy",
                },
              },
            },
          })
        end,
      })

      -- LSP completion
      vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'
      vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { noremap = true })

      -- Auto-format toggle
      vim.g.autoformat_enabled = true
      vim.keymap.set('n', '<leader>af', function()
        vim.g.autoformat_enabled = not vim.g.autoformat_enabled
        print("Auto-format on save: " .. (vim.g.autoformat_enabled and "enabled" or "disabled"))
      end, { noremap = true })
    end,
  },
}
