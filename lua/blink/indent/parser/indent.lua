--- @class blink.indent.CacheEntry
--- @field indent_levels table<integer, integer>
--- @field whitespace_lens table<integer, integer>
--- @field start_line integer
--- @field end_line integer
--- @field horizontal_offset integer

--- @class blink.indent.ParseRange
--- @field start_line integer
--- @field end_line integer
--- @field horizontal_offset integer

local config = require('blink.indent.config')
local utils = require('blink.indent.utils')

local M = {}

-- stylua: ignore
local default_dedent_scoped_filetypes = {
  automake = true, bzl = true, cabal = true, cabalconfig = true, cabalproject = true, chaskell = true, clean = true,
  earthfile = true, elm = true, fsharp = true, gdscript = true, haml = true, haskell = true, haskellpersistent = true,
  idris2 = true, just = true, kivy = true, lean = true, lhaskell = true, lidris2 = true, make = true,
  moonscript = true, nim = true, ninja = true, pug = true, purescript = true, pyrex = true, python = true,
  raml = true, roc = true, sage = true, salt = true, sass = true, snakemake = true, starlark = true, stylus = true,
  yaml = true
}

--- @type table<integer, blink.indent.CacheEntry>
M.cache = utils.make_buffer_cache()

--- @param bufnr integer
--- @return boolean
function M.is_dedent_scoped(bufnr)
  local filetype = vim.bo[bufnr].filetype
  local filetypes = config.dedent_scoped_filetypes
  if filetypes == true then return true end

  --- @cast filetypes blink.indent.FiletypeListWithDefaults
  if filetypes[filetype] ~= nil then return filetypes[filetype] == true end

  return (filetypes.include_defaults ~= false and default_dedent_scoped_filetypes[filetype] == true)
    or vim.tbl_contains(filetypes, filetype)
end

--- @param bufnr integer
--- @param range blink.indent.ParseRange
--- @return table<integer, integer> indent_levels
--- @return table<integer, integer> whitespace_lens
--- @return boolean is_cached
function M.get_indent_levels(bufnr, range)
  local cache_entry = M.cache[bufnr]
  local shiftwidth = utils.get_shiftwidth(bufnr)
  if cache_entry ~= nil and cache_entry.start_line == range.start_line and cache_entry.end_line == range.end_line then
    return cache_entry.indent_levels,
      cache_entry.whitespace_lens,
      cache_entry.horizontal_offset == range.horizontal_offset
  end

  local dedent_scoped = M.is_dedent_scoped(bufnr)
  local indent_levels, whitespace_lens = M._get_indent_levels(bufnr, range, shiftwidth, dedent_scoped)
  M.cache[bufnr] = {
    indent_levels = indent_levels,
    whitespace_lens = whitespace_lens,
    start_line = range.start_line,
    end_line = range.end_line,
    horizontal_offset = range.horizontal_offset,
  }

  return indent_levels, whitespace_lens, false
end

--- @private
--- @param bufnr integer
--- @param range blink.indent.ParseRange
--- @param shiftwidth integer
--- @param dedent_scoped boolean
--- @return table<integer, integer> indent_levels
--- @return table<integer, integer> whitespace_lens
function M._get_indent_levels(bufnr, range, shiftwidth, dedent_scoped)
  local indent_levels = {}
  local whitespace_lens = {}

  local lines = vim.api.nvim_buf_get_lines(bufnr, range.start_line - 1, range.end_line, false)
  local whitespace_lines_before = 0
  local prev_indent_level = 0
  for line = range.start_line, range.end_line do
    local indent_level, is_all_whitespace, whitespace_len =
      M.get_indent_level(lines[line - range.start_line + 1], shiftwidth)
    indent_levels[line] = indent_level
    whitespace_lens[line] = whitespace_len

    if is_all_whitespace then
      whitespace_lines_before = whitespace_lines_before + 1
    else
      local whitespace_indent_level = dedent_scoped and indent_level or math.max(indent_level, prev_indent_level)
      for whitespace_line = line - whitespace_lines_before, line - 1 do
        indent_levels[whitespace_line] = whitespace_indent_level
      end
      whitespace_lines_before = 0
      prev_indent_level = indent_level
    end
  end

  return indent_levels, whitespace_lens
end

--- @param line string
--- @param shiftwidth integer
--- @return integer indent_level
--- @return boolean is_all_whitespace
--- @return integer whitespace_len
function M.get_indent_level(line, shiftwidth)
  local whitespace_chars = line:match('^%s*')
  --- @cast whitespace_chars string
  local whitespace_char_count = whitespace_chars:find('\t') ~= nil
      and whitespace_chars:gsub('\t', (' '):rep(shiftwidth)):len()
    or whitespace_chars:len()

  return math.floor(whitespace_char_count / shiftwidth), #whitespace_chars == #line, #whitespace_chars
end

--- Get the top and bottom line of the viewport
--- @param winnr integer
--- @param bufnr integer
--- @return blink.indent.ParseRange
function M.get_parse_range(winnr, bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  return {
    start_line = math.max(1, vim.fn.line('w0', winnr) - 1),
    end_line = math.min(line_count, vim.fn.line('w$', winnr) + 1),
    horizontal_offset = vim.api.nvim_win_call(winnr, function() return vim.fn.winsaveview().leftcol end),
  }
end

return M
