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
      vim.opt.fillchars:append {
        foldopen = '',
        foldclose = '',
        foldinner = '│',
        foldsep = '│',
      }

      local group = vim.api.nvim_create_augroup('config-ufo-fold-style', { clear = true })
      local function apply_fold_style()
        vim.api.nvim_set_hl(0, 'FoldColumn', { fg = '#6b7280', bg = 'NONE' })
        vim.api.nvim_set_hl(0, 'CursorLineFold', { fg = '#9aa3b2', bg = 'NONE', bold = true })
        vim.api.nvim_set_hl(0, 'Folded', { fg = '#7f8896', bg = 'NONE', italic = true })
      end

      vim.api.nvim_create_autocmd('ColorScheme', {
        group = group,
        callback = apply_fold_style,
      })

      apply_fold_style()
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
      fold_virt_text_handler = function(virt_text, _, _, width, truncate)
        local new_virt_text = {}
        local suffix = '  ⋯ '
        local suffix_width = vim.fn.strdisplaywidth(suffix)
        local target_width = width - suffix_width
        local current_width = 0

        for _, chunk in ipairs(virt_text) do
          local chunk_text = chunk[1]
          local chunk_width = vim.fn.strdisplaywidth(chunk_text)

          if current_width + chunk_width <= target_width then
            table.insert(new_virt_text, chunk)
          else
            chunk_text = truncate(chunk_text, target_width - current_width)
            table.insert(new_virt_text, { chunk_text, chunk[2] })
            chunk_width = vim.fn.strdisplaywidth(chunk_text)
            if current_width + chunk_width < target_width then
              suffix = suffix .. (' '):rep(target_width - current_width - chunk_width)
            end
            break
          end

          current_width = current_width + chunk_width
        end

        table.insert(new_virt_text, { suffix, 'UfoFoldedEllipsis' })
        return new_virt_text
      end,
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
          local bufnr = vim.api.nvim_get_current_buf()
          local current = vim.diagnostic.config(nil, bufnr)
          local global = vim.diagnostic.config()
          local use_virtual_lines = not current.virtual_lines

          local virtual_lines = { only_current_line = false }
          if type(global.virtual_lines) == 'table' then
            virtual_lines = vim.deepcopy(global.virtual_lines)
          end

          local virtual_text = global.virtual_text
          if virtual_text == false then
            virtual_text = {
              spacing = 2,
              source = 'if_many',
              prefix = '*',
            }
          end

          vim.diagnostic.config({
            virtual_lines = use_virtual_lines and virtual_lines or false,
            virtual_text = use_virtual_lines and false or virtual_text,
          }, bufnr)

          if use_virtual_lines then
            vim.notify('Diagnostics style (buffer): virtual lines', vim.log.levels.INFO)
          else
            vim.notify('Diagnostics style (buffer): virtual text', vim.log.levels.INFO)
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
        'oil',
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
