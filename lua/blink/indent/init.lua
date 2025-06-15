-- Adds a virtual text to the left of the line to show the indent level
-- Somewhat equivalent to indent-blankline but fast

local M = {}

--- @param opts blink.indent.Config
M.setup = function(opts)
  local config = require('blink.indent.config')
  config.setup(opts)
  M.setup_hl_groups()

  local ns = vim.api.nvim_create_namespace('blink_indent')
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, winnr, bufnr)
      local indent = require('blink.indent.indent')
      local utils = require('blink.indent.utils')

      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      if utils.is_buf_blocked(bufnr) then return end

      local range = utils.get_win_scroll_range(winnr)
      if range.end_line == range.start_line then return end

      local indent_levels, scope_range = indent.get_indent_levels(winnr, range.bufnr, range.start_line, range.end_line)
      if config.static.enabled then
        require('blink.indent.static').partial_draw(
          ns,
          indent_levels,
          range.bufnr,
          range.start_line,
          range.end_line,
          range.horizontal_offset
        )
      end
      if config.scope.enabled then
        require('blink.indent.scope').partial_draw(
          ns,
          indent_levels,
          range.bufnr,
          scope_range[1],
          scope_range[2],
          range.start_line,
          range.end_line,
          range.horizontal_offset
        )
      end
    end,
  })
end

M.setup_hl_groups = function()
  vim.api.nvim_set_hl(0, 'BlinkIndent', { default = true, link = 'Whitespace' })

  local function set_hl(color, fg)
    vim.api.nvim_set_hl(0, 'BlinkIndent' .. color, { default = true, fg = fg, ctermfg = color:match('Indent(%w+)') })
    vim.api.nvim_set_hl(0, 'BlinkIndent' .. color .. 'Underline', { default = true, sp = fg, underline = true })
  end

  set_hl('Red', '#cc241d')
  set_hl('Orange', '#d65d0e')
  set_hl('Yellow', '#d79921')
  set_hl('Green', '#689d6a')
  set_hl('Cyan', '#a89984')
  set_hl('Blue', '#458588')
  set_hl('Violet', '#b16286')
end

--- Enables the visibility of indent guides
--- @return boolean success Returns true if state changed, false if already enabled
M.enable = function()
  if vim.g.indent_guide ~= false then
    -- Already enabled
    return false
  end

  vim.g.indent_guide = true
  return true
end

--- Disables the visibility of indent guides
--- @return boolean success Returns true if state changed, false if already disabled
M.disable = function()
  if vim.g.indent_guide == false then
    -- Already disabled
    return false
  end

  vim.g.indent_guide = false

  -- Clear indent markers from all buffers
  local ns = vim.api.nvim_create_namespace('blink_indent')
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end
  end

  return true
end

--- Toggles the visibility of indent guides
--- @return boolean new_state Returns the new visibility state
M.toggle = function()
  if vim.g.indent_guide ~= false then return M.disable() end
  return M.enable()
end

return M
