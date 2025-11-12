<p align="center">
  <h2 align="center">Blink Indent (blink.indent)</h2>
</p>

**blink.indent** provides indent guides with scope on every keystroke (0.1-1ms per render), including on massive files. These indent guides work in the vast majority of valid code and compute quicker (~10x) than via Treesitter. If you want something more feature rich, consider using [indent-blankline](https://github.com/lukas-reineke/indent-blankline.nvim) or [snacks.indent](https://github.com/folke/snacks.nvim/blob/main/docs/indent.md) instead.

<img width="900" src="https://github.com/user-attachments/assets/275dbac8-0f2a-4703-ac01-58152afc2c92" alt="Screenshot" />

*code from [frizbee](https://github.com/saghen/frizbee)*

## Install

```lua
-- lazy.nvim
{
  'saghen/blink.indent',
  --- @module 'blink.indent'
  --- @type blink.indent.Config
  -- opts = {},
}

-- vim.pack
vim.pack.add({ 'saghen/blink.indent' })
-- require('blink.indent').setup({})
```

## Options

Note that calling `setup()` is optional, as the plugin will automatically initialize with the default configuration.

Disable with `vim.g.indent_guide = false` (global) or `vim.b[bufnr].indent_guide = false` (per-buffer). Some filetypes and buftypes are disabled by default, see below. You may also create a keymap to toggle visibility like so:

```lua
local indent = require('blink.indent')
vim.keymap.set('n', 'some-key', function() indent.enable(not indent.is_enabled()) end, { desc = 'Toggle indent guides' })
```

or toggle on a per-buffer basis with `indent.enable(not indent.is_enabled({ bufnr = 0 }), { bufnr = 0 })`.

```lua
require('blink.indent').setup({
  blocked = {
    -- default: 'terminal', 'quickfix', 'nofile', 'prompt'
    buftypes = { include_defaults = true },
    -- default: 'lspinfo', 'packer', 'checkhealth', 'help', 'man', 'gitcommit', 'dashboard', ''
    filetypes = { include_defaults = true },
  },
  mappings = {
    -- which lines around the scope are included for 'ai': 'top', 'bottom', 'both', or 'none'
    border = 'both',
    -- set to '' to disable
    -- textobjects (e.g. `y2ii` to yank current and outer scope)
    object_scope = 'ii',
    object_scope_with_border = 'ai',
    -- motions
    goto_top = '[i',
    goto_bottom = ']i',
  },
  static = {
    enabled = true,
    char = '▎',
    whitespace_char = nil, -- inherits from `vim.opt.listchars:get().space` when `nil` (see `:h listchars`)
    priority = 1,
    -- specify multiple highlights here for rainbow-style indent guides
    -- highlights = { 'BlinkIndentRed', 'BlinkIndentOrange', 'BlinkIndentYellow', 'BlinkIndentGreen', 'BlinkIndentViolet', 'BlinkIndentCyan' },
    highlights = { 'BlinkIndent' },
  },
  scope = {
    enabled = true,
    char = '▎',
    priority = 1000,
    -- set this to a single highlight, such as 'BlinkIndent' to disable rainbow-style indent guides
    -- highlights = { 'BlinkIndentScope' },
    -- optionally add: 'BlinkIndentRed', 'BlinkIndentCyan', 'BlinkIndentYellow', 'BlinkIndentGreen'
    highlights = { 'BlinkIndentOrange', 'BlinkIndentViolet', 'BlinkIndentBlue' },
    -- enable to show underlines on the line above the current scope
    underline = {
      enabled = false,
      -- optionally add: 'BlinkIndentRedUnderline', 'BlinkIndentCyanUnderline', 'BlinkIndentYellowUnderline', 'BlinkIndentGreenUnderline'
      highlights = { 'BlinkIndentOrangeUnderline', 'BlinkIndentVioletUnderline', 'BlinkIndentBlueUnderline' },
    },
  },
})
```

## Performance

To compare the performance to [indent-blankline](https://github.com/lukas-reineke/indent-blankline.nvim), I monkey patched the draw/refresh code of both projects, enabling each separately to compare. On my machine, blink.indent took ~0.15ms per render while indent-blankline took ~2-5ms.

```lua
local refresh = require('ibl').refresh
require('ibl').refresh = function(...)
  local start_time = vim.loop.hrtime()
  refresh(...)
  local end_time = vim.loop.hrtime()
  print(string.format('indent-blankline.nvim: %.2fms', (end_time - start_time) / 1e6))
end

local draw = require('blink.indent').draw
require('blink.indent').draw = function(...)
  local start_time = vim.loop.hrtime()
  draw(...)
  local end_time = vim.loop.hrtime()
  print(string.format('blink.indent: %.2fms', (end_time - start_time) / 1e6))
end
```
