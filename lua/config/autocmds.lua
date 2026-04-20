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
