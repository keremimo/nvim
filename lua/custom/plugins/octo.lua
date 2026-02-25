return {
  {
    'pwntester/octo.nvim',
    cmd = 'Octo',
    opts = {
      picker = 'telescope',
      enable_builtin = true,
      mappings = {
        pull_request = {
          checkout_pr = { lhs = '<localleader>oc', desc = 'checkout PR' },
          resolve_thread = { lhs = '<localleader>or', desc = 'resolve PR thread' },
        },
        review_thread = {
          resolve_thread = { lhs = '<localleader>or', desc = 'resolve PR thread' },
        },
      },
    },
    keys = {
      {
        '<leader>oi',
        '<CMD>Octo issue list<CR>',
        desc = 'List GitHub Issues',
      },
      {
        '<leader>op',
        '<CMD>Octo pr list<CR>',
        desc = 'List GitHub PullRequests',
      },
      {
        '<leader>od',
        '<CMD>Octo discussion list<CR>',
        desc = 'List GitHub Discussions',
      },
      {
        '<leader>on',
        '<CMD>Octo notification list<CR>',
        desc = 'List GitHub Notifications',
      },
      {
        '<leader>os',
        function()
          require('octo.utils').create_base_search_command { include_current_repo = true }
        end,
        desc = 'Search GitHub',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
  },
}
