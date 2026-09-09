local M = {}

local config = require('blink.indent.config')
local utils = require('blink.indent.utils')

--- @type table<integer, { indent_levels: table<integer, integer>, extmark_ids: table<integer, integer>, fold_headers: table<integer, boolean>, horizontal_offset: integer }>
M.cache = utils.make_buffer_cache()

local function get_virt_text(whitespace, width, shiftwidth, space, tabchars)
  local whitespace_width = not whitespace:find('\t', 1, true) and #whitespace
    or not tabchars and not whitespace:find('[^ \t]') and vim.fn.strdisplaywidth(whitespace)
  if whitespace_width and (whitespace_width == 0 or whitespace_width >= width) then
    local fill = whitespace_width == 0 and ' ' or space
    return (config.static.char .. fill:rep(shiftwidth - 1)):rep(width / shiftwidth)
  end

  local chars = {}
  for char in whitespace:gmatch('.') do
    local column = #chars
    if column >= width then break end
    local char_width = char == '\t' and vim.fn.strdisplaywidth(char, column) or 1
    for offset = 1, char_width do
      chars[column + offset] = char == '\t'
          and tabchars
          and (offset == char_width and tabchars[3] or (offset == 1 and tabchars[1] or tabchars[2]))
        or space
    end
  end
  for column = 1, width do
    chars[column] = (column - 1) % shiftwidth == 0 and config.static.char or chars[column] or ' '
  end
  return table.concat(chars, '', 1, width)
end

--- @param winnr integer
--- @param bufnr integer
--- @param ns integer
--- @param indent_levels table<integer, integer>
--- @param whitespace table<integer, string>
--- @param range { start_line: integer, end_line: integer, horizontal_offset: integer }
function M.draw(winnr, bufnr, ns, indent_levels, whitespace, range)
  -- cache the indent levels to avoid unnecessary extmark draws
  if not M.cache[bufnr] or M.cache[bufnr].horizontal_offset ~= range.horizontal_offset then
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    M.cache[bufnr] =
      { indent_levels = {}, extmark_ids = {}, fold_headers = {}, horizontal_offset = range.horizontal_offset }
  else
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, range.start_line - 1)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, range.end_line, -1)
  end
  local cache_entry = M.cache[bufnr]
  cache_entry.fold_headers = cache_entry.fold_headers or {}

  local breakindent = utils.get_breakindent(winnr)
  local foldenable = vim.wo[winnr].foldenable
  local shiftwidth = utils.get_shiftwidth(bufnr)
  local space, tabchars = config.static.whitespace_char
  if not space then
    space, tabchars = utils.get_listchars(winnr)
  end

  -- cache the virt text to avoid unnecessary string edit calls
  local virt_text_cache = {}
  local extmark_opts = {
    virt_text = { { '', '' } },
    virt_text_pos = 'overlay',
    virt_text_repeat_linebreak = breakindent,
    hl_mode = 'combine',
    priority = config.static.priority,
  }

  -- main draw loop
  -- folds are per-window, wrap so foldclosed() runs on the correct window
  vim.api.nvim_win_call(winnr, function()
    for line_number = range.start_line, range.end_line do
      local indent_level = indent_levels[line_number]
      if foldenable and vim.fn.foldclosed(line_number) == line_number then
        local extmark_id = cache_entry.extmark_ids[line_number]
        if extmark_id ~= nil then
          vim.api.nvim_buf_del_extmark(bufnr, ns, extmark_id)
          cache_entry.extmark_ids[line_number] = nil
        end
        cache_entry.fold_headers[line_number] = true
      elseif
        (cache_entry.fold_headers[line_number] or cache_entry.indent_levels[line_number] ~= indent_level)
        and indent_level * shiftwidth > range.horizontal_offset
      then
        cache_entry.fold_headers[line_number] = nil
        local whitespace_chars = space == ' ' and not tabchars and '' or whitespace[line_number]
        local key = whitespace_chars == '' and indent_level or indent_level .. ':' .. whitespace_chars
        local virt_text = virt_text_cache[key]
        if not virt_text then
          virt_text = get_virt_text(whitespace_chars, indent_level * shiftwidth, shiftwidth, space, tabchars)

          if range.horizontal_offset > 0 then
            local symbol_offset_index = vim.str_byteindex(virt_text, 'utf-32', range.horizontal_offset)
            virt_text = virt_text:sub(symbol_offset_index + 1)
          end
          virt_text_cache[key] = virt_text
        end

        local hl_group = utils.get_rainbow_hl(indent_level, config.static.highlights)
        extmark_opts.id = cache_entry.extmark_ids[line_number]
        extmark_opts.virt_text[1][1], extmark_opts.virt_text[1][2] = virt_text, hl_group
        cache_entry.extmark_ids[line_number] = vim.api.nvim_buf_set_extmark(bufnr, ns, line_number - 1, 0, extmark_opts)
      end
    end
  end)

  cache_entry.indent_levels = indent_levels
end

return M
