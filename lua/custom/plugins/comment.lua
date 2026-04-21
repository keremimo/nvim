return {
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
  opts = function()
    return {
      pre_hook = function(ctx)
        local ok_ft, ft = pcall(require, 'Comment.ft')
        if not ok_ft then
          return vim.bo.commentstring
        end

        local fallback = ft.get(vim.bo.filetype, ctx.ctype) or vim.bo.commentstring
        local ok_parser, parser = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
        if not ok_parser or not parser then
          return fallback
        end

        local ok_cstr, cstr = pcall(ft.calculate, ctx)
        if ok_cstr and type(cstr) == 'string' and cstr:find '%%s' then
          return cstr
        end

        return fallback
      end,
    }
  end,
  config = function(_, opts)
    local ok_utils, utils = pcall(require, 'Comment.utils')
    if ok_utils and utils and utils.catch then
      utils.catch = function(fn, ...)
        xpcall(fn, function(err)
          local msg
          if type(err) == 'table' then
            msg = err.msg or err.message or vim.inspect(err)
          else
            msg = tostring(err)
          end
          vim.notify(string.format('[Comment.nvim] %s', msg), vim.log.levels.WARN)
        end, ...)
      end
    end

    require('Comment').setup(opts)
  end,
}
