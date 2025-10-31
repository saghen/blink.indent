# Blink Indent (blink.indent)

**blink.indent** provides indent guides with scope on every keystroke (0.1-2ms per render), including on massive files, without Treesitter. These indent guides work in the vast majority of valid code and compute quicker than via Treesitter. If you want something more feature rich, consider using [indent-blankline](https://github.com/lukas-reineke/indent-blankline.nvim) instead.

Disable with `vim.g.indent_guide = false` (global) or `vim.b[bufnr].indent_guide = false` (per-buffer). Some filetypes and buftypes are disabled by default, see the bottom of `plugin/blink-indent.lua`. You may also create a keymap to toggle visibility like so:

```lua
local indent = require('blink.indent')
vim.keymap.set('n', 'some-key', function() indent.enable(not indent.is_enabled()) end, { desc = 'Toggle indent guides' })
```

or toggle on a per-buffer basis with `indent.enable(not indent.is_enabled({ bufnr = 0 }), { bufnr = 0 })`.

## Install

`lazy.nvim`

```lua
{
  'saghen/blink.indent',
  --- @module 'blink.indent'
  --- @type blink.indent.Config
  opts = {
    static = {
      enabled = true,
      char = '▎',
      priority = 1,
      -- specify multiple highlights here for rainbow-style indent guides
      -- highlights = { 'BlinkIndentRed', 'BlinkIndentOrange', 'BlinkIndentYellow', 'BlinkIndentGreen', 'BlinkIndentViolet', 'BlinkIndentCyan' },
      highlights = { 'BlinkIndent' },
    },
    scope = {
      enabled = true,
      char = '▎',
      priority = 1024,
      -- set this to a single highlight, such as 'BlinkIndent' to disable rainbow-style indent guides
      -- highlights = { 'BlinkIndent' },
      highlights = {
        'BlinkIndentOrange',
        'BlinkIndentViolet',
        'BlinkIndentBlue',
        -- 'BlinkIndentRed',
        -- 'BlinkIndentCyan',
        -- 'BlinkIndentYellow',
        -- 'BlinkIndentGreen',
      },
      underline = {
        -- enable to show underlines on the line above the current scope
        enabled = false,
        highlights = {
          'BlinkIndentOrangeUnderline',
          'BlinkIndentVioletUnderline',
          'BlinkIndentBlueUnderline',
          -- 'BlinkIndentRedUnderline',
          -- 'BlinkIndentCyanUnderline',
          -- 'BlinkIndentYellowUnderline',
          -- 'BlinkIndentGreenUnderline',
        },
      },
    },
  },
}
```

`vim.pack`

```lua
vim.pack.add({ 'saghen/blink.indent' })
-- plugin initializes automatically, optionally configure
require('blink.indent').setup({})
```
