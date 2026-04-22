-- Plugin: folke/flash.nvim
-- Installed via store.nvim

return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  ---@type Flash.Config
  opts = {
    labels = 'asdfghjklqwertyuiopzxcvbnm',
    modes = {
      treesitter = {
        labels = 'asdfghjklqwertyuiopzxcvbnm',
        jump = { pos = 'range', autojump = true },
        label = { before = true, after = false, style = 'inline' },
        highlight = {
          backdrop = false,
          matches = false,
        },
      },
    },
  },
  keys = {
    {
      's',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
    {
      'S',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').treesitter()
      end,
      desc = 'Flash Treesitter',
    },
    {
      '<C-Space>',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').treesitter {
          actions = {
            ['<C-Space>'] = 'next',
            ['<C-@>'] = 'next',
            ['<BS>'] = 'prev',
          },
        }
      end,
      desc = 'Treesitter Incremental Selection',
    },
    {
      '<C-@>',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').treesitter {
          actions = {
            ['<C-Space>'] = 'next',
            ['<C-@>'] = 'next',
            ['<BS>'] = 'prev',
          },
        }
      end,
      desc = 'Treesitter Incremental Selection',
    },
    {
      'r',
      mode = 'o',
      function()
        require('flash').remote()
      end,
      desc = 'Remote Flash',
    },
    {
      'R',
      mode = { 'o', 'x' },
      function()
        require('flash').treesitter_search()
      end,
      desc = 'Treesitter Search',
    },
    {
      '<c-s>',
      mode = { 'c' },
      function()
        require('flash').toggle()
      end,
      desc = 'Toggle Flash Search',
    },
  },
}
