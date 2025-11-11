-- Adds virtual text to the left of the line to show the indent level
-- Somewhat equivalent to indent-blankline but fast

local config = require('blink.indent.config')
local motion = require('blink.indent.motion')
local parser = require('blink.indent.parser')
local static = require('blink.indent.static')
local scope = require('blink.indent.scope')

--- @class blink.indent.Filter
--- @field bufnr? integer

local M = {}

--- @param opts blink.indent.Config
M.setup = function(opts)
  config.setup(opts)
  motion.register()
  M.draw_all(true)
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

  M.draw_all(true)
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
  if force then
    parser.cache[bufnr] = nil
    scope.cache[bufnr] = nil
    static.cache[bufnr] = nil
  end

  if not M.is_enabled({ bufnr = bufnr }) or (not config.static.enabled and not config.scope.enabled) then
    vim.api.nvim_buf_clear_namespace(bufnr, config.static.ns, 0, -1)
    vim.api.nvim_buf_clear_namespace(bufnr, config.scope.ns, 0, -1)
    return
  end

  -- parse
  local range = parser.get_parse_range(winnr, bufnr)
  local indent_levels, is_cached = parser.get_indent_levels(bufnr, range)

  -- static
  if config.static.enabled and not is_cached then
    static.draw(bufnr, config.static.ns, indent_levels, range)
  elseif not config.static.enabled then
    vim.api.nvim_buf_clear_namespace(bufnr, config.static.ns, 0, -1)
  end

  -- scope
  if config.scope.enabled then
    local scope_range = parser.get_scope_partial(bufnr, winnr, indent_levels, range)
    scope.draw(bufnr, config.scope.ns, indent_levels, scope_range, range)
  elseif not config.scope.enabled then
    vim.api.nvim_buf_clear_namespace(bufnr, config.scope.ns, 0, -1)
  end
end

return M
