local g = vim.g
local opt = vim.opt

-- Leaders and global toggles
g.mapleader = ' '
g.maplocalleader = ' '
g.have_nerd_font = true

-- UI
opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.laststatus = 3
opt.cmdheight = 0
opt.list = true
opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }
opt.signcolumn = 'no'
opt.scrolloff = 10
opt.mouse = 'a'
opt.mousemodel = 'extend'
opt.showmode = false
opt.termguicolors = true
opt.breakindent = true

-- Editing defaults
opt.undofile = true
opt.autoread = true
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = 'split'
opt.timeoutlen = 300
opt.updatetime = 250
opt.foldcolumn = '0'
opt.foldmethod = 'manual'
opt.spell = false

local tab_width = 2
opt.expandtab = true
opt.smartindent = true
opt.tabstop = tab_width
opt.softtabstop = tab_width
opt.shiftwidth = tab_width
opt.smarttab = true

vim.schedule(function()
  opt.clipboard = 'unnamedplus'
end)

vim.diagnostic.config { virtual_text = false, virtual_lines = true }

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  command = 'setlocal tabstop=2 shiftwidth=2 expandtab',
})

vim.api.nvim_set_hl(0, 'NotifyBackground', { bg = '#222222' })
vim.o.showtabline = 2
