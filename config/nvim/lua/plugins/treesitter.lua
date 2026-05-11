vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter'
      and (ev.data.kind == 'install' or ev.data.kind == 'update') then
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  'https://github.com/nvim-treesitter/nvim-treesitter',
})

if not pcall(require, 'nvim-treesitter') then return end

require('nvim-treesitter').install({
  'bash', 'css', 'csv', 'diff', 'dockerfile', 'fish',
  'git_config', 'git_rebase', 'gitcommit', 'gitignore',
  'html', 'javascript', 'json', 'lua', 'make', 'markdown',
  'markdown_inline', 'python', 'regex', 'ruby', 'rust',
  'scss', 'sql', 'ssh_config', 'tmux', 'toml', 'tsx',
  'typescript', 'yaml',
})

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
