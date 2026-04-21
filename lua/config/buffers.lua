local M = {}

local function is_valid_buf(buf)
  return type(buf) == 'number' and buf > 0 and vim.api.nvim_buf_is_valid(buf)
end

local function is_listed_buf(buf)
  return is_valid_buf(buf) and vim.bo[buf].buflisted
end

local function pick_fallback(exclude)
  local alt = vim.fn.bufnr '#'
  if alt ~= exclude and is_listed_buf(alt) then
    return alt
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= exclude and is_listed_buf(buf) then
      return buf
    end
  end
end

function M.delete(buf, opts)
  opts = opts or {}
  buf = buf or vim.api.nvim_get_current_buf()
  if not is_valid_buf(buf) then
    return false
  end

  local fallback = pick_fallback(buf)
  local wins = vim.fn.win_findbuf(buf)

  if fallback and is_valid_buf(fallback) then
    for _, win in ipairs(wins) do
      if vim.api.nvim_win_is_valid(win) then
        pcall(vim.api.nvim_win_set_buf, win, fallback)
      end
    end
  else
    local replacement = vim.api.nvim_create_buf(true, false)
    for _, win in ipairs(wins) do
      if vim.api.nvim_win_is_valid(win) then
        pcall(vim.api.nvim_win_set_buf, win, replacement)
      end
    end
  end

  local ok = pcall(vim.api.nvim_buf_delete, buf, { force = opts.force or false })
  return ok
end

function M.delete_current(opts)
  return M.delete(vim.api.nvim_get_current_buf(), opts)
end

return M
