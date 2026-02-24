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
      local stacked_column_width = 30
      local moving_claude = false

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
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          if vim.bo[buf].buftype == 'terminal' and name:match('claude') then
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

      vim.api.nvim_create_autocmd('BufWinEnter', {
        group = group,
        pattern = 'term://*claude*',
        callback = function(args)
          local win = vim.fn.bufwinid(args.buf)
          apply_claude_width(win)
          vim.schedule(function()
            stack_claude_with_neotree(args.buf)
          end)
        end,
        desc = 'Keep Claude terminal width constrained',
      })

      vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
        group = group,
        pattern = 'term://*claude*',
        callback = function(args)
          local buf = args.buf
          if not buf or not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          if vim.bo[buf].buftype ~= 'terminal' then
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
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            local name = vim.api.nvim_buf_get_name(buf)
            if vim.bo[buf].buftype == 'terminal' and name:match('claude') then
              apply_claude_width(win)
            end
          end
        end,
        desc = 'Reapply Claude terminal width after editor resize',
      })

      vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
        group = group,
        pattern = { 'neo-tree', '*' },
        callback = function(args)
          if args.event == 'BufWinEnter' then
            local buf = args.buf
            if not buf or not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= 'neo-tree' then
              return
            end
          end
          if args.event == 'FileType' and vim.bo[args.buf].filetype ~= 'neo-tree' then
            return
          end
          vim.schedule(function()
            for _, term_buf in ipairs(visible_claude_term_bufs()) do
              stack_claude_with_neotree(term_buf)
            end
          end)
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
