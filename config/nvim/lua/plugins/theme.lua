vim.pack.add({
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
})

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
    custom_highlights = function(colors)
      return {
        WinSeparator       = { fg = colors.surface1 },
        VertSplit          = { fg = colors.surface1 },
        ColorColumn        = { link = "StatusLine" },
        DiffAdd            = { bg = colors.surface0 },
        DiffDelete         = { bg = colors.surface0 },
        DiffChange         = { bg = colors.surface0 },
        DiffText           = { bg = colors.surface1 },
      }
    end,
  })

  vim.cmd.colorscheme("catppuccin")
end

if not pcall(catppuccin_setup) then return end

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "background",
  callback = catppuccin_setup,
})

vim.api.nvim_create_user_command("ThemeToggle", function()
  vim.o.background = vim.o.background == "dark" and "light" or "dark"
end, {})
