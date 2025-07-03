return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        ruby_lsp = {
          mason = false,
          -- cmd = { vim.fn.expand("~/.local/share/gem/ruby/3.3.0/bin/ruby-lsp") },
        },
      },
    },
  },
}
