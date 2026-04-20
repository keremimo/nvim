return {
  {
    'kevinhwang91/nvim-ufo',
    event = 'BufReadPost',
    dependencies = { 'kevinhwang91/promise-async' },
    init = function()
      vim.o.foldcolumn = '1'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    keys = {
      {
        'zR',
        function()
          require('ufo').openAllFolds()
        end,
        desc = 'Folds: Open all',
      },
      {
        'zM',
        function()
          require('ufo').closeAllFolds()
        end,
        desc = 'Folds: Close all',
      },
      {
        'zr',
        function()
          require('ufo').openFoldsExceptKinds()
        end,
        desc = 'Folds: Open level',
      },
      {
        'zm',
        function()
          require('ufo').closeFoldsWith()
        end,
        desc = 'Folds: Close level',
      },
      {
        'zp',
        function()
          require('ufo').peekFoldedLinesUnderCursor()
        end,
        desc = 'Folds: Peek under cursor',
      },
    },
    opts = {
      provider_selector = function(_, filetype, buftype)
        if buftype ~= '' then
          return ''
        end
        if filetype == 'gitcommit' or filetype == 'markdown' then
          return { 'treesitter', 'indent' }
        end
        return { 'lsp', 'indent' }
      end,
      preview = {
        win_config = {
          border = 'rounded',
          winblend = 0,
        },
      },
    },
  },

  {
    'dnlhc/glance.nvim',
    cmd = 'Glance',
    keys = {
      { '<leader>ld', '<cmd>Glance definitions<CR>', desc = '[L]SP peek: [D]efinition' },
      { '<leader>lr', '<cmd>Glance references<CR>', desc = '[L]SP peek: [R]eferences' },
      { '<leader>li', '<cmd>Glance implementations<CR>', desc = '[L]SP peek: [I]mplementations' },
      { '<leader>lt', '<cmd>Glance type_definitions<CR>', desc = '[L]SP peek: [T]ype definitions' },
      { '<leader>lo', '<cmd>Glance resume<CR>', desc = '[L]SP peek: Re-[O]pen' },
    },
    opts = {
      detached = function(winid)
        return vim.api.nvim_win_get_width(winid) < 110
      end,
      border = {
        enable = true,
      },
      use_trouble_qf = true,
    },
  },

  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle', 'UndotreeShow', 'UndotreeHide', 'UndotreeFocus' },
    keys = {
      { '<leader>uu', '<cmd>UndotreeToggle<CR>', desc = '[U]ndo tree: Toggle' },
      { '<leader>uf', '<cmd>UndotreeFocus<CR>', desc = '[U]ndo tree: [F]ocus' },
    },
  },

  {
    'maan2003/lsp_lines.nvim',
    event = 'LspAttach',
    keys = {
      {
        '<leader>tl',
        function()
          local config = vim.diagnostic.config()
          local use_virtual_lines = not config.virtual_lines

          vim.diagnostic.config {
            virtual_lines = use_virtual_lines and { only_current_line = false } or false,
            virtual_text = use_virtual_lines and false or {
              spacing = 2,
              source = 'if_many',
              prefix = '*',
            },
          }

          if use_virtual_lines then
            vim.notify('Diagnostics style: virtual lines', vim.log.levels.INFO)
          else
            vim.notify('Diagnostics style: virtual text', vim.log.levels.INFO)
          end
        end,
        desc = '[T]oggle diagnostics virtual [L]ines',
      },
    },
    config = function()
      require('lsp_lines').setup()
    end,
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

  {
    'lewis6991/satellite.nvim',
    event = 'VeryLazy',
    init = function()
      vim.g.satellite_enabled = true
    end,
    keys = {
      {
        '<leader>ts',
        function()
          if vim.g.satellite_enabled then
            vim.cmd 'SatelliteDisable'
            vim.g.satellite_enabled = false
            vim.notify('Satellite scrollbar: disabled', vim.log.levels.INFO)
            return
          end
          vim.cmd 'SatelliteEnable'
          vim.g.satellite_enabled = true
          vim.notify('Satellite scrollbar: enabled', vim.log.levels.INFO)
        end,
        desc = '[T]oggle [S]atellite scrollbar',
      },
      { '<leader>tS', '<cmd>SatelliteRefresh<CR>', desc = '[T]oggle: [S]atellite refresh' },
    },
    opts = {
      current_only = false,
      winblend = 35,
      zindex = 40,
      width = 2,
      excluded_filetypes = {
        'bigfile',
        'checkhealth',
        'dashboard',
        'fugitive',
        'help',
        'lazy',
        'mason',
        'neo-tree',
        'noice',
        'qf',
      },
      handlers = {
        search = {
          enable = true,
        },
        cursor = {
          enable = true,
        },
        diagnostic = {
          enable = true,
          min_severity = vim.diagnostic.severity.HINT,
        },
        gitsigns = {
          enable = true,
        },
        marks = {
          enable = true,
        },
        quickfix = {
          enable = true,
        },
      },
    },
  },

  {
    'stevearc/quicker.nvim',
    ft = 'qf',
    keys = {
      {
        '<leader>xq',
        function()
          require('quicker').toggle { focus = true }
        end,
        desc = 'Diagnostics: Toggle [Q]uickfix',
      },
      {
        '<leader>xl',
        function()
          require('quicker').toggle { loclist = true, focus = true }
        end,
        desc = 'Diagnostics: Toggle [L]oclist',
      },
    },
    opts = {
      edit = {
        enabled = true,
        autosave = 'unmodified',
      },
      keys = {
        {
          '>',
          function()
            require('quicker').expand { before = 2, after = 2, add_to_existing = true }
          end,
          desc = 'Quickfix: Expand context',
        },
        {
          '<',
          function()
            require('quicker').collapse()
          end,
          desc = 'Quickfix: Collapse context',
        },
      },
    },
  },
}
