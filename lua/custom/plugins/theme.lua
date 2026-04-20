local before_by_scheme = {
  ['gruvbox-material'] = [[
    vim.g.gruvbox_material_background = 'hard'
    vim.g.gruvbox_material_enable_italic = 0
    vim.g.gruvbox_material_better_performance = 1
  ]],
  ['everforest'] = [[
    vim.g.everforest_background = 'hard'
    vim.g.everforest_enable_italic = 0
    vim.g.everforest_better_performance = 1
  ]],
}

local function build_themes()
  local schemes = vim.fn.getcompletion('', 'color')
  table.sort(schemes)

  local themes = {}
  for _, scheme in ipairs(schemes) do
    if scheme ~= 'default' then
      local entry = {
        name = scheme,
        colorscheme = scheme,
      }

      local before = before_by_scheme[scheme]
      if before then
        entry.before = before
      end

      table.insert(themes, entry)
    end
  end

  return themes
end

local function apply_transparency()
  local groups = vim.fn.getcompletion('', 'highlight')
  for _, group in ipairs(groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok and type(hl) == 'table' then
      hl.bg = 'NONE'
      hl.ctermbg = 'NONE'
      pcall(vim.api.nvim_set_hl, 0, group, hl)
    end
  end

  pcall(vim.api.nvim_set_hl, 0, 'Normal', { bg = 'NONE', ctermbg = 'NONE' })
  pcall(vim.api.nvim_set_hl, 0, 'NormalFloat', { bg = 'NONE', ctermbg = 'NONE' })
  pcall(vim.api.nvim_set_hl, 0, 'NeoTreeNormal', { bg = 'NONE', ctermbg = 'NONE' })
  pcall(vim.api.nvim_set_hl, 0, 'NeoTreeNormalNC', { bg = 'NONE', ctermbg = 'NONE' })
end

return {
  -- Theme pack
  { 'folke/tokyonight.nvim', lazy = false, priority = 1000 },
  { 'rose-pine/neovim', name = 'rose-pine', lazy = false, priority = 1000 },
  { 'sainnhe/gruvbox-material', lazy = false, priority = 1000 },
  { 'sainnhe/everforest', lazy = false, priority = 1000 },
  { 'rebelot/kanagawa.nvim', lazy = false, priority = 1000 },
  { 'EdenEast/nightfox.nvim', lazy = false, priority = 1000 },
  { 'Mofiqul/vscode.nvim', lazy = false, priority = 1000 },
  { 'navarasu/onedark.nvim', lazy = false, priority = 1000 },
  { 'projekt0n/github-nvim-theme', lazy = false, priority = 1000 },
  { 'Mofiqul/dracula.nvim', lazy = false, priority = 1000 },
  { 'marko-cerovac/material.nvim', lazy = false, priority = 1000 },
  { 'ellisonleao/gruvbox.nvim', lazy = false, priority = 1000 },
  { 'Shatur/neovim-ayu', lazy = false, priority = 1000 },
  { 'bluz71/vim-moonfly-colors', lazy = false, priority = 1000 },
  { 'bluz71/vim-nightfly-colors', lazy = false, priority = 1000 },
  { 'tiagovla/tokyodark.nvim', lazy = false, priority = 1000 },
  { 'nyoom-engineering/oxocarbon.nvim', lazy = false, priority = 1000 },
  { 'dasupradyumna/midnight.nvim', lazy = false, priority = 1000 },

  {
    'zaldih/themery.nvim',
    lazy = false,
    priority = 999,
    config = function()
      local transparency_group = vim.api.nvim_create_augroup('config-global-transparency', { clear = true })
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = transparency_group,
        callback = apply_transparency,
      })
      vim.api.nvim_create_autocmd('FileType', {
        group = transparency_group,
        pattern = { 'neo-tree', 'neo-tree-popup' },
        callback = apply_transparency,
      })

      require('themery').setup {
        themes = build_themes(),
        livePreview = true,
      }

      if vim.g.colors_name == nil or vim.g.colors_name == 'default' then
        pcall(vim.cmd.colorscheme, 'tokyonight-moon')
      end

      apply_transparency()
    end,
  },
}
