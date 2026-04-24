local default_scheme = 'tokyonight-moon'

local theme_plugins = {
  {
    repo = 'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    schemes = { 'tokyonight', 'tokyonight-night', 'tokyonight-storm', 'tokyonight-day', 'tokyonight-moon' },
    config = function()
      if vim.g.colors_name == nil or vim.g.colors_name == 'default' then
        pcall(vim.cmd.colorscheme, default_scheme)
      end
    end,
  },
  {
    repo = 'rose-pine/neovim',
    name = 'rose-pine',
    schemes = { 'rose-pine', 'rose-pine-main', 'rose-pine-moon', 'rose-pine-dawn' },
  },
  {
    repo = 'sainnhe/gruvbox-material',
    schemes = { 'gruvbox-material' },
    init = function()
      vim.g.gruvbox_material_background = 'hard'
      vim.g.gruvbox_material_enable_italic = 0
      vim.g.gruvbox_material_better_performance = 1
    end,
    before = [[
      vim.g.gruvbox_material_background = 'hard'
      vim.g.gruvbox_material_enable_italic = 0
      vim.g.gruvbox_material_better_performance = 1
    ]],
  },
  {
    repo = 'sainnhe/everforest',
    schemes = { 'everforest' },
    init = function()
      vim.g.everforest_background = 'hard'
      vim.g.everforest_enable_italic = 0
      vim.g.everforest_better_performance = 1
    end,
    before = [[
      vim.g.everforest_background = 'hard'
      vim.g.everforest_enable_italic = 0
      vim.g.everforest_better_performance = 1
    ]],
  },
  {
    repo = 'rebelot/kanagawa.nvim',
    schemes = { 'kanagawa', 'kanagawa-wave', 'kanagawa-dragon', 'kanagawa-lotus' },
  },
  {
    repo = 'EdenEast/nightfox.nvim',
    schemes = { 'nightfox', 'dayfox', 'dawnfox', 'duskfox', 'nordfox', 'terafox', 'carbonfox' },
  },
  { repo = 'Mofiqul/vscode.nvim', schemes = { 'vscode' } },
  { repo = 'navarasu/onedark.nvim', schemes = { 'onedark' } },
  {
    repo = 'projekt0n/github-nvim-theme',
    schemes = {
      'github_dark',
      'github_dark_default',
      'github_dark_dimmed',
      'github_dark_high_contrast',
      'github_light',
      'github_light_default',
      'github_light_high_contrast',
    },
  },
  { repo = 'Mofiqul/dracula.nvim', schemes = { 'dracula' } },
  {
    repo = 'marko-cerovac/material.nvim',
    schemes = { 'material', 'material-darker', 'material-lighter', 'material-oceanic', 'material-palenight', 'material-deep-ocean' },
  },
  { repo = 'ellisonleao/gruvbox.nvim', schemes = { 'gruvbox' } },
  { repo = 'Shatur/neovim-ayu', schemes = { 'ayu', 'ayu-dark', 'ayu-light', 'ayu-mirage' } },
  { repo = 'bluz71/vim-moonfly-colors', schemes = { 'moonfly' } },
  { repo = 'bluz71/vim-nightfly-colors', schemes = { 'nightfly' } },
  { repo = 'tiagovla/tokyodark.nvim', schemes = { 'tokyodark' } },
  { repo = 'nyoom-engineering/oxocarbon.nvim', schemes = { 'oxocarbon' } },
  { repo = 'dasupradyumna/midnight.nvim', schemes = { 'midnight' } },
}

local function plugin_name(plugin)
  return plugin.name or plugin.repo:match '/([^/]+)$'
end

local function lazy_load_before(plugin)
  local lines = {
    string.format("require('lazy').load({ plugins = { %q } })", plugin_name(plugin)),
  }

  if plugin.before then
    table.insert(lines, plugin.before)
  end

  return table.concat(lines, '\n')
end

local function build_themes()
  local themes = {}

  for _, plugin in ipairs(theme_plugins) do
    for _, scheme in ipairs(plugin.schemes) do
      table.insert(themes, {
        name = scheme,
        colorscheme = scheme,
        before = lazy_load_before(plugin),
      })
    end
  end

  table.sort(themes, function(a, b)
    return a.name < b.name
  end)

  return themes
end

local specs = {}

for _, plugin in ipairs(theme_plugins) do
  table.insert(specs, {
    plugin.repo,
    name = plugin.name,
    lazy = plugin.lazy ~= false,
    priority = plugin.priority,
    init = plugin.init,
    config = plugin.config,
  })
end

table.insert(specs, {
  'zaldih/themery.nvim',
  cmd = 'Themery',
  opts = {
    themes = build_themes(),
    livePreview = true,
  },
})

return specs
