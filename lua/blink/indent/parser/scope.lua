--- @class blink.indent.ScopeRange
--- @field indent_level integer
--- @field start_line integer
--- @field end_line integer

local utils = require('blink.indent.utils')
local config = require('blink.indent.config')
local indent = require('blink.indent.parser.indent')

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
    M.get_scope_start(bufnr, winnr, cursor_line, range, utils.get_shiftwidth(bufnr))

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
--- @param line? integer Use this line's indentation without treating it as a scope border
--- @return blink.indent.ScopeRange scope_range
function M.get_scope(bufnr, winnr, line)
  if not bufnr or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if not winnr or winnr == 0 then winnr = vim.api.nvim_get_current_win() end

  local shiftwidth = utils.get_shiftwidth(bufnr)
  local cursor_line = line or vim.api.nvim_win_get_cursor(winnr)[1]
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local dedent_scoped = indent.is_dedent_scoped(bufnr)
  local start_line, scope_indent_level = M.get_scope_start(
    bufnr,
    winnr,
    cursor_line,
    { start_line = 1, end_line = line_count, horizontal_offset = 0 },
    shiftwidth,
    line == nil
  )
  if scope_indent_level == 0 then return { start_line = 1, end_line = line_count, indent_level = 0 } end

  -- move up and down to find the scope
  local scope_start_line = start_line
  while scope_start_line > 1 do
    local prev_indent_level, is_all_whitespace =
      M.get_effective_line_indent_level(bufnr, scope_start_line - 1, line_count, shiftwidth, dedent_scoped)
    if not is_all_whitespace and scope_indent_level > prev_indent_level then break end
    scope_start_line = scope_start_line - 1
  end
  local scope_end_line = start_line
  while scope_end_line < line_count do
    local next_indent_level, is_all_whitespace =
      M.get_effective_line_indent_level(bufnr, scope_end_line + 1, line_count, shiftwidth, dedent_scoped)
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
--- @param winnr integer
--- @param cursor_line integer
--- @param range blink.indent.ParseRange
--- @param shiftwidth integer
--- @param try_as_border? boolean
--- @return integer cursor_line
--- @return integer scope_indent_level
function M.get_scope_start(bufnr, winnr, cursor_line, range, shiftwidth, try_as_border)
  -- search upward for the first non all-whitespace line
  local scope_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, cursor_line, shiftwidth)
  local cursor_is_whitespace = is_all_whitespace
  while is_all_whitespace and cursor_line > range.start_line do
    cursor_line = cursor_line - 1
    scope_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, cursor_line, shiftwidth)
  end

  if try_as_border == false then return cursor_line, scope_indent_level end

  -- clamp indent level to cursor
  if config.scope.indent_at_cursor then
    local cursor_indent_level, covers_all_whitespace = M.get_cursor_indent_level(bufnr, winnr, cursor_line, shiftwidth)
    if cursor_indent_level <= scope_indent_level and not covers_all_whitespace then
      return cursor_line, math.ceil(cursor_indent_level)
    end
  end

  -- start from next or previous line line if indent level is higher
  for _, step in ipairs({ 1, -1 }) do
    -- ignore previous line if the current line is all whitespace
    if step == -1 and (cursor_is_whitespace or indent.is_dedent_scoped(bufnr)) then break end

    local last_line = step == 1 and range.end_line or range.start_line
    for line = cursor_line + step, last_line, step do
      local level, is_whitespace = M.get_line_indent_level(bufnr, line, shiftwidth)
      if not is_whitespace then
        if level > scope_indent_level then return cursor_line + step, level end
        break
      end
    end
  end

  return cursor_line, scope_indent_level
end

--- @param bufnr integer
--- @param winnr integer
--- @param cursor_line integer
--- @param shiftwidth integer
--- @return integer indent_level Indent level at the cursor, rounded up
--- @return boolean covers_all_whitespace Whether the cursor is on or past the first non-whitespace character
function M.get_cursor_indent_level(bufnr, winnr, cursor_line, shiftwidth)
  local cursor_col = vim.api.nvim_win_get_cursor(winnr)[2] + 1
  local line = utils.get_line(bufnr, cursor_line)

  local whitespace_chars = line:match('^%s*')
  local covers_all_whitespace = #whitespace_chars <= cursor_col - 1

  whitespace_chars = whitespace_chars:sub(1, cursor_col)
  local whitespace_char_count = utils.get_whitespace_width(whitespace_chars, bufnr)

  local indent_level = math.ceil(whitespace_char_count / shiftwidth)
  return math.ceil(indent_level), covers_all_whitespace
end

--- @param bufnr integer
--- @param line_number integer
--- @param shiftwidth integer
--- @return integer indent_level
--- @return boolean is_all_whitespace
function M.get_line_indent_level(bufnr, line_number, shiftwidth)
  return indent.get_indent_level(utils.get_line(bufnr, line_number), shiftwidth, bufnr)
end

--- @param bufnr integer
--- @param line_number integer
--- @param line_count integer
--- @param shiftwidth integer
--- @param dedent_scoped boolean
--- @return integer indent_level
--- @return boolean is_all_whitespace
function M.get_effective_line_indent_level(bufnr, line_number, line_count, shiftwidth, dedent_scoped)
  local indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, line_number, shiftwidth)
  if not is_all_whitespace or not dedent_scoped then return indent_level, is_all_whitespace end

  while line_number < line_count do
    line_number = line_number + 1
    local indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, line_number, shiftwidth)
    if not is_all_whitespace then return indent_level, false end
  end
  return 0, false
end

return M
