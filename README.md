# B41 Farming Interaction XP

## EN

### Overview

`B41 Farming Interaction XP` redistributes Farming XP across the full crop interaction loop in Project Zomboid Build 41.

Instead of concentrating progression only on harvest, this mod rewards:

- plowing furrows
- sowing seeds
- watering crops
- fertilizing crops
- harvesting through vanilla behavior

The implementation is focused on Build 41 Host multiplayer and single-player. XP is granted authoritatively on the Host and mirrored back to the client UI so Agriculture progress is visible immediately.

### Features

- Host-authoritative Farming XP for `furrow`, `sow`, `water`, and `fertilize`
- Vanilla harvest XP preserved
- Client hooks for B41 timed actions
- Basic anti-abuse protection for watering through per-plant cooldown
- Immediate Agriculture UI sync on the client
- Project Zomboid Studio (`pzstudio`) build workflow

### Compatibility

- Target game version: `41.78`
- Primary target: Host multiplayer
- Secondary target: single-player
- Dedicated server support is not the main target of this release

### Balance

Current base values follow the defaults used by `Vanilla Agriculture Fix` as a balance reference:

- `FurrowXP = 1.0`
- `SowingXP = 2.0`
- `WateringXP = 2.0`
- `FertilizeXP = 4.0`
- `HarvestBonusXP = 0.0`

With `EngineXPMultiplier = 4.0`, the practical in-game grant becomes:

- furrow: `4`
- sow: `8`
- water: `8`
- fertilize: `16`

Harvest remains vanilla.

### Development

This repository uses `pzstudio` for project structure and local Workshop output syncing.

Useful commands:

```bash
npm run build
npm run watch
npm run clean
```

### AI Assistance Disclaimer

This mod was written with AI assistance for code drafting, review, debugging, documentation, and release preparation.

Final integration, testing, balancing choices, and publication decisions remain the responsibility of the author.

### Credits

- Author: `Tiago Becker`
- Balance reference: `Vanilla Agriculture Fix` by `DarylMasterGG`
- Build tooling: `Project Zomboid Studio` by `Konijima`

## PT-BR

### Visao Geral

`B41 Farming Interaction XP` redistribui a XP de Agricultura ao longo de todo o ciclo de interacoes com plantacoes no Project Zomboid Build 41.

Em vez de concentrar a progressao apenas na colheita, este mod recompensa:

- criar sulcos
- semear
- regar
- fertilizar
- colher pelo comportamento vanilla

A implementacao e focada em Build 41 no modo Host multiplayer e single-player. A XP e concedida de forma autoritativa pelo Host e espelhada de volta para a UI do cliente para que o progresso de Agricultura apareca imediatamente.

### Recursos

- XP de Agricultura autoritativa no Host para `furrow`, `sow`, `water` e `fertilize`
- XP vanilla de colheita preservada
- Hooks cliente para as timed actions da B41
- Protecao basica contra abuso na rega com cooldown por planta
- Sincronizacao imediata da UI de Agricultura no cliente
- Fluxo de build com `pzstudio`

### Compatibilidade

- Versao alvo do jogo: `41.78`
- Alvo principal: Host multiplayer
- Alvo secundario: single-player
- Suporte a dedicated server nao e o foco principal desta release

### Balanceamento

Os valores base atuais seguem os defaults usados por `Vanilla Agriculture Fix` como referencia de balanceamento:

- `FurrowXP = 1.0`
- `SowingXP = 2.0`
- `WateringXP = 2.0`
- `FertilizeXP = 4.0`
- `HarvestBonusXP = 0.0`

Com `EngineXPMultiplier = 4.0`, o ganho pratico no jogo fica:

- furrow: `4`
- sow: `8`
- water: `8`
- fertilize: `16`

A colheita permanece vanilla.

### Desenvolvimento

Este repositorio usa `pzstudio` para a estrutura do projeto e a sincronizacao local da saida do Workshop.

Comandos uteis:

```bash
npm run build
npm run watch
npm run clean
```

### Aviso Sobre Uso De IA

Este mod foi escrito com auxilio de IA para rascunho de codigo, revisao, debugging, documentacao e preparacao de release.

A integracao final, os testes, as escolhas de balanceamento e as decisoes de publicacao continuam sendo responsabilidade do autor.

### Creditos

- Autor: `Tiago Becker`
- Referencia de balanceamento: `Vanilla Agriculture Fix` por `DarylMasterGG`
- Ferramenta de build: `Project Zomboid Studio` por `Konijima`
