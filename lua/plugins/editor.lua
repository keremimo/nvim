return {
  'tpope/vim-sleuth',

  {
    'folke/todo-comments.nvim',
    event = 'VeryLazy',
    cmd = { 'TodoTrouble', 'TodoTelescope', 'TodoLocList', 'TodoQuickFix' },
    keys = {
      { ']t', function() require('todo-comments').jump_next() end, desc = 'Next todo comment' },
      { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous todo comment' },
      { '<leader>st', '<cmd>TodoTelescope<cr>', desc = '[S]earch [T]odo comments' },
      { '<leader>xt', '<cmd>TodoTrouble<cr>', desc = 'Todo comments (Trouble)' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  {
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    config = function()
      require('mini.diff').setup()
      require('mini.surround').setup()
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      current_line_blame = false,
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
        theme = 'catppuccin-nvim',
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
