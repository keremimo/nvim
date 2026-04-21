local function executable(cmd)
  return vim.fn.executable(cmd) == 1
end

local js_debug_filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }

local function load_js_launchjs()
  local ok_dap, dap = pcall(require, 'dap')
  if not ok_dap then
    return
  end

  pcall(function()
    dap.ext.vscode.load_launchjs(nil, {
      ['pwa-node'] = js_debug_filetypes,
      ['node-terminal'] = js_debug_filetypes,
      ['pwa-chrome'] = js_debug_filetypes,
    })
  end)
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
      {
        '<leader>db',
        function()
          local ok, pb = pcall(require, 'persistent-breakpoints.api')
          if ok then
            pb.toggle_breakpoint()
            return
          end
          require('dap').toggle_breakpoint()
        end,
        desc = 'Debug: Toggle Breakpoint',
      },
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
      {
        '<leader>dj',
        function()
          local ft = vim.bo.filetype
          local is_js = false
          for _, candidate in ipairs(js_debug_filetypes) do
            if ft == candidate then
              is_js = true
              break
            end
          end

          if not is_js then
            vim.notify('JS/TS debug launch is only available for JS/TS buffers', vim.log.levels.WARN)
            return
          end

          require('dap').run {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch current file',
            program = '${file}',
            cwd = '${workspaceFolder}',
          }
        end,
        desc = 'Debug: Launch JS/TS file',
      },
      { '<leader>dL', load_js_launchjs, desc = 'Debug: Reload launch.json' },
      { '<leader>de', function() require('dap').terminate() end, desc = 'Debug: Terminate' },
      { '<leader>du', function() require('dapui').toggle() end, desc = 'Debug: Toggle UI' },
    },
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'mxsdev/nvim-dap-vscode-js',
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
        ensure_installed = { 'delve', 'js', 'python' },
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

      local ok_js, dap_vscode_js = pcall(require, 'dap-vscode-js')
      if ok_js then
        dap_vscode_js.setup {
          debugger_cmd = { 'js-debug-adapter' },
          adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
        }

        for _, language in ipairs(js_debug_filetypes) do
          dap.configurations[language] = {
            {
              type = 'pwa-node',
              request = 'launch',
              name = 'Launch current file',
              program = '${file}',
              cwd = '${workspaceFolder}',
            },
            {
              type = 'pwa-node',
              request = 'attach',
              name = 'Attach to process',
              processId = require('dap.utils').pick_process,
              cwd = '${workspaceFolder}',
            },
            {
              type = 'pwa-chrome',
              request = 'launch',
              name = 'Launch Chrome (localhost:3000)',
              url = 'http://localhost:3000',
              webRoot = '${workspaceFolder}',
            },
          }
        end
      end

      load_js_launchjs()
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
      { '<leader>nF', function() require('neotest').rerun_failed.run_last_failed() end, desc = 'Test: Rerun failed' },
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
      local rerun_failed_consumer = function(client)
        local nio = require 'nio'
        local M = {}

        local function collect_failed(adapter_id)
          local positions = client:get_position(nil, { adapter = adapter_id })
          if not positions then
            return {}
          end

          local results = client:get_results(adapter_id) or {}
          local failed = {}

          for _, pos in positions:iter() do
            local data = pos:data()
            if data.type == 'test' then
              local result = results[data.id]
              if result and result.status == 'failed' then
                table.insert(failed, data.id)
              end
            end
          end

          return failed
        end

        function M.run_last_failed()
          nio.run(function()
            local adapters = client:get_adapters()
            local rerun = {}

            for _, adapter_id in ipairs(adapters) do
              local failed_ids = collect_failed(adapter_id)
              for _, id in ipairs(failed_ids) do
                table.insert(rerun, { adapter = adapter_id, id = id })
              end
            end

            if #rerun == 0 then
              vim.notify('Neotest: no failed tests to rerun', vim.log.levels.INFO)
              return
            end

            for _, entry in ipairs(rerun) do
              local tree = client:get_position(entry.id, { adapter = entry.adapter })
              if tree then
                client:run_tree(tree, { adapter = entry.adapter })
              end
            end

            vim.notify(string.format('Neotest: rerunning %d failed test(s)', #rerun), vim.log.levels.INFO)
          end)
        end

        return M
      end

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
        consumers = {
          rerun_failed = rerun_failed_consumer,
        },
        discovery = { enabled = true },
        output = { open_on_run = false },
        diagnostic = {
          enabled = true,
          severity = vim.diagnostic.severity.ERROR,
        },
        status = {
          enabled = true,
          virtual_text = true,
          signs = false,
        },
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
    event = 'VeryLazy',
    config = function()
      local lint = require 'lint'

      lint.linters_by_ft = {
        bash = { 'shellcheck' },
        dockerfile = { 'hadolint' },
        eruby = { 'erb_lint' },
        sh = { 'shellcheck' },
        go = { 'golangcilint' },
        javascript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        json = { 'jsonlint' },
        jsonc = { 'jsonlint' },
        lua = { 'selene' },
        markdown = { 'markdownlint' },
        typescript = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
        python = { 'ruff' },
        yaml = { 'yamllint' },
        zsh = { 'shellcheck' },
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
    'Bekaboo/dropbar.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    keys = {
      {
        '<leader>;',
        function()
          require('dropbar.api').pick()
        end,
        desc = 'Winbar: Pick breadcrumb',
      },
      {
        '[;',
        function()
          require('dropbar.api').goto_context_start()
        end,
        desc = 'Winbar: Context start',
      },
      {
        '];',
        function()
          require('dropbar.api').select_next_context()
        end,
        desc = 'Winbar: Next context',
      },
    },
    opts = {
      bar = {
        padding = {
          left = 1,
          right = 1,
        },
        enable = function(buf, win, _)
          if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
            return false
          end
          if vim.fn.win_gettype(win) ~= '' then
            return false
          end

          local ft = vim.bo[buf].filetype
          local bt = vim.bo[buf].buftype
          if
            ft == 'neo-tree'
            or ft == 'trouble'
            or ft == 'qf'
            or ft == 'help'
            or ft == 'lazy'
            or ft == 'mason'
            or ft == 'toggleterm'
          then
            return false
          end

          return bt == ''
        end,
      },
    },
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
    'ahmedkhalf/project.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    keys = {
      {
        '<leader>sp',
        function()
          local ok, telescope = pcall(require, 'telescope')
          if not ok then
            return
          end
          local ok_projects, projects = pcall(function()
            return telescope.extensions.projects
          end)
          if ok_projects and projects and projects.projects then
            projects.projects {}
            return
          end
          require('telescope.builtin').find_files()
        end,
        desc = '[S]earch [P]rojects',
      },
    },
    config = function()
      require('project_nvim').setup {
        detection_methods = { 'lsp', 'pattern' },
        patterns = {
          '.git',
          '.hg',
          '.svn',
          'package.json',
          'pyproject.toml',
          'go.mod',
          'Cargo.toml',
          'Gemfile',
          '.luarc.json',
        },
        silent_chdir = true,
      }

      pcall(function()
        require('telescope').load_extension 'projects'
      end)
    end,
  },

  {
    'folke/persistence.nvim',
    event = 'VeryLazy',
    opts = {},
    config = function(_, opts)
      local persistence = require 'persistence'
      persistence.setup(opts)
      persistence.stop()
    end,
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
      {
        '<leader>pS',
        function()
          require('persistence').save()
        end,
        desc = '[P]ersistence: [S]ave',
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
      { '<leader>gf', '<cmd>DiffviewFocusFiles<CR>', desc = '[G]it dif[f] file panel' },
      { '<leader>gR', '<cmd>DiffviewRefresh<CR>', desc = '[G]it diffview [R]efresh' },
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

  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<S-h>', '<cmd>BufferLineCyclePrev<CR>', desc = 'Buffer: Previous' },
      { '<S-l>', '<cmd>BufferLineCycleNext<CR>', desc = 'Buffer: Next' },
      { '[b', '<cmd>BufferLineCyclePrev<CR>', desc = 'Buffer: Previous' },
      { ']b', '<cmd>BufferLineCycleNext<CR>', desc = 'Buffer: Next' },
      { '<leader>bp', '<cmd>BufferLineTogglePin<CR>', desc = '[B]uffer: Toggle [P]in' },
      {
        '<leader>bc',
        function()
          require('config.buffers').delete_current()
        end,
        desc = '[B]uffer: [C]lose current',
      },
      { '<leader>bo', '<cmd>BufferLineCloseOthers<CR>', desc = '[B]uffer: Close [O]thers' },
      { '<leader>bP', '<cmd>BufferLinePick<CR>', desc = '[B]uffer: [P]ick' },
      { '<leader>b,', '<cmd>BufferLineMovePrev<CR>', desc = '[B]uffer: Move left' },
      { '<leader>b.', '<cmd>BufferLineMoveNext<CR>', desc = '[B]uffer: Move right' },
      { '<leader>bl', '<cmd>BufferLineCloseLeft<CR>', desc = '[B]uffer: Close [L]eft' },
      { '<leader>br', '<cmd>BufferLineCloseRight<CR>', desc = '[B]uffer: Close [R]ight' },
    },
    opts = {
      options = {
        mode = 'buffers',
        close_command = function(bufnr)
          require('config.buffers').delete(bufnr)
        end,
        right_mouse_command = function(bufnr)
          require('config.buffers').delete(bufnr)
        end,
        numbers = 'ordinal',
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level, _, context)
          if context.buffer:current() then
            return ''
          end
          local icon = level:match 'error' and ' ' or ' '
          return icon .. count
        end,
        indicator = {
          icon = '▎',
          style = 'icon',
        },
        hover = {
          enabled = true,
          delay = 120,
          reveal = { 'close' },
        },
        separator_style = 'slant',
        max_name_length = 28,
        max_prefix_length = 18,
        truncate_names = true,
        tab_size = 22,
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        sort_by = 'insert_after_current',
        offsets = {
          {
            filetype = 'neo-tree',
            text = '  Explorer',
            text_align = 'left',
            separator = true,
          },
        },
      },
    },
  },

  {
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    opts = {},
    keys = {
      {
        '<leader>sR',
        function()
          require('grug-far').open()
        end,
        desc = '[S]earch and [R]eplace (project)',
      },
      {
        '<leader>sF',
        function()
          require('grug-far').open {
            prefills = {
              paths = vim.fn.expand '%',
            },
          }
        end,
        desc = '[S]earch and replace current [F]ile',
      },
    },
  },

  {
    'ThePrimeagen/refactoring.nvim',
    cmd = 'Refactor',
    keys = {
      {
        '<leader>cR',
        function()
          require('refactoring').select_refactor()
        end,
        mode = { 'n', 'x' },
        desc = '[C]ode [R]efactor',
      },
      {
        '<leader>ce',
        function()
          require('refactoring').refactor 'Extract Function'
        end,
        mode = 'x',
        desc = '[C]ode: [E]xtract function',
      },
      {
        '<leader>cf',
        function()
          require('refactoring').refactor 'Extract Function To File'
        end,
        mode = 'x',
        desc = '[C]ode: Extract to [F]ile',
      },
      {
        '<leader>cv',
        function()
          require('refactoring').refactor 'Extract Variable'
        end,
        mode = 'x',
        desc = '[C]ode: Extract [V]ariable',
      },
      {
        '<leader>cI',
        function()
          require('refactoring').refactor 'Inline Variable'
        end,
        mode = { 'n', 'x' },
        desc = '[C]ode: [I]nline variable',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('refactoring').setup {}
      pcall(function()
        require('telescope').load_extension 'refactoring'
      end)
    end,
  },

  {
    'Weissle/persistent-breakpoints.nvim',
    event = 'BufReadPost',
    opts = {
      load_breakpoints_event = { 'BufReadPost' },
    },
    keys = {
      {
        '<leader>dS',
        function()
          require('persistent-breakpoints.api').save_breakpoints()
        end,
        desc = 'Debug: [S]ave breakpoints',
      },
      {
        '<leader>dR',
        function()
          require('persistent-breakpoints.api').load_breakpoints()
        end,
        desc = 'Debug: [R]eload breakpoints',
      },
      {
        '<leader>dX',
        function()
          require('persistent-breakpoints.api').clear_all_breakpoints()
        end,
        desc = 'Debug: Clear all breakpoints',
      },
    },
  },

  {
    'andythigpen/nvim-coverage',
    cmd = {
      'Coverage',
      'CoverageLoad',
      'CoverageShow',
      'CoverageHide',
      'CoverageToggle',
      'CoverageSummary',
    },
    keys = {
      { '<leader>nC', '<cmd>CoverageLoad<CR>', desc = '[N]eotest: Load [C]overage' },
      { '<leader>nt', '<cmd>CoverageToggle<CR>', desc = '[N]eotest: [T]oggle coverage' },
      { '<leader>nc', '<cmd>CoverageSummary<CR>', desc = '[N]eotest: [C]overage summary' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      auto_reload = true,
    },
  },

  {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    opts = {
      timeout = 3000,
      stages = 'fade_in_slide_out',
      render = 'wrapped-compact',
      max_width = function()
        return math.floor(vim.o.columns * 0.4)
      end,
    },
    config = function(_, opts)
      local notify = require 'notify'
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    cmd = 'Noice',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    opts = {
      lsp = {
        progress = {
          enabled = true,
        },
        hover = {
          enabled = false,
        },
        signature = {
          enabled = false,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
    },
    keys = {
      { '<leader>xn', '<cmd>Noice history<CR>', desc = 'Diagnostics: [N]otification history' },
      { '<leader>xm', '<cmd>Noice last<CR>', desc = 'Diagnostics: Last [M]essage' },
      { '<leader>xd', '<cmd>Noice dismiss<CR>', desc = 'Diagnostics: [D]ismiss messages' },
    },
  },

  {
    'tpope/vim-dadbod',
    cmd = { 'DB', 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    dependencies = {
      {
        'kristijanhusak/vim-dadbod-ui',
        cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
      },
      {
        'kristijanhusak/vim-dadbod-completion',
        ft = { 'sql', 'mysql', 'plsql' },
      },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = vim.g.have_nerd_font and 1 or 0
      vim.g.db_ui_save_location = vim.fn.stdpath 'data' .. '/db_ui'
    end,
    keys = {
      { '<leader>md', '<cmd>DBUIToggle<CR>', desc = '[M]ake: [D]atabase UI' },
    },
  },

  {
    'rest-nvim/rest.nvim',
    ft = { 'http' },
    cmd = 'Rest',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<localleader>rr', '<cmd>Rest run<CR>', ft = 'http', desc = 'HTTP: [R]un request' },
      { '<localleader>rl', '<cmd>Rest run last<CR>', ft = 'http', desc = 'HTTP: Run [L]ast request' },
      { '<localleader>rp', '<cmd>Rest run preview<CR>', ft = 'http', desc = 'HTTP: [P]review request' },
    },
    opts = {
      result = {
        show_url = true,
        show_http_info = true,
        show_headers = true,
      },
    },
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      {
        '<leader>ja',
        function()
          require('harpoon'):list():add()
        end,
        desc = '[J]ump list: [A]dd file',
      },
      {
        '<leader>jj',
        function()
          local harpoon = require 'harpoon'
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = '[J]ump list: Toggle menu',
      },
      {
        '<leader>j1',
        function()
          require('harpoon'):list():select(1)
        end,
        desc = '[J]ump list: file 1',
      },
      {
        '<leader>j2',
        function()
          require('harpoon'):list():select(2)
        end,
        desc = '[J]ump list: file 2',
      },
      {
        '<leader>j3',
        function()
          require('harpoon'):list():select(3)
        end,
        desc = '[J]ump list: file 3',
      },
      {
        '<leader>j4',
        function()
          require('harpoon'):list():select(4)
        end,
        desc = '[J]ump list: file 4',
      },
      {
        '<leader>jn',
        function()
          require('harpoon'):list():next()
        end,
        desc = '[J]ump list: [N]ext',
      },
      {
        '<leader>jp',
        function()
          require('harpoon'):list():prev()
        end,
        desc = '[J]ump list: [P]revious',
      },
    },
    config = function()
      require('harpoon'):setup()
    end,
  },
}
