local M = {}

local function is_valid_win(win)
  return type(win) == 'number' and win > 0 and vim.api.nvim_win_is_valid(win)
end

local function is_valid_buf(buf)
  return type(buf) == 'number' and buf > 0 and vim.api.nvim_buf_is_valid(buf)
end

local function is_editor_buffer(buf)
  return is_valid_buf(buf) and vim.bo[buf].buftype == ''
end

function M.is_real_editor_window(win)
  if not is_valid_win(win) or vim.fn.win_gettype(win) ~= '' then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win)
  return is_editor_buffer(buf)
end

local function is_meaningful_editor_window(win)
  if not M.is_real_editor_window(win) then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local name = vim.api.nvim_buf_get_name(buf)
  return name ~= '' or vim.bo[buf].modified
end

function M.count_real_editor_windows(tab)
  local count = 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if M.is_real_editor_window(win) then
      count = count + 1
    end
  end
  return count
end

function M.has_meaningful_editor_windows()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if is_meaningful_editor_window(win) then
        return true
      end
    end
  end
  return false
end

function M.close_current_target()
  local tab = vim.api.nvim_get_current_tabpage()
  local tab_count = #vim.api.nvim_list_tabpages()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local is_file_buffer = is_editor_buffer(buf)

  if is_file_buffer and M.count_real_editor_windows(tab) <= 1 then
    if tab_count > 1 then
      vim.cmd 'tabclose'
    else
      vim.cmd 'qa'
    end
    return
  end

  if is_file_buffer then
    local ok = pcall(vim.cmd, 'bdelete')
    if ok then
      return
    end
  end

  pcall(vim.cmd, 'q')

  vim.schedule(function()
    if vim.v.exiting ~= 0 then
      return
    end
    if M.has_meaningful_editor_windows() then
      return
    end
    pcall(vim.cmd, 'qa')
  end)
end

return M
