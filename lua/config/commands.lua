local state_dir = vim.fn.stdpath 'state'

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
  local ok, report = pcall(vim.fn.execute, 'checkhealth')
  if not ok then
    vim.notify('checkhealth failed: ' .. tostring(report), vim.log.levels.ERROR)
    return
  end

  local write_ok, err = pcall(vim.fn.writefile, vim.split(report, '\n', { plain = true }), path)
  if not write_ok then
    vim.notify('Failed to write health report: ' .. tostring(err), vim.log.levels.ERROR)
    return
  end

  vim.notify('Health report written to ' .. path, vim.log.levels.INFO)
end, {
  nargs = '?',
  complete = 'file',
  desc = 'Run :checkhealth and write output to a file',
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
  local message = string.format(
    'Startup: %d/%d plugins in %.2fms (lazy.nvim %.2fms)',
    stats.loaded,
    stats.count,
    stats.startuptime,
    stats.times.LazyDone or 0
  )
  vim.notify(message, vim.log.levels.INFO)
end, {
  desc = 'Show lazy.nvim startup statistics',
})
