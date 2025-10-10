local M = {}

function M.focus_or_open(path, opts)
  if not path or path == '' then
    return false
  end

  opts = opts or {}
  local fallback = opts.fallback
  local after = opts.after
  local prefer_current = opts.prefer_current

  local function run_after(bufnr, win)
    if not after then
      return
    end
    vim.schedule(function()
      after(bufnr, win)
    end)
  end

  local bufnr = vim.fn.bufnr(path, false)

  if bufnr > 0 then
    if prefer_current then
      vim.schedule(function()
        local win = vim.api.nvim_get_current_win()
        if not vim.api.nvim_buf_is_loaded(bufnr) then
          pcall(vim.fn.bufload, bufnr)
        end
        pcall(vim.api.nvim_win_set_buf, win, bufnr)
        run_after(bufnr, win)
      end)
      return true
    end

    local wins = vim.fn.win_findbuf(bufnr)
    for _, win in ipairs(wins) do
      if vim.api.nvim_win_is_valid(win) then
        local tab = vim.api.nvim_win_get_tabpage(win)
        if tab then
          vim.schedule(function()
            pcall(vim.api.nvim_set_current_tabpage, tab)
            if vim.api.nvim_get_current_win() ~= win then
              pcall(vim.api.nvim_set_current_win, win)
            end
            run_after(bufnr, win)
          end)
          return true
        end
      end
    end
  end

  if fallback then
    fallback(function()
      run_after(vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win())
    end)
    return true
  end

  return false
end

return M
