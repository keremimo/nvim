-- lua/custom/plugins/smartsplit.lua
return {
  -- Optional helper for tmux/kitty/wezterm-aware moves/resizes.
  {
    'mrjones2014/smart-splits.nvim',
    lazy = true,
    opts = {
      at_edge = 'wrap',
      default_amount = 3,
      resize_mode = { quit_key = '<ESC>' },
    },
  },

  -- Our dynamic tiler (no external repo; just runs config)
  {
    dir = vim.fn.stdpath 'config', -- point to your config dir; we only need config() to run
    name = 'smart-tiler',
    lazy = false,
    config = function()
      -- Keep layout balanced like a tiler
      vim.opt.equalalways = true
      vim.opt.eadirection = 'both'

      -- >>> Safe min sizes: set current targets first, then mins (avoids E591)
      local MIN_H = 5
      local MIN_W = 20
      if vim.o.winheight < MIN_H then
        vim.o.winheight = MIN_H
      end
      if vim.o.winwidth < MIN_W then
        vim.o.winwidth = MIN_W
      end
      vim.o.winminheight = MIN_H
      vim.o.winminwidth = MIN_W
      -- <<<

      -- Where new splits land
      vim.opt.splitright = true
      vim.opt.splitbelow = true

      -- Decide orientation each time based on current pane shape + min sizes
      local function smart_split()
        local w = vim.api.nvim_win_get_width(0)
        local h = vim.api.nvim_win_get_height(0)

        local can_v = (w >= (vim.o.winminwidth * 2 + 1)) -- room for two columns
        local can_h = (h >= (vim.o.winminheight * 2 + 1)) -- room for two rows

        -- Score choices; pick the axis with more headroom
        local score_v = can_v and (w / math.max(h, 1)) or -1
        local score_h = can_h and (h / math.max(w, 1)) or -1

        if score_v < 0 and score_h < 0 then
          -- Worst case: split along the larger dimension and let equalalways tidy
          if w >= h then
            vim.cmd 'vsplit'
          else
            vim.cmd 'split'
          end
          return
        end

        if score_v >= score_h then
          vim.cmd 'vsplit'
        else
          vim.cmd 'split'
        end
      end

      -- Command + keymaps
      vim.api.nvim_create_user_command('SSplit', smart_split, {})
      vim.keymap.set('n', '<leader>w', smart_split, { desc = 'Smart split (auto h/v)' })
      vim.keymap.set('n', '<leader>tt', '<cmd>vsplit<CR>', { desc = 'Vertical split' })
      vim.keymap.set('n', '<leader>ts', '<cmd>split<CR>', { desc = 'Horizontal split' })

      -- Auto-rebalance on layout changes (extra safety)
      vim.api.nvim_create_autocmd({ 'WinNew', 'WinClosed' }, {
        group = vim.api.nvim_create_augroup('smart_tiler_equalize', { clear = true }),
        callback = function()
          vim.cmd 'wincmd ='
        end,
      })

      -- Optional: navigation/resize that’s terminal-mux aware (if the plugin loaded)
      local ok, ss = pcall(require, 'smart-splits')
      if ok then
        vim.keymap.set('n', '<C-h>', ss.move_cursor_left, { desc = 'Move left split' })
        vim.keymap.set('n', '<C-j>', ss.move_cursor_down, { desc = 'Move down split' })
        vim.keymap.set('n', '<C-k>', ss.move_cursor_up, { desc = 'Move up split' })
        vim.keymap.set('n', '<C-l>', ss.move_cursor_right, { desc = 'Move right split' })

        vim.keymap.set('n', '<A-Left>', ss.resize_left, { desc = 'Shrink left' })
        vim.keymap.set('n', '<A-Right>', ss.resize_right, { desc = 'Grow right' })
        vim.keymap.set('n', '<A-Up>', ss.resize_up, { desc = 'Grow up' })
        vim.keymap.set('n', '<A-Down>', ss.resize_down, { desc = 'Shrink down' })
      end
    end,
  },
}
