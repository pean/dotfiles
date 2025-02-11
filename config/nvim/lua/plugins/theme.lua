-- dracula pro
return {
  {
    name = "dracula_pro",
    lazy = true,
    dir = "~/.config/nvim/pack/themes/dracula_pro",
  },
  { 
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      require('catppuccin').setup({
        flavour = "mocha",
        integrations = {
          gitgutter = true,

        }
      })
    end
  },
}
