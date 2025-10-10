-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      commands = {
        open_tab_smart = function(state)
          local node = state.tree:get_node()
          if not node then
            return
          end

          local navigation = require('custom.utils.navigation')
          local fs_commands = require('neo-tree.sources.filesystem.commands')

          if node.type ~= 'file' then
            fs_commands.toggle_node(state)
            return
          end

          local path = vim.fn.fnamemodify(node:get_id(), ':p')

          if navigation.focus_or_open(path, {
            fallback = function(done)
              fs_commands.open_tabnew(state)
              if done then
                vim.schedule(done)
              end
            end,
          }) then
            return
          end
        end,

        open_current_smart = function(state)
          local node = state.tree:get_node()
          if not node then
            return
          end

          local navigation = require('custom.utils.navigation')
          local fs_commands = require('neo-tree.sources.filesystem.commands')

          if node.type ~= 'file' then
            fs_commands.toggle_node(state)
            return
          end

          local path = vim.fn.fnamemodify(node:get_id(), ':p')

          if navigation.focus_or_open(path, {
            prefer_current = true,
            fallback = function(done)
              fs_commands.open(state)
              if done then
                vim.schedule(done)
              end
            end,
          }) then
            return
          end
        end,
      },
      filtered_items = {
        bind_to_cwd = true,
        cwd_target = {
          sidebar = 'global', -- sidebar is when position = left or right
          current = 'window', -- current is when position = current
        },
        visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      window = {
        width = 20,
        position = 'right',
        auto_expand_width = true,
        mappings = {
          ['<cr>'] = 'open_tab_smart',
          ['o'] = 'open_tab_smart',
          ['<S-CR>'] = 'open_current_smart',
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
