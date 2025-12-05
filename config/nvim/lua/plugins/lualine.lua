return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    init = function ()
      -- Custom Nord theme with dimmed inactive colors
      local nord_theme = require('lualine.themes.nord')

      -- Dim all inactive colors by using darker Nord colors
      nord_theme.inactive = {
        a = { fg = '#4C566A', bg = '#3B4252', gui = 'none' },
        b = { fg = '#D8DEE9', bg = '#3B4252', gui = 'none' },
        c = { fg = '#4C566A', bg = '#3B4252', gui = 'none' },
        x = { fg = '#4C566A', bg = '#3B4252', gui = 'none' },
        y = { fg = '#4C566A', bg = '#3B4252', gui = 'none' },
        z = { fg = '#4C566A', bg = '#3B4252', gui = 'none' },
      }

      require('lualine').setup({
        options = {
          theme = nord_theme,
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
          lualine_y = {"location", "searchcount", "selectioncount"},
          lualine_z = {"progress"},
        },
        inactive_sections = {
          lualine_a = {"mode"},
          lualine_b = {
            {
              "filename",
              path = 1,
            },
          },
          lualine_c = {},
          lualine_x = {{"diff", colored = false}},
          lualine_y = {"location", "searchcount", "selectioncount"},
          lualine_z = {"progress"},
        },
      })
    end
  },
}
