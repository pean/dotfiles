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
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
          vim.lsp.buf.format { async = true }
        end, opts)
        
        -- Diagnostic navigation
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        
        -- Disable LSP formatting for JS/TS files to use Prettier
        if client.name == "ts_ls" then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
        
        -- Auto-format on type for supported languages (TypeScript/JavaScript)
        if client.supports_method("textDocument/onTypeFormatting") then
          vim.api.nvim_buf_set_option(bufnr, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
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

      -- Setup language servers manually
      -- TypeScript/JavaScript with enhanced React support
      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        filetypes = { 
          "javascript", 
          "javascriptreact", 
          "typescript", 
          "typescriptreact",
          "typescript.tsx"
        },
        settings = {
          typescript = {
            preferences = {
              includePackageJsonAutoImports = "auto",
            },
          },
          javascript = {
            preferences = {
              includePackageJsonAutoImports = "auto",
            },
          },
        },
      })

      -- Ruby with mise compatibility
      lspconfig.ruby_lsp.setup({
        on_attach = on_attach,
        cmd = { "/Users/peter/.dotfiles/scripts/ruby-lsp-wrapper.sh" },
        filetypes = { "ruby" },
        root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
        init_options = {
          enabledFeatures = {
            "codeActions",
            "diagnostics", 
            "documentHighlights",
            "documentLink",
            "documentSymbols",
            "foldingRanges",
            "formatting",
            "hover",
            "inlayHint",
            "onTypeFormatting",
            "selectionRanges",
            "semanticHighlighting",
            "completion",
            "codeLens",
            "definition",
            "workspaceSymbol",
            "signatureHelp",
            "typeHierarchy"
          },
          -- Completely disable custom bundle creation
          customBundleGemfile = false,
          useCustomBundle = false,
          bundleGemfile = false,
        },
        settings = {
          rubyLsp = {
            -- Force disable custom bundle features
            bundleGemfile = false,
            customBundleGemfile = false,
            useCustomBundle = false,
            -- Always use RuboCop instead of StandardRB
            linters = { "rubocop" },
            formatter = "rubocop",
            disabledFeatures = { "standard" },
          }
        },
      })

      -- Lua with Neovim support
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = { globals = {'vim'} },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
          },
        },
      })

      -- Rust with cargo + clippy
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

      -- Web languages (CSS, HTML, JSON, YAML)
      lspconfig.cssls.setup({ on_attach = on_attach })
      lspconfig.html.setup({ on_attach = on_attach })
      lspconfig.jsonls.setup({ on_attach = on_attach })
      lspconfig.yamlls.setup({ on_attach = on_attach })

      -- LSP completion
      vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { noremap = true })
    end,
  },
}
