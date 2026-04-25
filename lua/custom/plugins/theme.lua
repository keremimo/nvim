local default_scheme = 'tokyonight-moon'

local function configure_transparent_themes(plugin)
  require('config.transparency').configure_theme_integrations {
    modules = plugin.modules,
  }
end

local theme_plugins = {
  {
    repo = 'folke/tokyonight.nvim',
    modules = { 'tokyonight' },
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
    modules = { 'rose-pine' },
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
    modules = { 'kanagawa' },
    schemes = { 'kanagawa', 'kanagawa-wave', 'kanagawa-dragon', 'kanagawa-lotus' },
  },
  {
    repo = 'EdenEast/nightfox.nvim',
    modules = { 'nightfox' },
    schemes = { 'nightfox', 'dayfox', 'dawnfox', 'duskfox', 'nordfox', 'terafox', 'carbonfox' },
  },
  { repo = 'Mofiqul/vscode.nvim', modules = { 'vscode' }, schemes = { 'vscode' } },
  { repo = 'navarasu/onedark.nvim', modules = { 'onedark' }, schemes = { 'onedark' } },
  {
    repo = 'projekt0n/github-nvim-theme',
    modules = { 'github-theme' },
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
  { repo = 'Mofiqul/dracula.nvim', modules = { 'dracula' }, schemes = { 'dracula' } },
  {
    repo = 'marko-cerovac/material.nvim',
    modules = { 'material' },
    schemes = { 'material', 'material-darker', 'material-lighter', 'material-oceanic', 'material-palenight', 'material-deep-ocean' },
  },
  { repo = 'ellisonleao/gruvbox.nvim', modules = { 'gruvbox' }, schemes = { 'gruvbox' } },
  { repo = 'Shatur/neovim-ayu', modules = { 'ayu' }, schemes = { 'ayu', 'ayu-dark', 'ayu-light', 'ayu-mirage' } },
  { repo = 'bluz71/vim-moonfly-colors', schemes = { 'moonfly' } },
  { repo = 'bluz71/vim-nightfly-colors', schemes = { 'nightfly' } },
  { repo = 'tiagovla/tokyodark.nvim', modules = { 'tokyodark' }, schemes = { 'tokyodark' } },
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

  table.insert(
    lines,
    string.format(
      "require('config.transparency').configure_theme_integrations({ modules = %s })",
      vim.inspect(plugin.modules or {})
    )
  )

  return table.concat(lines, '\n')
end

local function plugin_config(plugin)
  return function()
    configure_transparent_themes(plugin)
    if plugin.config then
      plugin.config()
    end
  end
end

local function plugin_init(plugin)
  return function()
    if plugin.init then
      plugin.init()
    end
    require('config.transparency').configure_theme_integrations()
  end
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
    init = plugin_init(plugin),
    config = plugin_config(plugin),
  })
end

table.insert(specs, {
  'zaldih/themery.nvim',
  lazy = false,
  priority = 1001,
  opts = {
    themes = build_themes(),
    livePreview = true,
  },
})

return specs
