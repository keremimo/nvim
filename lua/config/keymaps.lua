local map = vim.keymap.set
local tabflow = require 'config.tabflow'

local function smart_split()
  local width = vim.api.nvim_win_get_width(0)
  local height = vim.api.nvim_win_get_height(0)
  local vertical_ratio_threshold = 1.8

  if (width / math.max(height, 1)) >= vertical_ratio_threshold then
    vim.cmd 'vsplit'
  else
    vim.cmd 'split'
  end
end

local function is_valid_win(win)
  return type(win) == 'number' and win > 0 and vim.api.nvim_win_is_valid(win)
end

local float_term_pair = {
  left = { buf = nil, win = nil, job = nil },
  right = { buf = nil, win = nil, job = nil },
}

local pair_focus_state = {
  previous_win = nil,
}

local function is_valid_buf(buf)
  return type(buf) == 'number' and buf > 0 and vim.api.nvim_buf_is_valid(buf)
end

local function is_pair_term_buf(buf)
  return is_valid_buf(buf)
    and vim.bo[buf].buftype == 'terminal'
    and vim.b[buf].float_term_pair == true
end

local function pair_geometry(side)
  local cols = vim.o.columns
  local lines = vim.o.lines
  local padding_x = math.max(math.floor(cols * 0.03), 1)
  local gap = 1
  local max_width = math.max(cols - padding_x * 2 - gap, 20)
  local width = math.max(math.floor(max_width / 2), 10)
  local height = math.max(math.floor(lines * 0.38), 8)
  local row = math.max(lines - height - 4, 1)
  local left_col = padding_x
  local right_col = left_col + width + gap

  if right_col + width > cols then
    right_col = math.max(cols - width, left_col + gap)
  end

  return {
    relative = 'editor',
    style = 'minimal',
    border = 'rounded',
    width = width,
    height = height,
    row = row,
    col = side == 'left' and left_col or right_col,
    zindex = 50,
  }
end

local function pair_job_running(job)
  if type(job) ~= 'number' or job <= 0 then
    return false
  end
  return vim.fn.jobwait({ job }, 0)[1] == -1
end

local function ensure_pair_terminal(entry)
  if not is_valid_buf(entry.buf) then
    entry.buf = vim.api.nvim_create_buf(false, false)
    vim.bo[entry.buf].bufhidden = 'hide'
    vim.b[entry.buf].float_term_pair = true
    entry.job = nil
  end

  if not pair_job_running(entry.job) then
    vim.api.nvim_buf_call(entry.buf, function()
      entry.job = vim.fn.termopen(vim.o.shell)
    end)
    vim.b[entry.buf].float_term_pair = true
  end
end

local function close_pair_windows()
  for _, entry in pairs(float_term_pair) do
    if is_valid_win(entry.win) then
      pcall(vim.api.nvim_win_close, entry.win, true)
    end
    entry.win = nil
  end
end

local function is_pair_window(win)
  if not is_valid_win(win) then
    return false
  end
  return win == float_term_pair.left.win or win == float_term_pair.right.win
end

local function find_non_pair_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_valid_win(win) and not is_pair_window(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if not is_pair_term_buf(buf) then
        return win
      end
    end
  end
end

local function focus_pair_window(win)
  if not is_valid_win(win) then
    return false
  end
  vim.api.nvim_set_current_win(win)
  vim.schedule(function()
    if is_pair_term_buf(vim.api.nvim_get_current_buf()) and vim.fn.mode() ~= 't' then
      vim.cmd.startinsert()
    end
  end)
  return true
end

local function pair_window_open_in_current_tab()
  local tab_wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    tab_wins[win] = true
  end
  for _, entry in pairs(float_term_pair) do
    if is_valid_win(entry.win) and tab_wins[entry.win] then
      return true
    end
  end
  return false
end

local function open_pair_windows()
  close_pair_windows()
  ensure_pair_terminal(float_term_pair.left)
  ensure_pair_terminal(float_term_pair.right)

  float_term_pair.left.win = vim.api.nvim_open_win(float_term_pair.left.buf, false, pair_geometry 'left')
  float_term_pair.right.win = vim.api.nvim_open_win(float_term_pair.right.buf, false, pair_geometry 'right')
  focus_pair_window(float_term_pair.left.win)
end

local function cycle_pair_terminals()
  local current = vim.api.nvim_get_current_win()

  if not pair_window_open_in_current_tab() then
    pair_focus_state.previous_win = current
    open_pair_windows()
    return
  end

  if current == float_term_pair.left.win then
    focus_pair_window(float_term_pair.right.win)
    return
  end

  if current == float_term_pair.right.win then
    local target = pair_focus_state.previous_win
    if not is_valid_win(target) or is_pair_window(target) then
      target = find_non_pair_window()
    end
    close_pair_windows()
    if target and is_valid_win(target) then
      vim.api.nvim_set_current_win(target)
    end
    return
  end

  pair_focus_state.previous_win = current
  focus_pair_window(float_term_pair.left.win)
end

-- Basics
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic location list' })

-- Terminal
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map('t', '<C-q>', function()
  vim.cmd.stopinsert()
  tabflow.close_current_target()
end, { silent = true, desc = 'Close current window' })

-- Window navigation
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })

-- Quick access
map('n', '<C-t>', cycle_pair_terminals, { silent = true, desc = 'Cycle pair terminal focus' })
map('t', '<C-t>', function()
  vim.cmd.stopinsert()
  cycle_pair_terminals()
end, { silent = true, desc = 'Cycle pair terminal focus' })
map('n', '<leader>ww', smart_split, { desc = 'Smart split (auto h/v)' })
map('n', '<leader>ws', '<C-w>s', { desc = 'Split window horizontally' })
map('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
map('n', '<leader>wo', '<C-w>o', { desc = 'Close other windows' })
map('n', '<leader>wq', '<Cmd>q<CR>', { silent = true, desc = 'Close current window' })
map('n', '<leader>w=', '<C-w>=', { desc = 'Equalize window sizes' })
map('n', '<C-q>', tabflow.close_current_target, { silent = true, desc = 'Close current target' })
map({ 'n', 'v', 'i' }, '<C-s>', '<Cmd>w<CR><ESC>', { silent = true, desc = 'Save file' })
map('n', '<leader>gg', '<Cmd>LazyGit<CR>', { silent = true, desc = 'Open LazyGit' })
map('n', '<leader>tt', '<Cmd>Themery<CR>', { silent = true, desc = '[T]oggle [T]heme picker' })
map('n', '<leader>tT', '<Cmd>Telescope colorscheme enable_preview=true<CR>', { silent = true, desc = 'Theme picker (Telescope)' })
map('n', '<leader>tn', '<Cmd>tabnext<CR>', { silent = true, desc = '[T]ab: [N]ext' })
map('n', '<leader>tp', '<Cmd>tabprevious<CR>', { silent = true, desc = '[T]ab: [P]revious' })
map('n', '<leader>up', function() require('config.profiles').pick() end, { desc = '[U]I: Pick workspace [P]rofile' })
map('n', '<leader>uc', function() require('config.profiles').apply 'coding' end, { desc = '[U]I: [C]oding profile' })
map('n', '<leader>uw', function() require('config.profiles').apply 'writing' end, { desc = '[U]I: [W]riting profile' })
map('n', '<leader>ud', function() require('config.profiles').apply 'debugging' end, { desc = '[U]I: [D]ebugging profile' })

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  group = vim.api.nvim_create_augroup('config-float-pair-terminal-focus', { clear = true }),
  callback = function(args)
    local buf = args.buf
    if not is_pair_term_buf(buf) then
      return
    end

    vim.schedule(function()
      if is_pair_term_buf(vim.api.nvim_get_current_buf()) and vim.fn.mode() ~= 't' then
        vim.cmd.startinsert()
      end
    end)
  end,
  desc = 'Always enter terminal mode when focusing float pair terminal',
})

-- Colemak-style cursor movement
-- map('', 'j', 'h', { noremap = true, silent = true })
-- map('', 'k', 'j', { noremap = true, silent = true })
-- map('', 'l', 'k', { noremap = true, silent = true })
-- map('', ';', 'l', { noremap = true, silent = true })
-- map('', 'h', '<Nop>', { noremap = true, silent = true })

-- Insert mode cursor tweaks
-- map('i', '<A-j>', '<Left>', { noremap = true, silent = true })
-- map('i', '<A-k>', '<Down>', { noremap = true, silent = true })
-- map('i', '<A-l>', '<Up>', { noremap = true, silent = true })
-- map('i', '<A-;>', '<Right>', { noremap = true, silent = true })
