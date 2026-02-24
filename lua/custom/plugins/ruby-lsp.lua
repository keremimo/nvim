return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        ruby_lsp = {
          -- cmd = { vim.fn.expand("~/.local/share/gem/ruby/3.3.0/bin/ruby-lsp") },
        },
      },
    },
  },
}
