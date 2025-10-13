return {
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = 'super-tab' },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'normal',
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = {
        documentation = { auto_show = false },
        accept = {
          -- Write completions to the `.` register
          dot_repeat = true,
          -- Create an undo point when accepting a completion item
          create_undo_point = true,
          -- How long to wait for the LSP to resolve the item with additional information before continuing as-is
          resolve_timeout_ms = 100,
          -- Experimental auto-brackets support
          auto_brackets = {
            -- Whether to auto-insert brackets for functions
            enabled = true,
            -- Default brackets to use for unknown languages
            default_brackets = { '(', ')' },
            -- Overrides the default blocked filetypes
            -- See: https://github.com/Saghen/blink.cmp/blob/main/lua/blink/cmp/completion/brackets/config.lua#L5-L9
            override_brackets_for_filetypes = {},
            -- Synchronously use the kind of the item to determine if brackets should be added
            kind_resolution = {
              enabled = true,
              blocked_filetypes = { 'typescriptreact', 'javascriptreact', 'vue' },
            },
            -- Asynchronously use semantic token to determine if brackets should be added
            semantic_token_resolution = {
              enabled = true,
              blocked_filetypes = { 'java' },
              -- How long to wait for semantic tokens to return before assuming no brackets should be added
              timeout_ms = 400,
            },
          },
        },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },
}
