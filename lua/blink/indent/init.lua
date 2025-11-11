-- Adds virtual text to the left of the line to show the indent level
-- Somewhat equivalent to indent-blankline but fast

local config = require('blink.indent.config')
local motion = require('blink.indent.motion')
local parser = require('blink.indent.parser')
local static = require('blink.indent.static')
local scope = require('blink.indent.scope')
local utils = require('blink.indent.utils')

--- @class blink.indent.Filter
--- @field bufnr? integer

local M = {}

--- @param opts blink.indent.Config
M.setup = function(opts)
  config.setup(opts)
  motion.register()
  M.draw_all()
end

--- Enables or disables visibility of indent guides
--- @param enable boolean?
--- @param filter blink.indent.Filter?
M.enable = function(enable, filter)
  if enable == nil then enable = true end

  if filter ~= nil and filter.bufnr ~= nil then
    if filter.bufnr == 0 then filter.bufnr = vim.api.nvim_get_current_buf() end
    vim.b[filter.bufnr].indent_guide = enable
  else
    vim.g.indent_guide = enable
  end

  M.draw_all()
end

--- Draws indent guides for all visible windows
--- @param force boolean? Ignores cache and always redraws
M.draw_all = function(force)
  for _, winnr in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    M.draw(winnr, bufnr, force)
  end
end

--- Draws indent guides for the given window
--- @param winnr integer
--- @param bufnr integer
--- @param force boolean? Ignores cache and always redraws
M.draw = function(winnr, bufnr, force)
  if not M.is_enabled({ bufnr = bufnr }) or (not config.static.enabled and not config.scope.enabled) then
    vim.api.nvim_buf_clear_namespace(bufnr, config.static.ns, 0, -1)
    vim.api.nvim_buf_clear_namespace(bufnr, config.scope.ns, 0, -1)
    return
  end

  local range = utils.get_win_scroll_range(winnr, bufnr)
  local indent_levels, is_all_whitespace, scope_range, is_cached =
    parser.get_indent_levels(winnr, bufnr, range.start_line, range.end_line, range.horizontal_offset)

  if config.static.enabled and (not is_cached or force) then
    static.draw(config.static.ns, indent_levels, is_all_whitespace, bufnr, range)
  elseif not config.static.enabled then
    vim.api.nvim_buf_clear_namespace(range.bufnr, config.static.ns, 0, -1)
  end

  if config.scope.enabled and (not is_cached or force) then
    scope.draw(config.scope.ns, indent_levels, bufnr, scope_range, range)
  elseif not config.scope.enabled then
    vim.api.nvim_buf_clear_namespace(bufnr, config.scope.ns, 0, -1)
  end
end

local default_blocked_filetypes = { 'lspinfo', 'packer', 'checkhealth', 'help', 'man', 'gitcommit', 'dashboard', '' }
local default_blocked_buftypes = { 'terminal', 'quickfix', 'nofile', 'prompt' }

--- @param filter blink.indent.Filter?
M.is_enabled = function(filter)
  if filter ~= nil and filter.bufnr ~= nil then
    local bufnr = filter.bufnr == 0 and vim.api.nvim_get_current_buf() or filter.bufnr

    if vim.b[bufnr].indent_guide ~= nil then return vim.b[bufnr].indent_guide == true end

    local blocked = config.blocked
    if
      (blocked.buftypes.include_defaults and vim.tbl_contains(default_blocked_buftypes, vim.bo[bufnr].buftype))
      or (#blocked.buftypes > 0 and vim.tbl_contains(blocked.buftypes, vim.bo[bufnr].buftype))
      or (blocked.filetypes.include_defaults and vim.tbl_contains(default_blocked_filetypes, vim.bo[bufnr].filetype))
      or (#blocked.filetypes > 0 and vim.tbl_contains(blocked.filetypes, vim.bo[bufnr].filetype))
    then
      return false
    end
  end

  return vim.g.indent_guide ~= false
end

return M
