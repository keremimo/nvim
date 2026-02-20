return {
  {
    'CRAG666/code_runner.nvim',
    opts = {
      mode = 'float',
      float = { border = 'single' },
      focus = true,
      startinsert = true,
      filetype = {
        go = { 'cd $dir &&', 'go run .' },
      },
    },
    config = function(_, opts)
      require('code_runner').setup(opts)
    end,
  },

  {
    'CRAG666/betterTerm.nvim',
    opts = {
      prefix = 'CRAG',
      startInserted = true,
      position = 'right',
      size = 80,
      jump_tab_mapping = '<A-$tab>',
    },
    config = function(_, opts)
      require('betterTerm').setup(opts)
    end,
  },

  'tpope/vim-sleuth',

  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.diff').setup()
      require('mini.surround').setup()
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
      },
      on_attach = function(buffer)
        local gitsigns = require 'gitsigns'
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end

        map('n', '<leader>hb', gitsigns.blame_line, 'Git: [B]lame Line')
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, '[T]oggle Git [B]lame')
        map('n', ']h', gitsigns.next_hunk, 'Git: Next Hunk')
        map('n', '[h', gitsigns.prev_hunk, 'Git: Previous Hunk')
        map('n', '<leader>hs', gitsigns.stage_hunk, 'Git: [S]tage Hunk')
        map('n', '<leader>hr', gitsigns.reset_hunk, 'Git: [R]eset Hunk')
      end,
    },
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = true,
        theme = 'catppuccin',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
          refresh_time = 16,
          events = {
            'WinEnter',
            'BufEnter',
            'BufWritePost',
            'SessionLoadPost',
            'FileChangedShellPost',
            'VimResized',
            'Filetype',
            'CursorMoved',
            'CursorMovedI',
            'ModeChanged',
          },
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    },
  },
}
