vim.opt.cursorline = true

-- Create a function to enable cursorline
local function on_win_enter()
  vim.opt.cursorline = true
end

-- Create a function to disable cursorline
local function on_win_leave()
  vim.opt.cursorline = false
end

-- Define an autocommand group for managing cursorline highlighting
vim.api.nvim_create_augroup('HighlightPane', { clear = true })

-- Set up autocmd to enable cursorline on window enter
vim.api.nvim_create_autocmd('WinEnter', {
  group = 'HighlightPane',
  callback = on_win_enter
})

-- Set up autocmd to disable cursorline on window leave
vim.api.nvim_create_autocmd('WinLeave', {
  group = 'HighlightPane',
  callback = on_win_leave
})
