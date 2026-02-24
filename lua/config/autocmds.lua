local group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Briefly highlight yanked text',
  group = group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

local reload_group = vim.api.nvim_create_augroup('kickstart-auto-reload', { clear = true })

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  desc = 'Reload files changed outside of Neovim',
  group = reload_group,
  callback = function()
    if vim.bo.buftype ~= '' then
      return
    end
    if vim.fn.mode() == 'c' then
      return
    end
    vim.cmd 'checktime'
  end,
})

local split_group = vim.api.nvim_create_augroup('config-balance-splits', { clear = true })
local balancing_splits = false

local function is_excluded_split_buf(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return true
  end

  local buftype = vim.bo[buf].buftype
  local filetype = vim.bo[buf].filetype
  if filetype == 'neo-tree' then
    return true
  end
  if buftype ~= '' then
    return true
  end

  local name = vim.api.nvim_buf_get_name(buf)
  if name:match '^term://' then
    return true
  end

  return false
end

local function editor_window_count()
  local count = 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if not is_excluded_split_buf(buf) then
        count = count + 1
      end
    end
  end
  return count
end

local function balance_editor_splits()
  if balancing_splits then
    return
  end
  if editor_window_count() < 2 then
    return
  end

  balancing_splits = true
  local current = vim.api.nvim_get_current_win()
  pcall(vim.cmd, 'wincmd =')
  if vim.api.nvim_win_is_valid(current) then
    pcall(vim.api.nvim_set_current_win, current)
  end
  balancing_splits = false
end

vim.api.nvim_create_autocmd('WinNew', {
  desc = 'Keep normal editor splits balanced without touching sidebars',
  group = split_group,
  callback = function(args)
    local new_win = tonumber(args.match)
    local attempts = 0

    local function maybe_balance()
      if not new_win or not vim.api.nvim_win_is_valid(new_win) then
        return
      end

      local buf = vim.api.nvim_win_get_buf(new_win)
      if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      local buftype = vim.bo[buf].buftype
      local filetype = vim.bo[buf].filetype
      local name = vim.api.nvim_buf_get_name(buf)
      if buftype == '' and filetype == '' and name == '' and attempts < 8 then
        attempts = attempts + 1
        vim.defer_fn(maybe_balance, 30)
        return
      end

      if is_excluded_split_buf(buf) then
        return
      end

      balance_editor_splits()
    end

    vim.defer_fn(maybe_balance, 20)
  end,
})
