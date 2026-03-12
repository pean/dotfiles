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

      -- Git worktree component with caching (10s cache to avoid subprocess overhead)
      local worktree_cache = { result = '', cwd = '', timestamp = 0 }
      local function git_worktree()
        local cwd = vim.fn.getcwd()
        local now = os.time()

        -- Return cached result if still valid (within 10s and same directory)
        if worktree_cache.cwd == cwd and (now - worktree_cache.timestamp) < 10 then
          return worktree_cache.result
        end

        -- Recalculate
        local handle = io.popen('git rev-parse --git-common-dir 2>/dev/null')
        if not handle then
          worktree_cache.result = ''
          worktree_cache.cwd = cwd
          worktree_cache.timestamp = now
          return ''
        end
        local common_dir = handle:read('*l')
        handle:close()

        if not common_dir or common_dir == '' then
          worktree_cache.result = ''
          worktree_cache.cwd = cwd
          worktree_cache.timestamp = now
          return ''
        end

        -- Check if we're in main repository
        if common_dir == '.git' then
          worktree_cache.result = '[M]'
          worktree_cache.cwd = cwd
          worktree_cache.timestamp = now
          return '[M]'
        end

        -- Check if it's actually a worktree (common_dir will be absolute path)
        if not common_dir:match('%.git/worktrees') and common_dir == '.git' then
          worktree_cache.result = '[M]'
          worktree_cache.cwd = cwd
          worktree_cache.timestamp = now
          return '[M]'
        end

        -- Get worktree path and main repo path
        local wt_handle = io.popen('git rev-parse --show-toplevel 2>/dev/null')
        if not wt_handle then
          worktree_cache.result = '[M]'
          worktree_cache.cwd = cwd
          worktree_cache.timestamp = now
          return '[M]'
        end
        local worktree_path = wt_handle:read('*l')
        wt_handle:close()

        local main_handle = io.popen('cd ' .. common_dir .. '/../.. && pwd 2>/dev/null')
        if not main_handle then
          worktree_cache.result = '[M]'
          worktree_cache.cwd = cwd
          worktree_cache.timestamp = now
          return '[M]'
        end
        local main_repo_path = main_handle:read('*l')
        main_handle:close()

        if not worktree_path or not main_repo_path then
          worktree_cache.result = '[M]'
          worktree_cache.cwd = cwd
          worktree_cache.timestamp = now
          return '[M]'
        end

        -- Calculate relative path
        local rel_path = worktree_path:gsub('^' .. main_repo_path:gsub('([^%w])', '%%%1') .. '/?', '')
        if rel_path == '' or rel_path == worktree_path then
          -- Fallback to basename if relative path calculation fails
          rel_path = worktree_path:match('([^/]+)$')
        end

        local result = '[WT] ' .. rel_path
        worktree_cache.result = result
        worktree_cache.cwd = cwd
        worktree_cache.timestamp = now
        return result
      end

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
          lualine_c = {
            {
              git_worktree,
              color = { fg = '#B48EAD' }, -- Nord15 purple for worktree
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
    end
  },
}
