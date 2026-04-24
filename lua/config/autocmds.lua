local tabflow = require 'config.tabflow'

local function is_exiting()
  return vim.v.exiting ~= nil and vim.v.exiting ~= vim.NIL and vim.v.exiting ~= 0
end

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

local function has_dashboard_window()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'dashboard' then
          return true
        end
      end
    end
  end

  return false
end

local function quit_if_empty()
  if vim.v.vim_did_enter == 0 or is_exiting() then
    return
  end

  vim.schedule(function()
    if is_exiting() then
      return
    end
    if has_dashboard_window() then
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

local neotree_persist = require 'config.neotree_persist'
local neotree_persist_group = vim.api.nvim_create_augroup('config-neotree-persistent-pane', { clear = true })

vim.api.nvim_create_autocmd({ 'TabEnter', 'TabNewEntered', 'BufEnter', 'BufWinEnter', 'WinClosed' }, {
  desc = 'Keep Neo-tree visible as a persistent sidebar per tab',
  group = neotree_persist_group,
  callback = function()
    neotree_persist.schedule_all(80, 6)
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Restore Neo-tree sidebars after startup settles',
  group = neotree_persist_group,
  callback = function()
    neotree_persist.schedule_all(250, 20)
  end,
})

vim.api.nvim_create_autocmd('SessionLoadPost', {
  desc = 'Restore Neo-tree sidebars after loading a Vim session',
  group = neotree_persist_group,
  callback = function()
    neotree_persist.schedule_all(250, 20)
  end,
})

vim.api.nvim_create_autocmd('User', {
  desc = 'Restore Neo-tree sidebars after plugin startup and Persistence loads',
  group = neotree_persist_group,
  pattern = { 'LazyDone', 'VeryLazy', 'PersistenceLoadPost' },
  callback = function()
    neotree_persist.schedule_all(250, 20)
  end,
})
