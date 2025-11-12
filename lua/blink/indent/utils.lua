local M = {}

--- @param bufnr integer
function M.get_shiftwidth(bufnr)
  local shiftwidth = vim.bo[bufnr].shiftwidth
  if shiftwidth == 0 then shiftwidth = vim.bo[bufnr].tabstop end
  return math.max(shiftwidth, 2)
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
