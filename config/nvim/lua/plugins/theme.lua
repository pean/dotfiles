-- dracula pro
return {
  -- {
  --   name = "dracula_pro",
  --   lazy = true,
  --   dir = "~/.config/nvim/pack/themes/dracula_pro",
  -- },
  {
    "nordtheme/vim",
    name = "nord",
    priority = 1000,
  },
  -- Catppuccin theme (preserved but commented out)
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   init = function()
  --     require('catppuccin').setup({
  --       flavour = "mocha",
  --       integrations = {
  --         gitgutter = true,
  --       }
  --     })
  --   end
  -- },
}
