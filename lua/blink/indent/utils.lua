local M = {}

--- @param bufnr integer
--- @return integer
function M.get_shiftwidth(bufnr)
  local shiftwidth = vim.bo[bufnr].shiftwidth
  if shiftwidth == 0 then shiftwidth = vim.bo[bufnr].tabstop end
  return math.max(shiftwidth, 2)
end

--- @param winnr integer
--- @return string space
--- @return string[]? tab
function M.get_listchars(winnr)
  if not vim.wo[winnr].list then return ' ' end
  local listchars = ',' .. vim.wo[winnr].listchars
  local space = listchars:match(',space:([^,]*)') or ' '
  local tab = listchars:match(',tab:([^,]*)')
  return space, tab and vim.fn.split(tab, '\\zs')
end

--- @param whitespace string
--- @param bufnr? integer
--- @return integer
function M.get_whitespace_width(whitespace, bufnr)
  if not whitespace:find('\t', 1, true) then return #whitespace end
  if not bufnr or bufnr == 0 or bufnr == vim.api.nvim_get_current_buf() then
    return vim.fn.strdisplaywidth(whitespace)
  end
  return vim.api.nvim_buf_call(bufnr, function() return vim.fn.strdisplaywidth(whitespace) end)
end

--- @param winnr integer
--- @return boolean
function M.get_breakindent(winnr)
  local breakindent = vim.wo[winnr].breakindent
  if breakindent == nil then breakindent = vim.o.breakindent end
  return breakindent
end

--- @param bufnr integer
--- @param line_idx integer
--- @return string
function M.get_line(bufnr, line_idx) return vim.api.nvim_buf_get_lines(bufnr, line_idx - 1, line_idx, false)[1] end

--- @param idx number
--- @param hl_groups string[]
--- @return string
function M.get_rainbow_hl(idx, hl_groups) return hl_groups[(math.floor(idx)) % #hl_groups + 1] end

function M.make_buffer_cache()
  local augroup = vim.api.nvim_create_augroup('blink.indent', { clear = false })
  local cache = {}
  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    group = augroup,
    callback = function(args) cache[args.buf] = nil end,
  })
  return cache
end

return M
