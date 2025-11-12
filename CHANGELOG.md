## [2.0.0](https://github.com/saghen/blink.indent/compare/v1.0.0..v2.0.0) - 2025-11-12

### Breaking Changes

- set `BlinkIndentScope` to `Delimiter` by default ([87e55cc](https://github.com/saghen/blink.indent/commit/87e55ccda476a133b721c9efb6d7b32b61637c56))
- add motions and textobjects ([2227b35](https://github.com/saghen/blink.indent/commit/2227b3526bf34eb71601cf817cfb861a51abcf50))
- use listchars.space for whitespace in static indents ([c2d68d5](https://github.com/saghen/blink.indent/commit/c2d68d58aefd3a0c8fa812e7c15a6675dcf986cf))

### Features

- drop unused blocked filetypes ([b09ba7a](https://github.com/saghen/blink.indent/commit/b09ba7ac02aee24a8040783fa5a1ae19090e58bf))
- drop goto to support lua 5.1 ([b370759](https://github.com/saghen/blink.indent/commit/b370759f264c693cd2e0406fd2470eb632863a13))
- add `static.whitespace_char` option ([350aa0f](https://github.com/saghen/blink.indent/commit/350aa0f0b35f780ce3b601115d8fad2b311376d4))
- add support for breakindent (#35) ([c6f98c3](https://github.com/saghen/blink.indent/commit/c6f98c364b065be520243c91c1a01314fdbe9b2a))

### Bug Fixes

- wrong buffer for buffer local enabled ([d542e00](https://github.com/saghen/blink.indent/commit/d542e005fcae3f2703db7ab83dae7d6b137fc54e))
- wrong window for horizontal_offset ([b2fab41](https://github.com/saghen/blink.indent/commit/b2fab41ea004b2d508a39ad3e627229afc3f8cdc))
- byte index when horizontal_offset applied ([14a159b](https://github.com/saghen/blink.indent/commit/14a159bfe31a3fe7ae4cb3c6349d861bb86a09ce))
- use cache but redraw when horizontal_offset changes ([c9a6c70](https://github.com/saghen/blink.indent/commit/c9a6c70ed6e8dd0fae8ccc6116c174cd015a0908))
- default to space if no listchars.space is set (#12) ([f32c4df](https://github.com/saghen/blink.indent/commit/f32c4df47bd731c77beaff07b12125c91febf28a))
- improved annotations, added missing ones (#20) ([8cac11b](https://github.com/saghen/blink.indent/commit/8cac11b1b3ea330056d96332d847b89cea8ed3e7))
- redraw only indent guides instead of using `nvim__redraw` ([3577699](https://github.com/saghen/blink.indent/commit/357769996082899892b32f0526cb9389a4d2946a))
- incorrect indent level on empty line in new scope ([b7a3e1b](https://github.com/saghen/blink.indent/commit/b7a3e1b6d9e128ba3628edc83a337cd82caa4367))
- incorrect winnr on draw_all ([a66ac16](https://github.com/saghen/blink.indent/commit/a66ac16464f22a813c755af283af423a38bbde65))
- add missing border setting in mapping config ([9f56dcb](https://github.com/saghen/blink.indent/commit/9f56dcbd34854027cde821e62df45582dcc9792e))
- drop incorrect keymap clearing, add todo ([d0548ff](https://github.com/saghen/blink.indent/commit/d0548ffdf7b8c2f5dbfc1f201439c83176af014f))
- remove debug scope range statement (#25) ([c456dc4](https://github.com/saghen/blink.indent/commit/c456dc4706e8fb1f2496264b74972d7180760ddb))
- redraw on `vim.opt.listchars` change ([30de5db](https://github.com/saghen/blink.indent/commit/30de5db24bac75f865827329a57d358758a6c758))
- add missing `draw_underline` function ([d961d82](https://github.com/saghen/blink.indent/commit/d961d8295395a242f4a158e39fd54611c660d654))
- use changedtick instead of textchanged for cache invalidation ([b571886](https://github.com/saghen/blink.indent/commit/b57188610b762033665872daeb47c6ddf91380dc))

### Refactor

- replaced most of `string.<fun>()` statements with simpler ones (#18) ([f5f1b3e](https://github.com/saghen/blink.indent/commit/f5f1b3e52bf221f651418d48a6f49b3c69f577b7))
- rename no_override to default for mappings ([fef1b77](https://github.com/saghen/blink.indent/commit/fef1b77265138356dac65f3acdb9142150816b93))

### Documentation

- add ref for frizbee screenshot ([cd9985a](https://github.com/saghen/blink.indent/commit/cd9985a961f970f80d46a5945ecf2c10ffea0a84))
- add performance section ([8943ae7](https://github.com/saghen/blink.indent/commit/8943ae77c4f3e8828a079c2710e5a65fcb4df6a5))
- fix reference for blocked filetypes/buftypes ([831f998](https://github.com/saghen/blink.indent/commit/831f998dc481d9e5815975dde2d1f6c7fc9cbbf5))
- drop redundant treesitter ref ([a8feeea](https://github.com/saghen/blink.indent/commit/a8feeeae8510d16f26afbb5c81f2ad1ccea38d62))
- add license (#14) ([7d4463b](https://github.com/saghen/blink.indent/commit/7d4463bceca9a9d36d2d3a813a85842a44704f45))
- missing comma in `setup()` code block (#16) ([6455b04](https://github.com/saghen/blink.indent/commit/6455b045d1ac55594dbaceecd1ea3ae31fcd1c0a))
- include setup call for `vim.pack` ([bba9082](https://github.com/saghen/blink.indent/commit/bba908208683ad5bcbd7b0726d43647ff957f512))
- add vim help (#22) ([e28c938](https://github.com/saghen/blink.indent/commit/e28c938a3bdcf9bb818302398d272205ab06f8a6))
- drop exclamations from breaking changes header ([eefb7a6](https://github.com/saghen/blink.indent/commit/eefb7a6627abb74e4cd8c759de3ab043304bd3f2))
- fix vim.pack instructions, misc ([330956d](https://github.com/saghen/blink.indent/commit/330956dcfd454aebd98b49ea30b01eb5732b476a))
- fix git-cliff spacing ([3b28a54](https://github.com/saghen/blink.indent/commit/3b28a549976514f8b422bc0fd6cfe751af63ea52))

### Performance

- ignore draw when horizontal offset > indent level ([31af51b](https://github.com/saghen/blink.indent/commit/31af51b3d1a8667b5e13fd7e2a3af9d51a99ffdb))
- re-use `is_all_whitespace` table from parser ([6a94ee2](https://github.com/saghen/blink.indent/commit/6a94ee258b23f25b32bcf2ca20dd8d81b6ba3d33))
- optionally skip tab replacement when calculating indent level ([c3d4f80](https://github.com/saghen/blink.indent/commit/c3d4f80bd15c1224f6d8a817ebb4edb31d081096))
- rework parser for incremental draw (#28) ([d8a75ad](https://github.com/saghen/blink.indent/commit/d8a75ad22a5df67f91c704bb787e8a42b4588359))

## New Contributors ❤︎

- @saghen made their first contribution in [#35](https://github.com/saghen/blink.indent/pull/35)
- @tristan957 made their first contribution in [#25](https://github.com/saghen/blink.indent/pull/25)
- @DrKJeff16 made their first contribution in [#18](https://github.com/saghen/blink.indent/pull/18)
- @stefanboca made their first contribution in [#14](https://github.com/saghen/blink.indent/pull/14)
- @ribru17 made their first contribution in [#12](https://github.com/saghen/blink.indent/pull/12)

## [1.0.0] - 2025-11-06

### Breaking Changes

- partial config, `blink_indent` ns, vim.g.indent_guide for disable/enable ([4ea3573](https://github.com/saghen/blink.indent/commit/4ea3573ca492f0cf51e2a974b511fb0751d2f99d))
- automatic initialization, drop `opts.blocked` ([ad2ea82](https://github.com/saghen/blink.indent/commit/ad2ea822b3fc6c6c2f0078d357e65a90535b4c55))
- set default scope priority to 1000 ([5e75e86](https://github.com/saghen/blink.indent/commit/5e75e86783f6e00daafb856905173fe275d95a8a))

### Features

- initial ([1b0f9e6](https://github.com/saghen/blink.indent/commit/1b0f9e6e41e4f3909940b3ec93724acad7491d4b))
- switch to decoration provider ([4e33f50](https://github.com/saghen/blink.indent/commit/4e33f50b8111fbe3055e5e1224aaec448c0f85f9))
- add flake ([4b081ef](https://github.com/saghen/blink.indent/commit/4b081efe1700a3359df361a4965f6732c99f3705))
- make rainbow colors colour picking more consistent ([f874238](https://github.com/saghen/blink.indent/commit/f87423807afe0246070a6c9027ae4dcdbd651551))
- add back to repo ([824258a](https://github.com/saghen/blink.indent/commit/824258affb860b395de27c9bf83cead734ae0185))
- multi-repo setup based on mini.nvim ([2360071](https://github.com/saghen/blink.indent/commit/2360071acc93ed862399b7b6f59e507cf7ec3f46))
- hl groups and configuration ([e4cc14a](https://github.com/saghen/blink.indent/commit/e4cc14ac419c51a73a6518bcfcaa90e29086f616))
- rework configuration ([727f1d3](https://github.com/saghen/blink.indent/commit/727f1d30d969fec9477f0afd41ca13b5e6d15d17))
- update flake to reflect merge with mono-repo ([d7b20e5](https://github.com/saghen/blink.indent/commit/d7b20e5b343c4aa1ad4c8add60d78ab748a19771))
- lazy loading and enable/disable config ([5107d7f](https://github.com/saghen/blink.indent/commit/5107d7ff4aa17c6acac1a1ac4e9df6584f9b13c2))
- support `vim.g.indent_guide` or `vim.b.indent_guide` for disabling ([4bd92d7](https://github.com/saghen/blink.indent/commit/4bd92d7d3dd612460294dbea6c47b9440a6310fd))
- load utils on demand ([f8e5120](https://github.com/saghen/blink.indent/commit/f8e5120e5791c6468420ad397a0ae43a9894d4c5))
- add caching to indent levels, scope and static ([f47666e](https://github.com/saghen/blink.indent/commit/f47666ef0e6285a09ab3351d3a6919880801dcb2))
- simplify caching logic ([25fbb6d](https://github.com/saghen/blink.indent/commit/25fbb6da3660ce93a9b3342c194b0577cd894005))
- add back `config.blocked.*`, refactor codebase ([41d1b09](https://github.com/saghen/blink.indent/commit/41d1b096c9d1362af8d9ecfaea3578e8a29345c7))

### Bug Fixes

- plugin paths ([7c8860f](https://github.com/saghen/blink.indent/commit/7c8860f454a947ae178b7b499a952704589c71e2))
- swap measure time for defer_fn ([9428f80](https://github.com/saghen/blink.indent/commit/9428f801f0fb1b31f357a4704c4592d44f3208cd))
- a lot ([a1a5587](https://github.com/saghen/blink.indent/commit/a1a55870551aa4ef6ed93c536c84fc0620d251fe))
- use current window cursor position ([b4e8b8b](https://github.com/saghen/blink.indent/commit/b4e8b8bc85f1524aa0b0cbffd8ac481eebbe986f))
- horizontal scroll ([6caa740](https://github.com/saghen/blink.indent/commit/6caa740da588e8211cea79eb2530ea81a3aa38a6))
- add blink-indent.lua to top level ([ae8e986](https://github.com/saghen/blink.indent/commit/ae8e9869ceec4b393ca509581da7cf9e34c89b3d))
- remove buggy lazy loading ([ffb4dfc](https://github.com/saghen/blink.indent/commit/ffb4dfc7ac47add6df7d489b3f018673b992f617))
- config failing when setup not called ([ab84ddd](https://github.com/saghen/blink.indent/commit/ab84ddd6d18dc1bef7eecdf393205f911d7b8132))
- config not taking effect ([8439abf](https://github.com/saghen/blink.indent/commit/8439abf58b06c5e6846dd0fab95a28395af1dbd1))
- off by one indent level on first line ([7510d32](https://github.com/saghen/blink.indent/commit/7510d32d81e399f1fcbd1f449ec4ae1ebfe7d1ac))
- incorrect underline highlight group names ([f3e47c6](https://github.com/saghen/blink.indent/commit/f3e47c627659c698367a7206d72412df4ec70415))
- checking wrong buffer for is_enabled ([3d5d29e](https://github.com/saghen/blink.indent/commit/3d5d29ed68c35e47e87a13ed74219ee89b66e141))

### Refactor

- drop deprecated usage of `vim.str_byteindex` ([693e37d](https://github.com/saghen/blink.indent/commit/693e37dfe00387306b4f51509e031db9a4bbace5))
- drop deprecated `nvim_buf_add_highlight` ([cfa576c](https://github.com/saghen/blink.indent/commit/cfa576c67d5310d488e8df611a4d0b3a97203f88))
- move indent logic to `indent.lua` ([9385576](https://github.com/saghen/blink.indent/commit/9385576533f8530d0affe85b101057d6a18b2562))
- drop unused range check ([991d399](https://github.com/saghen/blink.indent/commit/991d399735a1177dd01015da0b4b5e40ae43789e))

### Documentation

- add readme ([8a9148b](https://github.com/saghen/blink.indent/commit/8a9148bbbc2669832650ef789f6e86e5af0008f5))
- fix install instructions ([5a349fa](https://github.com/saghen/blink.indent/commit/5a349fa8857823c346c76ee962861d017e7e92e9))
- update reason to use indent-blankline ([18315cc](https://github.com/saghen/blink.indent/commit/18315ccf08d054f31741f23f8f1dda4a10708e31))
- vim.pack instructions ([6b01ac6](https://github.com/saghen/blink.indent/commit/6b01ac69d5e931ed7ab0e8c23c18324dfb7490c5))
- config section in readme ([44f0b65](https://github.com/saghen/blink.indent/commit/44f0b65b5d9648764fea0577f332f7364bd94d8b))
- add image, center align title ([a0d6b8e](https://github.com/saghen/blink.indent/commit/a0d6b8e74933e7075f80e96d0e4699587fe15d99))

## New Contributors ❤︎

- @saghen made their first contribution
- @atweiden made their first contribution
- @redxtech made their first contribution

