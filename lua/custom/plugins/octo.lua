return {
  {
    'pwntester/octo.nvim',
    cmd = 'Octo',
    opts = {
      picker = 'telescope',
      enable_builtin = true,
      reviews = {
        auto_show_threads = true,
        focus = 'right',
      },
      mappings = {
        pull_request = {
          checkout_pr = { lhs = '<localleader>po', desc = 'checkout PR' },
          list_commits = { lhs = '<localleader>pc', desc = 'list PR commits' },
          list_changed_files = { lhs = '<localleader>pf', desc = 'list changed files' },
          show_pr_diff = { lhs = '<localleader>pd', desc = 'show PR diff' },
          add_comment = { lhs = '<localleader>ca', desc = 'add comment' },
          add_reply = { lhs = '<localleader>cr', desc = 'reply to comment' },
          review_start = { lhs = '<localleader>vs', desc = 'start review' },
          review_resume = { lhs = '<localleader>vr', desc = 'resume review' },
          resolve_thread = { lhs = '<localleader>rt', desc = 'resolve PR thread' },
          unresolve_thread = { lhs = '<localleader>rT', desc = 'unresolve PR thread' },
        },
        review_thread = {
          add_comment = { lhs = '<localleader>ca', desc = 'add comment' },
          add_reply = { lhs = '<localleader>cr', desc = 'reply to comment' },
          add_suggestion = { lhs = '<localleader>sa', desc = 'add suggestion' },
          resolve_thread = { lhs = '<localleader>rt', desc = 'resolve PR thread' },
          unresolve_thread = { lhs = '<localleader>rT', desc = 'unresolve PR thread' },
        },
        review_diff = {
          add_review_comment = { lhs = '<localleader>ca', desc = 'add review comment' },
          add_review_suggestion = { lhs = '<localleader>sa', desc = 'add review suggestion' },
          submit_review = { lhs = '<localleader>vs', desc = 'submit review' },
          discard_review = { lhs = '<localleader>vd', desc = 'discard review' },
          next_thread = { lhs = ']t', desc = 'next review thread' },
          prev_thread = { lhs = '[t', desc = 'previous review thread' },
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
      { '<leader>or', '<CMD>Octo review start<CR>', desc = 'Start PR review' },
      { '<leader>oR', '<CMD>Octo review resume<CR>', desc = 'Resume PR review' },
      { '<leader>oc', '<CMD>Octo review comments<CR>', desc = 'Review comments' },
      { '<leader>oS', '<CMD>Octo review submit<CR>', desc = 'Submit PR review' },
      { '<leader>ov', '<CMD>Octo pr diff<CR>', desc = 'View PR diff' },
      { '<leader>ot', '<CMD>Octo thread resolve<CR>', desc = 'Resolve review thread' },
      { '<leader>oT', '<CMD>Octo thread unresolve<CR>', desc = 'Unresolve review thread' },
      { '<leader>ob', '<CMD>Octo pr browser<CR>', desc = 'Open PR in browser' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
  },
}
