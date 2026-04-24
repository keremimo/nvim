return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>b', group = '[B]uffers' },
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument / Debug' },
        { '<leader>g', group = '[G]it' },
        { '<leader>j', group = '[J]ump list' },
        { '<leader>l', group = '[L]SP Peek' },
        { '<leader>m', group = '[M]ake / Tasks' },
        { '<leader>n', group = '[N]eotest' },
        { '<leader>o', group = 'GitHub [O]cto' },
        { '<leader>p', group = '[P]ersistence' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>u', group = '[U]ndo / UI helpers' },
        { '<leader>w', group = '[W]indows' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>x', group = 'Diagnostics/Trouble' },
      },
    },
  },

  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    branch = '0.1.x',
    keys = {
      { '<leader>sh', function() require('telescope.builtin').help_tags() end, desc = '[S]earch [H]elp' },
      { '<leader>sk', function() require('telescope.builtin').keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>sf', function() require('telescope.builtin').find_files() end, desc = '[S]earch [F]iles' },
      { '<leader>ss', function() require('telescope.builtin').builtin() end, desc = '[S]elect Telescope' },
      { '<leader>sw', function() require('telescope.builtin').grep_string() end, desc = '[S]earch current [W]ord' },
      { '<leader>sg', function() require('telescope.builtin').live_grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', function() require('telescope.builtin').resume() end, desc = '[S]earch [R]esume' },
      { '<leader>s.', function() require('telescope.builtin').oldfiles() end, desc = '[S]earch Recent Files' },
      { '<leader><leader>', function() require('telescope.builtin').buffers() end, desc = 'Find existing buffers' },
      {
        '<leader>/',
        function()
          local builtin = require 'telescope.builtin'
          local themes = require 'telescope.themes'
          builtin.current_buffer_fuzzy_find(themes.get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        desc = 'Fuzzy search in buffer',
      },
      {
        '<leader>s/',
        function()
          require('telescope.builtin').live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        desc = 'Grep open files',
      },
      {
        '<leader>sn',
        function()
          require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
        end,
        desc = 'Search Neovim config',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'
      local action_set = require 'telescope.actions.set'
      local action_state = require 'telescope.actions.state'
      local Path = require 'plenary.path'
      local uv = vim.uv or vim.loop

      local function ensure_neotree_sidebar_preserve_focus()
        local win = vim.api.nvim_get_current_win()
        local ok, neotree_command = pcall(require, 'neo-tree.command')
        if ok then
          pcall(neotree_command.execute, {
            action = 'focus',
            source = 'filesystem',
            position = 'right',
          })
        else
          pcall(vim.cmd, 'silent! Neotree focus position=right filesystem')
        end

        if vim.api.nvim_win_is_valid(win) then
          pcall(vim.api.nvim_set_current_win, win)
        end
      end

      local function resolve_entry_filename(entry, cwd)
        local filename = entry.path or entry.filename
        if (not filename or filename == '') and type(entry.value) == 'string' and entry.value ~= '' then
          filename = vim.split(entry.value, ':')[1]
        end
        if (not filename or filename == '') and type(entry.bufnr) == 'number' and entry.bufnr > 0 then
          filename = vim.api.nvim_buf_get_name(entry.bufnr)
        end
        if not filename or filename == '' then
          return nil
        end

        local normalized = Path:new(filename):normalize(cwd)
        local stat = uv.fs_stat(normalized)
        if not stat or stat.type ~= 'file' then
          return nil
        end

        return normalized
      end

      local function select_tab_drop(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if not entry then
          return action_set.select(prompt_bufnr, 'default')
        end

        local picker = action_state.get_current_picker(prompt_bufnr)
        local cwd = (picker and picker.cwd) or uv.cwd()
        local filename = resolve_entry_filename(entry, cwd)
        if not filename then
          return action_set.select(prompt_bufnr, 'default')
        end

        local lnum = tonumber(entry.lnum) or tonumber(entry.line)
        local col = tonumber(entry.col) or tonumber(entry.column)

        actions.close(prompt_bufnr)
        vim.cmd('tab drop ' .. vim.fn.fnameescape(filename))
        if lnum and lnum > 0 then
          local target_col = (col and col > 0) and (col - 1) or 0
          pcall(vim.api.nvim_win_set_cursor, 0, { lnum, target_col })
        end
        vim.schedule(ensure_neotree_sidebar_preserve_focus)
      end

      local tab_drop_mappings = {
        i = { ['<CR>'] = select_tab_drop },
        n = { ['<CR>'] = select_tab_drop },
      }

      telescope.setup {
        defaults = {
          file_ignore_patterns = { 'node_modules/', '%.git/' },
          preview = {
            treesitter = false,
          },
          mappings = tab_drop_mappings,
        },
        pickers = {
          find_files = { mappings = tab_drop_mappings },
          oldfiles = { mappings = tab_drop_mappings },
          git_files = { mappings = tab_drop_mappings },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')
    end,
  },
}
