--- @class blink.indent.ScopeRange
--- @field indent_level integer
--- @field start_line integer
--- @field end_line integer

local utils = require('blink.indent.utils')
local config = require('blink.indent.config')

local M = {}

--- Gets the scope within the given range using the parsed indent levels
--- @param bufnr integer
--- @param winnr integer
--- @param indent_levels table<integer, integer>
--- @param range blink.indent.ParseRange
--- @return blink.indent.ScopeRange
function M.get_scope_partial(bufnr, winnr, indent_levels, range)
  local cursor_line = M.get_cursor_line_in_range(winnr, range)
  local scope_search_start_line, scope_indent_level =
    M.get_scope_start(bufnr, cursor_line, range, utils.get_shiftwidth(bufnr))

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
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local start_line, scope_indent_level =
    M.get_scope_start(bufnr, cursor_line, { start_line = 1, end_line = line_count, horizontal_offset = 0 }, shiftwidth)

  -- move up and down to find the scope
  local scope_start_line = start_line
  while scope_start_line > 1 do
    local prev_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, scope_start_line - 1, shiftwidth)
    if not is_all_whitespace and scope_indent_level > prev_indent_level then break end
    scope_start_line = scope_start_line - 1
  end
  local scope_end_line = start_line
  while scope_end_line < line_count do
    local next_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, scope_end_line + 1, shiftwidth)

    if not is_all_whitespace and scope_indent_level > next_indent_level then break end
    scope_end_line = scope_end_line + 1
  end

  return { start_line = scope_start_line, end_line = scope_end_line, indent_level = scope_indent_level }
end

--- In some rare cases, the cursor line can reside outside of the window's viewport, such as after
--- cancelling a search. As a result, when using the indent levels from a range, we must bound the
--- cursor line to the bottom/top of the viewport.
--- See https://github.com/saghen/blink.indent/issues/36#issuecomment-3715378685
--- @param winnr integer
--- @param range blink.indent.ParseRange
--- @return integer
function M.get_cursor_line_in_range(winnr, range)
  local cursor_line = vim.api.nvim_win_get_cursor(winnr)[1]
  return math.max(range.start_line, math.min(range.end_line, cursor_line))
end

--- @param bufnr integer
--- @param cursor_line integer
--- @param range blink.indent.ParseRange
--- @param shiftwidth integer
--- @return integer cursor_line
--- @return integer scope_indent_level
function M.get_scope_start(bufnr, cursor_line, range, shiftwidth)
  -- search upward for the first non all-whitespace line
  local scope_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, cursor_line, shiftwidth)
  while is_all_whitespace and cursor_line > range.start_line do
    cursor_line = cursor_line - 1
    scope_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, cursor_line, shiftwidth)
  end

  -- clamp indent level to cursor
  if config.scope.indent_at_cursor then
    local cursor_indent_level, covers_all_whitespace = M.get_cursor_indent_level(bufnr, cursor_line, shiftwidth)
    if cursor_indent_level <= scope_indent_level and not covers_all_whitespace then
      return cursor_line, math.ceil(cursor_indent_level)
    end
  end

  if cursor_line == range.end_line then return cursor_line, scope_indent_level end

  local next_line = cursor_line + 1
  local scope_next_indent_level, next_is_all_whitespace = M.get_line_indent_level(bufnr, next_line, shiftwidth)
  while next_is_all_whitespace and next_line < range.end_line do
    next_line = next_line + 1
    scope_next_indent_level, next_is_all_whitespace = M.get_line_indent_level(bufnr, next_line, shiftwidth)
  end

  -- start from the next line if its indent level its higher
  if scope_next_indent_level > scope_indent_level then return cursor_line + 1, scope_next_indent_level end
  return cursor_line, scope_indent_level
end

--- @param bufnr integer
--- @param cursor_line integer
--- @param shiftwidth integer
--- @return integer indent_level Indent level at the cursor, rounded up
--- @return boolean covers_all_whitespace Whether the cursor is on or past the first non-whitespace character
function M.get_cursor_indent_level(bufnr, cursor_line, shiftwidth)
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local line = utils.get_line(bufnr, cursor_line)

  local whitespace_chars = line:match('^%s*')
  local covers_all_whitespace = #whitespace_chars <= cursor_col - 1

  whitespace_chars = whitespace_chars:sub(1, cursor_col)
  local whitespace_char_count = whitespace_chars:find('\t') ~= nil
      and whitespace_chars:gsub('\t', (' '):rep(shiftwidth)):len()
    or whitespace_chars:len()

  local indent_level = math.ceil(whitespace_char_count / shiftwidth)
  return math.ceil(indent_level), covers_all_whitespace
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
