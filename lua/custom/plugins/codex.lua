return {
  {
    'rhart92/codex.nvim',
    keys = {
      {
        '<leader>cc',
        function()
          require('codex').toggle()
        end,
        desc = 'Codex: Toggle',
      },
      {
        '<leader>cs',
        function()
          require('codex').actions.send_selection()
        end,
        mode = 'v',
        desc = 'Codex: Send selection',
      },
    },
  },
}
