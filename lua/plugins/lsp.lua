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
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    opts = {
      auto_inlay_hints = true,
      servers = {
        clangd = {},
        gopls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
        rust_analyzer = {},
        ruby_lsp = {
          init_options = {
            formatter = 'standard',
            linters = { 'standard' },
          },
        },
      },
      ensure_installed = { 'stylua' },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
        callback = function(event)
          local buffer = event.buf
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = buffer, desc = desc and ('LSP: ' .. desc) or nil })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buffer })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      if opts.capabilities then
        capabilities = vim.tbl_deep_extend('force', capabilities, opts.capabilities)
      end

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

      for server_name in pairs(servers) do
        vim.lsp.enable(server_name)
      end

      require('mason').setup()

      local ensure = vim.list_extend({}, opts.ensure_installed or {})
      local mason_skip = { ruby_lsp = true }
      for server_name in pairs(servers) do
        if not mason_skip[server_name] then
          table.insert(ensure, server_name)
        end
      end
      require('mason-tool-installer').setup { ensure_installed = ensure }

      require('mason-lspconfig').setup {}
    end,
  },

  {
    'stevearc/conform.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
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
      format_on_save = function(_)
        return {
          timeout_ms = 500,
          lsp_fallback = true,
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        eruby = { 'erb_format' },
        ruby = { 'rubocop' },
        go = { 'gofmt' },
      },
    },
  },
}
