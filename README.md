# B41 Farming Interaction XP

## Overview

`B41 Farming Interaction XP` redistributes Farming XP across the full crop interaction loop in Project Zomboid Build 41.

Instead of concentrating progression only on harvest, this mod rewards:

- plowing furrows
- sowing seeds
- watering crops
- fertilizing crops
- harvesting through vanilla behavior

The implementation is focused on Build 41 Host multiplayer and single-player. XP is granted authoritatively on the Host and mirrored back to the client UI so Agriculture progress is visible immediately.

## Features

- Host-authoritative Farming XP for `furrow`, `sow`, `water`, and `fertilize`
- Vanilla harvest XP preserved
- Client hooks for B41 timed actions
- Basic anti-abuse protection for watering through per-plant cooldown
- Immediate Agriculture UI sync on the client
- Project Zomboid Studio (`pzstudio`) build workflow

## Compatibility

- Target game version: `41.78`
- Primary target: Host multiplayer
- Secondary target: single-player
- Dedicated server support is not the main target of this release

## Balance

Current base values follow the defaults used by `Vanilla Agriculture Fix` as a balance reference:

- `FurrowXP = 1.0`
- `SowingXP = 2.0`
- `WateringXP = 2.0`
- `FertilizeXP = 4.0`
- `HarvestBonusXP = 0.0`

Harvest remains vanilla.

## Development

This repository uses `pzstudio` for project structure and local Workshop output syncing.

Useful commands:

```bash
npm run build
npm run watch
npm run clean
```

## AI Assistance Disclaimer

This mod was written with AI assistance for code drafting, review, debugging, documentation, and release preparation.

Final integration, testing, balancing choices, and publication decisions remain the responsibility of the author.

## Credits

- Author: `Becker`
- Balance reference: `Vanilla Agriculture Fix` by `DarylMasterGG`
- Build tooling: `Project Zomboid Studio` by `Konijima`
