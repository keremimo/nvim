local state_dir = vim.fn.stdpath 'state'
local config_dir = vim.fn.stdpath 'config'

local function write_command_report(command, path, label)
  local ok, report = pcall(vim.fn.execute, command)
  if not ok then
    vim.notify(label .. ' failed: ' .. tostring(report), vim.log.levels.ERROR)
    return
  end

  local write_ok, err = pcall(vim.fn.writefile, vim.split(report, '\n', { plain = true }), path)
  if not write_ok then
    vim.notify('Failed to write ' .. label .. ' report: ' .. tostring(err), vim.log.levels.ERROR)
    return
  end

  vim.notify(label .. ' report written to ' .. path, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('ProfileStart', function(opts)
  local path = opts.args ~= '' and opts.args or (state_dir .. '/profile.log')
  vim.cmd('profile start ' .. vim.fn.fnameescape(path))
  vim.cmd 'profile func *'
  vim.cmd 'profile file *'
  vim.notify('Profiling started: ' .. path, vim.log.levels.INFO)
end, {
  nargs = '?',
  complete = 'file',
  desc = 'Start Neovim profiling',
})

vim.api.nvim_create_user_command('ProfileStop', function()
  vim.cmd 'profile pause'
  vim.cmd 'profile stop'
  vim.notify('Profiling stopped', vim.log.levels.INFO)
end, {
  desc = 'Stop Neovim profiling',
})

vim.api.nvim_create_user_command('HealthReport', function(opts)
  local path = opts.args ~= '' and opts.args or (state_dir .. '/health-report.txt')
  write_command_report('checkhealth', path, 'Health')
end, {
  nargs = '?',
  complete = 'file',
  desc = 'Run :checkhealth and write output to a file',
})

vim.api.nvim_create_user_command('DeprecatedHealthReport', function(opts)
  local path = opts.args ~= '' and opts.args or (state_dir .. '/deprecated-health-report.txt')
  write_command_report('checkhealth vim.deprecated', path, 'Deprecated health')
end, {
  nargs = '?',
  complete = 'file',
  desc = 'Run :checkhealth vim.deprecated and write output to a file',
})

vim.api.nvim_create_user_command('LazyProfile', function()
  vim.cmd 'Lazy profile'
end, {
  desc = 'Open lazy.nvim startup profiler',
})

vim.api.nvim_create_user_command('LazyStats', function()
  local ok, lazy = pcall(require, 'lazy')
  if not ok then
    vim.notify('lazy.nvim is not available', vim.log.levels.ERROR)
    return
  end

  local stats = lazy.stats()
  local message = string.format('Startup: %d/%d plugins in %.2fms (lazy.nvim %.2fms)', stats.loaded, stats.count, stats.startuptime, stats.times.LazyDone or 0)
  vim.notify(message, vim.log.levels.INFO)
end, {
  desc = 'Show lazy.nvim startup statistics',
})

local function search_config()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok then
    builtin.find_files { cwd = config_dir }
    return
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(config_dir))
end

local function live_grep_config()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok then
    builtin.live_grep { cwd = config_dir }
    return
  end

  vim.notify('Telescope is not available', vim.log.levels.ERROR)
end

vim.api.nvim_create_user_command('ConfigMenu', function()
  local actions = {
    {
      label = 'Edit init.lua',
      run = function()
        vim.cmd('edit ' .. vim.fn.fnameescape(config_dir .. '/init.lua'))
      end,
    },
    {
      label = 'Search config files',
      run = search_config,
    },
    {
      label = 'Grep config',
      run = live_grep_config,
    },
    {
      label = 'Workspace profile',
      run = function()
        require('config.profiles').pick()
      end,
    },
    {
      label = 'Theme picker',
      run = function()
        vim.cmd 'Themery'
      end,
    },
    {
      label = 'Lazy stats',
      run = function()
        vim.cmd 'LazyStats'
      end,
    },
    {
      label = 'Lazy profile',
      run = function()
        vim.cmd 'LazyProfile'
      end,
    },
    {
      label = 'Write health report',
      run = function()
        vim.cmd 'HealthReport'
      end,
    },
    {
      label = 'Write deprecated health report',
      run = function()
        vim.cmd 'DeprecatedHealthReport'
      end,
    },
  }

  vim.ui.select(actions, {
    prompt = 'Neovim config',
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      choice.run()
    end
  end)
end, {
  desc = 'Open Neovim config action menu',
})
