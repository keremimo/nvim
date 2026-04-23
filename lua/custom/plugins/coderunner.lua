return {
  'CRAG666/code_runner.nvim',
  keys = { { '<leader>rr', '<Cmd>RunCode<CR>', desc = '[R]un [R]un code' } },
  config = function()
    require('code_runner').setup {
      mode = 'float',
      float = { border = 'single' },
      focus = true,
      startinsert = true,
    }
  end,
}
