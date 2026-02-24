local map = vim.keymap.set

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

-- Basics
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic location list' })

-- Terminal
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map('t', '<C-q>', '<C-\\><C-n><Cmd>q<CR>', { silent = true, desc = 'Quit terminal window' })

-- Window navigation
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })

-- Quick access
map('n', '<leader>e', '<Cmd>Neotree toggle<CR>', { silent = true, desc = 'Toggle Neo-tree' })
map('n', '<C-e>', '<Cmd>Neotree toggle<CR>', { silent = true, desc = 'Toggle Neo-tree' })
map('n', '<C-t>', '<Cmd>tabnew<CR>', { silent = true, desc = 'New tab' })
map('n', '<C-S-w>', '<Cmd>tabclose<CR>', { silent = true, desc = 'Close tab' })
map('n', '<leader>w', smart_split, { desc = 'Smart split (auto h/v)' })
map('n', '<C-q>', '<Cmd>q<CR>', { silent = true, desc = 'Quit window' })
map({ 'n', 'v', 'i' }, '<C-s>', '<Cmd>w<CR><ESC>', { silent = true, desc = 'Save file' })
map('n', '<C-g>', '<Cmd>LazyGit<CR>', { silent = true, desc = 'Open LazyGit' })
map('n', '<leader>rr', '<Cmd>RunCode<CR>', { silent = true, desc = 'Run code' })

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
