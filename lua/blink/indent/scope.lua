local M = {}

local config = require('blink.indent.config')
local utils = require('blink.indent.utils')

M.cache = utils.make_buffer_cache()

--- @param bufnr integer
--- @param ns integer
--- @param indent_levels table<integer, integer>
--- @param scope_range blink.indent.ScopeRange
--- @param range blink.indent.ParseRange
function M.draw(bufnr, ns, indent_levels, scope_range, range)
  local cache_entry = M.cache[bufnr]
  if
    cache_entry ~= nil
    and cache_entry.start_line == scope_range.start_line
    and cache_entry.end_line == scope_range.end_line
    and cache_entry.indent_level == scope_range.indent_level
    and range.horizontal_offset == cache_entry.horizontal_offset
  then
    return
  end
  M.cache[bufnr] = {
    start_line = scope_range.start_line,
    end_line = scope_range.end_line,
    indent_level = scope_range.indent_level,
    horizontal_offset = range.horizontal_offset,
  }

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local indent_level = scope_range.indent_level
  if indent_level == 0 then return end

  local win_col = (indent_level - 1) * utils.get_shiftwidth(bufnr) - range.horizontal_offset
  if win_col < 0 then return end

  local symbol = config.scope.char
  local hl_group = utils.get_rainbow_hl(indent_level - 1, config.scope.highlights)

  for i = scope_range.start_line, scope_range.end_line do
    vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
      virt_text = { { symbol, hl_group } },
      virt_text_pos = 'overlay',
      virt_text_win_col = win_col,
      hl_mode = 'combine',
      priority = config.scope.priority,
    })
  end

  if config.scope.underline.enabled then M.draw_underline(bufnr, ns, indent_levels, scope_range) end
end

return M
