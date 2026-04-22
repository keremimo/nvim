local function toggle_oil_float()
  local ok, oil = pcall(require, 'oil')
  if ok and type(oil.toggle_float) == 'function' then
    oil.toggle_float()
    return
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'oil' and vim.api.nvim_win_get_config(win).relative ~= '' then
      vim.api.nvim_win_close(win, true)
      return
    end
  end

  vim.cmd 'Oil --float'
end

local function select_oil_entry_tab_drop()
  local ok, oil = pcall(require, 'oil')
  if not ok then
    return
  end

  local function find_replaceable_empty_win()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(win).relative == '' then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype ~= 'oil' and vim.bo[buf].buftype == '' and not vim.bo[buf].modified and vim.api.nvim_buf_get_name(buf) == '' then
          return win, buf
        end
      end
    end
  end

  local function tab_drop_buffer(buf_id)
    local wins = vim.fn.win_findbuf(buf_id)
    if #wins > 0 and vim.fn.win_gotoid(wins[1]) == 1 then
      return
    end

    local empty_win, empty_buf = find_replaceable_empty_win()
    if empty_win and vim.api.nvim_win_is_valid(empty_win) then
      vim.bo[empty_buf].bufhidden = 'wipe'
      vim.api.nvim_set_current_win(empty_win)
      vim.api.nvim_set_current_buf(buf_id)
      return
    end

    vim.cmd.tabnew()
    local new_buf = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_get_name(new_buf) == '' and vim.bo[new_buf].buftype == '' and not vim.bo[new_buf].modified then
      vim.bo[new_buf].bufhidden = 'wipe'
    end
    vim.api.nvim_set_current_buf(buf_id)
  end

  oil.select {
    close = true,
    handle_buffer_callback = function(buf_id)
      local name = vim.api.nvim_buf_get_name(buf_id)
      if name == '' or name:sub(-1) == '/' or name:match '^oil://' then
        vim.api.nvim_set_current_buf(buf_id)
        return
      end

      tab_drop_buffer(buf_id)
    end,
  }
end

return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'refractalize/oil-git-status.nvim',
    },
    cmd = { 'Oil' },
    keys = {
      { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' },
      {
        '<leader>-',
        function()
          toggle_oil_float()
        end,
        desc = 'Toggle Oil (float)',
      },
      {
        '<leader>e',
        function()
          toggle_oil_float()
        end,
        desc = 'Toggle Explorer (Oil float)',
      },
      {
        '<C-e>',
        function()
          toggle_oil_float()
        end,
        desc = 'Toggle Explorer (Oil float)',
      },
    },
    opts = {
      default_file_explorer = true,
      columns = { 'icon' },
      win_options = {
        signcolumn = 'yes:2',
      },
      keymaps = {
        ['<CR>'] = {
          callback = select_oil_entry_tab_drop,
          desc = 'Open entry with tab drop',
          mode = 'n',
        },
      },
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 2,
        border = 'rounded',
      },
    },
    config = function(_, opts)
      require('oil').setup(opts)
      require('oil-git-status').setup()
    end,
  },
}
