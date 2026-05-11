vim.pack.add({
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/nvim-lualine/lualine.nvim',
})

local palette = require('palette')

-- Git worktree component with caching (10s cache to avoid subprocess overhead)
local worktree_cache = { result = '', cwd = '', timestamp = 0 }
local function git_worktree()
  local cwd = vim.fn.getcwd()
  local now = os.time()

  if worktree_cache.cwd == cwd and (now - worktree_cache.timestamp) < 10 then
    return worktree_cache.result
  end

  local function cache(val)
    worktree_cache.result = val
    worktree_cache.cwd = cwd
    worktree_cache.timestamp = now
    return val
  end

  local r1 = vim.system({ 'git', 'rev-parse', '--git-common-dir' }, { text = true }):wait()
  if r1.code ~= 0 then return cache('') end
  local common_dir = vim.trim(r1.stdout)
  if common_dir == '' then return cache('') end
  if common_dir == '.git' then return cache('[M]') end
  if not common_dir:match('%.git/worktrees') then return cache('[M]') end

  local r2 = vim.system({ 'git', 'rev-parse', '--show-toplevel' }, { text = true }):wait()
  if r2.code ~= 0 then return cache('[M]') end
  local worktree_path = vim.trim(r2.stdout)

  local r3 = vim.system(
    { 'git', '-C', common_dir .. '/../..', 'rev-parse', '--show-toplevel' },
    { text = true }
  ):wait()
  if r3.code ~= 0 then return cache('[M]') end
  local main_repo_path = vim.trim(r3.stdout)

  if worktree_path == '' or main_repo_path == '' then return cache('[M]') end

  local rel_path = worktree_path:gsub('^' .. main_repo_path:gsub('([^%w])', '%%%1') .. '/?', '')
  if rel_path == '' or rel_path == worktree_path then
    rel_path = worktree_path:match('([^/]+)$')
  end

  return cache('[WT] ' .. rel_path)
end

if not pcall(require, 'lualine') then return end

require('lualine').setup({
  options = {
    theme = "catppuccin-nvim",
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
    lualine_c = {
      {
        git_worktree,
        color = function()
          local p = vim.o.background == "light" and palette.latte or palette.mocha
          return { fg = p.mauve }
        end,
      },
    },
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
    lualine_c = {git_worktree},
    lualine_x = {{"diff", colored = false}},
    lualine_y = {"location", "searchcount", "selectioncount"},
    lualine_z = {"progress"},
  },
})
