return {
  "goolord/alpha-nvim",
  config = function()
    local startify = require("alpha.themes.startify")
    local stats = require("lazy").stats()

    startify.section.top_buttons.val = {
      startify.button("e", "New file"),
      startify.button("o", "New note", ":ObsidianNew<CR>"),
    }

    startify.section.mru.val = { { type = "padding", val = 0 } }
    startify.file_icons.enabled = false

    startify.section.footer.val = {
      {
        opts = {
          position = "center",
        },
        type = "text",
        val = "⚡ Neovim loaded "
          .. stats.loaded
          .. "/"
          .. stats.count
          .. " plugins"
      }
    }

    require("alpha").setup(
      startify.config
    )

  end,
}
