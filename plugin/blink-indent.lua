local augroup = vim.api.nvim_create_augroup('blink.indent', {})

--- highlights
local function setup_hl()
  vim.api.nvim_set_hl(0, 'BlinkIndent', { default = true, link = 'Whitespace' })
  vim.api.nvim_set_hl(0, 'BlinkIndentScope', { default = true, link = 'Delimiter' })

  vim.api.nvim_set_hl(0, 'BlinkIndentRed', { default = true, fg = '#cc241d', ctermfg = 'Red' })
  vim.api.nvim_set_hl(0, 'BlinkIndentOrange', { default = true, fg = '#d65d0e', ctermfg = 'Brown' })
  vim.api.nvim_set_hl(0, 'BlinkIndentYellow', { default = true, fg = '#d79921', ctermfg = 'Yellow' })
  vim.api.nvim_set_hl(0, 'BlinkIndentGreen', { default = true, fg = '#689d6a', ctermfg = 'Green' })
  vim.api.nvim_set_hl(0, 'BlinkIndentCyan', { default = true, fg = '#a89984', ctermfg = 'Cyan' })
  vim.api.nvim_set_hl(0, 'BlinkIndentBlue', { default = true, fg = '#458588', ctermfg = 'Blue' })
  vim.api.nvim_set_hl(0, 'BlinkIndentViolet', { default = true, fg = '#b16286', ctermfg = 'Magenta' })

  vim.api.nvim_set_hl(0, 'BlinkIndentRedUnderline', { default = true, sp = '#cc241d', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentOrangeUnderline', { default = true, sp = '#d65d0e', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentYellowUnderline', { default = true, sp = '#d79921', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentGreenUnderline', { default = true, sp = '#689d6a', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentCyanUnderline', { default = true, sp = '#a89984', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentBlueUnderline', { default = true, sp = '#458588', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentVioletUnderline', { default = true, sp = '#b16286', underline = true })
end

setup_hl()
vim.api.nvim_create_autocmd('ColorScheme', { group = augroup, callback = setup_hl })

--- highlighter
local ns = vim.api.nvim_create_namespace('blink.indent')
local indent = require('blink.indent')
vim.api.nvim_set_decoration_provider(ns, { on_win = function(_, winnr, bufnr) indent.draw(winnr, bufnr) end })
vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
  group = augroup,
  callback = function() indent.draw(vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()) end,
})
vim.api.nvim_create_autocmd('OptionSet', {
  group = augroup,
  pattern = 'listchars',
  callback = function() indent.draw_all(true) end,
})

--- motions
require('blink.indent.motion').register(true)
