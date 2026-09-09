-- Based on mini.indentscope's implementation. License: MIT
-- https://github.com/nvim-mini/mini.nvim/blob/79654ef28182986dcdd9e2d3506d1728fc7c4f79/lua/mini/indentscope.lua

local config = require('blink.indent.config')
local parser = require('blink.indent.parser')

local M = {}

--- @param scope_range blink.indent.ScopeRange
--- @param side "top" | "bottom"
--- @param border? "top" | "bottom" | "both" | "none"
local function get_target_line(scope_range, side, border)
  local offset = (border == 'both' or border == side) and 1 or 0
  local target_line = side == 'top' and scope_range.start_line - offset or scope_range.end_line + offset
  return math.min(math.max(target_line, 1), vim.fn.line('$'))
end

local function move_cursor(scope_range, side, border)
  vim.api.nvim_win_set_cursor(0, { get_target_line(scope_range, side, border), 0 })
  vim.cmd('normal! ^')
end

local function exit_visual_mode()
  local ctrl_v = vim.api.nvim_replace_termcodes('<C-v>', true, true, true)
  local cur_mode = vim.fn.mode()
  if cur_mode == 'v' or cur_mode == 'V' or cur_mode == ctrl_v then vim.cmd('normal! ' .. cur_mode) end
end

--- Jump to side of scope. Respects |count| and dot-repeat (in operator-pending mode).
--- Ignored when in the root scope.
---
--- @param side string One of "top" or "bottom".
--- @param add_to_jumplist? boolean Whether to add movement to jump list.
function M.operator(side, add_to_jumplist)
  assert(vim.tbl_contains({ 'top', 'bottom' }, side), 'Invalid side: ' .. side)

  return function()
    local scope = parser.get_scope()
    if get_target_line(scope, side, 'both') == vim.api.nvim_win_get_cursor(0)[1] then
      scope = parser.get_scope(0, 0, vim.fn.line('.'))
    end
    if scope.indent_level == 0 then return end

    -- needs remembering `count1` before adding to jump list because it seems to reset it to 1
    local count = vim.v.count1
    if add_to_jumplist then vim.cmd('normal! m`') end

    -- Make sequence of jumps
    for _ = 1, count do
      move_cursor(scope, side, 'both')

      scope = parser.get_scope(0, 0, vim.fn.line('.'))
      if scope.indent_level == 0 then return end
    end
  end
end

--- Textobject of the current scope. Respects |count| and dot-repeat (in operator-pending mode).
--- Ignored when in the root scope.
---
--- @param opts? { border?: "top" | "bottom" | "both" | "none" }
function M.textobject(opts)
  opts = opts or {}

  return function()
    local scope = parser.get_scope()
    if scope.indent_level == 0 then return end

    local function parent_scope()
      local line = scope.start_line > 1 and scope.start_line - 1 or scope.end_line + 1
      if line > vim.fn.line('$') then return nil end
      local parent = parser.get_scope(0, 0, line)
      if parent.indent_level == 0 or parent.indent_level >= scope.indent_level then return nil end
      return parent
    end

    -- Repeated selections must grow beyond the existing visual range
    if vim.fn.mode() == 'V' then
      local anchor, cursor = vim.fn.line('v'), vim.fn.line('.')
      local first, last = math.min(anchor, cursor), math.max(anchor, cursor)
      while
        get_target_line(scope, 'top', opts.border) >= first and get_target_line(scope, 'bottom', opts.border) <= last
      do
        local parent = parent_scope()
        if not parent then return end
        scope = parent
      end
    end

    for _ = 2, vim.v.count1 do
      local parent = parent_scope()
      if not parent then break end
      scope = parent
    end

    exit_visual_mode()
    move_cursor(scope, 'top', opts.border)
    vim.cmd('normal! V')
    move_cursor(scope, 'bottom', opts.border)
  end
end

--- @param default? boolean Will not override existing keymaps
function M.register(default)
  local maps = config.mappings

  local function find_keymap(mode, lhs)
    local mappings = vim.api.nvim_get_keymap(mode)
    for _, mapping in ipairs(mappings) do
      if mapping.lhs == lhs then return mapping end
    end
  end

  local function map(mode, lhs, rhs, opts)
    if default and find_keymap(mode, lhs) then return end
    -- TODO: clear default keymap
    if lhs == '' then return end

    opts.silent = true
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  map('n', maps.goto_top, M.operator('top', true), { desc = 'Go to indent scope top' })
  map('n', maps.goto_bottom, M.operator('bottom', true), { desc = 'Go to indent scope bottom' })

  map('x', maps.goto_top, M.operator('top'), { desc = 'Go to indent scope top' })
  map('x', maps.goto_bottom, M.operator('bottom'), { desc = 'Go to indent scope bottom' })
  map('x', maps.object_scope, M.textobject(), { desc = 'Object scope' })
  map('x', maps.object_scope_with_border, M.textobject({ border = maps.border }), { desc = 'Object scope with border' })

  map('o', maps.goto_top, M.operator('top'), { desc = 'Go to indent scope top' })
  map('o', maps.goto_bottom, M.operator('bottom'), { desc = 'Go to indent scope bottom' })
  map('o', maps.object_scope, M.textobject(), { desc = 'Object scope' })
  map('o', maps.object_scope_with_border, M.textobject({ border = maps.border }), { desc = 'Object scope with border' })
end

return M
