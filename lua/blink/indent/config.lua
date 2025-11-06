--- @class blink.indent.BlockedConfig
--- @field buftypes blink.indent.ListWithDefaults defaults: 'terminal', 'quickfix', 'nofile', 'prompt'
--- @field filetypes blink.indent.ListWithDefaults defaults: 'lspinfo', 'packer', 'checkhealth', 'help', 'man', 'gitcommit', 'TelescopePrompt', 'TelescopeResults', 'dashboard', ''

--- @class blink.indent.ListWithDefaults
--- @field include_defaults boolean
--- @field [number] string

--- @class (exact) blink.indent.BlockedConfigPartial : blink.indent.BlockedConfig, {}

---
--- @class blink.indent.StaticConfig
--- @field enabled boolean
--- @field ns number Namespace of the extmarks used to draw the static guides
--- @field char '┆' | '┊' | '╎' | '║' | '▏' | '▎' | string Character used to draw the scope guides
--- @field priority number
--- @field highlights string[]

--- @class (exact) blink.indent.StaticConfigPartial : blink.indent.StaticConfig, {}

--- @class blink.indent.ScopeConfig
--- @field enabled boolean Highlights highest leve of indentation on the current line
--- @field ns number Namespace of the extmarks used to draw the scope guides
--- @field char '┆' | '┊' | '╎' | '║' | '▏' | '▎' | string Character used to draw the scope guides
--- @field priority number Priority of the extmarks used to draw the scope guides
--- @field highlights string[] Highlight groups used to draw the scope guides
--- @field underline blink.indent.ScopeUnderlineConfig

--- @class (exact) blink.indent.ScopeConfigPartial : blink.indent.ScopeConfig, {}
--- @field underline blink.indent.ScopeUnderlineConfigPartial

--- @class blink.indent.ScopeUnderlineConfig
--- @field enabled boolean
--- @field highlights string[]

--- @class (exact) blink.indent.ScopeUnderlineConfigPartial : blink.indent.ScopeUnderlineConfig, {}

--- @class blink.indent.ConfigStrict
--- @field blocked blink.indent.BlockedConfig
--- @field static blink.indent.StaticConfig
--- @field scope blink.indent.ScopeConfig

--- @class (exact) blink.indent.Config : blink.indent.ConfigStrict, {}
--- @field blocked blink.indent.BlockedConfigPartial
--- @field static blink.indent.StaticConfigPartial
--- @field scope blink.indent.ScopeConfigPartial

--- @type blink.indent.ConfigStrict
local config = {
  blocked = {
    buftypes = { include_defaults = true },
    filetypes = { include_defaults = true },
  },
  static = {
    enabled = true,
    ns = vim.api.nvim_create_namespace('blink.indent.static'),
    char = '▎',
    priority = 1,
    highlights = { 'BlinkIndent' },
  },
  scope = {
    enabled = true,
    ns = vim.api.nvim_create_namespace('blink.indent.scope'),
    char = '▎',
    priority = 1024,
    highlights = { 'BlinkIndentOrange', 'BlinkIndentViolet', 'BlinkIndentBlue' },
    underline = {
      enabled = false,
      highlights = { 'BlinkIndentOrangeUnderline', 'BlinkIndentVioletUnderline', 'BlinkIndentBlueUnderline' },
    },
  },
}

--- @param opts blink.indent.Config
local function setup(opts) config = vim.tbl_deep_extend('force', config, opts or {}) end

--- @type blink.indent.ConfigStrict
local M = setmetatable({}, { __index = function(_, k) return k == 'setup' and setup or config[k] end })
return M
