return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    init = function ()
      require('lualine').setup({
        options = {
          theme = "catppuccin",
          component_separators = "",
          section_separators = "",
        },
        sections = {
          lualine_a = {"mode"},
          lualine_b = {
            {
              "filename",
              path = 1,
            },
          },
          lualine_c = {},
          lualine_x = {"diff"},
          lualine_y = {"location"},
          lualine_z = {"progress"},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {
            {
              "filename",
              path = 1,
            },
          },
          lualine_c = {},
          lualine_x = {{"diff", colored = false}},
          lualine_y = {"location"},
          lualine_z = {"progress"},
        },
      })
    end
  },
}
