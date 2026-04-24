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

local function ensure_sidebar_preserve_focus()
  local tab = vim.api.nvim_get_current_tabpage()
  local win = vim.api.nvim_get_current_win()

  local ok, neotree_command = pcall(require, 'neo-tree.command')
  if ok then
    pcall(neotree_command.execute, {
      action = 'focus',
      source = 'filesystem',
      position = 'right',
    })
  else
    pcall(vim.cmd, 'silent! Neotree focus position=right filesystem')
  end

  if vim.api.nvim_tabpage_is_valid(tab) and vim.api.nvim_get_current_tabpage() == tab and vim.api.nvim_win_is_valid(win) then
    pcall(vim.api.nvim_set_current_win, win)
  end
end

local function open_tab_drop_persistent(state)
  local node = state and state.tree and state.tree:get_node()
  if not node then
    return
  end

  local path = node.path
  if not path and type(node.get_id) == 'function' then
    path = node:get_id()
  end

  if node.type == 'directory' or not path or vim.fn.isdirectory(path) == 1 then
    vim.cmd 'Neotree action=open'
    return
  end

  local ok = pcall(vim.cmd, 'tab drop ' .. vim.fn.fnameescape(path))
  if not ok then
    return
  end

  vim.schedule(ensure_sidebar_preserve_focus)
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
        open_tab_drop_persistent = open_tab_drop_persistent,
      },
      event_handlers = {
        {
          event = 'file_opened',
          handler = function()
            vim.defer_fn(function()
              if vim.v.exiting ~= 0 then
                return
              end
              if vim.bo[vim.api.nvim_get_current_buf()].filetype == 'neo-tree' then
                return
              end
              pcall(vim.cmd, 'silent! Neotree show position=right filesystem')
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
            ['<CR>'] = 'open_tab_drop_persistent',
            ['<2-LeftMouse>'] = 'open_tab_drop_persistent',
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
    end,
  },
}
