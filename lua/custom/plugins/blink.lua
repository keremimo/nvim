return {
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*',

    opts = {
      keymap = {
        preset = 'none',
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<CR>'] = { 'select_and_accept', 'fallback' },


        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
      },

      appearance = {
        nerd_font_variant = 'normal',
      },

      completion = {
        trigger = {
          prefetch_on_insert = true,
          show_in_snippet = false,
          show_on_backspace = true,
          show_on_backspace_in_keyword = true,
          show_on_accept_on_trigger_character = true,
          show_on_insert_on_trigger_character = true,
          show_on_x_blocked_trigger_characters = { "'", '"', '(', '{', '[' },
        },
        list = {
          max_items = 80,
          selection = {
            preselect = function()
              return not require('blink.cmp').snippet_active { direction = 1 }
            end,
            auto_insert = false,
          },
          cycle = {
            from_bottom = true,
            from_top = true,
          },
        },
        menu = {
          border = 'rounded',
          auto_show_delay_ms = 0,
          draw = {
            treesitter = { 'lsp' },
            columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 }, { 'source_name' } },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 150,
          update_delay_ms = 50,
          window = {
            border = 'rounded',
          },
        },
        ghost_text = { enabled = true },
        accept = {
          dot_repeat = true,
          create_undo_point = true,
          resolve_timeout_ms = 200,
          auto_brackets = {
            enabled = true,
            default_brackets = { '(', ')' },
            override_brackets_for_filetypes = {},
            kind_resolution = {
              enabled = true,
              blocked_filetypes = { 'typescriptreact', 'javascriptreact', 'vue' },
            },
            semantic_token_resolution = {
              enabled = true,
              blocked_filetypes = { 'java' },
              timeout_ms = 400,
            },
          },
        },
      },

      signature = {
        enabled = true,
        trigger = {
          show_on_insert = true,
          show_on_accept = true,
        },
        window = {
          border = 'rounded',
          show_documentation = true,
        },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = {
          lua = { inherit_defaults = true, 'lazydev' },
          sql = { inherit_defaults = true, 'dadbod' },
          mysql = { inherit_defaults = true, 'dadbod' },
          plsql = { inherit_defaults = true, 'dadbod' },
        },
        providers = {
          lsp = {
            name = 'LSP',
            min_keyword_length = 1,
            score_offset = 4,
            fallbacks = {},
          },
          path = {
            name = 'Path',
            min_keyword_length = 0,
            score_offset = 3,
            opts = {
              trailing_slash = true,
              label_trailing_slash = true,
              get_cwd = function()
                return vim.fn.getcwd()
              end,
              show_hidden_files_by_default = false,
            },
          },
          snippets = {
            name = 'Snip',
            min_keyword_length = 2,
            score_offset = 1,
            opts = {
              friendly_snippets = true,
              search_paths = { vim.fn.stdpath 'config' .. '/snippets' },
            },
          },
          buffer = {
            name = 'Buffer',
            min_keyword_length = 3,
            max_items = 10,
            score_offset = -3,
            opts = {
              get_bufnrs = function()
                return vim.tbl_filter(function(buf)
                  return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) ~= ''
                end, vim.api.nvim_list_bufs())
              end,
              use_cache = true,
              max_total_buffer_size = 1 * 1024 * 1024,
            },
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
          dadbod = {
            name = 'Dadbod',
            module = 'vim_dadbod_completion.blink',
            score_offset = 90,
          },
        },
      },

      cmdline = {
        keymap = { preset = 'cmdline' },
        completion = {
          menu = {
            auto_show = function(ctx)
              return ctx.mode == 'cmdwin' or vim.fn.getcmdtype() == ':'
            end,
          },
          list = {
            selection = {
              preselect = true,
              auto_insert = false,
            },
          },
          ghost_text = { enabled = true },
        },
      },

      fuzzy = {
        implementation = 'prefer_rust',
        sorts = { 'exact', 'score', 'sort_text' },
      },
    },

    opts_extend = { 'sources.default' },
  },
}
