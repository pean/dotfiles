return {
  -- Mason: Modern LSP server manager
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded", -- Rounded border for Mason UI
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
        
        -- Core LSP navigation keybindings
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)           -- Go to definition
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                 -- Show hover info
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)       -- Go to implementation
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)    -- Show function signature
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)        -- Rename symbol
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)   -- Show code actions
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)           -- Find references
        vim.keymap.set('n', '<space>f', function()                        -- Format document
          vim.lsp.buf.format { async = true }
        end, opts)
        
        -- Diagnostic navigation
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)  -- Show diagnostic popup
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)         -- Previous diagnostic
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)         -- Next diagnostic
        vim.keymap.set('n', '<space>q', vim.diagnostic.setqflist, opts)   -- Open all diagnostics in quickfix list
        
        -- Disable LSP formatting for JS/TS files to use Prettier instead
        if client.name == "ts_ls" then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
        
        -- Enable format-on-type for supported languages (auto-completes 'end', formats on Enter)
        if client.supports_method("textDocument/onTypeFormatting") then
          vim.api.nvim_buf_set_option(bufnr, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
        end
        
        -- Enable inlay hints if supported (shows type info and parameter names inline)
        if client.supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(bufnr, true)
        end
      end

      -- Configure how diagnostics are displayed
      vim.diagnostic.config({
        virtual_text = true,      -- Show diagnostic messages inline next to code
        signs = true,             -- Show diagnostic signs in gutter
        underline = true,         -- Underline diagnostic text
        update_in_insert = false, -- Don't update diagnostics while typing
      })

      -- Custom diagnostic signs in the gutter
      local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "»" }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Setup language servers manually with specific configurations
      
      -- TypeScript/JavaScript with enhanced React support
      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        filetypes = { 
          "javascript", 
          "javascriptreact", 
          "typescript", 
          "typescriptreact",
          "typescript.tsx"  -- Support .tsx files
        },
        settings = {
          typescript = {
            preferences = {
              includePackageJsonAutoImports = "auto", -- Auto-import from package.json
            },
          },
          javascript = {
            preferences = {
              includePackageJsonAutoImports = "auto", -- Auto-import from package.json
            },
          },
        },
      })

      -- Ruby with mise compatibility and explicit feature control
      lspconfig.ruby_lsp.setup({
        on_attach = on_attach,
        cmd = { "/Users/peter/.dotfiles/scripts/ruby-lsp-wrapper.sh" }, -- Custom wrapper for mise
        filetypes = { "ruby" },
        root_dir = lspconfig.util.root_pattern("Gemfile", ".git"), -- Project detection
        init_options = {
          -- Explicitly enable all Ruby LSP features
          enabledFeatures = {
            "codeActions",         -- Quick fixes and refactoring
            "diagnostics",         -- Error/warning detection
            "documentHighlights",  -- Highlight symbol occurrences
            "documentLink",        -- Clickable links in comments
            "documentSymbols",     -- Outline/symbol navigation
            "foldingRanges",       -- Code folding
            "formatting",          -- Code formatting
            "hover",               -- Show documentation on hover
            "inlayHint",           -- Show type hints inline
            "onTypeFormatting",    -- Format as you type
            "selectionRanges",     -- Smart text selection
            "semanticHighlighting",-- Better syntax highlighting
            "completion",          -- Auto-completion
            "codeLens",           -- Run/debug buttons for tests
            "definition",         -- Go-to-definition
            "workspaceSymbol",    -- Project-wide symbol search
            "signatureHelp",      -- Method parameter hints
            "typeHierarchy"       -- Class inheritance navigation
          },
          -- Disable Ruby LSP's custom bundle creation (causes issues with mise)
          customBundleGemfile = false,
          useCustomBundle = false,
          bundleGemfile = false,
        },
        settings = {
          rubyLsp = {
            -- Force disable custom bundle features (redundant but explicit)
            bundleGemfile = false,
            customBundleGemfile = false,
            useCustomBundle = false,
            -- Always use RuboCop instead of StandardRB for linting/formatting
            linters = { "rubocop" },
            formatter = "rubocop",
            disabledFeatures = { "standard" }, -- Disable StandardRB integration
          }
        },
      })

      -- Lua with Neovim-specific configuration
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = { globals = {'vim'} },  -- Recognize 'vim' as global variable
            workspace = { library = vim.api.nvim_get_runtime_file("", true) }, -- Include Neovim runtime
            telemetry = { enable = false },       -- Disable telemetry data collection
          },
        },
      })

      -- Rust with enhanced toolchain integration
      lspconfig.rust_analyzer.setup({
        on_attach = on_attach,
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,       -- Enable all Cargo features for better analysis
            },
            checkOnSave = {
              command = "cargo clippy", -- Use Clippy for additional linting on save
            },
          },
        },
      })

      -- Web development language servers (minimal configuration)
      lspconfig.cssls.setup({ on_attach = on_attach })   -- CSS language server
      lspconfig.html.setup({ on_attach = on_attach })    -- HTML language server
      lspconfig.jsonls.setup({ on_attach = on_attach })  -- JSON language server
      lspconfig.yamlls.setup({ on_attach = on_attach })  -- YAML language server

      -- LSP completion configuration
      vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { noremap = true }) -- Trigger completion with Ctrl+Space
    end,
  },
}
