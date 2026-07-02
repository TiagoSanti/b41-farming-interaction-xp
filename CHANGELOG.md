# Changelog

## EN

## [Unreleased]

### Notes
- Host-side XP granting was adjusted to prefer vanilla/B41 `addXp()` and fall back to `Xp:AddXP()` with a multiplayer-compatible signature.
- `EngineXPMultiplier = 4.0` was added in `B41FIX_Config.lua` to make interaction rewards visible in-game.
- Base XP values now follow `Vanilla Agriculture Fix` defaults for `furrow`, `sow`, `water`, and `fertilize`, while `harvest` remains vanilla.

### Changed
- `B41FIX_ActionHooks.lua` (client) now calls `B41FIX.Client.sendCmd()` after furrow, sow, water, fertilize, and harvest actions.
- `B41FIX_Server.lua` (server) now logs received client commands per action at `INFO`.
- Watering now sends `usesConsumed` in the client -> Host payload for validation before XP/cooldown handling.
- `B41FIX_Server.lua` now tries vanilla/B41 `addXp()` first and falls back to `Xp:AddXP()` with a multiplayer-compatible signature, also logging method and before/after state.
- `B41FIX_Config.lua` now includes `EngineXPMultiplier = 4.0` so per-action values stay readable without losing visible in-game effect.
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

## PT-BR

## [Unreleased]

### Notes
- O grant de XP no Host foi ajustado para priorizar o caminho vanilla/B41 `addXp()` e cair para `Xp:AddXP()` com assinatura compativel com multiplayer.
- `EngineXPMultiplier = 4.0` foi adicionado em `B41FIX_Config.lua` para deixar as recompensas de interacao visiveis no jogo.
- Os valores base de XP agora seguem os defaults do `Vanilla Agriculture Fix` para `furrow`, `sow`, `water` e `fertilize`, enquanto `harvest` continua vanilla.

### Changed
- `B41FIX_ActionHooks.lua` (client) agora chama `B41FIX.Client.sendCmd()` apos as acoes de sulco, semeadura, rega, fertilizacao e colheita.
- `B41FIX_Server.lua` (server) agora registra em `INFO` os comandos recebidos do cliente por acao.
- A rega agora envia `usesConsumed` no payload cliente -> Host para validacao antes da etapa de XP/cooldown.
- `B41FIX_Server.lua` agora tenta primeiro o caminho vanilla/B41 `addXp()` e cai para `Xp:AddXP()` com assinatura compativel de multiplayer, registrando tambem metodo e estado antes/depois.
- `B41FIX_Config.lua` agora inclui `EngineXPMultiplier = 4.0` para manter os valores por acao legiveis sem perder efeito visivel no jogo.
- O Host agora envia `syncFarmingXP` de volta ao cliente para atualizar a UI local de Agricultura apos o grant autoritativo de XP.
- `B41FIX_ActionHooks.lua` e os comentarios auxiliares foram limpos para refletir o fluxo final em B41.

### Added
- Concessao inicial de XP no Host para `furrow`, `sow`, `water` e `fertilize`.
- Cooldown simples de rega no servidor via `plant:getModData().B41FIX.lastWaterRewardHour`.

## [0.1.0] - 2026-07-02

### Added
- `mod.info` com metadados do mod (`name`, `id`, `description`, `versionMin`, `versionMax`).
- `project.json` atualizado com `description`, `versionMin`, `versionMax` e `visibility = "unlisted"`.
- `B41FIX_Config.lua` (shared) com toggles por acao, valores de XP, cooldown de rega e `DebugLogging`.
- `B41FIX_Logger.lua` (shared) com filtragem de logs prefixados por `[B41FIX]` para `ERROR`, `WARN`, `INFO`, `DEBUG` e `TRACE`.
- `B41FIX_Util.lua` (shared) com funcoes auxiliares: `getPlayerUsername`, `getSquareCoords`, `getPlantCoords`, `getModData`, `getGameHour`.
- `B41FIX_ActionHooks.lua` (client) com wrappers das timed actions vanilla de agricultura para a fase inicial de logging.
- `B41FIX_Client.lua` (client) com `sendCmd()` para despacho cliente -> Host via `sendClientCommand`.
- `B41FIX_Server.lua` (server) com listener `Events.OnClientCommand` para `B41FarmingInteractionXP`.

### Fixed
- Corrigido o crash de arranque causado por `_orig = nil` quando `complete()` nao estava definido diretamente em algumas class tables de timed actions da B41; resolvido com fallback `safeOrig()` para `function() return true end`.
- Corrigido o risco de `Util = nil` (e o mesmo padrao para `Logger`/`Config`): capturas file-scope como `local X = B41FIX.X` eram avaliadas antes de todos os ficheiros `shared/` terminarem de carregar, entao foram substituidas por acesso dinamico dentro das funcoes.
