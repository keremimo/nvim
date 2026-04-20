local themes = {
  {
    label = 'Tokyo Night Moon',
    plugin = 'tokyonight',
    colorscheme = 'tokyonight',
    apply = function()
      require('tokyonight').setup {
        style = 'moon',
        transparent = false,
        terminal_colors = true,
        styles = {
          sidebars = 'dark',
          floats = 'dark',
        },
      }
    end,
  },
  {
    label = 'Rose Pine Main',
    plugin = 'rose-pine',
    colorscheme = 'rose-pine',
    apply = function()
      require('rose-pine').setup {
        variant = 'main',
        dark_variant = 'main',
        disable_background = false,
      }
    end,
  },
  {
    label = 'Gruvbox Material Hard',
    plugin = 'gruvbox-material',
    colorscheme = 'gruvbox-material',
    apply = function()
      vim.g.gruvbox_material_background = 'hard'
      vim.g.gruvbox_material_enable_italic = 0
      vim.g.gruvbox_material_better_performance = 1
    end,
  },
}

local current_idx = 1

local function apply_theme(idx)
  local theme = themes[idx]
  if not theme then
    return
  end

  current_idx = idx
  require('lazy').load { plugins = { theme.plugin } }

  if theme.apply then
    theme.apply()
  end

  vim.cmd.colorscheme(theme.colorscheme)
  vim.notify('Theme: ' .. theme.label, vim.log.levels.INFO)
end

local function cycle_theme()
  local next_idx = current_idx + 1
  if next_idx > #themes then
    next_idx = 1
  end
  apply_theme(next_idx)
end

local function pick_theme()
  local items = {}
  for i, theme in ipairs(themes) do
    items[i] = string.format('%d. %s', i, theme.label)
  end

  vim.ui.select(items, { prompt = 'Select Theme' }, function(choice)
    if not choice then
      return
    end

    local idx = tonumber(choice:match '^(%d+)')
    if idx then
      apply_theme(idx)
    end
  end)
end

return {
  {
    'folke/tokyonight.nvim',
    name = 'tokyonight',
    lazy = false,
    priority = 1000,
    config = function()
      apply_theme(1)

      vim.api.nvim_create_user_command('ThemeCycle', cycle_theme, { desc = 'Cycle colorscheme' })
      vim.api.nvim_create_user_command('ThemePick', pick_theme, { desc = 'Pick colorscheme from list' })
    end,
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = true,
  },
  {
    'sainnhe/gruvbox-material',
    name = 'gruvbox-material',
    lazy = true,
  },
}
