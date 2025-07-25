-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Escape insert mode' })
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Escape insert mode' })
vim.keymap.set('n', '<leader>e', '<Cmd>Neotree toggle<CR>', { silent = true })
vim.keymap.set('n', '<C-e>', '<Cmd>Neotree toggle<CR>', { silent = true })
vim.keymap.set('n', '<C-q>', '<Cmd>:q<CR>', { silent = true })
vim.keymap.set({ 'n', 'v', 'i' }, '<C-s>', '<Cmd>:w<CR>', { silent = true })
vim.keymap.set('n', '<C-g>', '<Cmd>:LazyGit<CR>', { silent = true })
