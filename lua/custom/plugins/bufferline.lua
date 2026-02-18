-- Plugin: akinsho/bufferline.nvim
-- The most popular tab/buffer line plugin for Neovim

return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  event = 'VeryLazy',
  config = function()
    require('bufferline').setup {
      options = {
        mode = 'tabs', -- Show tabs instead of buffers
        separator_style = 'slant',
        show_buffer_close_icons = true,
        show_close_icon = false,
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level)
          local icon = level:match 'error' and ' ' or ' '
          return ' ' .. icon .. count
        end,
        offsets = {
          {
            filetype = 'NvimTree',
            text = 'File Explorer',
            highlight = 'Directory',
            separator = true,
          },
          {
            filetype = 'neo-tree',
            text = 'File Explorer',
            highlight = 'Directory',
            separator = true,
          },
        },
      },
    }

    -- Keymaps for tab navigation (same as before)
    vim.keymap.set('n', ']t', '<cmd>tabnext<CR>', { desc = 'Next tab' })
    vim.keymap.set('n', '[t', '<cmd>tabprevious<CR>', { desc = 'Previous tab' })
  end,
}
