-- dracula pro
return {
  name = "dracula_pro",
  lazy = true,
  dir = "~/.config/nvim/pack/themes/dracula_pro",
  init = function()
    vim.cmd.colorscheme("dracula_pro")
  end,
}
