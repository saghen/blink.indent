local M = {}

local config = require('blink.indent.config')
local utils = require('blink.indent.utils')

--- @param ns integer
--- @param bufnr integer
--- @param range { start_line: integer, end_line: integer, horizontal_offset: integer }
--- @param indent_level integer
--- @param line_number integer
local function set_extmark(ns, bufnr, range, indent_level, line_number)
  local shiftwidth = utils.get_shiftwidth(bufnr)
  local space = vim.opt.listchars:get().space or ' '
  local symbol = config.static.char .. space:rep(shiftwidth - 1)
  local virt_text = symbol:rep(indent_level)
  if range.horizontal_offset > 0 then
    local success, symbol_offset_index = pcall(vim.str_byteindex, symbol, 'utf-32', range.horizontal_offset)

    if not success then return end

    virt_text = virt_text:sub(symbol_offset_index + 1)
  end

  vim.api.nvim_buf_set_extmark(bufnr, ns, line_number - 1, 0, {
    virt_text = { { virt_text, utils.get_rainbow_hl(indent_level, config.static.highlights) } },
    virt_text_pos = 'overlay',
    hl_mode = 'combine',
    priority = config.static.priority,
  })
end

--- @param ns integer
--- @param indent_levels table<integer, integer>
--- @param bufnr integer
--- @param range { start_line: integer, end_line: integer, horizontal_offset: integer }
function M.draw(ns, indent_levels, bufnr, range)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  -- add the new indents
  local lines = vim.api.nvim_buf_get_lines(bufnr, range.start_line - 1, range.end_line, false)
  local previous_indent_level = indent_levels[range.start_line]
  for line_number = range.start_line, range.end_line do
    local line = lines[line_number - range.start_line + 1]
    local whitespace_chars = line:match('^%s*')

    local is_all_whitespace = #whitespace_chars == #line
    local current_indent_level = indent_levels[line_number]
    local indent_level = (is_all_whitespace and previous_indent_level ~= nil) and previous_indent_level
      or current_indent_level
    previous_indent_level = indent_level

    -- draw
    if indent_level > range.horizontal_offset then set_extmark(ns, bufnr, range, indent_level, line_number) end
  end
end

return M
