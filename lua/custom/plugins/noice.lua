return {
  {
    'folke/noice.nvim',
    enabled = false, -- Disabled in favor of snacks.notifier
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
  },
}
