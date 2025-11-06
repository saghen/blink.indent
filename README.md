<p align="center">
  <h2 align="center">Blink Indent (blink.indent)</h2>
</p>

**blink.indent** provides indent guides with scope on every keystroke (0.1-2ms per render), including on massive files, without Treesitter in ~500 LoC. These indent guides work in the vast majority of valid code and compute quicker than via Treesitter. If you want something more feature rich, consider using [indent-blankline](https://github.com/lukas-reineke/indent-blankline.nvim) instead.

<img width="900" src="https://github.com/user-attachments/assets/275dbac8-0f2a-4703-ac01-58152afc2c92" alt="Screenshot" />

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
```

## Options

Note that calling `setup` is optional, as the plugin will automatically initialize with the default configuration.

Disable with `vim.g.indent_guide = false` (global) or `vim.b[bufnr].indent_guide = false` (per-buffer). Some filetypes and buftypes are disabled by default, see the bottom of `plugin/blink-indent.lua`. You may also create a keymap to toggle visibility like so:

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
    priority = 1000,
    -- set this to a single highlight, such as 'BlinkIndent' to disable rainbow-style indent guides
    -- highlights = { 'BlinkIndentScope' },
    -- optionally add: 'BlinkIndentRed', 'BlinkIndentCyan', 'BlinkIndentYellow', 'BlinkIndentGreen'
    highlights = { 'BlinkIndentOrange', 'BlinkIndentViolet', 'BlinkIndentBlue' }
    -- enable to show underlines on the line above the current scope
    underline = {
      enabled = false,
      -- optionally add: 'BlinkIndentRedUnderline', 'BlinkIndentCyanUnderline', 'BlinkIndentYellowUnderline', 'BlinkIndentGreenUnderline'
      highlights = { 'BlinkIndentOrangeUnderline', 'BlinkIndentVioletUnderline', 'BlinkIndentBlueUnderline' },
    },
  },
})
```
