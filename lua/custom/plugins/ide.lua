local function executable(cmd)
  return vim.fn.executable(cmd) == 1
end

return {
  {
    'mfussenegger/nvim-dap',
    cmd = {
      'DapContinue',
      'DapStepOver',
      'DapStepInto',
      'DapStepOut',
      'DapTerminate',
      'DapToggleBreakpoint',
      'DapSetLogLevel',
    },
    keys = {
      { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
      { '<F10>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
      { '<F11>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
      { '<F12>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
      { '<leader>dc', function() require('dap').continue() end, desc = 'Debug: Continue' },
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
      {
        '<leader>dB',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Conditional Breakpoint',
      },
      { '<leader>do', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
      { '<leader>di', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
      { '<leader>dO', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
      { '<leader>dr', function() require('dap').repl.toggle() end, desc = 'Debug: Toggle REPL' },
      { '<leader>dl', function() require('dap').run_last() end, desc = 'Debug: Run Last' },
      { '<leader>de', function() require('dap').terminate() end, desc = 'Debug: Terminate' },
      { '<leader>du', function() require('dapui').toggle() end, desc = 'Debug: Toggle UI' },
    },
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('nvim-dap-virtual-text').setup()
      dapui.setup()

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      require('mason-nvim-dap').setup {
        automatic_installation = true,
        ensure_installed = { 'delve', 'python' },
      }

      local ok_go, dap_go = pcall(require, 'dap-go')
      if ok_go then
        dap_go.setup {
          delve = {
            detached = vim.fn.has 'win32' == 0,
          },
        }
      end

      local ok_py, dap_python = pcall(require, 'dap-python')
      if ok_py and executable 'python3' then
        dap_python.setup(vim.fn.exepath 'python3')
      end
    end,
  },

  {
    'nvim-neotest/neotest',
    cmd = {
      'Neotest',
      'NeotestRun',
      'NeotestOutput',
      'NeotestSummary',
      'NeotestOutputPanel',
    },
    keys = {
      { '<leader>nn', function() require('neotest').run.run() end, desc = 'Test: Run nearest' },
      { '<leader>nf', function() require('neotest').run.run(vim.fn.expand '%') end, desc = 'Test: Run file' },
      {
        '<leader>na',
        function()
          local uv = vim.uv or vim.loop
          require('neotest').run.run(uv.cwd())
        end,
        desc = 'Test: Run all',
      },
      { '<leader>nl', function() require('neotest').run.run_last() end, desc = 'Test: Run last' },
      { '<leader>nd', function() require('neotest').run.run { strategy = 'dap' } end, desc = 'Test: Debug nearest' },
      { '<leader>ns', function() require('neotest').summary.toggle() end, desc = 'Test: Toggle summary' },
      { '<leader>no', function() require('neotest').output.open { enter = true, auto_close = true } end, desc = 'Test: Open output' },
      { '<leader>nO', function() require('neotest').output_panel.toggle() end, desc = 'Test: Toggle output panel' },
      { '<leader>nq', function() require('neotest').run.stop() end, desc = 'Test: Stop run' },
    },
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-neotest/neotest-go',
      'nvim-neotest/neotest-python',
      'marilari88/neotest-vitest',
    },
    config = function()
      local adapters = {}

      local ok_go, neotest_go = pcall(require, 'neotest-go')
      if ok_go then
        table.insert(adapters, neotest_go {})
      end

      local ok_python, neotest_python = pcall(require, 'neotest-python')
      if ok_python then
        table.insert(adapters, neotest_python { dap = { justMyCode = false } })
      end

      local ok_vitest, neotest_vitest = pcall(require, 'neotest-vitest')
      if ok_vitest then
        table.insert(adapters, neotest_vitest {})
      end

      require('neotest').setup {
        adapters = adapters,
        discovery = { enabled = true },
        output = { open_on_run = false },
        quickfix = {
          enabled = true,
          open = function()
            local ok = pcall(vim.cmd, 'Trouble qflist open')
            if not ok then
              vim.cmd 'copen'
            end
          end,
        },
        summary = {
          mappings = {
            expand = { '<CR>', 'l' },
            output = 'o',
            run = 'r',
            short = 's',
            stop = 'u',
          },
        },
      }
    end,
  },

  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      lint.linters_by_ft = {
        lua = { 'selene' },
        bash = { 'shellcheck' },
        sh = { 'shellcheck' },
        zsh = { 'shellcheck' },
        javascript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescript = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
        python = { 'ruff' },
        go = { 'golangcilint' },
        markdown = { 'markdownlint' },
      }

      local group = vim.api.nvim_create_augroup('config-lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
        group = group,
        callback = function()
          if vim.bo.buftype ~= '' then
            return
          end

          local names = lint.linters_by_ft[vim.bo.filetype]
          if names == nil then
            return
          end

          if type(names) == 'string' then
            names = { names }
          end

          local available = {}
          for _, name in ipairs(names) do
            local linter = lint.linters[name]
            if linter then
              local cmd = linter.cmd
              if type(cmd) == 'function' then
                local ok, resolved = pcall(cmd)
                cmd = ok and resolved or nil
              end
              if type(cmd) == 'string' and executable(cmd) then
                table.insert(available, name)
              end
            end
          end

          if #available > 0 then
            lint.try_lint(available)
          end
        end,
      })
    end,
  },

  {
    'stevearc/aerial.nvim',
    cmd = { 'AerialToggle', 'AerialOpen', 'AerialNavToggle' },
    keys = {
      { '<leader>co', '<cmd>AerialToggle!<CR>', desc = '[C]ode [O]utline' },
      { '<leader>cO', '<cmd>AerialNavToggle<CR>', desc = '[C]ode outline nav' },
      { '[a', '<cmd>AerialPrev<CR>', desc = 'Aerial: Prev symbol' },
      { ']a', '<cmd>AerialNext<CR>', desc = 'Aerial: Next symbol' },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-treesitter/nvim-treesitter' },
    opts = {
      backends = { 'lsp', 'treesitter', 'markdown', 'man' },
      layout = {
        default_direction = 'prefer_right',
        min_width = 24,
        max_width = { 40, 0.25 },
      },
      attach_mode = 'global',
      show_guides = true,
      filter_kind = false,
    },
  },

  {
    'SmiteshP/nvim-navic',
    event = 'LspAttach',
    opts = {
      highlight = true,
      separator = '  ',
      depth_limit = 5,
      lsp = {
        auto_attach = false,
      },
    },
    config = function(_, opts)
      local navic = require 'nvim-navic'
      navic.setup(opts)

      local function refresh_winbar()
        if vim.bo.buftype ~= '' then
          return
        end
        if navic.is_available() then
          vim.wo.winbar = " %{%v:lua.require'nvim-navic'.get_location()%}"
        else
          vim.wo.winbar = ''
        end
      end

      local navic_group = vim.api.nvim_create_augroup('config-navic', { clear = true })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = navic_group,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            navic.attach(client, args.buf)
            refresh_winbar()
          end
        end,
      })

      local current = vim.api.nvim_get_current_buf()
      for _, client in ipairs(vim.lsp.get_clients { bufnr = current }) do
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, current)
          break
        end
      end

      vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'CursorHold', 'InsertLeave' }, {
        group = navic_group,
        callback = refresh_winbar,
      })
    end,
  },

  {
    'stevearc/overseer.nvim',
    cmd = {
      'OverseerRun',
      'OverseerToggle',
      'OverseerQuickAction',
      'OverseerTaskAction',
      'OverseerRunCmd',
      'OverseerBuild',
    },
    keys = {
      { '<leader>mr', '<cmd>OverseerRun<CR>', desc = '[M]ake: [R]un task' },
      { '<leader>mt', '<cmd>OverseerToggle<CR>', desc = '[M]ake: [T]oggle task list' },
      { '<leader>ma', '<cmd>OverseerQuickAction<CR>', desc = '[M]ake: Quick [A]ction' },
      { '<leader>mb', '<cmd>OverseerBuild<CR>', desc = '[M]ake: [B]uild' },
      { '<leader>mc', '<cmd>OverseerRunCmd<CR>', desc = '[M]ake: Run [C]ommand' },
    },
    opts = {
      strategy = 'toggleterm',
      task_list = {
        direction = 'right',
        min_width = 40,
      },
    },
    config = function(_, opts)
      require('overseer').setup(opts)
      local ok, telescope = pcall(require, 'telescope')
      if ok then
        pcall(telescope.load_extension, 'overseer')
      end
    end,
  },

  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    keys = {
      {
        '<leader>ps',
        function()
          require('persistence').load()
        end,
        desc = '[P]ersistence: restore [S]ession',
      },
      {
        '<leader>pl',
        function()
          require('persistence').load { last = true }
        end,
        desc = '[P]ersistence: restore [L]ast',
      },
      {
        '<leader>pd',
        function()
          require('persistence').stop()
        end,
        desc = '[P]ersistence: [D]isable',
      },
    },
  },

  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewFocusFiles' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = '[G]it [D]iff view' },
      { '<leader>gD', '<cmd>DiffviewClose<CR>', desc = '[G]it close [D]iff view' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = '[G]it file [H]istory' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<CR>', desc = '[G]it repo [H]istory' },
    },
    opts = {},
  },

  {
    'akinsho/git-conflict.nvim',
    version = '*',
    event = 'BufReadPre',
    opts = {
      default_mappings = true,
      default_commands = true,
      disable_diagnostics = false,
      list_opener = 'copen',
      highlights = {
        incoming = 'DiffAdd',
        current = 'DiffText',
      },
    },
    keys = {
      { ']x', '<Plug>(git-conflict-next-conflict)', desc = 'Git conflict: next', remap = true },
      { '[x', '<Plug>(git-conflict-prev-conflict)', desc = 'Git conflict: previous', remap = true },
      { '<leader>gx', '<cmd>GitConflictListQf<CR>', desc = '[G]it conflict list' },
    },
  },
}
