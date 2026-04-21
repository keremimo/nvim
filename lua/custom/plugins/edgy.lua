return {
  {
    'folke/edgy.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-neo-tree/neo-tree.nvim' },
    init = function()
      vim.opt.splitkeep = 'screen'
    end,
    keys = {
      {
        '<leader>e',
        function()
          require('edgy').toggle 'right'
        end,
        desc = 'Toggle Explorer Sidebar',
      },
      {
        '<C-e>',
        function()
          local edgy = require 'edgy'
          local buf = vim.api.nvim_get_current_buf()
          local ft = vim.bo[buf].filetype

          if ft == 'neo-tree' or ft == 'neo-tree-popup' then
            edgy.goto_main()
            return
          end

          local function focus_neotree()
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              local win_buf = vim.api.nvim_win_get_buf(win)
              local win_ft = vim.bo[win_buf].filetype
              if win_ft == 'neo-tree' or win_ft == 'neo-tree-popup' then
                vim.api.nvim_set_current_win(win)
                return true
              end
            end
            return false
          end

          edgy.open 'right'
          if focus_neotree() then
            return
          end

          vim.cmd 'Neotree filesystem reveal right'
          vim.schedule(focus_neotree)
        end,
        desc = 'Focus Edgy Neo-tree and Back',
      },
    },
    opts = {
      close_when_all_hidden = false,
      options = {
        right = { size = 30 },
      },
      right = {
        {
          title = 'Explorer',
          ft = 'neo-tree',
          filter = function(buf)
            return vim.b[buf].neo_tree_source == 'filesystem'
          end,
          pinned = true,
          open = 'Neotree filesystem reveal right',
        },
      },
    },
  },
}
