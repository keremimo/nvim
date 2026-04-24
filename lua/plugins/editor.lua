return {
  'tpope/vim-sleuth',

  {
    'folke/todo-comments.nvim',
    event = 'VeryLazy',
    cmd = { 'TodoTrouble', 'TodoTelescope', 'TodoLocList', 'TodoQuickFix' },
    keys = {
      {
        ']t',
        function()
          require('todo-comments').jump_next()
        end,
        desc = 'Next todo comment',
      },
      {
        '[t',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = 'Previous todo comment',
      },
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
      require('mini.surround').setup()
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      check_ts = true,
      disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
      fast_wrap = {},
    },
  },

  {
    'andweeb/presence.nvim',
    event = 'VeryLazy',
    opts = {
      auto_update = true,
      neovim_image_text = 'Neovim',
      main_image = 'neovim',
      enable_line_number = false,
      workspace_text = 'Working on a cool project',
      blacklist = {},
      buttons = true,
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    init = function()
      local group = vim.api.nvim_create_augroup('config-gitsigns-highlights', { clear = true })

      local function apply_git_highlights()
        vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = '#6ecb63' })
        vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = '#e5c07b' })
        vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = '#e06c75' })
        vim.api.nvim_set_hl(0, 'GitSignsChangedelete', { fg = '#d19a66' })
        vim.api.nvim_set_hl(0, 'GitSignsTopdelete', { fg = '#e06c75' })
        vim.api.nvim_set_hl(0, 'GitSignsUntracked', { fg = '#56b6c2' })
        vim.api.nvim_set_hl(0, 'GitSignsAddNr', { fg = '#6ecb63' })
        vim.api.nvim_set_hl(0, 'GitSignsChangeNr', { fg = '#e5c07b' })
        vim.api.nvim_set_hl(0, 'GitSignsDeleteNr', { fg = '#e06c75' })
        vim.api.nvim_set_hl(0, 'GitSignsChangedeleteNr', { fg = '#d19a66' })
        vim.api.nvim_set_hl(0, 'GitSignsTopdeleteNr', { fg = '#e06c75' })
        vim.api.nvim_set_hl(0, 'GitSignsUntrackedNr', { fg = '#56b6c2' })
        vim.api.nvim_set_hl(0, 'GitSignsCurrentLineBlame', { fg = '#7f848e', italic = true })
      end

      vim.api.nvim_create_autocmd('ColorScheme', {
        group = group,
        callback = apply_git_highlights,
      })

      apply_git_highlights()
    end,
    opts = {
      signcolumn = false,
      numhl = true,
      signs = {
        add = { text = '', show_count = false },
        change = { text = '', show_count = false },
        delete = { text = '', show_count = false },
        topdelete = { text = '', show_count = false },
        changedelete = { text = '', show_count = false },
        untracked = { text = '', show_count = false },
      },
      signs_staged = {
        add = { text = '', show_count = false },
        change = { text = '', show_count = false },
        delete = { text = '', show_count = false },
        topdelete = { text = '', show_count = false },
        changedelete = { text = '', show_count = false },
        untracked = { text = '', show_count = false },
      },
      signs_staged_enable = true,
      word_diff = false,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'right_align',
        delay = 250,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
      preview_config = {
        border = 'rounded',
        style = 'minimal',
        relative = 'cursor',
        row = 1,
        col = 0,
      },
      on_attach = function(buffer)
        local gitsigns = require 'gitsigns'
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end

        map('n', '<leader>hb', function()
          gitsigns.blame_line { full = true }
        end, 'Git: [B]lame Line')
        map('n', '<leader>hp', gitsigns.preview_hunk, 'Git: [P]review Hunk')
        map('n', '<leader>hi', gitsigns.preview_hunk_inline, 'Git: Preview [I]nline Hunk')
        map('n', '<leader>hS', gitsigns.stage_buffer, 'Git: [S]tage Buffer')
        map('n', '<leader>hR', gitsigns.reset_buffer, 'Git: [R]eset Buffer')
        map('n', '<leader>hB', gitsigns.blame, 'Git: [B]lame Buffer')
        map('n', '<leader>hq', gitsigns.setqflist, 'Git: Hunks to [Q]uickfix')
        map('n', '<leader>hQ', function()
          gitsigns.setqflist 'all'
        end, 'Git: Repo hunks to [Q]uickfix')
        map('n', '<leader>hd', gitsigns.diffthis, 'Git: [D]iff This')
        map('n', '<leader>hD', function()
          gitsigns.diffthis '~'
        end, 'Git: [D]iff Previous')

        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, '[T]oggle Git [B]lame')
        map('n', '<leader>tw', gitsigns.toggle_word_diff, '[T]oggle Git [W]ord Diff')

        map('n', ']h', gitsigns.next_hunk, 'Git: Next Hunk')
        map('n', '[h', gitsigns.prev_hunk, 'Git: Previous Hunk')
        map('n', '<leader>hs', gitsigns.stage_hunk, 'Git: [S]tage Hunk')
        map('n', '<leader>hr', gitsigns.reset_hunk, 'Git: [R]eset Hunk')
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'Git: [S]tage Hunk')
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'Git: [R]eset Hunk')
      end,
    },
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = false,
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
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    },
  },
}
