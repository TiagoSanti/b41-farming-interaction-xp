# Development Plan

## Scope

`B41 Farming Interaction XP` redistributes Agriculture XP across the main farming interactions in Project Zomboid Build 41 while keeping harvest behavior vanilla.

Current implementation focus:

- furrow XP
- sow XP
- water XP
- fertilize XP
- Host-authoritative multiplayer flow
- single-player support
- immediate client UI sync after server-side XP grants

## Current Status

- Core B41 action hooks are implemented and stable.
- Host-side XP granting is working for `furrow`, `sow`, `water`, and `fertilize`.
- Watering includes a basic per-plant cooldown.
- Harvest logging exists and harvest XP remains vanilla.
- Build and packaging flow are handled through `pzstudio`.

## Remaining Work

- Validate harvest logging and edge cases on mature crops.
- Test more Host multiplayer scenarios with guests.
- Add release assets such as final poster/icon polish if needed.
- Publish and monitor balance feedback.

## Technical Direction

- Keep hooks lightweight and B41-native.
- Prefer Host-side authority for XP and validation.
- Avoid deep rewrites of vanilla farming systems unless a real compatibility issue appears.
- Keep third-party mods as balance and behavior references only.

## Balance Baseline

- `FurrowXP = 1.0`
- `SowingXP = 2.0`
- `WateringXP = 2.0`
- `FertilizeXP = 4.0`
- `HarvestBonusXP = 0.0`
- `EngineXPMultiplier = 1.0`

Reference source: `Vanilla Agriculture Fix` by `DarylMasterGG` for gameplay balance only.
