local theme_file = vim.fn.expand("~/.config/theme")
local theme_mode = "dark"
if vim.fn.filereadable(theme_file) == 1 then
  local content = vim.fn.readfile(theme_file)
  if content[1] == "latte" then
    theme_mode = "light"
  end
end
vim.o.background = theme_mode