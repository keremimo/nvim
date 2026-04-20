return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 1000,
  },
  {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 1000,
  },
  {
    'zaldih/themery.nvim',
    lazy = false,
    priority = 999,
    config = function()
      require('themery').setup {
        themes = {
          {
            name = 'Tokyo Night Moon',
            colorscheme = 'tokyonight-moon',
          },
          {
            name = 'Rose Pine Main',
            colorscheme = 'rose-pine-main',
          },
          {
            name = 'Gruvbox Material Hard',
            colorscheme = 'gruvbox-material',
            before = [[
              vim.g.gruvbox_material_background = 'hard'
              vim.g.gruvbox_material_enable_italic = 0
              vim.g.gruvbox_material_better_performance = 1
            ]],
          },
        },
        livePreview = true,
      }

      if vim.g.colors_name == nil or vim.g.colors_name == 'default' then
        pcall(vim.cmd.colorscheme, 'tokyonight-moon')
      end
    end,
  },
}
