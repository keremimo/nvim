return {
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
      local logo = {
        '',
        '███╗   ██╗██╗   ██╗██╗███╗   ███╗',
        '████╗  ██║██║   ██║██║████╗ ████║',
        '██╔██╗ ██║██║   ██║██║██╔████╔██║',
        '██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║',
        '██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║',
        '╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝',
        '',
      }

      return {
        theme = 'doom',
        hide = {
          statusline = false,
          tabline = false,
          winbar = false,
        },
        config = {
          header = logo,
          center = {
            {
              icon = '  ',
              desc = 'Find File',
              key = 'f',
              keymap = 'SPC s f',
              action = 'Telescope find_files',
            },
            {
              icon = '  ',
              desc = 'Recent Files',
              key = 'r',
              keymap = 'SPC s .',
              action = 'Telescope oldfiles',
            },
            {
              icon = '  ',
              desc = 'Live Grep',
              key = 'g',
              keymap = 'SPC s g',
              action = 'Telescope live_grep',
            },
            {
              icon = '  ',
              desc = 'Projects',
              key = 'p',
              keymap = 'SPC p p',
              action = 'Telescope projects',
            },
            {
              icon = '  ',
              desc = 'Restore Session',
              key = 's',
              keymap = 'SPC p s',
              action = function()
                require('persistence').load()
              end,
            },
            {
              icon = '  ',
              desc = 'Coding Profile',
              key = 'c',
              keymap = 'SPC u c',
              action = function()
                require('config.profiles').apply 'coding'
              end,
            },
            {
              icon = '  ',
              desc = 'Writing Profile',
              key = 'w',
              keymap = 'SPC u w',
              action = function()
                require('config.profiles').apply 'writing'
              end,
            },
            {
              icon = '  ',
              desc = 'Debugging Profile',
              key = 'd',
              keymap = 'SPC u d',
              action = function()
                require('config.profiles').apply 'debugging'
              end,
            },
            {
              icon = '  ',
              desc = 'Lazy',
              key = 'l',
              keymap = ':Lazy',
              action = 'Lazy',
            },
            {
              icon = '  ',
              desc = 'Quit',
              key = 'q',
              keymap = ':qa',
              action = 'qa',
            },
          },
          footer = {
            'Ready.',
          },
        },
      }
    end,
  },
}
