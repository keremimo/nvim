return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'TSInstall', 'TSUpdate', 'TSUninstall', 'TSBufEnable', 'TSBufDisable', 'TSModuleInfo' },
    build = ':TSUpdate',
    main = 'nvim-treesitter',
    dependencies = { 'RRethy/nvim-treesitter-endwise' },
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'ruby',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = {
        enable = true,
        disable = { 'ruby' },
      },
    },
  },
}
