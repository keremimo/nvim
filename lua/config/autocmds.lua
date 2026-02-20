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
