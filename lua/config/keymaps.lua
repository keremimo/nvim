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

local float_term = {
  buf = nil,
  win = nil,
  job = nil,
  previous_win = nil,
}

local function is_valid_buf(buf)
  return type(buf) == 'number' and buf > 0 and vim.api.nvim_buf_is_valid(buf)
end

local function is_float_term_buf(buf)
  return is_valid_buf(buf) and vim.bo[buf].buftype == 'terminal' and vim.b[buf].float_term == true
end

local function float_term_geometry()
  local cols = vim.o.columns
  local lines = vim.o.lines
  local padding_x = math.max(math.floor(cols * 0.03), 1)
  local width = math.max(cols - padding_x * 2, 20)
  local height = math.max(math.floor(lines * 0.38), 8)
  local row = math.max(lines - height - 4, 1)

  return {
    relative = 'editor',
    style = 'minimal',
    border = 'rounded',
    width = width,
    height = height,
    row = row,
    col = padding_x,
    zindex = 50,
  }
end

local function float_term_job_running(job)
  if type(job) ~= 'number' or job <= 0 then
    return false
  end
  return vim.fn.jobwait({ job }, 0)[1] == -1
end

local function ensure_float_terminal()
  if not is_valid_buf(float_term.buf) then
    float_term.buf = vim.api.nvim_create_buf(false, false)
    vim.bo[float_term.buf].bufhidden = 'hide'
    vim.b[float_term.buf].float_term = true
    float_term.job = nil
  end

  if not float_term_job_running(float_term.job) then
    vim.api.nvim_buf_call(float_term.buf, function()
      float_term.job = vim.fn.termopen(vim.o.shell)
    end)
    vim.b[float_term.buf].float_term = true
  end
end

local function close_float_terminal()
  if is_valid_win(float_term.win) then
    pcall(vim.api.nvim_win_close, float_term.win, true)
  end
  float_term.win = nil
end

local function is_float_term_window(win)
  return is_valid_win(win) and win == float_term.win
end

local function find_non_float_term_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_valid_win(win) and not is_float_term_window(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if not is_float_term_buf(buf) then
        return win
      end
    end
  end
end

local function focus_float_terminal()
  if not is_valid_win(float_term.win) then
    return false
  end
  vim.api.nvim_set_current_win(float_term.win)
  vim.schedule(function()
    if is_float_term_buf(vim.api.nvim_get_current_buf()) and vim.fn.mode() ~= 't' then
      vim.cmd.startinsert()
    end
  end)
  return true
end

local function float_terminal_open_in_current_tab()
  if not is_valid_win(float_term.win) then
    return false
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win == float_term.win then
      return true
    end
  end
  return false
end

local function open_float_terminal()
  close_float_terminal()
  ensure_float_terminal()
  float_term.win = vim.api.nvim_open_win(float_term.buf, false, float_term_geometry())
  focus_float_terminal()
end

local function toggle_float_terminal()
  local current = vim.api.nvim_get_current_win()

  if not float_terminal_open_in_current_tab() then
    float_term.previous_win = current
    open_float_terminal()
    return
  end

  if current == float_term.win then
    local target = float_term.previous_win
    if not is_valid_win(target) or is_float_term_window(target) then
      target = find_non_float_term_window()
    end
    close_float_terminal()
    if target and is_valid_win(target) then
      vim.api.nvim_set_current_win(target)
    end
    return
  end

  float_term.previous_win = current
  focus_float_terminal()
end

local function toggle_diagnostic_virtual_lines()
  local bufnr = vim.api.nvim_get_current_buf()
  local current = vim.diagnostic.config(nil, bufnr)
  local global = vim.diagnostic.config()
  local use_virtual_lines = not current.virtual_lines

  local virtual_lines = { only_current_line = false }
  if type(global.virtual_lines) == 'table' then
    virtual_lines = vim.deepcopy(global.virtual_lines)
  end

  local virtual_text = global.virtual_text
  if virtual_text == false then
    virtual_text = {
      spacing = 2,
      source = 'if_many',
      prefix = '*',
    }
  end

  vim.diagnostic.config({
    virtual_lines = use_virtual_lines and virtual_lines or false,
    virtual_text = use_virtual_lines and false or virtual_text,
  }, bufnr)

  if use_virtual_lines then
    vim.notify('Diagnostics style (buffer): virtual lines', vim.log.levels.INFO)
  else
    vim.notify('Diagnostics style (buffer): virtual text', vim.log.levels.INFO)
  end
end

-- Basics
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic location list' })
map('i', 'jk', '<Esc>', { desc = 'Exit insert mode' })

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
map('n', '<C-t>', toggle_float_terminal, { silent = true, desc = 'Toggle floating terminal' })
map('t', '<C-t>', function()
  vim.cmd.stopinsert()
  toggle_float_terminal()
end, { silent = true, desc = 'Toggle floating terminal' })
map('n', '<leader>ww', smart_split, { desc = 'Smart split (auto h/v)' })
map('n', '<leader>ws', '<C-w>s', { desc = 'Split window horizontally' })
map('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
map('n', '<leader>wo', '<C-w>o', { desc = 'Close other windows' })
map('n', '<leader>wq', '<Cmd>q<CR>', { silent = true, desc = 'Close current window' })
map('n', '<leader>w=', '<C-w>=', { desc = 'Equalize window sizes' })
map('n', '<C-q>', tabflow.close_current_target, { silent = true, desc = 'Close current target' })
map({ 'n', 'v', 'i' }, '<C-s>', '<Cmd>w<CR><ESC>', { silent = true, desc = 'Save file' })
map('n', '<leader>gg', '<Cmd>LazyGit<CR>', { silent = true, desc = 'Open LazyGit' })
map('n', '<leader>tr', function()
  require('config.transparency').toggle()
end, { silent = true, desc = '[T]oggle t[R]ansparency' })
map('n', '<leader>tl', toggle_diagnostic_virtual_lines, { desc = '[T]oggle diagnostics virtual [L]ines' })
map('n', '<leader>tt', '<Cmd>Themery<CR>', { silent = true, desc = '[T]oggle [T]heme picker' })
map('n', '<leader>tT', '<Cmd>Telescope colorscheme enable_preview=true<CR>', { silent = true, desc = 'Theme picker (Telescope)' })
map('n', '<leader>tn', '<Cmd>tabnext<CR>', { silent = true, desc = '[T]ab: [N]ext' })
map('n', '<leader>tp', '<Cmd>tabprevious<CR>', { silent = true, desc = '[T]ab: [P]revious' })
map('n', '<leader>up', function()
  require('config.profiles').pick()
end, { desc = '[U]I: Pick workspace [P]rofile' })
map('n', '<leader>uC', '<Cmd>ConfigMenu<CR>', { silent = true, desc = '[U]I: [C]onfig menu' })
map('n', '<leader>uc', function()
  require('config.profiles').apply 'coding'
end, { desc = '[U]I: [C]oding profile' })
map('n', '<leader>uw', function()
  require('config.profiles').apply 'writing'
end, { desc = '[U]I: [W]riting profile' })
map('n', '<leader>ud', function()
  require('config.profiles').apply 'debugging'
end, { desc = '[U]I: [D]ebugging profile' })

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  group = vim.api.nvim_create_augroup('config-floating-terminal-focus', { clear = true }),
  callback = function(args)
    local buf = args.buf
    if not is_float_term_buf(buf) then
      return
    end

    vim.schedule(function()
      if is_float_term_buf(vim.api.nvim_get_current_buf()) and vim.fn.mode() ~= 't' then
        vim.cmd.startinsert()
      end
    end)
  end,
  desc = 'Always enter terminal mode when focusing floating terminal',
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
