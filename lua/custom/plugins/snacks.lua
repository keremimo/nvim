return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = { enabled = false },
      gitbrowse = { enabled = true },
      notifier = { enabled = false },
      picker = { enabled = true },
      profiler = { enabled = true },
      quickfile = {
        enabled = true,
        exclude = { 'latex', 'markdown', 'markdown_inline' },
      },
      scope = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      {
        ']w',
        function()
          require('snacks').words.jump(vim.v.count1)
        end,
        desc = 'Words: Next reference',
      },
      {
        '[w',
        function()
          require('snacks').words.jump(-vim.v.count1)
        end,
        desc = 'Words: Previous reference',
      },
      {
        '<leader>sB',
        function()
          require('snacks').picker.grep_buffers()
        end,
        desc = '[S]earch: [G]rep [B]uffers (Snacks)',
      },
      {
        '<leader>sP',
        function()
          require('snacks').picker.projects()
        end,
        desc = '[S]earch: [P]rojects (Snacks)',
      },
      {
        '<leader>gB',
        function()
          require('snacks').gitbrowse()
        end,
        mode = { 'n', 'x' },
        desc = '[G]it: [B]rowse remote',
      },
      {
        '<leader>mp',
        function()
          require('snacks').profiler.toggle()
        end,
        desc = '[M]ake: Toggle [P]rofiler',
      },
      {
        '<leader>mP',
        function()
          require('snacks').profiler.scratch()
        end,
        desc = '[M]ake: [P]rofiler scratch',
      },
    },
  },
}
