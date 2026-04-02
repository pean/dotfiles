-- catppuccin/nvim provides full highlight coverage for treesitter, LSP,
-- diagnostics, and plugin integrations. We pass flavor via setup() and
-- re-call on background change so dark=mocha, light=latte.

local function catppuccin_setup()
  local flavour = vim.o.background == "light" and "latte" or "mocha"

  require("catppuccin").setup({
    flavour = flavour,
    background = { light = "latte", dark = "mocha" },
    transparent_background = false,
    term_colors = true,
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      telescope = { enabled = true },
      treesitter = true,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
        },
        inlay_hints = { background = true },
      },
      which_key = false,
      indent_blankline = { enabled = false },
      rainbow_delimiters = false,
    },
    -- Custom highlights on top of catppuccin defaults
    custom_highlights = function(colors)
      return {
        WinSeparator = { fg = colors.surface1 },
        VertSplit    = { fg = colors.surface1 },
        ColorColumn  = { link = "StatusLine" },
        -- Use catppuccin diff colors
        DiffAdd      = { bg = colors.surface0 },
        DiffDelete   = { bg = colors.surface0 },
        DiffChange   = { bg = colors.surface0 },
        DiffText     = { bg = colors.surface1 },
      }
    end,
  })

  vim.cmd.colorscheme("catppuccin")
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      catppuccin_setup()

      -- Re-apply when background changes (e.g. from theme-toggle --remote-send)
      vim.api.nvim_create_autocmd("OptionSet", {
        pattern = "background",
        callback = catppuccin_setup,
      })

      -- Explicit command for remote toggle via --remote-send
      vim.api.nvim_create_user_command("ThemeToggle", function()
        vim.o.background = vim.o.background == "dark" and "light" or "dark"
      end, {})
    end,
  },
}
