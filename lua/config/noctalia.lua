local M = {}

local uv = vim.uv or vim.loop

local state = {
  autoreload_setup = false,
  refresh_scheduled = false,
  signature = nil,
  watchers = {},
}

local fallback = {
  background = '#271721',
  foreground = '#f3f2f2',
  surface = '#271721',
  surface_variant = '#341e2c',
  on_surface_variant = '#b6afb4',
  outline = '#76616e',
  primary = '#e467b7',
  secondary = '#d66b5c',
  tertiary = '#cc8b66',
  error = '#fd4663',
  cursor = '#f3f2f2',
  cursor_text = '#271721',
  selection_background = '#cc8b66',
  selection_foreground = '#0e090d',
  palette = {
    [0] = '#341e2c',
    [1] = '#fd4663',
    [2] = '#e467b7',
    [3] = '#d66b5c',
    [4] = '#cc8b66',
    [5] = '#ec93cc',
    [6] = '#e9a096',
    [7] = '#f3f2f2',
    [8] = '#b6afb4',
    [9] = '#fd4663',
    [10] = '#e467b7',
    [11] = '#d66b5c',
    [12] = '#cc8b66',
    [13] = '#ec93cc',
    [14] = '#e9a096',
    [15] = '#f3f2f2',
  },
}

local function expand(path)
  return vim.fn.expand(path)
end

local function ghostty_theme_path()
  return expand(vim.g.noctalia_ghostty_theme_path or '~/.config/ghostty/themes/noctalia')
end

local function ghostty_config_path()
  return expand(vim.g.noctalia_ghostty_config_path or '~/.config/ghostty/config.ghostty')
end

local function noctalia_colors_path()
  return expand(vim.g.noctalia_colors_path or '~/.config/noctalia/colors.json')
end

local function is_hex(value)
  return type(value) == 'string' and value:match '^#%x%x%x%x%x%x$' ~= nil
end

local function color_or(value, default)
  if is_hex(value) then
    return value:lower()
  end
  return default
end

local function read_lines(path)
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end

  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or type(lines) ~= 'table' then
    return nil
  end
  return lines
end

local function read_json(path)
  local lines = read_lines(path)
  if not lines then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not ok or type(decoded) ~= 'table' then
    return nil
  end
  return decoded
end

local function parse_ghostty_theme(path)
  local lines = read_lines(path)
  if not lines then
    return nil
  end

  local theme = {
    palette = {},
  }

  for _, line in ipairs(lines) do
    local key, value = line:match '^%s*([%w%-]+)%s*=%s*(.-)%s*$'
    if key == 'palette' then
      local index, color = value:match '^(%d+)%s*=%s*(#%x%x%x%x%x%x)'
      index = tonumber(index)
      if index and is_hex(color) then
        theme.palette[index] = color:lower()
      end
    elseif key then
      local color = value:match '(#%x%x%x%x%x%x)'
      if is_hex(color) then
        theme[key:gsub('%-', '_')] = color:lower()
      end
    end
  end

  if next(theme.palette) == nil and not theme.background and not theme.foreground then
    return nil
  end

  return theme
end

local function hex_to_rgb(hex)
  hex = color_or(hex, '#000000'):sub(2)
  return {
    r = tonumber(hex:sub(1, 2), 16),
    g = tonumber(hex:sub(3, 4), 16),
    b = tonumber(hex:sub(5, 6), 16),
  }
end

local function rgb_to_hex(rgb)
  return string.format('#%02x%02x%02x', rgb.r, rgb.g, rgb.b)
end

local function blend(fg, bg, alpha)
  local foreground = hex_to_rgb(fg)
  local background = hex_to_rgb(bg)
  local function channel(name)
    return math.floor((foreground[name] * alpha) + (background[name] * (1 - alpha)) + 0.5)
  end

  return rgb_to_hex {
    r = channel 'r',
    g = channel 'g',
    b = channel 'b',
  }
end

local function lighten(color, amount)
  return blend('#ffffff', color, amount)
end

local function darken(color, amount)
  return blend('#000000', color, amount)
end

local function derived_palette()
  local terminal = parse_ghostty_theme(ghostty_theme_path()) or {}
  local app = read_json(noctalia_colors_path()) or {}
  local palette = vim.tbl_extend('force', fallback.palette, terminal.palette or {})

  local bg = color_or(terminal.background, color_or(app.mSurface, fallback.background))
  local fg = color_or(terminal.foreground, color_or(app.mOnSurface, fallback.foreground))
  local surface = color_or(app.mSurface, bg)
  local surface_variant = color_or(app.mSurfaceVariant, color_or(palette[0], lighten(bg, 0.08)))
  local outline = color_or(app.mOutline, color_or(palette[8], lighten(bg, 0.42)))
  local on_surface_variant = color_or(app.mOnSurfaceVariant, color_or(palette[8], blend(fg, bg, 0.68)))

  return {
    bg = bg,
    bg_dark = darken(bg, 0.32),
    fg = fg,
    muted = on_surface_variant,
    surface = surface,
    surface0 = surface_variant,
    surface1 = lighten(bg, 0.08),
    surface2 = lighten(bg, 0.13),
    surface3 = lighten(bg, 0.18),
    border = outline,
    overlay = blend(fg, bg, 0.42),
    primary = color_or(app.mPrimary, color_or(palette[2], fallback.primary)),
    on_primary = color_or(app.mOnPrimary, bg),
    secondary = color_or(app.mSecondary, color_or(palette[3], fallback.secondary)),
    on_secondary = color_or(app.mOnSecondary, bg),
    tertiary = color_or(app.mTertiary, color_or(palette[4], fallback.tertiary)),
    on_tertiary = color_or(app.mOnTertiary, fallback.selection_foreground),
    error = color_or(app.mError, color_or(palette[1], fallback.error)),
    on_error = color_or(app.mOnError, bg),
    magenta = color_or(palette[5], color_or(app.mPrimary, fallback.primary)),
    cyan = color_or(palette[6], color_or(app.mSecondary, fallback.secondary)),
    cursor = color_or(terminal.cursor_color, fg),
    cursor_text = color_or(terminal.cursor_text, bg),
    selection_bg = color_or(terminal.selection_background, color_or(app.mHover, fallback.selection_background)),
    selection_fg = color_or(terminal.selection_foreground, color_or(app.mOnHover, fallback.selection_foreground)),
    diff_add = blend(color_or(app.mPrimary, palette[2]), bg, 0.22),
    diff_change = blend(color_or(app.mTertiary, palette[4]), bg, 0.22),
    diff_delete = blend(color_or(app.mError, palette[1]), bg, 0.22),
    palette = palette,
  }
end

local function set(name, values)
  pcall(vim.api.nvim_set_hl, 0, name, values)
end

local function link(name, target)
  set(name, { link = target })
end

local function set_terminal_colors(colors)
  for index = 0, 15 do
    vim.g['terminal_color_' .. index] = colors.palette[index] or fallback.palette[index]
  end
end

local function set_editor_highlights(c)
  set('Normal', { fg = c.fg, bg = c.bg })
  set('NormalNC', { fg = c.fg, bg = c.bg })
  set('NormalFloat', { fg = c.fg, bg = c.surface1 })
  set('FloatBorder', { fg = c.border, bg = c.surface1 })
  set('FloatTitle', { fg = c.primary, bg = c.surface1, bold = true })
  set('Cursor', { fg = c.cursor_text, bg = c.cursor })
  set('lCursor', { fg = c.cursor_text, bg = c.cursor })
  set('CursorIM', { fg = c.cursor_text, bg = c.cursor })
  set('TermCursor', { fg = c.cursor_text, bg = c.cursor })
  set('TermCursorNC', { fg = c.muted })
  set('ColorColumn', { bg = c.surface1 })
  set('Conceal', { fg = c.muted })
  set('CursorColumn', { bg = c.surface1 })
  set('CursorLine', { bg = c.surface1 })
  set('CursorLineNr', { fg = c.primary, bg = c.surface1, bold = true })
  set('LineNr', { fg = c.overlay })
  set('LineNrAbove', { fg = c.overlay })
  set('LineNrBelow', { fg = c.overlay })
  set('FoldColumn', { fg = c.muted, bg = c.bg })
  set('Folded', { fg = c.muted, bg = c.surface1 })
  set('SignColumn', { fg = c.muted, bg = c.bg })
  set('EndOfBuffer', { fg = c.bg })
  set('NonText', { fg = c.overlay })
  set('Whitespace', { fg = c.surface3 })
  set('SpecialKey', { fg = c.overlay })
  set('VertSplit', { fg = c.border, bg = c.bg })
  set('WinSeparator', { fg = c.border, bg = c.bg })
  set('Visual', { fg = c.selection_fg, bg = c.selection_bg })
  set('VisualNOS', { fg = c.selection_fg, bg = c.selection_bg })
  set('Search', { fg = c.on_tertiary, bg = c.tertiary })
  set('IncSearch', { fg = c.on_error, bg = c.error })
  set('CurSearch', { fg = c.on_error, bg = c.error })
  set('Substitute', { fg = c.on_error, bg = c.error })
  set('MatchParen', { fg = c.primary, bg = c.surface2, bold = true })
  set('Directory', { fg = c.primary })
  set('Title', { fg = c.primary, bold = true })
  set('Question', { fg = c.primary })
  set('MoreMsg', { fg = c.primary })
  set('ModeMsg', { fg = c.fg, bold = true })
  set('WarningMsg', { fg = c.tertiary })
  set('ErrorMsg', { fg = c.error })
  set('MsgArea', { fg = c.fg, bg = c.bg })
  set('MsgSeparator', { fg = c.border, bg = c.bg })

  set('Pmenu', { fg = c.fg, bg = c.surface1 })
  set('PmenuSel', { fg = c.on_primary, bg = c.primary })
  set('PmenuSbar', { bg = c.surface2 })
  set('PmenuThumb', { bg = c.primary })
  set('PmenuKind', { fg = c.secondary, bg = c.surface1 })
  set('PmenuKindSel', { fg = c.on_primary, bg = c.primary })
  set('PmenuExtra', { fg = c.muted, bg = c.surface1 })
  set('PmenuExtraSel', { fg = c.on_primary, bg = c.primary })

  set('StatusLine', { fg = c.fg, bg = c.surface1 })
  set('StatusLineNC', { fg = c.muted, bg = c.bg })
  set('WinBar', { fg = c.fg, bg = c.bg, bold = true })
  set('WinBarNC', { fg = c.muted, bg = c.bg })
  set('TabLine', { fg = c.muted, bg = c.surface0 })
  set('TabLineFill', { fg = c.muted, bg = c.bg })
  set('TabLineSel', { fg = c.on_primary, bg = c.primary, bold = true })
  set('WildMenu', { fg = c.on_primary, bg = c.primary })
  set('QuickFixLine', { fg = c.on_primary, bg = c.primary })
end

local function set_syntax_highlights(c)
  set('Comment', { fg = c.muted, italic = true })
  set('Constant', { fg = c.tertiary })
  set('String', { fg = c.secondary })
  set('Character', { fg = c.secondary })
  set('Number', { fg = c.tertiary })
  set('Boolean', { fg = c.tertiary })
  set('Float', { fg = c.tertiary })
  set('Identifier', { fg = c.fg })
  set('Function', { fg = c.primary })
  set('Statement', { fg = c.magenta })
  set('Conditional', { fg = c.magenta })
  set('Repeat', { fg = c.magenta })
  set('Label', { fg = c.magenta })
  set('Operator', { fg = c.muted })
  set('Keyword', { fg = c.magenta })
  set('Exception', { fg = c.error })
  set('PreProc', { fg = c.primary })
  set('Include', { fg = c.primary })
  set('Define', { fg = c.primary })
  set('Macro', { fg = c.primary })
  set('PreCondit', { fg = c.primary })
  set('Type', { fg = c.primary })
  set('StorageClass', { fg = c.magenta })
  set('Structure', { fg = c.primary })
  set('Typedef', { fg = c.primary })
  set('Special', { fg = c.cyan })
  set('SpecialChar', { fg = c.cyan })
  set('Tag', { fg = c.tertiary })
  set('Delimiter', { fg = c.overlay })
  set('SpecialComment', { fg = c.muted, italic = true })
  set('Debug', { fg = c.error })
  set('Underlined', { fg = c.primary, underline = true })
  set('Ignore', { fg = c.overlay })
  set('Error', { fg = c.error })
  set('Todo', { fg = c.on_tertiary, bg = c.tertiary, bold = true })

  link('@variable', 'Identifier')
  link('@variable.builtin', 'Special')
  link('@constant', 'Constant')
  link('@constant.builtin', 'Constant')
  link('@module', 'Identifier')
  link('@string', 'String')
  link('@character', 'Character')
  link('@number', 'Number')
  link('@boolean', 'Boolean')
  link('@float', 'Float')
  link('@function', 'Function')
  link('@function.builtin', 'Function')
  link('@function.call', 'Function')
  link('@constructor', 'Function')
  link('@keyword', 'Keyword')
  link('@keyword.function', 'Keyword')
  link('@keyword.operator', 'Keyword')
  link('@keyword.return', 'Keyword')
  link('@conditional', 'Conditional')
  link('@repeat', 'Repeat')
  link('@operator', 'Operator')
  link('@type', 'Type')
  link('@type.builtin', 'Type')
  link('@property', 'Identifier')
  link('@field', 'Identifier')
  link('@parameter', 'Identifier')
  link('@punctuation.delimiter', 'Delimiter')
  link('@punctuation.bracket', 'Delimiter')
  link('@punctuation.special', 'Special')
  link('@comment', 'Comment')
  link('@tag', 'Tag')
  link('@tag.attribute', 'Identifier')
  link('@tag.delimiter', 'Delimiter')
  link('@markup.heading', 'Title')
  link('@markup.link', 'Underlined')
  link('@markup.raw', 'String')
end

local function set_diagnostics_highlights(c)
  set('DiagnosticError', { fg = c.error })
  set('DiagnosticWarn', { fg = c.tertiary })
  set('DiagnosticInfo', { fg = c.primary })
  set('DiagnosticHint', { fg = c.cyan })
  set('DiagnosticOk', { fg = c.secondary })
  set('DiagnosticVirtualTextError', { fg = c.error, bg = blend(c.error, c.bg, 0.12) })
  set('DiagnosticVirtualTextWarn', { fg = c.tertiary, bg = blend(c.tertiary, c.bg, 0.12) })
  set('DiagnosticVirtualTextInfo', { fg = c.primary, bg = blend(c.primary, c.bg, 0.12) })
  set('DiagnosticVirtualTextHint', { fg = c.cyan, bg = blend(c.cyan, c.bg, 0.12) })
  set('DiagnosticUnderlineError', { sp = c.error, undercurl = true })
  set('DiagnosticUnderlineWarn', { sp = c.tertiary, undercurl = true })
  set('DiagnosticUnderlineInfo', { sp = c.primary, undercurl = true })
  set('DiagnosticUnderlineHint', { sp = c.cyan, undercurl = true })
end

local function set_plugin_highlights(c)
  set('DiffAdd', { bg = c.diff_add })
  set('DiffChange', { bg = c.diff_change })
  set('DiffDelete', { fg = c.error, bg = c.diff_delete })
  set('DiffText', { bg = blend(c.primary, c.bg, 0.32) })

  set('GitSignsAdd', { fg = c.primary, bg = c.bg })
  set('GitSignsChange', { fg = c.tertiary, bg = c.bg })
  set('GitSignsDelete', { fg = c.error, bg = c.bg })

  set('TelescopeNormal', { fg = c.fg, bg = c.surface1 })
  set('TelescopeBorder', { fg = c.border, bg = c.surface1 })
  set('TelescopePromptNormal', { fg = c.fg, bg = c.surface2 })
  set('TelescopePromptBorder', { fg = c.border, bg = c.surface2 })
  set('TelescopePromptTitle', { fg = c.on_primary, bg = c.primary, bold = true })
  set('TelescopeSelection', { fg = c.fg, bg = c.surface2 })
  set('TelescopeMatching', { fg = c.primary, bold = true })

  set('NeoTreeNormal', { fg = c.fg, bg = c.bg })
  set('NeoTreeNormalNC', { fg = c.fg, bg = c.bg })
  set('NeoTreeEndOfBuffer', { fg = c.bg, bg = c.bg })
  set('NeoTreeDirectoryName', { fg = c.primary })
  set('NeoTreeDirectoryIcon', { fg = c.primary })
  set('NeoTreeGitAdded', { fg = c.primary })
  set('NeoTreeGitModified', { fg = c.tertiary })
  set('NeoTreeGitDeleted', { fg = c.error })

  set('WhichKeyNormal', { fg = c.fg, bg = c.surface1 })
  set('WhichKeyBorder', { fg = c.border, bg = c.surface1 })
  set('WhichKey', { fg = c.primary })
  set('WhichKeyGroup', { fg = c.secondary })
  set('WhichKeyDesc', { fg = c.fg })
  set('WhichKeySeparator', { fg = c.overlay })

  set('LazyNormal', { fg = c.fg, bg = c.surface1 })
  set('MasonNormal', { fg = c.fg, bg = c.surface1 })
  set('TroubleNormal', { fg = c.fg, bg = c.bg })
  set('TroubleNormalNC', { fg = c.muted, bg = c.bg })

  set('BlinkCmpMenu', { fg = c.fg, bg = c.surface1 })
  set('BlinkCmpMenuBorder', { fg = c.border, bg = c.surface1 })
  set('BlinkCmpMenuSelection', { fg = c.on_primary, bg = c.primary })
  set('BlinkCmpLabelMatch', { fg = c.primary, bold = true })

  set('SnacksNormal', { fg = c.fg, bg = c.bg })
  set('SnacksPicker', { fg = c.fg, bg = c.surface1 })
  set('SnacksPickerBorder', { fg = c.border, bg = c.surface1 })
  set('NotifyBackground', { bg = c.surface1 })
end

local function current_signature()
  local parts = {}
  for _, path in ipairs(M.watch_paths()) do
    local stat = uv.fs_stat(path)
    if stat then
      table.insert(parts, table.concat({ path, stat.size or 0, stat.mtime.sec or 0, stat.mtime.nsec or 0 }, ':'))
    end
  end
  return table.concat(parts, '|')
end

local function schedule_refresh()
  if state.refresh_scheduled then
    return
  end

  state.refresh_scheduled = true
  vim.schedule(function()
    vim.defer_fn(function()
      state.refresh_scheduled = false
      M.reload_if_current()
    end, 100)
  end)
end

local function refresh_lualine()
  local lualine = package.loaded.lualine
  if not lualine then
    return
  end

  package.loaded['lualine.themes.noctalia'] = nil
  package.loaded['lualine.themes.auto'] = nil

  pcall(function()
    lualine.setup(lualine.get_config())
  end)
end

local function reapply_transparency()
  local ok, transparency = pcall(require, 'config.transparency')
  if not ok or not transparency.is_enabled() then
    return
  end

  transparency.apply()
  vim.schedule(transparency.apply)
end

function M.watch_paths()
  return {
    ghostty_theme_path(),
    noctalia_colors_path(),
  }
end

function M.palette()
  return derived_palette()
end

function M.apply()
  vim.o.termguicolors = true
  vim.o.background = 'dark'

  if vim.g.colors_name then
    vim.cmd 'highlight clear'
  end

  if vim.fn.exists('syntax_on') == 1 then
    vim.cmd 'syntax reset'
  end

  vim.g.colors_name = 'noctalia'

  local c = M.palette()
  set_terminal_colors(c)
  set_editor_highlights(c)
  set_syntax_highlights(c)
  set_diagnostics_highlights(c)
  set_plugin_highlights(c)

  state.signature = current_signature()
  M.setup_autoreload()
end

function M.lualine_theme()
  local c = M.palette()

  local theme = {
    normal = {
      a = { fg = c.on_primary, bg = c.primary, gui = 'bold' },
      b = { fg = c.primary, bg = c.surface1 },
      c = { fg = c.fg, bg = c.bg },
    },
    insert = {
      a = { fg = c.on_secondary, bg = c.secondary, gui = 'bold' },
      b = { fg = c.secondary, bg = c.surface1 },
      c = { fg = c.fg, bg = c.bg },
    },
    visual = {
      a = { fg = c.on_tertiary, bg = c.tertiary, gui = 'bold' },
      b = { fg = c.tertiary, bg = c.surface1 },
      c = { fg = c.fg, bg = c.bg },
    },
    replace = {
      a = { fg = c.on_error, bg = c.error, gui = 'bold' },
      b = { fg = c.error, bg = c.surface1 },
      c = { fg = c.fg, bg = c.bg },
    },
    command = {
      a = { fg = c.on_primary, bg = c.magenta, gui = 'bold' },
      b = { fg = c.magenta, bg = c.surface1 },
      c = { fg = c.fg, bg = c.bg },
    },
    inactive = {
      a = { fg = c.muted, bg = c.bg },
      b = { fg = c.muted, bg = c.bg },
      c = { fg = c.muted, bg = c.bg },
    },
  }

  theme.terminal = theme.command
  return theme
end

function M.reload_if_current(force)
  if vim.g.colors_name ~= 'noctalia' then
    state.signature = current_signature()
    return
  end

  local signature = current_signature()
  if not force and signature == state.signature then
    return
  end

  pcall(vim.cmd.colorscheme, 'noctalia')
  refresh_lualine()
  reapply_transparency()
end

function M.setup_autoreload()
  if state.autoreload_setup then
    return
  end
  state.autoreload_setup = true

  local group = vim.api.nvim_create_augroup('config-noctalia', { clear = true })
  vim.api.nvim_create_autocmd({ 'FocusGained', 'VimResume' }, {
    group = group,
    callback = function()
      M.reload_if_current()
    end,
    desc = 'Reload Noctalia colors when generated palette files change',
  })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      for _, watcher in pairs(state.watchers) do
        pcall(function()
          watcher:stop()
          watcher:close()
        end)
      end
      state.watchers = {}
    end,
    desc = 'Stop Noctalia palette watchers',
  })

  for _, path in ipairs(M.watch_paths()) do
    local dir = vim.fn.fnamemodify(path, ':h')
    if dir ~= '' and vim.fn.isdirectory(dir) == 1 and not state.watchers[dir] then
      local watcher = uv.new_fs_event()
      if watcher then
        local basename = vim.fn.fnamemodify(path, ':t')
        local ok = watcher:start(dir, {}, function(_, filename)
          if filename == nil or filename == basename then
            schedule_refresh()
          end
        end)
        if ok then
          state.watchers[dir] = watcher
        else
          watcher:close()
        end
      end
    end
  end
end

function M.ghostty_uses_noctalia()
  local lines = read_lines(ghostty_config_path())
  if not lines then
    return false
  end

  for _, line in ipairs(lines) do
    local theme = line:match '^%s*theme%s*=%s*([^#%s]+)'
    if theme == 'noctalia' then
      return true
    end
  end

  return false
end

function M.should_prefer()
  return M.ghostty_uses_noctalia() and vim.fn.filereadable(ghostty_theme_path()) == 1
end

function M.themery_before_code()
  return "require('config.noctalia').setup_autoreload()"
end

function M.prefer_themery_state(theme_id)
  if not theme_id or not M.should_prefer() then
    return
  end

  local state_dir = vim.fn.stdpath('data') .. '/themery'
  local state_file = state_dir .. '/state.json'
  local before = M.themery_before_code() .. '\n'
  local current = read_json(state_file) or {}

  if current.colorscheme == 'noctalia' and current.theme_id == theme_id and current.beforeCode == before then
    return
  end

  local ok = pcall(vim.fn.mkdir, state_dir, 'p')
  if not ok then
    return
  end

  local data = {
    version = 0,
    colorscheme = 'noctalia',
    theme_id = theme_id,
    beforeCode = before,
    afterCode = '',
    globalBeforeCode = current.globalBeforeCode or '',
    globalAfterCode = current.globalAfterCode or '',
  }

  pcall(vim.fn.writefile, { vim.json.encode(data) }, state_file)
end

return M
