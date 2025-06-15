local M = {}

--- TODO: possible to cache this?
--- @param winnr number
--- @param bufnr number
--- @param start_line number
--- @param end_line number
--- @return table<number, number> indent_levels
--- @return [number, number] scope_range
function M.get_indent_levels(winnr, bufnr, start_line, end_line)
  local utils = require('blink.indent.utils')

  local indent_levels = {}
  local shiftwidth = utils.get_shiftwidth(bufnr)

  local cursor_line = vim.api.nvim_win_get_cursor(winnr)[1]

  local scope_indent_level = M.get_indent_level(utils.get_line(bufnr, cursor_line), shiftwidth)
  local scope_next_line = utils.get_line(bufnr, cursor_line + 1)
  local scope_next_indent_level = scope_next_line ~= nil and M.get_indent_level(scope_next_line, shiftwidth)
    or scope_indent_level

  -- start from the next line if it's indent level its higher
  local starting_from_next_line = scope_next_indent_level > scope_indent_level
  if starting_from_next_line then
    cursor_line = cursor_line + 1
    scope_indent_level = scope_next_indent_level
  end

  -- move up and down to find the scope
  local scope_start_line = cursor_line
  while scope_start_line > 1 do
    local prev_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, scope_start_line - 1, shiftwidth)
    indent_levels[scope_start_line - 1] = prev_indent_level

    if not is_all_whitespace and scope_indent_level > prev_indent_level then break end
    scope_start_line = scope_start_line - 1
  end
  local scope_end_line = cursor_line
  while scope_end_line < end_line do
    local next_indent_level, is_all_whitespace = M.get_line_indent_level(bufnr, scope_end_line + 1, shiftwidth)
    indent_levels[scope_end_line + 1] = next_indent_level

    if not is_all_whitespace and scope_indent_level > next_indent_level then break end
    scope_end_line = scope_end_line + 1
  end

  start_line = math.min(start_line, scope_start_line)
  end_line = math.max(end_line, scope_end_line)

  -- fill in remaining lines with their indent levels
  for line_number = start_line, end_line do
    if indent_levels[line_number] == nil then
      local indent_level = M.get_line_indent_level(bufnr, line_number, shiftwidth)
      indent_levels[line_number] = indent_level
    end
  end

  return indent_levels, { scope_start_line, scope_end_line }
end

--- @param line string
--- @param shiftwidth number
--- @return number indent_level
--- @return boolean is_all_whitespace
function M.get_indent_level(line, shiftwidth)
  local whitespace_chars = line:match('^%s*')
  local whitespace_char_count = string.len(string.gsub(whitespace_chars, '\t', string.rep(' ', shiftwidth)))

  return math.floor(whitespace_char_count / shiftwidth), #whitespace_chars == #line
end

--- @param bufnr number
--- @param line_number number
--- @param shiftwidth number
--- @return number indent_level
--- @return boolean is_all_whitespace
function M.get_line_indent_level(bufnr, line_number, shiftwidth)
  local utils = require('blink.indent.utils')
  local line = utils.get_line(bufnr, line_number)

  local whitespace_chars = line:match('^%s*')
  local whitespace_char_count = string.len(string.gsub(whitespace_chars, '\t', string.rep(' ', shiftwidth)))

  return whitespace_char_count / shiftwidth, #whitespace_chars == #line
end

return M
