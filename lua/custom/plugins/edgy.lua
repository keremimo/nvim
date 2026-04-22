local function find_neotree_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == 'neo-tree' or ft == 'neo-tree-popup' then
      return win
    end
  end
end

local function is_neotree_buffer(buf)
  local ft = vim.bo[buf].filetype
  return ft == 'neo-tree' or ft == 'neo-tree-popup'
end

local function is_real_file_buffer(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  if vim.bo[buf].buftype ~= '' then
    return false
  end
  if is_neotree_buffer(buf) or vim.bo[buf].filetype == 'dashboard' then
    return false
  end
  return vim.api.nvim_buf_get_name(buf) ~= ''
end

local function is_sidebar_candidate(buf)
  return is_real_file_buffer(buf) or vim.bo[buf].filetype == 'dashboard'
end

local function ensure_sidebar(opts)
  opts = opts or {}

  local edgy = require 'edgy'
  local origin = vim.api.nvim_get_current_win()

  edgy.open 'right'

  local tree_win = find_neotree_window()
  if not tree_win then
    vim.cmd 'Neotree filesystem reveal right'
    vim.schedule(function()
      local resolved_tree_win = find_neotree_window()
      if not resolved_tree_win or not vim.api.nvim_win_is_valid(resolved_tree_win) then
        return
      end

      vim.api.nvim_set_current_win(resolved_tree_win)

      if opts.focus then
        return
      end

      if vim.api.nvim_win_is_valid(origin) then
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(origin) then
            vim.api.nvim_set_current_win(origin)
          end
        end)
      end
    end)
    return
  end

  if opts.focus then
    vim.api.nvim_set_current_win(tree_win)
    return
  end

  if vim.api.nvim_win_is_valid(origin) then
    vim.api.nvim_set_current_win(origin)
  end
end

return {
  {
    'folke/edgy.nvim',
    lazy = false,
    dependencies = { 'nvim-neo-tree/neo-tree.nvim' },
    init = function()
      vim.opt.splitkeep = 'screen'
    end,
    keys = {
      {
        '<leader>e',
        function()
          ensure_sidebar()
        end,
        desc = 'Open Explorer Sidebar',
      },
      {
        '<C-e>',
        function()
          local buf = vim.api.nvim_get_current_buf()
          if is_neotree_buffer(buf) then
            require('edgy').goto_main()
            return
          end

          ensure_sidebar { focus = true }
        end,
        desc = 'Focus Explorer Sidebar',
      },
    },
    opts = {
      close_when_all_hidden = false,
      animate = {
        enabled = false,
      },
      options = {
        right = { size = 30 },
      },
      right = {
        {
          title = 'Explorer',
          ft = 'neo-tree',
          filter = function(buf)
            return vim.b[buf].neo_tree_source == 'filesystem'
          end,
          pinned = true,
          open = 'Neotree filesystem reveal right',
        },
      },
    },
    config = function(_, opts)
      require('edgy').setup(opts)

      local group = vim.api.nvim_create_augroup('config-edgy-sidebar', { clear = true })

      vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = 'DashboardLoaded',
        desc = 'Open Edgy sidebar when dashboard loads',
        callback = function()
          vim.schedule(ensure_sidebar)
        end,
      })

      vim.api.nvim_create_autocmd('BufEnter', {
        group = group,
        desc = 'Open Edgy sidebar when entering real files',
        callback = function(args)
          if not is_real_file_buffer(args.buf) then
            return
          end
          vim.schedule(ensure_sidebar)
        end,
      })

      vim.api.nvim_create_autocmd({ 'TabEnter', 'TabNewEntered' }, {
        group = group,
        desc = 'Re-open Edgy sidebar when entering tabs',
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          if not is_sidebar_candidate(buf) then
            return
          end
          vim.schedule(ensure_sidebar)
        end,
      })
    end,
  },
}
