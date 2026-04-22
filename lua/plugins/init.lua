local M = {}

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

local function bootstrap_lazy()
  local uv = vim.uv or vim.loop
  if not uv.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
      error('Error cloning lazy.nvim:\n' .. out)
    end
  end
  vim.opt.rtp:prepend(lazypath)
end

function M.setup()
  bootstrap_lazy()

  require('lazy').setup({
    { import = 'plugins.editor' },
    { import = 'plugins.ui' },
    { import = 'plugins.lsp' },
    { import = 'plugins.treesitter' },
    { import = 'custom.plugins' },
  }, {
    checker = {
      enabled = false,
    },
    change_detection = {
      enabled = false,
      notify = false,
    },
    rocks = {
      enabled = false,
    },
    performance = {
      rtp = {
        disabled_plugins = {
          '2html_plugin',
          'getscript',
          'getscriptPlugin',
          'gzip',
          'logipat',
          'netrw',
          'netrwPlugin',
          'netrwSettings',
          'netrwFileHandlers',
          'rrhelper',
          'tar',
          'tarPlugin',
          'tohtml',
          'tutor',
          'vimball',
          'vimballPlugin',
          'zip',
          'zipPlugin',
        },
      },
    },
    ui = {
      icons = vim.g.have_nerd_font and {} or {
        cmd = '⌘',
        config = '🛠',
        event = '📅',
        ft = '📂',
        init = '⚙',
        keys = '🗝',
        plugin = '🔌',
        runtime = '💻',
        require = '🌙',
        source = '📄',
        start = '🚀',
        task = '📌',
        lazy = '💤 ',
      },
    },
  })
end

return M
