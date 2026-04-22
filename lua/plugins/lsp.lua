local default_auto_inlay_hints = {
  gopls = {
    gopls = {
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
  lua_ls = {
    Lua = {
      hint = { enable = true },
    },
  },
  pyright = {
    python = {
      analysis = {
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = true,
          callArgumentTypes = true,
          propertyDeclarationTypes = true,
        },
      },
    },
  },
  basedpyright = {
    python = {
      analysis = {
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = true,
          callArgumentTypes = true,
          propertyDeclarationTypes = true,
        },
      },
    },
  },
  ts_ls = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
  tsserver = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
  rust_analyzer = {
    ['rust-analyzer'] = {
      inlayHints = {
        bindingModeHints = { enable = true },
        chainingHints = { enable = true },
        closingBraceHints = { enable = true },
        closureReturnTypeHints = { enable = true },
        lifetimeElisionHints = { enable = 'always' },
        parameterHints = { enable = true },
        reborrowHints = { enable = true },
        typeHints = { enable = true },
      },
    },
  },
  clangd = function(_, config)
    local cmd = config.cmd
    if cmd == nil then
      cmd = { 'clangd' }
    else
      cmd = vim.deepcopy(cmd)
    end

    local has_inlay_flag = false
    for _, entry in ipairs(cmd) do
      if entry == '--inlay-hints' or entry:find '^%-%-inlay%-hints=' then
        has_inlay_flag = true
        break
      end
    end

    if not has_inlay_flag then
      table.insert(cmd, '--inlay-hints')
    end

    config.cmd = cmd

    return {
      clangd = {
        InlayHints = {
          Enabled = true,
          ParameterNames = true,
          DeducedTypes = true,
          Designators = true,
        },
      },
    }
  end,
  ruby_lsp = function(_, config)
    config.init_options = config.init_options or {}
    local enabled = config.init_options.enabledFeatures
    if enabled == nil then
      enabled = {}
      config.init_options.enabledFeatures = enabled
    end

    if type(enabled) == 'table' then
      local found = false
      for _, feature in ipairs(enabled) do
        if feature == 'inlayHints' then
          found = true
          break
        end
      end
      if not found then
        table.insert(enabled, 'inlayHints')
      end
    end
  end,
}

return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  { 'Bilal2453/luvit-meta', lazy = true },

  {
    'neovim/nvim-lspconfig',
    ft = {
      'bash',
      'c',
      'cpp',
      'dockerfile',
      'eruby',
      'go',
      'javascript',
      'javascriptreact',
      'json',
      'jsonc',
      'lua',
      'markdown',
      'python',
      'sh',
      'rust',
      'ruby',
      'toml',
      'typescript',
      'typescriptreact',
      'yaml',
      'zsh',
    },
    cmd = { 'LspInfo', 'LspStart', 'LspStop', 'LspRestart' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      {
        'j-hui/fidget.nvim',
        opts = {
          progress = {
            display = {
              done_icon = 'OK',
            },
          },
          notification = {
            override_vim_notify = false,
            window = {
              normal_hl = 'NormalFloat',
              winblend = 0,
            },
          },
        },
      },
      {
        'antosha417/nvim-lsp-file-operations',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
          require('lsp-file-operations').setup()
        end,
      },
      { 'smjonas/inc-rename.nvim', opts = {} },
      { 'aznhe21/actions-preview.nvim', opts = {} },
    },
    opts = {
      auto_inlay_hints = true,
      servers = {
        bashls = {},
        clangd = {},
        dockerls = {},
        gopls = {
          settings = {
            gopls = {
              completeUnimported = true,
              usePlaceholders = true,
              gofumpt = true,
              staticcheck = true,
              analyses = {
                nilness = true,
                shadow = true,
                unusedparams = true,
                useany = true,
              },
              codelenses = {
                gc_details = true,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
            },
          },
        },
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
        marksman = {},
        pyright = {
          settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
                diagnosticMode = 'workspace',
                typeCheckingMode = 'standard',
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        ruff = {},
        rust_analyzer = {},
        ruby_lsp = {
          init_options = {
            formatter = 'standard',
            linters = { 'standard' },
          },
        },
        taplo = {},
        ts_ls = {
          init_options = {
            hostInfo = 'neovim',
          },
          settings = {
            typescript = {
              suggest = {
                completeFunctionCalls = true,
              },
              updateImportsOnFileMove = {
                enabled = 'always',
              },
              preferences = {
                includeCompletionsForImportStatements = true,
                includeCompletionsForModuleExports = true,
                includeCompletionsWithInsertText = true,
                importModuleSpecifierPreference = 'non-relative',
              },
            },
            javascript = {
              suggest = {
                completeFunctionCalls = true,
              },
              updateImportsOnFileMove = {
                enabled = 'always',
              },
              preferences = {
                includeCompletionsForImportStatements = true,
                includeCompletionsForModuleExports = true,
                includeCompletionsWithInsertText = true,
              },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
              validate = true,
              schemaStore = {
                enable = true,
                url = 'https://www.schemastore.org/api/json/catalog.json',
              },
            },
          },
        },
      },
      ensure_installed = {
        'eslint_d',
        'golangci-lint',
        'markdownlint',
        'prettierd',
        'ruff',
        'shellcheck',
        'shfmt',
        'stylua',
        'yamlfmt',
      },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
        callback = function(event)
          local buffer = event.buf
          local client = event.data and vim.lsp.get_client_by_id(event.data.client_id) or nil

          local function ensure_single_ts_client()
            local ft = vim.bo[buffer].filetype
            if ft ~= 'javascript' and ft ~= 'javascriptreact' and ft ~= 'typescript' and ft ~= 'typescriptreact' then
              return false
            end

            local preference = {
              ts_ls = 1,
              vtsls = 2,
              tsserver = 3,
            }

            local js_ts_clients = {}
            for _, attached in ipairs(vim.lsp.get_clients { bufnr = buffer }) do
              if preference[attached.name] ~= nil then
                table.insert(js_ts_clients, attached)
              end
            end

            if #js_ts_clients <= 1 then
              return false
            end

            table.sort(js_ts_clients, function(a, b)
              local pa = preference[a.name] or math.huge
              local pb = preference[b.name] or math.huge
              if pa == pb then
                return a.id < b.id
              end
              return pa < pb
            end)

            local keep = js_ts_clients[1]
            for i = 2, #js_ts_clients do
              vim.lsp.buf_detach_client(buffer, js_ts_clients[i].id)
            end

            return client ~= nil and client.id ~= keep.id
          end

          if ensure_single_ts_client() then
            return
          end

          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = buffer, desc = desc and ('LSP: ' .. desc) or nil })
          end

          local telescope_lsp = function(method)
            return function()
              require('telescope.builtin')[method]()
            end
          end

          local glance_or_telescope = function(glance_method, telescope_method)
            return function()
              local ok_glance, glance = pcall(require, 'glance')
              if ok_glance and glance and glance.actions then
                glance.actions.open(glance_method, {
                  hooks = {
                    before_open = function(results, open, jump)
                      if results and #results == 1 then
                        jump(results[1])
                        return
                      end
                      open(results)
                    end,
                  },
                })
                return
              end

              require('telescope.builtin')[telescope_method]()
            end
          end

          local declaration_or_jump = function()
            local params = vim.lsp.util.make_position_params()
            vim.lsp.buf_request_all(buffer, 'textDocument/declaration', params, function(results)
              local locations = {}

              for client_id, client_result in pairs(results or {}) do
                local result = client_result and client_result.result
                if result then
                  local client = vim.lsp.get_client_by_id(client_id)
                  local offset_encoding = client and client.offset_encoding or 'utf-16'
                  if vim.islist(result) then
                    for _, loc in ipairs(result) do
                      table.insert(locations, { location = loc, offset_encoding = offset_encoding })
                    end
                  else
                    table.insert(locations, { location = result, offset_encoding = offset_encoding })
                  end
                end
              end

              if #locations == 0 then
                vim.notify('No declaration found', vim.log.levels.INFO)
                return
              end

              if #locations == 1 then
                vim.lsp.util.jump_to_location(locations[1].location, locations[1].offset_encoding)
                return
              end

              local items = {}
              for _, entry in ipairs(locations) do
                local qf_items = vim.lsp.util.locations_to_items({ entry.location }, entry.offset_encoding)
                vim.list_extend(items, qf_items)
              end

              vim.fn.setqflist({}, ' ', {
                title = 'LSP Declarations',
                items = items,
              })

              local ok_trouble = pcall(require, 'trouble')
              if ok_trouble then
                vim.cmd 'Trouble qflist toggle focus=true'
                return
              end
              vim.cmd 'copen'
            end)
          end

          map('gd', glance_or_telescope('definitions', 'lsp_definitions'), '[G]oto [D]efinition')
          map('gr', glance_or_telescope('references', 'lsp_references'), '[G]oto [R]eferences')
          map('gi', glance_or_telescope('implementations', 'lsp_implementations'), '[G]oto [I]mplementation')
          map('gI', glance_or_telescope('implementations', 'lsp_implementations'), '[G]oto [I]mplementation')
          map('<leader>D', glance_or_telescope('type_definitions', 'lsp_type_definitions'), 'Type [D]efinition')
          map('<leader>ds', telescope_lsp 'lsp_document_symbols', '[D]ocument [S]ymbols')
          map('<leader>sW', telescope_lsp 'lsp_dynamic_workspace_symbols', '[S]earch [W]orkspace Symbols')
          if vim.fn.exists ':IncRename' == 2 then
            vim.keymap.set('n', '<leader>rn', function()
              return ':IncRename ' .. vim.fn.expand '<cword>'
            end, {
              expr = true,
              buffer = buffer,
              desc = 'LSP: [R]e[n]ame',
            })
          else
            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          end
          map('<leader>ca', function()
            local ok_actions_preview, actions_preview = pcall(require, 'actions-preview')
            if ok_actions_preview then
              actions_preview.code_actions()
              return
            end
            vim.lsp.buf.code_action()
          end, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', declaration_or_jump, '[G]oto [D]eclaration')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gK', vim.lsp.buf.signature_help, 'Signature Help')
          map('<leader>cwa', vim.lsp.buf.add_workspace_folder, '[C]ode [W]orkspace: [A]dd Folder')
          map('<leader>cwr', vim.lsp.buf.remove_workspace_folder, '[C]ode [W]orkspace: [R]emove Folder')
          map('<leader>cwl', function()
            vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()), vim.log.levels.INFO)
          end, '[C]ode [W]orkspace: [L]ist Folders')
          map('gl', vim.diagnostic.open_float, 'Open Diagnostic Float')
          map('<leader>td', function()
            local enabled = true
            if vim.diagnostic.is_enabled then
              enabled = vim.diagnostic.is_enabled { bufnr = buffer }
            end
            vim.diagnostic.enable(not enabled, { bufnr = buffer })
          end, '[T]oggle [D]iagnostics')
          map(']d', function()
            vim.diagnostic.jump { count = 1, float = true }
          end, 'Next Diagnostic')
          map('[d', function()
            vim.diagnostic.jump { count = -1, float = true }
          end, 'Previous Diagnostic')

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_group = vim.api.nvim_create_augroup('config-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group = highlight_group,
              buffer = buffer,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              group = highlight_group,
              buffer = buffer,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('config-lsp-detach', { clear = true }),
              callback = function(args)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = highlight_group, buffer = args.buf }
              end,
            })
          end

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buffer })
            end, '[T]oggle Inlay [H]ints')
          end

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) then
            vim.lsp.codelens.enable(true, { bufnr = buffer })

            map('<leader>cL', function()
              vim.lsp.codelens.enable(false, { bufnr = buffer })
              vim.lsp.codelens.enable(true, { bufnr = buffer })
            end, '[C]ode Lens: Refresh')
            map('<leader>cA', vim.lsp.codelens.run, '[C]ode Lens: Run Action')
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, 'blink.cmp')
      if ok_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end
      if opts.capabilities then
        capabilities = vim.tbl_deep_extend('force', capabilities, opts.capabilities)
      end

      capabilities.textDocument = capabilities.textDocument or {}
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      local servers = opts.servers or {}
      local global_defaults = vim.lsp.config['*'] or {}
      vim.lsp.config(
        '*',
        vim.tbl_deep_extend('force', {}, global_defaults, {
          capabilities = vim.tbl_deep_extend('force', {}, global_defaults.capabilities or {}, capabilities),
        })
      )

      local auto_inlay_hints = opts.auto_inlay_hints
      local auto_inlay_presets
      if auto_inlay_hints then
        auto_inlay_presets = vim.deepcopy(default_auto_inlay_hints)
        if type(auto_inlay_hints) == 'table' then
          auto_inlay_presets = vim.tbl_deep_extend('force', auto_inlay_presets, auto_inlay_hints)
        end
      end

      for server_name, server_config in pairs(servers) do
        if auto_inlay_presets then
          local preset = auto_inlay_presets[server_name]
          if preset == false then
            preset = nil
          elseif type(preset) == 'function' then
            preset = preset(server_name, server_config)
          end
          if preset then
            server_config.settings = vim.tbl_deep_extend('force', {}, preset, server_config.settings or {})
          end
        end

        vim.lsp.config(server_name, server_config)
      end

      require('mason').setup()

      local ensure = {}
      local seen = {}
      local function add_ensure(tool)
        if not seen[tool] then
          seen[tool] = true
          table.insert(ensure, tool)
        end
      end

      for _, tool in ipairs(opts.ensure_installed or {}) do
        add_ensure(tool)
      end

      local mason_tool_installer = require 'mason-tool-installer'
      mason_tool_installer.setup {
        ensure_installed = ensure,
        run_on_start = false,
        auto_update = false,
        debounce_hours = 24,
        integrations = {
          ['mason-lspconfig'] = true,
        },
      }

      vim.schedule(function()
        mason_tool_installer.check_install(false)
      end)

      local mason_skip = { ruby_lsp = true }
      local mason_lspconfig = require 'mason-lspconfig'
      local lsp_to_package = mason_lspconfig.get_mappings().lspconfig_to_package
      local mason_servers = {}
      local manual_servers = {}

      for server_name in pairs(servers) do
        if not mason_skip[server_name] and lsp_to_package[server_name] then
          table.insert(mason_servers, server_name)
        else
          table.insert(manual_servers, server_name)
        end
      end

      table.sort(mason_servers)
      table.sort(manual_servers)

      mason_lspconfig.setup {
        ensure_installed = mason_servers,
        automatic_enable = true,
      }

      for _, server_name in ipairs(manual_servers) do
        vim.lsp.enable(server_name)
      end
    end,
  },

  {
    'stevearc/conform.nvim',
    ft = {
      'bash',
      'eruby',
      'go',
      'javascript',
      'javascriptreact',
      'json',
      'jsonc',
      'lua',
      'markdown',
      'python',
      'ruby',
      'sh',
      'toml',
      'typescript',
      'typescriptreact',
      'yaml',
      'zsh',
    },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format {
            async = true,
            lsp_fallback = true,
          }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local timeout = 500
        if vim.bo[bufnr].filetype == 'ruby' then
          timeout = 3000
        end
        return {
          timeout_ms = timeout,
          lsp_fallback = true,
        }
      end,
      formatters_by_ft = {
        bash = { 'shfmt' },
        go = { 'goimports', 'gofmt' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        jsonc = { 'prettierd', 'prettier', stop_after_first = true },
        lua = { 'stylua' },
        markdown = { 'prettierd', 'prettier', stop_after_first = true },
        python = { 'ruff_organize_imports', 'ruff_fix', 'ruff_format' },
        eruby = { 'erb_format' },
        ruby = { 'rubocop' },
        sh = { 'shfmt' },
        toml = { 'taplo' },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'yamlfmt' },
        zsh = { 'shfmt' },
      },
    },
  },
}
