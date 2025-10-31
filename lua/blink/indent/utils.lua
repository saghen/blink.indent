local M = {}

function M.get_shiftwidth(bufnr)
  local shiftwidth = vim.api.nvim_get_option_value('shiftwidth', { buf = bufnr })
  -- todo: is this correct?
  if shiftwidth == 0 then shiftwidth = vim.api.nvim_get_option_value('tabstop', { buf = bufnr }) end
  -- default to 2 if shiftwidth and tabwidth are 0
  return math.max(shiftwidth, 2)
end

function M.get_line(bufnr, line_idx) return vim.api.nvim_buf_get_lines(bufnr, line_idx - 1, line_idx, false)[1] end

function M.get_rainbow_hl(idx, hl_groups) return hl_groups[(math.floor(idx)) % #hl_groups + 1] end

M.get_win_scroll_range = function(winnr)
  local bufnr = vim.api.nvim_win_get_buf(winnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  -- Get the scrolled range (start and end line)
  local start_line = math.max(1, vim.fn.line('w0', winnr) - 1)
  local end_line = math.max(start_line, math.min(line_count, vim.fn.line('w$', winnr) + 1))

  local horizontal_offset = vim.fn.winsaveview().leftcol

  return { bufnr = bufnr, start_line = start_line, end_line = end_line, horizontal_offset = horizontal_offset }
end

return M
