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
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
