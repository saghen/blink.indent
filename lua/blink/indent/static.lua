local M = {}

local config = require('blink.indent.config')
local utils = require('blink.indent.utils')

local cache = {}
vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
  group = vim.api.nvim_create_augroup('blink.indent.static', { clear = false }),
  callback = function(args) cache[args.buf] = nil end,
})

M.partial_draw = function(ns, indent_levels, bufnr, range)
  --- don't redraw if nothing changed
  local cache_entry = cache[bufnr]
  if
    cache_entry ~= nil
    and cache_entry.indent_levels == indent_levels
    and cache_entry.changedtick == vim.b[bufnr].changedtick
    and cache_entry.range.start_line == range.start_line
    and cache_entry.range.end_line == range.end_line
  then
    return
  end
  cache[bufnr] = {
    indent_levels = indent_levels,
    changedtick = vim.b[bufnr].changedtick,
    range = range,
  }

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local shiftwidth = utils.get_shiftwidth(bufnr)
  local symbol = config.static.char .. string.rep(' ', shiftwidth - 1)

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
    if indent_level > 0 then
      local virt_text = string.rep(symbol, indent_level)

      local success, symbol_offset_index = pcall(vim.str_byteindex, symbol, 'utf-8', range.horizontal_offset)
      if not success then goto continue end
      virt_text = virt_text:sub(symbol_offset_index + 1)
      local hl_group = utils.get_rainbow_hl(indent_level, config.static.highlights)
      vim.api.nvim_buf_set_extmark(bufnr, ns, line_number - 1, 0, {
        virt_text = { { virt_text, hl_group } },
        virt_text_pos = 'overlay',
        hl_mode = 'combine',
        priority = config.static.priority,
      })
    end

    ::continue::
  end
end

return M
