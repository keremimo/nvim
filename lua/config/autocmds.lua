local tabflow = require 'config.tabflow'

local group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Briefly highlight yanked text',
  group = group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

local reload_group = vim.api.nvim_create_augroup('kickstart-auto-reload', { clear = true })

vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose' }, {
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

local large_file_group = vim.api.nvim_create_augroup('config-large-file', { clear = true })
local max_large_file_size = 1024 * 1024
local uv = vim.uv or vim.loop

vim.api.nvim_create_autocmd('BufReadPre', {
  desc = 'Enable large-file safeguards',
  group = large_file_group,
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].buftype ~= '' then
      return
    end

    local path = vim.api.nvim_buf_get_name(buf)
    if path == '' then
      return
    end

    local stat = uv.fs_stat(path)
    if not stat or stat.size <= max_large_file_size then
      return
    end

    vim.b[buf].large_file = true
    vim.bo[buf].swapfile = false
    vim.bo[buf].undofile = false
    vim.bo[buf].synmaxcol = 200
    vim.bo[buf].foldmethod = 'manual'
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Disable expensive features for large files',
  group = large_file_group,
  callback = function(args)
    local buf = args.buf
    if not vim.b[buf].large_file then
      return
    end

    pcall(vim.treesitter.stop, buf)
    vim.diagnostic.enable(false, { bufnr = buf })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Work around Neovim 0.12 markdown treesitter injection crash',
  group = vim.api.nvim_create_augroup('config-markdown-treesitter-guard', { clear = true }),
  pattern = { 'markdown' },
  callback = function(args)
    vim.treesitter.stop(args.buf)
    vim.bo[args.buf].syntax = 'markdown'
  end,
})

local auto_quit_group = vim.api.nvim_create_augroup('config-auto-quit-empty', { clear = true })

local function quit_if_empty()
  if vim.v.vim_did_enter == 0 or vim.v.exiting ~= 0 then
    return
  end

  vim.schedule(function()
    if vim.v.exiting ~= 0 then
      return
    end
    if tabflow.has_meaningful_editor_windows() then
      return
    end
    pcall(vim.cmd, 'qa')
  end)
end

vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout', 'WinClosed', 'TabClosed' }, {
  desc = 'Quit Neovim when only side panels remain',
  group = auto_quit_group,
  callback = quit_if_empty,
})

local neotree_persist_group = vim.api.nvim_create_augroup('config-neotree-persistent-pane', { clear = true })
local neotree_sidebar_pending = false

local function has_neotree_in_tab(tab)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if vim.api.nvim_win_is_valid(win) and vim.fn.win_gettype(win) == '' then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'neo-tree' then
        return true
      end
    end
  end
  return false
end

local function has_regular_editor_in_tab(tab)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if vim.api.nvim_win_is_valid(win) and vim.fn.win_gettype(win) == '' then
      local buf = vim.api.nvim_win_get_buf(win)
      local bt = vim.bo[buf].buftype
      local ft = vim.bo[buf].filetype
      if bt == '' and ft ~= 'neo-tree' and ft ~= 'dashboard' and ft ~= 'lazy' and ft ~= 'mason' then
        return true
      end
    end
  end
  return false
end

local function force_show_neotree_sidebar()
  local original_win = vim.api.nvim_get_current_win()
  local ok, neotree_command = pcall(require, 'neo-tree.command')
  if ok then
    neotree_command.execute {
      action = 'focus',
      source = 'filesystem',
      position = 'right',
    }
    if vim.api.nvim_win_is_valid(original_win) then
      pcall(vim.api.nvim_set_current_win, original_win)
    end
  else
    pcall(vim.cmd, 'silent! Neotree show position=right filesystem')
  end
end

local function ensure_neotree_sidebar()
  if vim.v.exiting ~= 0 then
    return
  end
  if neotree_sidebar_pending then
    return
  end

  neotree_sidebar_pending = true

  local tab = vim.api.nvim_get_current_tabpage()

  vim.defer_fn(function()
    neotree_sidebar_pending = false

    if vim.v.exiting ~= 0 or not vim.api.nvim_tabpage_is_valid(tab) then
      return
    end

    if tab ~= vim.api.nvim_get_current_tabpage() then
      return
    end

    local current_buf = vim.api.nvim_get_current_buf()
    local current_ft = vim.bo[current_buf].filetype
    local current_bt = vim.bo[current_buf].buftype
    if current_ft == 'neo-tree' or current_ft == 'dashboard' or current_ft == 'lazy' or current_ft == 'mason' or current_bt ~= '' then
      return
    end

    if has_neotree_in_tab(tab) or not has_regular_editor_in_tab(tab) then
      return
    end

    force_show_neotree_sidebar()
  end, 60)
end

vim.api.nvim_create_autocmd({ 'VimEnter', 'TabEnter', 'TabNewEntered', 'BufEnter', 'WinClosed' }, {
  desc = 'Keep Neo-tree visible as a persistent sidebar per tab',
  group = neotree_persist_group,
  callback = ensure_neotree_sidebar,
})
