-- Filetype-specific indentation settings

-- Ruby and Rails specific indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby", "eruby" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true
  end,
})

-- JavaScript/TypeScript indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true
  end,
})

-- HTML/CSS indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "scss", "sass" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true
  end,
})

-- YAML indentation (important for proper YAML formatting)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = false -- YAML doesn't work well with smartindent
  end,
})

-- JSON indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true
  end,
})