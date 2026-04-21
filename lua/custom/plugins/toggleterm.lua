return {
  'akinsho/toggleterm.nvim',
  version = '*',
  cmd = { 'ToggleTerm', 'TermExec', 'LazyGit' },
  opts = {
    open_mapping = [[<c-\>]],
    direction = 'horizontal',
    start_in_insert = true,
    persist_mode = false,
    insert_mappings = true,
    terminal_mappings = true,
    float_opts = {
      border = 'curved',
    },
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    local Terminal = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new { cmd = 'lazygit', hidden = true, direction = 'float' }

    vim.api.nvim_create_user_command('LazyGit', function()
      lazygit:toggle()
    end, { desc = 'Open LazyGit in floating terminal' })

    local term_group = vim.api.nvim_create_augroup('config-toggleterm-focus-insert', { clear = true })
    vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter', 'WinEnter' }, {
      group = term_group,
      callback = function(args)
        local buf = args.buf
        if not buf or not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        if vim.bo[buf].buftype ~= 'terminal' or vim.bo[buf].filetype ~= 'toggleterm' then
          return
        end

        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_get_current_buf() ~= buf then
            return
          end
          if vim.fn.mode() ~= 't' then
            vim.cmd.startinsert()
          end
        end)
      end,
      desc = 'Always enter terminal-mode when focusing ToggleTerm',
    })
  end,
}
