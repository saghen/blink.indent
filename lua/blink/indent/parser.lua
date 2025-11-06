local utils = require('blink.indent.utils')

local M = {}

local cache = {}
vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
  group = vim.api.nvim_create_augroup('blink.indent', { clear = false }),
  callback = function(args) cache[args.buf] = nil end,
})

--- @param winnr number
--- @param bufnr number
--- @param start_line number
--- @param end_line number
--- @return table<number, number> indent_levels
--- @return { start_line: number, end_line: number } scope_range
--- @return boolean is_cached
function M.get_indent_levels(winnr, bufnr, start_line, end_line)
  local cache_entry = cache[bufnr]
  local cursor = vim.api.nvim_win_get_cursor(winnr)
  local shiftwidth = utils.get_shiftwidth(bufnr)
  if
    cache_entry ~= nil
    and cache_entry.shiftwidth == shiftwidth
    and cache_entry.changedtick == vim.b[bufnr].changedtick
    and cache_entry.start_line == start_line
    and cache_entry.end_line == end_line
    and cache_entry.cursor[1] == cursor[1]
  then
    return cache_entry.indent_levels, cache_entry.scope_range, true
  end
  local indent_levels, scope_range = M._get_indent_levels(bufnr, start_line, end_line, shiftwidth, cursor[1])
  cache[bufnr] = {
    indent_levels = indent_levels,
    shiftwidth = shiftwidth,
    changedtick = vim.b[bufnr].changedtick,
    scope_range = scope_range,
    start_line = start_line,
    end_line = end_line,
    cursor = cursor,
  }
  return indent_levels, scope_range, false
end

--- @param bufnr number
--- @param start_line number
--- @param end_line number
--- @param shiftwidth number
--- @param cursor_line number
--- @return table<number, number> indent_levels
--- @return { start_line: number, end_line: number } scope_range
function M._get_indent_levels(bufnr, start_line, end_line, shiftwidth, cursor_line)
  local indent_levels = {}

  local scope_indent_level = M.get_line_indent_level(bufnr, cursor_line, shiftwidth)
  local scope_next_line = utils.get_line(bufnr, cursor_line + 1)
  local scope_next_indent_level = scope_next_line ~= nil and M.get_indent_level(scope_next_line, shiftwidth)
    or scope_indent_level

  -- start from the next line if its indent level its higher
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

  return indent_levels, { start_line = scope_start_line, end_line = scope_end_line }
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
  local line = utils.get_line(bufnr, line_number)

  local whitespace_chars = line:match('^%s*')
  local whitespace_char_count = string.len(string.gsub(whitespace_chars, '\t', string.rep(' ', shiftwidth)))

  return math.floor(whitespace_char_count / shiftwidth), #whitespace_chars == #line
end

return M
