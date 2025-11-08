local M = {}

function M.get_shiftwidth(bufnr)
  local shiftwidth = vim.bo[bufnr].shiftwidth
  if shiftwidth == 0 then shiftwidth = vim.bo[bufnr].tabstop end
  return math.max(shiftwidth, 2)
end

function M.get_line(bufnr, line_idx) return vim.api.nvim_buf_get_lines(bufnr, line_idx - 1, line_idx, false)[1] end

function M.get_rainbow_hl(idx, hl_groups) return hl_groups[(math.floor(idx)) % #hl_groups + 1] end

--- Get the top and bottom line of the viewport
--- @param winnr number
--- @param bufnr number
--- @return { bufnr: number, start_line: number, end_line: number, horizontal_offset: number }
M.get_win_scroll_range = function(winnr, bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  return {
    bufnr = bufnr,
    start_line = math.max(1, vim.fn.line('w0', winnr) - 1),
    end_line = math.min(line_count, vim.fn.line('w$', winnr) + 1),
    horizontal_offset = vim.api.nvim_win_call(winnr, function() return vim.fn.winsaveview().leftcol end),
  }
end

return M
