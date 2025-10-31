local M = {}

local config = require('blink.indent.config')
local utils = require('blink.indent.utils')

M.partial_draw = function(ns, indent_levels, bufnr, scope_range, range)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local previous_indent_level = indent_levels[math.max(1, scope_range.start_line - 1)]
  local indent_level = indent_levels[scope_range.start_line]

  -- nothing to do
  if indent_level == 0 then return end

  local shiftwidth = utils.get_shiftwidth(bufnr)
  local symbol = config.scope.char

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local starting_from_next_line = cursor_line + 1 == scope_range.start_line

  -- highlight the line above the first line if it has a lower indent level
  -- and we didn't start from that line
  if scope_range.start_line > 1 and not starting_from_next_line then
    -- underline highlighting
    if previous_indent_level < indent_level and config.scope.underline.enabled then
      local line = vim.api.nvim_buf_get_lines(bufnr, scope_range.start_line - 2, scope_range.start_line - 1, false)[1]
      local whitespace_chars = line:match('^%s*')
      vim.hl.range(
        bufnr,
        ns,
        utils.get_rainbow_hl(previous_indent_level, config.scope.underline.highlights),
        { scope_range.start_line - 2, #whitespace_chars },
        { scope_range.start_line - 2, -1 }
      )
    end

    indent_level = previous_indent_level
  elseif starting_from_next_line then
    indent_level = previous_indent_level
  end

  if range.horizontal_offset > shiftwidth * indent_level then return end

  -- apply the highlight
  local hl_group = utils.get_rainbow_hl(indent_level, config.scope.highlights)
  for i = math.max(range.start_line, scope_range.start_line), math.min(range.end_line, scope_range.end_line) do
    vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
      virt_text = { { symbol, hl_group } },
      virt_text_pos = 'overlay',
      virt_text_win_col = indent_level * shiftwidth - range.horizontal_offset,
      hl_mode = 'combine',
      priority = config.scope.priority,
    })
  end
end

return M
