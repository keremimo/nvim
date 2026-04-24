local neotree_persist = require 'config.neotree_persist'

local function jump_to_editor_window()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local previous_win = vim.fn.win_getid(vim.fn.winnr '#')

  if previous_win > 0 and vim.api.nvim_win_is_valid(previous_win) and vim.api.nvim_win_get_tabpage(previous_win) == current_tab then
    local previous_buf = vim.api.nvim_win_get_buf(previous_win)
    if vim.fn.win_gettype(previous_win) == '' and vim.bo[previous_buf].filetype ~= 'neo-tree' then
      vim.api.nvim_set_current_win(previous_win)
      return true
    end
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
    if vim.api.nvim_win_is_valid(win) and vim.fn.win_gettype(win) == '' then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype ~= 'neo-tree' then
        vim.api.nvim_set_current_win(win)
        return true
      end
    end
  end

  return false
end

local function toggle_neotree_focus()
  if vim.bo[vim.api.nvim_get_current_buf()].filetype == 'neo-tree' then
    jump_to_editor_window()
    return
  end

  vim.cmd 'Neotree focus position=right filesystem'
end

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = { 'Neotree' },
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '-', '<cmd>Neotree reveal_force_cwd position=right filesystem<cr>', desc = 'Reveal in explorer' },
      { '<leader>-', '<cmd>Neotree reveal_force_cwd position=right filesystem<cr>', desc = 'Reveal in explorer' },
      { '<leader>e', '<cmd>Neotree reveal_force_cwd position=right filesystem<cr>', desc = 'Reveal in explorer' },
      { '<C-e>', toggle_neotree_focus, desc = 'Toggle focus: editor/explorer' },
    },
    opts = {
      close_if_last_window = false,
      popup_border_style = 'rounded',
      enable_git_status = true,
      enable_diagnostics = true,
      commands = {
        open_in_new_tab_persistent = neotree_persist.open_node_in_new_tab,
      },
      event_handlers = {
        {
          event = 'file_opened',
          handler = function()
            vim.defer_fn(function()
              if neotree_persist.is_exiting() then
                return
              end
              if vim.bo[vim.api.nvim_get_current_buf()].filetype == 'neo-tree' then
                return
              end
              neotree_persist.ensure_current()
            end, 20)
          end,
        },
      },
      window = {
        position = 'right',
        width = 34,
        mappings = {
          ['<bs>'] = 'navigate_up',
          ['-'] = 'navigate_up',
          ['h'] = 'close_node',
          ['l'] = 'open',
        },
      },
      filesystem = {
        window = {
          mappings = {
            ['<CR>'] = 'open_in_new_tab_persistent',
            ['<2-LeftMouse>'] = 'open_in_new_tab_persistent',
          },
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        use_libuv_file_watcher = true,
      },
    },
    config = function(_, opts)
      require('neo-tree').setup(opts)
      neotree_persist.schedule_all(250, 20)
    end,
  },
}
