--- @class blink.indent.BlockedConfig
--- @field buftypes blink.indent.ListWithDefaults defaults: 'terminal', 'quickfix', 'nofile', 'prompt'
--- @field filetypes blink.indent.ListWithDefaults defaults: 'lspinfo', 'packer', 'checkhealth', 'help', 'man', 'gitcommit', 'dashboard', ''

--- @class blink.indent.ListWithDefaults
--- @field include_defaults boolean
--- @field [number] string

--- @class blink.indent.FiletypeListWithDefaults : blink.indent.ListWithDefaults
--- @field [string] boolean? Set filetype keys to true/false to add/remove individual filetypes

--- @alias blink.indent.DedentScopedFiletypes true | blink.indent.FiletypeListWithDefaults

--- @class (exact) blink.indent.BlockedConfigPartial : blink.indent.BlockedConfig, {}

--- @class blink.indent.MappingsConfig
--- @field border 'top' | 'bottom' | 'both' | 'none' Border to include when using textobjects
--- @field object_scope 'ii' | string Textobject for scope (e.g. `y2ii` to yank current and outer scope)
--- @field object_scope_with_border 'ai' | string Textobject for scope including the line above and below (e.g. `yai` to yank current scope)
--- @field goto_top '[i' | string Jump to top of scope
--- @field goto_bottom ']i' | string Jump to bottom of scope

--- @class (exact) blink.indent.MappingsConfigPartial : blink.indent.MappingsConfig, {}

--- @class blink.indent.StaticConfig
--- @field enabled boolean
--- @field ns integer Namespace of the extmarks used to draw the static guides
--- @field char '┆' | '┊' | '╎' | '║' | '▏' | '▎' | string Character used to draw the scope guides
--- @field whitespace_char '·' | '␣' | string | nil Character used to draw the whitespace guides. When `nil` (default), inherits space/tab characters from 'listchars' when 'list' is enabled (see `:h 'listchars'`)
--- @field priority integer
--- @field highlights string[]

--- @class (exact) blink.indent.StaticConfigPartial : blink.indent.StaticConfig, {}

--- @class blink.indent.ScopeConfig
--- @field enabled boolean Highlights highest level of indentation on the current line
--- @field indent_at_cursor boolean Clamp to indent level of cursor
--- @field ns integer Namespace of the extmarks used to draw the scope guides
--- @field char '┆' | '┊' | '╎' | '║' | '▏' | '▎' | string Character used to draw the scope guides
--- @field priority integer Priority of the extmarks used to draw the scope guides
--- @field highlights string[] Highlight groups used to draw the scope guides
--- @field underline blink.indent.ScopeUnderlineConfig

--- @class (exact) blink.indent.ScopeConfigPartial : blink.indent.ScopeConfig, {}
--- @field underline blink.indent.ScopeUnderlineConfigPartial

--- @class blink.indent.ScopeUnderlineConfig
--- @field enabled boolean
--- @field highlights string[]

--- @class (exact) blink.indent.ScopeUnderlineConfigPartial : blink.indent.ScopeUnderlineConfig, {}

--- @class blink.indent.ConfigStrict
--- @field dedent_scoped_filetypes blink.indent.DedentScopedFiletypes defaults: filetypes where dedents close scopes
--- @field blocked blink.indent.BlockedConfig
--- @field mappings blink.indent.MappingsConfig
--- @field static blink.indent.StaticConfig
--- @field scope blink.indent.ScopeConfig

--- @class (exact) blink.indent.Config : blink.indent.ConfigStrict, {}
--- @field dedent_scoped_filetypes blink.indent.DedentScopedFiletypes
--- @field blocked blink.indent.BlockedConfigPartial
--- @field mappings blink.indent.MappingsConfigPartial
--- @field static blink.indent.StaticConfigPartial
--- @field scope blink.indent.ScopeConfigPartial

--- @type blink.indent.ConfigStrict
local config = {
  dedent_scoped_filetypes = { include_defaults = true },
  blocked = {
    buftypes = { include_defaults = true },
    filetypes = { include_defaults = true },
  },
  mappings = {
    border = 'both',
    object_scope = 'ii',
    object_scope_with_border = 'ai',
    goto_top = '[i',
    goto_bottom = ']i',
  },
  static = {
    enabled = true,
    ns = vim.api.nvim_create_namespace('blink.indent.static'),
    char = '▎',
    whitespace_char = nil,
    priority = 1,
    highlights = { 'BlinkIndent' },
  },
  scope = {
    enabled = true,
    indent_at_cursor = false,
    ns = vim.api.nvim_create_namespace('blink.indent.scope'),
    char = '▎',
    priority = 1000,
    highlights = { 'BlinkIndentOrange', 'BlinkIndentViolet', 'BlinkIndentBlue' },
    underline = {
      enabled = false,
      highlights = { 'BlinkIndentOrangeUnderline', 'BlinkIndentVioletUnderline', 'BlinkIndentBlueUnderline' },
    },
  },
}

--- @param opts? blink.indent.Config
local function setup(opts) config = vim.tbl_deep_extend('force', config, opts or {}) end

--- @type blink.indent.ConfigStrict | { setup: fun(opts?: blink.indent.Config) }
local M = setmetatable({}, { __index = function(_, k) return k == 'setup' and setup or config[k] end })
return M
