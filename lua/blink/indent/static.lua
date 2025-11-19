local M = {}

local config = require('blink.indent.config')
local utils = require('blink.indent.utils')

--- @type table<integer, { indent_levels: table<integer, integer>, extmark_ids: table<integer, integer>, horizontal_offset: integer }>
M.cache = utils.make_buffer_cache()

--- @param winnr integer
--- @param bufnr integer
--- @param ns integer
--- @param indent_levels table<integer, integer>
--- @param range { start_line: integer, end_line: integer, horizontal_offset: integer }
function M.draw(winnr, bufnr, ns, indent_levels, range)
  -- cache the indent levels to avoid unnecessary extmark draws
  if not M.cache[bufnr] or M.cache[bufnr].horizontal_offset ~= range.horizontal_offset then
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    M.cache[bufnr] = { indent_levels = {}, extmark_ids = {}, horizontal_offset = range.horizontal_offset }
  else
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, range.start_line - 1)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, range.end_line, -1)
  end
  local cache_entry = M.cache[bufnr]

  local breakindent = utils.get_breakindent(winnr)
  local shiftwidth = utils.get_shiftwidth(bufnr)
  local space = config.static.whitespace_char or vim.opt.listchars:get().space or ' '
  local symbol = config.static.char .. space:rep(shiftwidth - 1)

  -- cache the virt text to avoid unnecessary string.rep calls
  local virt_text_cache = {}

  -- draw
  for line_number = range.start_line, range.end_line do
    local indent_level = indent_levels[line_number]
    if
      cache_entry.indent_levels[line_number] ~= indent_level
      and indent_level * shiftwidth > range.horizontal_offset
    then
      local virt_text = virt_text_cache[indent_level] or symbol:rep(indent_level)
      if virt_text_cache[indent_level] == nil then virt_text_cache[indent_level] = virt_text end

      if range.horizontal_offset > 0 then
        local symbol_offset_index = vim.str_byteindex(virt_text, 'utf-32', range.horizontal_offset)
        virt_text = virt_text:sub(symbol_offset_index + 1)
      end

      local hl_group = utils.get_rainbow_hl(indent_level, config.static.highlights)
      cache_entry.extmark_ids[line_number] = vim.api.nvim_buf_set_extmark(bufnr, ns, line_number - 1, 0, {
        id = cache_entry.extmark_ids[line_number],
        virt_text = { { virt_text, hl_group } },
        virt_text_pos = 'overlay',
        virt_text_repeat_linebreak = breakindent,
        hl_mode = 'combine',
        priority = config.static.priority,
      })
    end
  end

  cache_entry.indent_levels = indent_levels
end

return M
