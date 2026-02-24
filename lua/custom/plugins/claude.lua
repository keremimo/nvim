return {
  {
    'coder/claudecode.nvim',
    opts = {
      terminal = {
        provider = 'native',
        split_width_percentage = 0.18,
        show_native_term_exit_tip = false,
      },
    },
    config = function(_, opts)
      require('claudecode').setup(opts)

      local stack_with_neotree = 'below' -- set to 'above' to place Claude above Neo-tree
      local stacked_height_ratio = 0.5
      local stacked_column_width = 40
      local moving_claude = false
      local restack_generation = 0
      vim.g.claude_sticky_tabs = vim.g.claude_sticky_tabs or false

      local function find_neotree_win()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'neo-tree' then
            return win
          end
        end
        return nil
      end

      local function win_col(win)
        local pos = vim.api.nvim_win_get_position(win)
        return pos[2]
      end

      local function get_active_claude_term_buf()
        local ok_terminal, terminal = pcall(require, 'claudecode.terminal')
        if not ok_terminal or type(terminal.get_active_terminal_bufnr) ~= 'function' then
          return nil
        end

        local term_buf = terminal.get_active_terminal_bufnr()
        if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
          return term_buf
        end

        return nil
      end

      local function is_claude_term_buf(buf)
        if not buf or not vim.api.nvim_buf_is_valid(buf) then
          return false
        end
        if vim.bo[buf].buftype ~= 'terminal' then
          return false
        end

        local active = get_active_claude_term_buf()
        if active and buf == active then
          return true
        end

        local name = vim.api.nvim_buf_get_name(buf)
        return name:match('claude') ~= nil
      end

      local function has_claude_in_tab(tab)
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if is_claude_term_buf(buf) then
            return true
          end
        end
        return false
      end

      local function any_claude_open()
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          if has_claude_in_tab(tab) then
            return true
          end
        end
        return false
      end

      local function refresh_claude_sticky_tabs()
        vim.g.claude_sticky_tabs = any_claude_open()
      end

      local function ensure_claude_in_current_tab()
        if has_claude_in_tab(0) then
          return true
        end

        local term_buf = get_active_claude_term_buf()
        local ok_terminal, terminal = pcall(require, 'claudecode.terminal')
        if (not term_buf or not vim.api.nvim_buf_is_valid(term_buf))
          and ok_terminal
          and type(terminal.ensure_visible) == 'function'
        then
          terminal.ensure_visible()
          return has_claude_in_tab(0)
        end

        if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
          return false
        end

        local current = vim.api.nvim_get_current_win()
        local neotree_win = find_neotree_win()
        local target_win

        if neotree_win and vim.api.nvim_win_is_valid(neotree_win) then
          local target_width = math.max(15, stacked_column_width)
          vim.api.nvim_set_option_value('winfixwidth', true, { win = neotree_win })
          pcall(vim.api.nvim_win_set_width, neotree_win, target_width)
          vim.api.nvim_win_call(neotree_win, function()
            if stack_with_neotree == 'above' then
              vim.cmd 'leftabove split'
            else
              vim.cmd 'rightbelow split'
            end
            target_win = vim.api.nvim_get_current_win()
          end)
          if target_win and vim.api.nvim_win_is_valid(target_win) then
            vim.api.nvim_win_set_buf(target_win, term_buf)
            vim.api.nvim_set_option_value('winfixwidth', true, { win = target_win })
            vim.api.nvim_set_option_value('winfixheight', true, { win = target_win })
            pcall(vim.api.nvim_win_set_width, target_win, target_width)
          end
        else
          local ratio = (opts.terminal and opts.terminal.split_width_percentage) or 0.22
          local width = math.max(30, math.floor(vim.o.columns * ratio))
          local side = (opts.terminal and opts.terminal.split_side) or 'right'
          if side == 'left' then
            vim.cmd('topleft ' .. width .. 'vsplit')
          else
            vim.cmd('botright ' .. width .. 'vsplit')
          end
          target_win = vim.api.nvim_get_current_win()
          if target_win and vim.api.nvim_win_is_valid(target_win) then
            vim.api.nvim_win_set_buf(target_win, term_buf)
            vim.api.nvim_set_option_value('winfixwidth', true, { win = target_win })
            vim.api.nvim_set_option_value('winfixheight', true, { win = target_win })
          end
        end

        if vim.api.nvim_win_is_valid(current) and current ~= target_win then
          pcall(vim.api.nvim_set_current_win, current)
        end

        return has_claude_in_tab(0)
      end

      local function stack_claude_with_neotree(term_buf)
        if moving_claude then
          return
        end

        local term_win = vim.fn.bufwinid(term_buf)
        if term_win == -1 or not vim.api.nvim_win_is_valid(term_win) then
          return
        end

        local neotree_win = find_neotree_win()
        if not neotree_win or not vim.api.nvim_win_is_valid(neotree_win) then
          return
        end

        if win_col(term_win) == win_col(neotree_win) then
          return
        end

        local original_current = vim.api.nvim_get_current_win()
        local neotree_height = vim.api.nvim_win_get_height(neotree_win)
        local target_win
        local target_width = math.max(15, stacked_column_width)

        moving_claude = true
        pcall(vim.api.nvim_win_set_width, neotree_win, target_width)
        vim.api.nvim_win_call(neotree_win, function()
          if stack_with_neotree == 'above' then
            vim.cmd 'leftabove split'
          else
            vim.cmd 'rightbelow split'
          end
          target_win = vim.api.nvim_get_current_win()
        end)

        if not target_win or not vim.api.nvim_win_is_valid(target_win) then
          moving_claude = false
          return
        end

        local desired_height = math.max(8, math.floor(neotree_height * stacked_height_ratio))

        vim.api.nvim_win_set_buf(target_win, term_buf)
        vim.api.nvim_set_option_value('winfixwidth', true, { win = target_win })
        vim.api.nvim_set_option_value('winfixheight', true, { win = target_win })
        vim.api.nvim_set_option_value('winfixwidth', true, { win = neotree_win })
        vim.api.nvim_set_option_value('winfixheight', true, { win = neotree_win })
        pcall(vim.api.nvim_win_set_width, target_win, target_width)
        pcall(vim.api.nvim_win_set_width, neotree_win, target_width)
        pcall(vim.api.nvim_win_set_height, target_win, desired_height)
        pcall(vim.api.nvim_win_set_height, neotree_win, math.max(8, neotree_height - desired_height))

        if term_win ~= target_win and vim.api.nvim_win_is_valid(term_win) then
          pcall(vim.api.nvim_win_close, term_win, false)
        end

        if vim.api.nvim_win_is_valid(original_current) and original_current ~= term_win then
          vim.api.nvim_set_current_win(original_current)
        elseif vim.api.nvim_win_is_valid(target_win) then
          vim.api.nvim_set_current_win(target_win)
        end

        moving_claude = false
      end

      local function visible_claude_term_bufs()
        local bufs = {}
        local active = get_active_claude_term_buf()
        if active then
          local active_win = vim.fn.bufwinid(active)
          if active_win ~= -1 and vim.api.nvim_win_is_valid(active_win) then
            bufs[active] = true
          end
        end

        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if is_claude_term_buf(buf) then
            bufs[buf] = true
          end
        end
        local out = {}
        for buf, _ in pairs(bufs) do
          table.insert(out, buf)
        end
        return out
      end

      local group = vim.api.nvim_create_augroup('ClaudeCodeTerminalWidth', { clear = true })
      local function is_sidebar_win(win)
        if not win or not vim.api.nvim_win_is_valid(win) then
          return false
        end

        local buf = vim.api.nvim_win_get_buf(win)
        if not buf or not vim.api.nvim_buf_is_valid(buf) then
          return false
        end

        return vim.bo[buf].filetype == 'neo-tree' or is_claude_term_buf(buf)
      end

      local function balance_main_windows()
        local main_wins = {}
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_is_valid(win) then
            if is_sidebar_win(win) then
              vim.api.nvim_set_option_value('winfixwidth', true, { win = win })
            else
              vim.api.nvim_set_option_value('winfixwidth', false, { win = win })
              vim.api.nvim_set_option_value('winfixheight', false, { win = win })
              table.insert(main_wins, win)
            end
          end
        end

        if #main_wins < 2 then
          return
        end

        local current = vim.api.nvim_get_current_win()
        vim.api.nvim_win_call(main_wins[1], function()
          pcall(vim.cmd, 'wincmd =')
        end)
        if vim.api.nvim_win_is_valid(current) then
          pcall(vim.api.nvim_set_current_win, current)
        end
      end

      local function apply_claude_width(win)
        if not win or not vim.api.nvim_win_is_valid(win) then
          return
        end
        local width
        local neotree_win = find_neotree_win()
        if neotree_win and vim.api.nvim_win_is_valid(neotree_win) and win_col(win) == win_col(neotree_win) then
          width = math.max(15, stacked_column_width)
          pcall(vim.api.nvim_win_set_width, neotree_win, width)
        else
          local ratio = (opts.terminal and opts.terminal.split_width_percentage) or 0.22
          width = math.max(30, math.floor(vim.o.columns * ratio))
        end
        vim.api.nvim_set_option_value('winfixwidth', true, { win = win })
        pcall(vim.api.nvim_win_set_width, win, width)
      end

      local function sync_claude_neotree_layout()
        for _, term_buf in ipairs(visible_claude_term_bufs()) do
          local win = vim.fn.bufwinid(term_buf)
          if win ~= -1 and vim.api.nvim_win_is_valid(win) then
            apply_claude_width(win)
            stack_claude_with_neotree(term_buf)
          end
        end
      end

      local function schedule_restack(retries, delay)
        retries = retries or 8
        delay = delay or 40

        restack_generation = restack_generation + 1
        local generation = restack_generation
        local attempt = 0

        local function tick()
          if generation ~= restack_generation then
            return
          end

          if any_claude_open() then
            vim.g.claude_sticky_tabs = true
          end
          sync_claude_neotree_layout()
          attempt = attempt + 1
          if attempt < retries then
            vim.defer_fn(tick, delay)
          else
            balance_main_windows()
            refresh_claude_sticky_tabs()
          end
        end

        vim.schedule(tick)
      end

      vim.api.nvim_create_autocmd({ 'TermOpen', 'BufWinEnter' }, {
        group = group,
        pattern = '*',
        callback = function(args)
          local buf = args.buf
          if not buf or not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          if vim.bo[buf].buftype == 'terminal' or is_claude_term_buf(buf) or vim.bo[buf].filetype == 'neo-tree' then
            if is_claude_term_buf(buf) then
              vim.g.claude_sticky_tabs = true
            end
            schedule_restack()
          end
        end,
        desc = 'Keep Claude and Neo-tree in a shared column',
      })

      vim.api.nvim_create_autocmd('BufWinLeave', {
        group = group,
        pattern = '*',
        callback = function(args)
          local buf = args.buf
          if not is_claude_term_buf(buf) then
            return
          end

          vim.defer_fn(function()
            if not buf or not vim.api.nvim_buf_is_valid(buf) then
              return
            end
            local win = vim.fn.bufwinid(buf)
            if win == -1 or not vim.api.nvim_win_is_valid(win) then
              schedule_restack(5, 35)
            else
              refresh_claude_sticky_tabs()
            end
          end, 20)
        end,
        desc = 'Rebalance main windows when Claude terminal window closes',
      })

      vim.api.nvim_create_autocmd('WinClosed', {
        group = group,
        pattern = '*',
        callback = function()
          refresh_claude_sticky_tabs()
          if find_neotree_win() then
            schedule_restack(4, 35)
          end
        end,
        desc = 'Keep layout stable when windows close in Claude/Neo-tree session',
      })

      local function materialize_sticky_sidebars()
        if #vim.api.nvim_list_uis() == 0 then
          return
        end

        local should_show_claude = vim.g.claude_sticky_tabs or any_claude_open()
        if should_show_claude then
          vim.g.claude_sticky_tabs = true
        end

        if vim.g.neotree_sticky_tabs and not find_neotree_win() then
          pcall(vim.cmd, 'Neotree show')
        end

        if should_show_claude then
          local ok_terminal, terminal = pcall(require, 'claudecode.terminal')
          if ok_terminal and type(terminal.ensure_visible) == 'function' then
            if not ensure_claude_in_current_tab() then
              terminal.ensure_visible()
            end
          end
          schedule_restack(10, 40)
        elseif vim.g.neotree_sticky_tabs then
          schedule_restack(6, 40)
        end
      end

      vim.api.nvim_create_autocmd({ 'TabNewEntered', 'TabEnter' }, {
        group = group,
        callback = function()
          vim.defer_fn(materialize_sticky_sidebars, 20)
        end,
        desc = 'Keep Claude terminal visible across tabs',
      })

      vim.api.nvim_create_autocmd('VimEnter', {
        group = group,
        once = true,
        callback = function()
          if #vim.api.nvim_list_uis() == 0 then
            return
          end

          vim.g.neotree_sticky_tabs = true
          vim.g.claude_sticky_tabs = true
          vim.defer_fn(materialize_sticky_sidebars, 40)
        end,
        desc = 'Open Neo-tree and Claude on startup',
      })

      vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
        group = group,
        pattern = '*',
        callback = function(args)
          local buf = args.buf
          if not is_claude_term_buf(buf) then
            return
          end
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_current_buf() == buf then
              vim.cmd 'startinsert'
            end
          end)
        end,
        desc = 'Auto-enter terminal mode when focusing Claude terminal',
      })

      vim.api.nvim_create_autocmd('VimResized', {
        group = group,
        callback = function()
          schedule_restack(6, 50)
        end,
        desc = 'Reapply Claude terminal width after editor resize',
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'neo-tree',
        callback = function()
          schedule_restack()
        end,
        desc = 'Restack Claude terminal when Neo-tree opens',
      })
    end,
    keys = {
      { '<leader>a', nil, desc = 'AI/Claude Code' },
      { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
      { '<C-Space>', '<cmd>ClaudeCode<cr>', mode = { 'n', 't' }, desc = 'Toggle Claude' },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
      { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
      { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
      { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
      {
        '<leader>as',
        '<cmd>ClaudeCodeTreeAdd<cr>',
        desc = 'Add file',
        ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
      },
      -- Diff management
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
  },
}
