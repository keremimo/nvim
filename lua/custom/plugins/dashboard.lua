return {
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      local ascii = require 'ascii'

      require('dashboard').setup {
        config = {
          week_header = {
            enable = false,
          },
          header = ascii.get_random_global(),
        },
      }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
  },
}
