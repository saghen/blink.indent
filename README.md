# Blink Indent (blink.indent)

**blink.indent** provides indent guides with scope on every keystroke (0.1-2ms per render), including on massive files, without Treesitter. These indent guides work in the vast majority of valid code and compute quicker than via Treesitter. If you want something more feature rich, consider using [indent-blankline](https://github.com/lukas-reineke/indent-blankline.nvim) instead.

## Install

`lazy.nvim`

```lua
{
  'saghen/blink.indent',
  opts = {
    -- or disable with `vim.g.indent_guide = false` (global) or `vim.b.indent_guide = false` (per-buffer)
    blocked = {
      buftypes = {},
      filetypes = {},
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
      priority = 1024,
      -- set this to a single highlight, such as 'BlinkIndent' to disable rainbow-style indent guides
      -- highlights = { 'BlinkIndent' },
      highlights = {
        'BlinkIndentRed',
        'BlinkIndentYellow',
        'BlinkIndentBlue',
        'BlinkIndentOrange',
        'BlinkIndentGreen',
        'BlinkIndentViolet',
        'BlinkIndentCyan',
      },
      underline = {
        -- enable to show underlines on the line above the current scope
        enabled = false,
        highlights = {
          'BlinkIndentRedUnderline',
          'BlinkIndentYellowUnderline',
          'BlinkIndentBlueUnderline',
          'BlinkIndentOrangeUnderline',
          'BlinkIndentGreenUnderline',
          'BlinkIndentVioletUnderline',
          'BlinkIndentCyanUnderline',
        },
      },
    },
  },
}
