--- @class blink.indent.StaticConfig
--- @field enabled boolean
--- @field char string
--- @field priority number
--- @field highlights string[]

--- @class (exact) blink.indent.StaticConfigPartial : blink.indent.StaticConfig, {}

--- @class blink.indent.ScopeConfig
--- @field enabled boolean
--- @field char string
--- @field priority number
--- @field highlights string[]
--- @field underline blink.indent.ScopeUnderlineConfig

--- @class (exact) blink.indent.ScopeConfigPartial : blink.indent.ScopeConfig, {}
--- @field underline blink.indent.ScopeUnderlineConfigPartial

--- @class blink.indent.ScopeUnderlineConfig
--- @field enabled boolean
--- @field highlights string[]

--- @class (exact) blink.indent.ScopeUnderlineConfigPartial : blink.indent.ScopeUnderlineConfig, {}

--- @class blink.indent.ConfigStrict
--- @field static blink.indent.StaticConfig
--- @field scope blink.indent.ScopeConfig

--- @class (exact) blink.indent.Config : blink.indent.ConfigStrict, {}
--- @field static blink.indent.StaticConfigPartial
--- @field scope blink.indent.ScopeConfigPartial

--- @type blink.indent.ConfigStrict
local config = {
  static = {
    enabled = true,
    char = '▎',
    priority = 1,
    highlights = { 'BlinkIndent' },
  },
  scope = {
    enabled = true,
    char = '▎',
    priority = 1024,
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
}

--- @param opts blink.indent.Config
local function setup(opts) config = vim.tbl_deep_extend('force', config, opts or {}) end

return setmetatable({}, { __index = function(_, k) return k == 'setup' and setup or config[k] end })
