local g = vim.g
local opt = vim.opt

-- Compatibility shim for plugins that still call vim.tbl_flatten on Neovim 0.12+.
if vim.iter then
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.tbl_flatten = function(tbl)
    return vim.iter(tbl):flatten(math.huge):totable()
  end
end

-- Compatibility shim for plugins still calling deprecated vim.lsp.buf_get_clients.
if vim.lsp and vim.lsp.get_clients then
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.buf_get_clients = function(bufnr)
    if bufnr == nil or bufnr == 0 then
      bufnr = vim.api.nvim_get_current_buf()
    end

    local by_id = {}
    for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
      by_id[client.id] = client
    end
    return by_id
  end
end

-- Leaders and global toggles
g.mapleader = ' '
g.maplocalleader = ' '
g.have_nerd_font = true
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0

-- UI
opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.laststatus = 3
opt.cmdheight = 1
opt.shortmess:append 'cW'
opt.list = true
opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }
opt.signcolumn = 'yes'
opt.statuscolumn = '%l %C%s'
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

vim.diagnostic.config {
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  virtual_text = false,
  virtual_lines = {
    only_current_line = false,
  },
  float = {
    border = 'rounded',
    source = 'if_many',
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  command = 'setlocal tabstop=2 shiftwidth=2 expandtab',
})

vim.api.nvim_set_hl(0, 'NotifyBackground', { bg = '#222222' })
vim.o.showtabline = 2
