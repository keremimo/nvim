local M = {}

local state_path = vim.fn.stdpath('state') .. '/config-transparency'

local state = {
  current_scheme = nil,
  enabled = false,
  setup = false,
}

local force_clear_groups = {
  'Normal',
  'NormalNC',
  'NormalFloat',
  'FloatBorder',
  'FloatTitle',
  'FloatFooter',
  'SignColumn',
  'FoldColumn',
  'Folded',
  'LineNr',
  'LineNrAbove',
  'LineNrBelow',
  'CursorLine',
  'CursorLineNr',
  'CursorLineFold',
  'CursorLineSign',
  'CursorColumn',
  'ColorColumn',
  'EndOfBuffer',
  'WinBar',
  'WinBarNC',
  'WinSeparator',
  'VertSplit',
  'StatusLine',
  'StatusLineNC',
  'TabLine',
  'TabLineFill',
  'TabLineSel',
  'Pmenu',
  'PmenuSbar',
  'PmenuThumb',
  'MsgArea',
  'MsgSeparator',
  'NormalSB',
  'NeoTreeNormal',
  'NeoTreeNormalNC',
  'NeoTreeEndOfBuffer',
  'TelescopeNormal',
  'TelescopeBorder',
  'TelescopePromptNormal',
  'TelescopePromptBorder',
  'TelescopeResultsNormal',
  'TelescopeResultsBorder',
  'TelescopePreviewNormal',
  'TelescopePreviewBorder',
  'WhichKeyNormal',
  'WhichKeyBorder',
  'LazyNormal',
  'MasonNormal',
  'TroubleNormal',
  'TroubleNormalNC',
  'NotifyBackground',
  'SnacksNormal',
  'SnacksPicker',
  'SnacksPickerBorder',
}

local theme_override_groups = vim.list_extend(vim.deepcopy(force_clear_groups), {
  'NvimTreeNormal',
  'NvimTreeNormalFloat',
  'NvimTreeEndOfBuffer',
  'NvimTreeVertSplit',
  'NvimTreeWinSeparator',
})

local preserve_background = {
  Cursor = true,
  lCursor = true,
  CursorIM = true,
  TermCursor = true,
  Visual = true,
  VisualNOS = true,
  Search = true,
  IncSearch = true,
  CurSearch = true,
  Substitute = true,
  MatchParen = true,
  PmenuSel = true,
  PmenuKindSel = true,
  PmenuExtraSel = true,
  WildMenu = true,
  QuickFixLine = true,
  DiffAdd = true,
  DiffChange = true,
  DiffDelete = true,
  DiffText = true,
  SpellBad = true,
  SpellCap = true,
  SpellLocal = true,
  SpellRare = true,
}

local preserve_patterns = {
  'Search',
  'Selection',
  'Selected',
  'Match',
  '^Diff',
  '^Spell',
  'Pmenu.*Sel$',
}

local function should_preserve_background(name)
  if preserve_background[name] then
    return true
  end

  for _, pattern in ipairs(preserve_patterns) do
    if name:find(pattern) then
      return true
    end
  end

  return false
end

local function highlight_group_names()
  local ok, groups = pcall(vim.api.nvim_get_hl, 0, {})
  if ok and type(groups) == 'table' then
    local names = {}
    for name in pairs(groups) do
      if type(name) == 'string' then
        table.insert(names, name)
      end
    end
    if #names > 0 then
      return names
    end
  end

  return vim.fn.getcompletion('', 'highlight')
end

local function clear_background(name, force)
  if should_preserve_background(name) then
    return
  end

  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or type(hl) ~= 'table' then
    return
  end

  if not force and hl.bg == nil and hl.ctermbg == nil then
    return
  end

  hl.bg = nil
  hl.ctermbg = nil
  pcall(vim.api.nvim_set_hl, 0, name, hl)
end

function M.apply()
  if not state.enabled then
    return
  end

  for _, name in ipairs(highlight_group_names()) do
    clear_background(name, false)
  end

  for _, name in ipairs(force_clear_groups) do
    clear_background(name, true)
  end
end

local function schedule_apply()
  if not state.enabled then
    return
  end

  vim.schedule(M.apply)
end

local function reload_colorscheme()
  local scheme = state.current_scheme or vim.g.colors_name
  if type(scheme) == 'string' and scheme ~= '' then
    pcall(vim.cmd.colorscheme, scheme)
  end
end

local function remember_colorscheme(args)
  if args and type(args.match) == 'string' and args.match ~= '' then
    state.current_scheme = args.match
  end
end

function M.theme_highlight_overrides()
  local overrides = {}
  for _, name in ipairs(theme_override_groups) do
    if not should_preserve_background(name) then
      overrides[name] = { bg = 'NONE' }
    end
  end
  return overrides
end

local function read_persisted_state()
  local ok, lines = pcall(vim.fn.readfile, state_path)
  if not ok or type(lines) ~= 'table' or not lines[1] then
    return nil
  end

  local value = vim.trim(lines[1]):lower()
  if value == 'enabled' or value == 'true' or value == '1' then
    return true
  end
  if value == 'disabled' or value == 'false' or value == '0' then
    return false
  end

  return nil
end

local function write_persisted_state(enabled)
  local dir = vim.fn.fnamemodify(state_path, ':h')
  local mkdir_ok, mkdir_err = pcall(vim.fn.mkdir, dir, 'p')
  if not mkdir_ok then
    vim.notify('Failed to persist transparency state: ' .. tostring(mkdir_err), vim.log.levels.WARN)
    return
  end

  local value = enabled and 'enabled' or 'disabled'
  local write_ok, write_err = pcall(vim.fn.writefile, { value }, state_path)
  if not write_ok then
    vim.notify('Failed to persist transparency state: ' .. tostring(write_err), vim.log.levels.WARN)
  end
end

local function global_transparency_enabled()
  local value = vim.g.config_transparency
  if value == nil then
    return nil
  end

  return value == true or value == 1 or value == 'true' or value == 'enabled'
end

local function setup_theme_module(module_name, configure, load)
  if not load and not package.loaded[module_name] then
    return
  end

  local ok, module = pcall(require, module_name)
  if ok then
    pcall(configure, module)
  end
end

function M.configure_theme_integrations(opts)
  opts = opts or {}
  local enabled = state.enabled
  local load_all = opts.load == true
  local load_modules = {}
  for _, module_name in ipairs(opts.modules or {}) do
    load_modules[module_name] = true
  end
  local transparent_style = enabled and 'transparent' or 'dark'

  vim.g.gruvbox_material_transparent_background = enabled and 2 or 0
  vim.g.everforest_transparent_background = enabled and 2 or 0
  vim.g.moonflyTransparent = enabled
  vim.g.nightflyTransparent = enabled
  vim.g.vscode_transparent = enabled

  setup_theme_module('tokyonight', function(tokyonight)
    tokyonight.setup {
      transparent = enabled,
      styles = {
        sidebars = transparent_style,
        floats = transparent_style,
      },
    }
  end, load_all or load_modules.tokyonight)

  setup_theme_module('rose-pine', function(rose_pine)
    rose_pine.setup {
      styles = {
        transparency = enabled,
      },
    }
  end, load_all or load_modules['rose-pine'])

  setup_theme_module('kanagawa', function(kanagawa)
    kanagawa.setup {
      transparent = enabled,
    }
  end, load_all or load_modules.kanagawa)

  setup_theme_module('nightfox', function(nightfox)
    nightfox.setup {
      options = {
        transparent = enabled,
      },
    }
  end, load_all or load_modules.nightfox)

  setup_theme_module('vscode', function(vscode)
    vscode.setup {
      transparent = enabled,
    }
  end, load_all or load_modules.vscode)

  setup_theme_module('onedark', function(onedark)
    onedark.setup {
      transparent = enabled,
      lualine = {
        transparent = enabled,
      },
    }
  end, load_all or load_modules.onedark)

  setup_theme_module('github-theme', function(github_theme)
    github_theme.setup {
      options = {
        transparent = enabled,
      },
    }
  end, load_all or load_modules['github-theme'])

  setup_theme_module('dracula', function(dracula)
    dracula.setup {
      transparent_bg = enabled,
    }
  end, load_all or load_modules.dracula)

  setup_theme_module('material', function(material)
    material.setup {
      disable = {
        background = enabled,
      },
    }
  end, load_all or load_modules.material)

  setup_theme_module('gruvbox', function(gruvbox)
    gruvbox.setup {
      transparent_mode = enabled,
    }
  end, load_all or load_modules.gruvbox)

  setup_theme_module('ayu', function(ayu)
    ayu.setup {
      overrides = enabled and M.theme_highlight_overrides() or {},
    }
  end, load_all or load_modules.ayu)

  setup_theme_module('tokyodark', function(tokyodark)
    tokyodark.setup {
      transparent_background = enabled,
    }
  end, load_all or load_modules.tokyodark)
end

function M.enable(opts)
  opts = opts or {}
  state.enabled = true
  vim.g.config_transparency = true
  M.configure_theme_integrations()
  reload_colorscheme()
  M.apply()

  if opts.persist ~= false then
    write_persisted_state(true)
  end

  if opts.notify ~= false then
    vim.notify('Transparency: enabled', vim.log.levels.INFO)
  end
end

function M.disable(opts)
  opts = opts or {}
  state.enabled = false
  vim.g.config_transparency = false
  M.configure_theme_integrations()
  reload_colorscheme()

  if opts.persist ~= false then
    write_persisted_state(false)
  end

  if opts.notify ~= false then
    vim.notify('Transparency: disabled', vim.log.levels.INFO)
  end
end

function M.toggle()
  if state.enabled then
    M.disable()
  else
    M.enable()
  end
end

function M.is_enabled()
  return state.enabled
end

function M.setup()
  if state.setup then
    return
  end
  state.setup = true

  local global_enabled = global_transparency_enabled()
  if global_enabled ~= nil then
    state.enabled = global_enabled
  else
    local persisted_enabled = read_persisted_state()
    if persisted_enabled ~= nil then
      state.enabled = persisted_enabled
    end
  end
  vim.g.config_transparency = state.enabled
  M.configure_theme_integrations()

  vim.api.nvim_create_user_command('TransparencyToggle', M.toggle, {
    desc = 'Toggle transparent backgrounds',
    force = true,
  })

  vim.api.nvim_create_user_command('TransparencyEnable', function()
    M.enable()
  end, {
    desc = 'Enable transparent backgrounds',
    force = true,
  })

  vim.api.nvim_create_user_command('TransparencyDisable', function()
    M.disable()
  end, {
    desc = 'Disable transparent backgrounds',
    force = true,
  })

  local group = vim.api.nvim_create_augroup('config-transparency', { clear = true })

  vim.api.nvim_create_autocmd('ColorSchemePre', {
    group = group,
    callback = function(args)
      remember_colorscheme(args)
      M.configure_theme_integrations()
    end,
    desc = 'Configure native theme transparency before colorscheme loads',
  })

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function(args)
      remember_colorscheme(args)
      M.apply()
    end,
    desc = 'Reapply transparent backgrounds after colorscheme changes',
  })

  vim.api.nvim_create_autocmd({ 'VimEnter', 'UIEnter' }, {
    group = group,
    callback = schedule_apply,
    desc = 'Apply transparent backgrounds after UI startup',
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = { 'LazyDone', 'LazyLoad', 'VeryLazy' },
    callback = schedule_apply,
    desc = 'Apply transparent backgrounds after lazy-loaded UI plugins',
  })

  schedule_apply()
end

return M
