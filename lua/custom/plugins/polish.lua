return {
  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle', 'UndotreeShow', 'UndotreeHide', 'UndotreeFocus' },
    keys = {
      { '<leader>uu', '<cmd>UndotreeToggle<CR>', desc = '[U]ndo tree: Toggle' },
      { '<leader>uf', '<cmd>UndotreeFocus<CR>', desc = '[U]ndo tree: [F]ocus' },
    },
  },

  {
    'chrisgrieser/nvim-scissors',
    cmd = { 'ScissorsAddNewSnippet', 'ScissorsEditSnippet' },
    keys = {
      {
        '<leader>sa',
        function()
          require('scissors').addNewSnippet()
        end,
        mode = { 'n', 'x' },
        desc = '[S]nippet: [A]dd',
      },
      {
        '<leader>se',
        function()
          require('scissors').editSnippet()
        end,
        desc = '[S]nippet: [E]dit',
      },
    },
    opts = {
      snippetDir = vim.fn.stdpath 'config' .. '/snippets',
      jsonFormatOpts = {
        sort_keys = true,
        indent = '  ',
      },
    },
  },
}
