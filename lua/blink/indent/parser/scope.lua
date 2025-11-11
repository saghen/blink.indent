--- @class blink.indent.ScopeRange
--- @field indent_level integer
--- @field start_line integer
--- @field end_line integer

local utils = require('blink.indent.utils')

local M = {}

--- Gets the scope within the given range using the parsed indent levels
--- @param bufnr integer
--- @param winnr integer
--- @param indent_levels table<integer, integer>
--- @param range blink.indent.ParseRange
--- @return blink.indent.ScopeRange
function M.get_scope_partial(bufnr, winnr, indent_levels, range)
  local cursor_line = vim.api.nvim_win_get_cursor(winnr)[1]
  local scope_search_start_line, scope_indent_level = M.get_scope_start(bufnr, cursor_line, utils.get_shiftwidth(bufnr))

  -- move up and down to find the scope
  local scope_start_line = scope_search_start_line
  while scope_start_line > range.start_line do
    if scope_indent_level > indent_levels[scope_start_line - 1] then break end
    scope_start_line = scope_start_line - 1
  end
  local scope_end_line = scope_search_start_line
  while scope_end_line < range.end_line do
    if scope_indent_level > indent_levels[scope_end_line + 1] then break end
    scope_end_line = scope_end_line + 1
  end

  return { indent_level = scope_indent_level, start_line = scope_start_line, end_line = scope_end_line }
end

--- Gets the scope range without any parsing beforehand, for motions/textobjects
--- @param bufnr? integer
--- @param winnr? integer
--- @return blink.indent.ScopeRange scope_range
function M.get_scope(bufnr, winnr)
  if not bufnr or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if not winnr or winnr == 0 then winnr = vim.api.nvim_get_current_win() end

  local shiftwidth = utils.get_shiftwidth(bufnr)
  local cursor_line = vim.api.nvim_win_get_cursor(winnr)[1]
  local start_line, scope_indent_level = M.get_scope_start(bufnr, cursor_line, shiftwidth)

  -- move up and down to find the scope
  local scope_start_line = start_line
  while scope_start_line > 1 do
    local prev_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, scope_start_line - 1, shiftwidth)
    if not is_all_whitespace and scope_indent_level > prev_indent_level then break end
    scope_start_line = scope_start_line - 1
  end
  local scope_end_line = start_line
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  while scope_end_line < line_count do
    local next_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, scope_end_line + 1, shiftwidth)

    if not is_all_whitespace and scope_indent_level > next_indent_level then break end
    scope_end_line = scope_end_line + 1
  end

  return { start_line = scope_start_line, end_line = scope_end_line, indent_level = scope_indent_level }
end

--- @param bufnr integer
--- @param cursor_line integer
--- @param shiftwidth integer
--- @return integer cursor_line
--- @return integer scope_indent_level
function M.get_scope_start(bufnr, cursor_line, shiftwidth)
  local scope_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, cursor_line, shiftwidth)
  while is_all_whitespace and cursor_line > 1 do
    cursor_line = cursor_line - 1
    scope_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, cursor_line, shiftwidth)
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local scope_next_indent_level, next_is_all_whitespace =
    line_count < cursor_line and M.get_line_indent_level(bufnr, cursor_line + 1, shiftwidth) or -1, false
  while cursor_line < line_count and next_is_all_whitespace do
    cursor_line = cursor_line + 1
    scope_next_indent_level, next_is_all_whitespace = M.get_line_indent_level(bufnr, cursor_line + 1, shiftwidth)
  end

  -- start from the next line if its indent level its higher
  local starting_from_next_line = scope_next_indent_level > scope_indent_level
  if starting_from_next_line then
    cursor_line = cursor_line + 1
    scope_indent_level = scope_next_indent_level
  end

  return cursor_line, scope_indent_level
end

--- @param bufnr integer
--- @param line_number integer
--- @param shiftwidth integer
--- @return integer indent_level
--- @return boolean is_all_whitespace
function M.get_line_indent_level(bufnr, line_number, shiftwidth)
  local line = utils.get_line(bufnr, line_number)

  local whitespace_chars = line:match('^%s*')
  --- @cast whitespace_chars string
  local whitespace_char_count = whitespace_chars:find('\t') ~= nil
      and whitespace_chars:gsub('\t', (' '):rep(shiftwidth)):len()
    or whitespace_chars:len()

  return math.floor(whitespace_char_count / shiftwidth), #whitespace_chars == #line
end

return M
