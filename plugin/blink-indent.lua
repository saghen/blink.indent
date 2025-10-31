local augroup = vim.api.nvim_create_augroup('blink.indent', { clear = true })

--- highlights

local function setup_hl()
  vim.api.nvim_set_hl(0, 'BlinkIndent', { default = true, link = 'Whitespace' })

  vim.api.nvim_set_hl(0, 'BlinkIndentRed', { default = true, fg = '#cc241d', ctermfg = 'Red' })
  vim.api.nvim_set_hl(0, 'BlinkIndentOrange', { default = true, fg = '#d65d0e', ctermfg = 'Brown' })
  vim.api.nvim_set_hl(0, 'BlinkIndentYellow', { default = true, fg = '#d79921', ctermfg = 'Yellow' })
  vim.api.nvim_set_hl(0, 'BlinkIndentGreen', { default = true, fg = '#689d6a', ctermfg = 'Green' })
  vim.api.nvim_set_hl(0, 'BlinkIndentCyan', { default = true, fg = '#a89984', ctermfg = 'Cyan' })
  vim.api.nvim_set_hl(0, 'BlinkIndentBlue', { default = true, fg = '#458588', ctermfg = 'Blue' })
  vim.api.nvim_set_hl(0, 'BlinkIndentViolet', { default = true, fg = '#b16286', ctermfg = 'Magenta' })

  vim.api.nvim_set_hl(0, 'BlinkIndentRed', { default = true, sp = '#cc241d', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentOrange', { default = true, sp = '#d65d0e', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentYellow', { default = true, sp = '#d79921', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentGreen', { default = true, sp = '#689d6a', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentCyan', { default = true, sp = '#a89984', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentBlue', { default = true, sp = '#458588', underline = true })
  vim.api.nvim_set_hl(0, 'BlinkIndentViolet', { default = true, sp = '#b16286', underline = true })
end

setup_hl()
vim.api.nvim_create_autocmd('ColorScheme', { group = augroup, callback = setup_hl })

--- highlighter

local ns = vim.api.nvim_create_namespace('blink.indent')
vim.api.nvim_set_decoration_provider(ns, {
  on_win = function(_, winnr, bufnr)
    local config = require('blink.indent.config')
    local indent = require('blink.indent.indent')
    local utils = require('blink.indent.utils')

    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    if not require('blink.indent').is_enabled({ bufnr = bufnr }) then return end

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

--- per-buffer filetype/buftype disabling

local blocked_buftypes = { 'terminal', 'quickfix', 'nofile', 'prompt' }
-- stylua: ignore
local blocked_filetypes = { 'lspinfo', 'packer', 'checkhealth', 'help', 'man', 'gitcommit', 'TelescopePrompt', 'TelescopeResults', 'dashboard', '' }

local function set_buf_enabled(args)
  if
    vim.b[args.buf].indent_guide ~= false
    and (
      vim.tbl_contains(blocked_buftypes, vim.bo[args.buf].buftype)
      or vim.tbl_contains(blocked_filetypes, vim.bo[args.buf].filetype)
    )
  then
    vim.b[args.buf].indent_guide = 'blocked'
  elseif vim.b[args.buf].indent_guide == 'blocked' then
    vim.b[args.buf].indent_guide = nil
  end
end

vim.api.nvim_create_autocmd('FileType', { group = augroup, callback = set_buf_enabled })
vim.api.nvim_create_autocmd('OptionSet', { group = augroup, pattern = 'buftype', callback = set_buf_enabled })

