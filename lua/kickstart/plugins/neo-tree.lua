-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    source_selector = {
      winbar = true,
      statusline = false,
      show_scrolled_off_parent_node = true,
      sources = {
        { source = 'filesystem', display_name = '  Files ' },
        { source = 'buffers', display_name = '  Buffers ' },
        { source = 'git_status', display_name = '  Git ' },
      },
    },
    filesystem = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      filtered_items = {
        bind_to_cwd = true,
        cwd_target = {
          sidebar = 'global', -- sidebar is when position = left or right
          current = 'window', -- current is when position = current
        },
        visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      window = {
        width = 28,
        position = 'right',
        auto_expand_width = false,
        mappings = {
          ['<cr>'] = 'open',
          ['o'] = 'open',
          ['<S-CR>'] = 'open',
          ['l'] = 'open',
          ['h'] = 'close_node',
          ['H'] = 'navigate_up',
          ['\\'] = 'close_window',
        },
      },
    },
  },
  config = function(_, opts)
    local function follow_current_file()
      local buf = vim.api.nvim_get_current_buf()
      if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      local filetype = vim.bo[buf].filetype
      if filetype == 'neo-tree' or filetype == 'neo-tree-popup' then
        return
      end
      if vim.bo[buf].buftype ~= '' then
        return
      end
      if vim.api.nvim_buf_get_name(buf) == '' then
        return
      end

      local ok, filesystem = pcall(require, 'neo-tree.sources.filesystem')
      if ok and type(filesystem.follow) == 'function' then
        filesystem.follow()
      end
    end

    opts.event_handlers = opts.event_handlers or {}
    table.insert(opts.event_handlers, {
      event = 'neo_tree_window_after_open',
      handler = function(args)
        local win = args and args.winid
        if win and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_set_option_value('winfixwidth', true, { win = win })
          pcall(vim.api.nvim_win_set_width, win, opts.filesystem.window.width or 20)
        end
      end,
    })

    require('neo-tree').setup(opts)
    do
      local ok_manager, manager = pcall(require, 'neo-tree.sources.manager')
      local ok_events, events = pcall(require, 'neo-tree.events')
      if ok_manager and ok_events and type(manager.unsubscribe) == 'function' then
        manager.unsubscribe('filesystem', {
          event = events.VIM_BUFFER_ENTER,
          id = 'filesystem.vim_buffer_enter',
        })
      end
    end

    local group = vim.api.nvim_create_augroup('NeoTreeRuntime', { clear = true })

    vim.api.nvim_create_autocmd('BufEnter', {
      group = group,
      callback = function(args)
        local buf = args.buf
        if not buf or not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        if vim.bo[buf].filetype == 'neo-tree' or vim.bo[buf].filetype == 'neo-tree-popup' then
          return
        end
        follow_current_file()
      end,
      desc = 'Follow the current file in Neo-tree without reacting to BufWinEnter noise',
    })

    vim.api.nvim_create_autocmd('VimResized', {
      group = group,
      callback = function()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == 'neo-tree' then
            vim.api.nvim_set_option_value('winfixwidth', true, { win = win })
            pcall(vim.api.nvim_win_set_width, win, opts.filesystem.window.width or 20)
          end
        end
      end,
      desc = 'Keep Neo-tree window width fixed',
    })
  end,
}
