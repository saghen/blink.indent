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

- @atweiden made their first contribution
- @redxtech made their first contribution
