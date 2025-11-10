local M = {}

local config = require('blink.indent.config')
local utils = require('blink.indent.utils')

--- @param ns integer
--- @param indent_levels table<integer, integer>
--- @param bufnr integer
--- @param range { start_line: integer, end_line: integer, horizontal_offset: integer }
M.draw = function(ns, indent_levels, bufnr, range)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local shiftwidth = utils.get_shiftwidth(bufnr)
  local space = vim.opt.listchars:get().space or ' '
  local symbol = config.static.char .. space:rep(shiftwidth - 1)

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
    if indent_level * shiftwidth > range.horizontal_offset then
      local virt_text = symbol:rep(indent_level)

      if range.horizontal_offset > 0 then
        local symbol_offset_index = vim.str_byteindex(virt_text, 'utf-32', range.horizontal_offset)
        virt_text = virt_text:sub(symbol_offset_index + 1)
      end

      local hl_group = utils.get_rainbow_hl(indent_level, config.static.highlights)
      vim.api.nvim_buf_set_extmark(bufnr, ns, line_number - 1, 0, {
        virt_text = { { virt_text, hl_group } },
        virt_text_pos = 'overlay',
        hl_mode = 'combine',
        priority = config.static.priority,
      })
    end
  end
end

return M
