return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
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
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
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
      telescope.setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      local themes = require 'telescope.themes'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'
      local navigation = require 'custom.utils.navigation'
      local map = vim.keymap.set

      local function extract_entry_target(entry)
        if not entry then
          return
        end

        local path = entry.path or entry.filename
        local lnum = entry.lnum or entry.line
        local col = entry.col or entry.column

        if not path then
          local value = entry.value
          if type(value) == 'table' then
            path = value.path or value.filename or value.file or value.text
            lnum = lnum or value.lnum or value.line or value.row
            col = col or value.col or value.column or value.start
          elseif type(value) == 'string' then
            path = value
          end
        end

        local bufnr = entry.bufnr or (entry.value and entry.value.bufnr)
        if not path and bufnr and vim.api.nvim_buf_is_valid(bufnr) then
          path = vim.api.nvim_buf_get_name(bufnr)
        end

        return path, lnum, col
      end

      local function smart_attach()
        return function(prompt_bufnr, map_buf)
          local function make_smart_open(prefer_current)
            return function()
              local entry = action_state.get_selected_entry()
              actions.close(prompt_bufnr)

              local path, lnum, col = extract_entry_target(entry)
              if not path then
                return
              end

              path = vim.fn.fnamemodify(path, ':p')
              lnum = tonumber(lnum)
              col = tonumber(col)

              if lnum and lnum < 1 then
                lnum = 1
              end

              local after = nil
              if lnum then
                local target_col = math.max((col or 1) - 1, 0)
                after = function(_, win)
                  if win and vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_set_cursor(win, { lnum, target_col })
                  end
                end
              end

              navigation.focus_or_open(path, {
                prefer_current = prefer_current,
                fallback = function(done)
                  vim.schedule(function()
                    local cmd = prefer_current and 'edit' or 'tabedit'
                    vim.cmd(string.format('%s %s', cmd, vim.fn.fnameescape(path)))
                    if done then
                      done()
                    end
                  end)
                end,
                after = after,
              })
            end
          end

          local open_in_tab = make_smart_open(false)
          local open_in_current = make_smart_open(true)

          map_buf('i', '<CR>', open_in_tab)
          map_buf('n', '<CR>', open_in_tab)
          map_buf('i', '<C-t>', open_in_tab)
          map_buf('n', '<C-t>', open_in_tab)
          map_buf('i', '<S-CR>', open_in_current)
          map_buf('n', '<S-CR>', open_in_current)

          return true
        end
      end

      local function with_smart_open(picker, opts)
        return function()
          local picker_opts = vim.tbl_deep_extend('force', opts or {}, {
            attach_mappings = smart_attach(),
          })
          picker(picker_opts)
        end
      end

      map('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      map('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      map('n', '<leader>sf', with_smart_open(builtin.find_files), { desc = '[S]earch [F]iles' })
      map('n', '<leader>ss', builtin.builtin, { desc = '[S]elect Telescope' })
      map('n', '<leader>sw', with_smart_open(builtin.grep_string), { desc = '[S]earch current [W]ord' })
      map('n', '<leader>sg', with_smart_open(builtin.live_grep), { desc = '[S]earch by [G]rep' })
      map('n', '<leader>sd', with_smart_open(builtin.diagnostics), { desc = '[S]earch [D]iagnostics' })
      map('n', '<leader>sr', with_smart_open(builtin.resume), { desc = '[S]earch [R]esume' })
      map('n', '<leader>s.', with_smart_open(builtin.oldfiles), { desc = '[S]earch Recent Files' })
      map('n', '<leader><leader>', with_smart_open(builtin.buffers), { desc = 'Find existing buffers' })

      map('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(themes.get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = 'Fuzzy search in buffer' })

      map('n', '<leader>s/', with_smart_open(builtin.live_grep, {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }), { desc = 'Grep open files' })

      map('n', '<leader>sn', with_smart_open(builtin.find_files, {
        cwd = vim.fn.stdpath 'config',
      }), { desc = 'Search Neovim config' })
    end,
  },
}
