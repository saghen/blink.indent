-- Based on mini.indentscope's implementation. License: MIT
-- https://github.com/nvim-mini/mini.nvim/blob/79654ef28182986dcdd9e2d3506d1728fc7c4f79/lua/mini/indentscope.lua

local config = require('blink.indent.config')
local parser = require('blink.indent.parser')

local M = {}

--- @param scope_range blink.indent.ScopeRange
--- @param side "top" | "bottom"
--- @param border? "top" | "bottom" | "both" | "none"
local function move_cursor(scope_range, side, border)
  local target_line = side == 'top' and scope_range.start_line or scope_range.end_line
  if side == 'top' and (border == 'both' or border == 'top') then
    target_line = target_line - 1
  elseif side == 'bottom' and (border == 'both' or border == 'bottom') then
    target_line = target_line + 1
  end
  target_line = math.min(math.max(target_line, 1), vim.fn.line('$'))

  vim.api.nvim_win_set_cursor(0, { target_line, 0 })
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
    if scope.indent_level == 0 then return end

    -- needs remembering `count1` before adding to jump list because it seems to reset it to 1
    local count = vim.v.count1
    if add_to_jumplist then vim.cmd('normal! m`') end

    -- Make sequence of jumps
    for _ = 1, count do
      move_cursor(scope, side)

      scope = parser.get_scope()
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

    -- Make sequence of incremental selections
    local count = vim.v.count1
    for i = 1, count do
      local border = opts.border
      if i ~= count then border = 'both' end

      -- finish cursor on border
      local start, finish = 'top', 'bottom'
      if border == 'top' then
        start, finish = 'bottom', 'top'
      end

      exit_visual_mode()
      move_cursor(scope, start, border)
      vim.cmd('normal! V')
      move_cursor(scope, finish, border)

      -- Use `try_as_border = false` to enable chaining
      scope = parser.get_scope()
      if scope.indent_level == 0 then return end
    end
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
