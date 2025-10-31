-- Adds a virtual text to the left of the line to show the indent level
-- Somewhat equivalent to indent-blankline but fast

--- @class blink.indent.Filter
--- @field bufnr? number

local M = {}

--- @param opts blink.indent.Config
M.setup = function(opts)
  require('blink.indent.config').setup(opts)
  vim.api.nvim__redraw({ flush = true })
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

  vim.api.nvim__redraw({ valid = false })
end

--- @param filter blink.indent.Filter?
M.is_enabled = function(filter)
  if filter ~= nil and filter.bufnr ~= nil and vim.b[filter.bufnr].indent_guide ~= nil then
    if filter.bufnr == 0 then filter.bufnr = vim.api.nvim_get_current_buf() end
    return vim.b[filter.bufnr].indent_guide == true
  else
    return vim.g.indent_guide ~= false
  end
end

return M
