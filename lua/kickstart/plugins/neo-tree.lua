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
          ['<cr>'] = 'open',
          ['o'] = 'open',
          ['<S-CR>'] = 'open',
          ['\\'] = 'close_window',
        },
      },
    },
  },
  config = function(_, opts)
    local function has_neotree_in_tab(tab)
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == 'neo-tree' then
          return true
        end
      end
      return false
    end

    local function any_neotree_open()
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if has_neotree_in_tab(tab) then
          return true
        end
      end
      return false
    end

    opts.event_handlers = opts.event_handlers or {}
    table.insert(opts.event_handlers, {
      event = 'neo_tree_window_after_open',
      handler = function()
        vim.g.neotree_sticky_tabs = true
      end,
    })
    table.insert(opts.event_handlers, {
      event = 'neo_tree_window_after_close',
      handler = function()
        vim.g.neotree_sticky_tabs = any_neotree_open()
      end,
    })

    require('neo-tree').setup(opts)

    local group = vim.api.nvim_create_augroup('NeoTreeStickyTabs', { clear = true })
    vim.api.nvim_create_autocmd('TabEnter', {
      group = group,
      callback = function()
        if not vim.g.neotree_sticky_tabs then
          return
        end
        if has_neotree_in_tab(0) then
          return
        end
        vim.cmd 'Neotree show'
      end,
    })
  end,
}
