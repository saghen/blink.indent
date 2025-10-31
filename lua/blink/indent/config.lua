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
local default_config = {
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

local config = default_config

--- @param opts blink.indent.Config
function config.setup(opts) config = vim.tbl_deep_extend('force', default_config, opts or {}) end

return setmetatable(config, { __index = function(_, k) return config[k] end })
