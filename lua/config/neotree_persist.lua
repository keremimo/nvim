local M = {}

local pending = false
local queued_attempts = 0

function M.is_exiting()
  return vim.v.exiting ~= nil and vim.v.exiting ~= vim.NIL and vim.v.exiting ~= 0
end

local ignored_filetypes = {
  ['neo-tree'] = true,
  dashboard = true,
  lazy = true,
  mason = true,
}

local function is_valid_win(win)
  return type(win) == 'number' and win > 0 and vim.api.nvim_win_is_valid(win)
end

local function is_valid_tab(tab)
  return type(tab) == 'number' and tab > 0 and vim.api.nvim_tabpage_is_valid(tab)
end

local function is_editor_win(win)
  if not is_valid_win(win) or vim.fn.win_gettype(win) ~= '' then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= '' then
    return false
  end

  if ignored_filetypes[vim.bo[buf].filetype] then
    return false
  end

  return vim.api.nvim_buf_get_name(buf) ~= '' or vim.bo[buf].modified
end

local function restore_window(tab, win)
  if not is_valid_tab(tab) then
    return
  end

  pcall(vim.api.nvim_set_current_tabpage, tab)
  if is_valid_win(win) and vim.api.nvim_win_get_tabpage(win) == tab then
    pcall(vim.api.nvim_set_current_win, win)
  end
end

function M.has_sidebar(tab)
  if not is_valid_tab(tab) then
    return false
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if is_valid_win(win) and vim.fn.win_gettype(win) == '' then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'neo-tree' then
        return true
      end
    end
  end

  return false
end

function M.editor_win(tab)
  if not is_valid_tab(tab) then
    return nil
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if is_editor_win(win) then
      return win
    end
  end

  return nil
end

function M.show_for_tab(tab, editor_win)
  if M.is_exiting() or not is_valid_tab(tab) or M.has_sidebar(tab) then
    return
  end

  editor_win = editor_win or M.editor_win(tab)
  if not is_valid_win(editor_win) then
    return
  end

  pcall(vim.api.nvim_set_current_tabpage, tab)
  pcall(vim.api.nvim_set_current_win, editor_win)

  local ok, neotree_command = pcall(require, 'neo-tree.command')
  if ok then
    local function show()
      neotree_command.execute {
        action = 'show',
        source = 'filesystem',
        position = 'right',
        reveal = false,
      }
    end

    pcall(show)
    if not M.has_sidebar(tab) then
      pcall(show)
    end
    if M.has_sidebar(tab) then
      return
    end

    pcall(neotree_command.execute, {
      action = 'show',
      source = 'filesystem',
      position = 'right',
      reveal = false,
      dir = vim.fn.getcwd(),
    })
    if M.has_sidebar(tab) then
      return
    end
  end

  pcall(vim.cmd, 'silent! Neotree action=show source=filesystem position=right reveal=false')
end

function M.ensure_all()
  if M.is_exiting() then
    return
  end

  local original_tab = vim.api.nvim_get_current_tabpage()
  local original_win = vim.api.nvim_get_current_win()

  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if not M.has_sidebar(tab) then
      M.show_for_tab(tab)
    end
  end

  restore_window(original_tab, original_win)
end

function M.ensure_current()
  if M.is_exiting() then
    return
  end

  local tab = vim.api.nvim_get_current_tabpage()
  local win = vim.api.nvim_get_current_win()

  M.show_for_tab(tab, win)
  restore_window(tab, win)
end

function M.needs_sidebar()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if not M.has_sidebar(tab) and M.editor_win(tab) then
      return true
    end
  end

  return false
end

function M.schedule_all(delay, attempts)
  if M.is_exiting() then
    return
  end

  attempts = attempts or 1

  if pending then
    queued_attempts = math.max(queued_attempts, attempts)
    return
  end

  pending = true

  vim.defer_fn(function()
    local followup_attempts = math.max(queued_attempts, attempts - 1)
    queued_attempts = 0

    local ok, err = pcall(M.ensure_all)
    pending = false

    if not ok then
      vim.notify('Neo-tree persistence failed: ' .. tostring(err), vim.log.levels.ERROR)
    end

    if followup_attempts > 0 and not M.is_exiting() and M.needs_sidebar() then
      M.schedule_all(delay, followup_attempts)
    end
  end, delay or 60)
end

function M.open_node_in_new_tab(state)
  local node = state and state.tree and state.tree:get_node()
  if not node then
    return
  end

  local path = node.path
  if not path and type(node.get_id) == 'function' then
    path = node:get_id()
  end

  if not path or path == '' then
    return
  end

  if node.type == 'directory' or vim.fn.isdirectory(path) == 1 then
    local ok, commands = pcall(require, 'neo-tree.sources.filesystem.commands')
    if ok and type(commands.open) == 'function' then
      commands.open(state)
    end
    return
  end

  if pcall(vim.cmd, 'tabnew ' .. vim.fn.fnameescape(path)) then
    vim.defer_fn(M.ensure_current, 20)
  end
end

return M
