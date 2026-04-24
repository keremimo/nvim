return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'TSInstall', 'TSUpdate', 'TSUninstall', 'TSBufEnable', 'TSBufDisable', 'TSModuleInfo' },
    build = ':TSUpdate',
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
      auto_install = false,
      highlight = {
        enable = true,
        disable = { 'markdown', 'markdown_inline' },
        additional_vim_regex_highlighting = { 'ruby', 'markdown' },
      },
      indent = {
        enable = true,
        disable = { 'ruby', 'markdown' },
      },
      endwise = { enable = true },
    },
    config = function(_, opts)
      local ok_configs, configs = pcall(require, 'nvim-treesitter.configs')
      if ok_configs then
        configs.setup(opts)
        return
      end

      local ok_ts, treesitter = pcall(require, 'nvim-treesitter')
      if ok_ts then
        treesitter.setup {}
      end
    end,
  },
}
