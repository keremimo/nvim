local M = {}

local profile_order = { 'coding', 'writing', 'debugging' }

local profiles = {
  coding = {
    desc = 'Coding profile',
    window = {
      number = true,
      relativenumber = false,
      wrap = false,
      linebreak = false,
      spell = false,
      colorcolumn = '',
      signcolumn = 'yes',
      cursorline = true,
    },
  },
  writing = {
    desc = 'Writing profile',
    window = {
      number = false,
      relativenumber = false,
      wrap = true,
      linebreak = true,
      spell = true,
      colorcolumn = '80',
      signcolumn = 'auto',
      cursorline = false,
    },
  },
  debugging = {
    desc = 'Debugging profile',
    window = {
      number = true,
      relativenumber = false,
      wrap = false,
      linebreak = false,
      spell = false,
      colorcolumn = '',
      signcolumn = 'yes:2',
      cursorline = true,
    },
    on_apply = function()
      pcall(function()
        require('dapui').open()
      end)
    end,
  },
}

local function set_window_option(name, value)
  pcall(vim.api.nvim_set_option_value, name, value, { scope = 'global' })
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    pcall(vim.api.nvim_set_option_value, name, value, { win = win })
  end
end

function M.apply(name)
  local profile = profiles[name]
  if not profile then
    vim.notify('Unknown workspace profile: ' .. tostring(name), vim.log.levels.ERROR)
    return
  end

  for option, value in pairs(profile.window or {}) do
    set_window_option(option, value)
  end

  if profile.diagnostics then
    vim.diagnostic.config(profile.diagnostics)
  end

  if profile.on_apply then
    pcall(profile.on_apply)
  end

  vim.g.workspace_profile = name
  vim.notify('Workspace profile: ' .. name, vim.log.levels.INFO)
end

function M.pick()
  vim.ui.select(profile_order, {
    prompt = 'Select workspace profile',
    format_item = function(item)
      return string.format('%s - %s', item, profiles[item].desc)
    end,
  }, function(choice)
    if choice then
      M.apply(choice)
    end
  end)
end

function M.setup()
  vim.api.nvim_create_user_command('WorkspaceProfile', function(opts)
    if opts.args == '' then
      M.pick()
      return
    end
    M.apply(opts.args)
  end, {
    nargs = '?',
    complete = function()
      return profile_order
    end,
    desc = 'Apply workspace profile (coding, writing, debugging)',
  })
end

return M
