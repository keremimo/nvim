return {
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
  config = function()
    require('Comment').setup()
  end,
  opts = {
    -- add any options here
  },
}
