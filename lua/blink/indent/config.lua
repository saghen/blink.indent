--- @class blink.indent.BlockedConfig
--- @field buftypes string[]
--- @field filetypes string[]

--- @class (exact) blink.indent.BlockedConfigPartial : blink.indent.BlockedConfig, {}

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
--- @field blocked blink.indent.BlockedConfig
--- @field static blink.indent.StaticConfig
--- @field scope blink.indent.ScopeConfig

--- @class (exact) blink.indent.Config : blink.indent.ConfigStrict, {}
--- @field blocked blink.indent.BlockedConfigPartial
--- @field static blink.indent.StaticConfigPartial
--- @field scope blink.indent.ScopeConfigPartial

local config = {
  --- @type blink.indent.ConfigStrict
  default = {
    blocked = {
      buftypes = { 'terminal', 'quickfix', 'nofile', 'prompt' },
      filetypes = {
        'lspinfo',
        'packer',
        'checkhealth',
        'help',
        'man',
        'gitcommit',
        'TelescopePrompt',
        'TelescopeResults',
        'dashboard',
        '',
      },
    },
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
        'BlinkIndentRed',
        'BlinkIndentYellow',
        'BlinkIndentBlue',
        'BlinkIndentOrange',
        'BlinkIndentGreen',
        'BlinkIndentViolet',
        'BlinkIndentCyan',
      },
      underline = {
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

--- @param opts blink.indent.Config
function config.setup(opts) config = vim.tbl_deep_extend('force', config.default, opts or {}) end

return setmetatable(config, { __index = function(_, k) return config[k] end })
