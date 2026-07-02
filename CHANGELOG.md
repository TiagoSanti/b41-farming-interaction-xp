# Changelog

## [Unreleased]

### Notes
- Host-side XP granting was adjusted to prefer vanilla/B41 `addXp()` and fall back to `Xp:AddXP()` with a multiplayer-compatible signature.
- `EngineXPMultiplier = 1.0` was added in `B41FIX_Config.lua`.
- Base XP values now follow `Vanilla Agriculture Fix` defaults for `furrow`, `sow`, `water`, and `fertilize`, while `harvest` remains vanilla.

### Changed
- `B41FIX_ActionHooks.lua` (client) now calls `B41FIX.Client.sendCmd()` after furrow, sow, water, fertilize, and harvest actions.
- `B41FIX_Server.lua` (server) now logs received client commands per action at `INFO`.
- Watering now sends `usesConsumed` in the client -> Host payload for validation before XP/cooldown handling.
- `B41FIX_Server.lua` now tries vanilla/B41 `addXp()` first and falls back to `Xp:AddXP()` with a multiplayer-compatible signature, also logging method and before/after state.
- `B41FIX_Config.lua` now includes `EngineXPMultiplier = 1.0`.
- The Host now sends `syncFarmingXP` back to the client so the local Agriculture UI updates after authoritative XP grants.
- `B41FIX_ActionHooks.lua` and helper comments were cleaned up to reflect the final B41 flow.

### Added
- Initial Host-side XP for `furrow`, `sow`, `water`, and `fertilize`.
- Simple server-side watering cooldown via `plant:getModData().B41FIX.lastWaterRewardHour`.

## [0.1.0] - 2026-07-02

### Added
- `mod.info` with mod metadata (`name`, `id`, `description`, `versionMin`, `versionMax`).
- `project.json` updated with `description`, `versionMin`, `versionMax`, and `visibility = "unlisted"`.
- `B41FIX_Config.lua` (shared) with action toggles, XP values, watering cooldown, and `DebugLogging`.
- `B41FIX_Logger.lua` (shared) with `[B41FIX]`-prefixed log filtering for `ERROR`, `WARN`, `INFO`, `DEBUG`, and `TRACE`.
- `B41FIX_Util.lua` (shared) helper functions: `getPlayerUsername`, `getSquareCoords`, `getPlantCoords`, `getModData`, `getGameHour`.
- `B41FIX_ActionHooks.lua` (client) with vanilla farming timed-action wrappers for the initial logging-only phase.
- `B41FIX_Client.lua` (client) with `sendCmd()` for client -> Host command dispatch through `sendClientCommand`.
- `B41FIX_Server.lua` (server) with `Events.OnClientCommand` listener for `B41FarmingInteractionXP`.

### Fixed
- Fixed startup crash caused by `_orig = nil` when `complete()` was not defined directly on some B41 timed-action class tables; solved with `safeOrig()` fallback `function() return true end`.
- Fixed `Util = nil` risk (and the same pattern for `Logger`/`Config`): file-scope captures like `local X = B41FIX.X` were evaluated before all `shared/` files had finished loading, so they were replaced with dynamic access inside functions.
