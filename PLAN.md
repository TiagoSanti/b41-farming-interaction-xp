# Plano de Desenvolvimento — B41 Farming Interaction XP

## 1. Visão geral

Este documento descreve o planejamento técnico para o desenvolvimento de um mod de **Project Zomboid Build 41.78.16**, voltado principalmente ao uso em **modo Host**, com foco em conceder XP de Agricultura durante diferentes interações com plantações.

O objetivo é distribuir a progressão de Agricultura ao longo de todo o ciclo de cultivo, em vez de concentrá-la apenas na colheita.

Funcionalidades previstas:

- XP ao criar sulcos;
- XP ao semear;
- XP ao regar;
- XP ao fertilizar;
- XP ao colher;
- proteção básica contra repetição abusiva de ações;
- configuração dos valores de XP;
- compatibilidade prioritária com modo Host;
- compatibilidade secundária com single-player;
- possibilidade de expansão futura para servidor dedicado.

Nome provisório do mod:

```text
B41 Farming Interaction XP
```

Mod ID sugerido:

```text
B41FarmingInteractionXP
```

## 2. Objetivos

### 2.1 Objetivo principal

Criar um mod para B41 que recompense o jogador com XP de Agricultura pelas seguintes ações:

1. criar um sulco;
2. semear;
3. regar;
4. fertilizar;
5. colher.

### 2.2 Prioridade de compatibilidade

```text
1. Modo Host B41
2. Single-player
3. Dedicated server futuramente
```

### 2.3 Fora do escopo inicial

A primeira versão não precisa incluir:

- suporte a servidores públicos;
- proteção avançada contra clientes adulterados;
- novos cultivos;
- alteração de rendimento;
- alteração de velocidade de crescimento;
- integração obrigatória com Farming API;
- compatibilidade ampla com todos os mods agrícolas;
- suporte completo a dedicated server;
- identificação obrigatória de quem plantou;
- sistema complexo de progressão agrícola.

## 3. Referência funcional

O mod será inspirado funcionalmente no comportamento do **Vanilla Agriculture Fix** da Build 42.

A versão B42 pode ser usada para:

- observar quais ações concedem XP;
- comparar proporções de recompensa;
- verificar comportamento de ações canceladas;
- entender como a rega é recompensada;
- observar limitações de XP;
- estudar opções de configuração;
- avaliar a experiência geral do usuário.

A implementação para B41 deve ser independente.

Não devem ser copiados sem autorização:

- código-fonte;
- assets;
- traduções;
- comentários;
- estrutura interna;
- funções específicas;
- algoritmos proprietários.

Caso o autor autorize a adaptação, partes do mod poderão ser estudadas com mais profundidade, desde que os termos de uso e crédito sejam respeitados.

Documento sugerido:

```text
docs/B42_BEHAVIOR_REFERENCE.md
```

## 3.1 Resultados da inspeção do código de referência

Foram inspecionados os arquivos fornecidos de:

- `Vanilla Agriculture Fix`, para Build 42;

Não foram encontradas instruções suspeitas, prompt injection ou conteúdo tentando orientar ferramentas externas. Os arquivos analisados são código Lua, definições Sandbox, scripts de receitas, metadados e documentação dos mods.

### Arquitetura observada no Vanilla Agriculture Fix

O mod da B42 divide a implementação em quatro partes principais:

```text
VAF_Core.lua
VAF_TimedActionPatch.lua
VAF_Server.lua
VAF_SpecializedAgriculture.lua
```

Para o escopo de XP por interações, os três primeiros são os mais relevantes.

#### Hooks usados na B42

O mod intercepta os métodos `complete()` das ações:

```text
ISPlowAction.complete
ISSeedActionNew.complete
ISWaterPlantAction.complete
ISFertilizeAction.complete
ISHarvestPlantAction.complete
```

Na rega, também intercepta:

```text
ISWaterPlantAction.start
```

Isso permite registrar o estado inicial da planta antes da ação.

O padrão usado é wrapping:

```lua
local originalComplete = SomeAction.complete

function SomeAction:complete()
    local result = originalComplete(self)

    if result then
        -- lógica adicional
    end

    return result
end
```

Esse padrão confirma a estratégia planejada para o mod B41: preservar a função original, executar a lógica vanilla e somente depois decidir se a XP deve ser concedida.

#### Fluxo cliente/Host-servidor

O mod B42 usa:

```lua
sendClientCommand(...)
Events.OnClientCommand.Add(...)
```

O cliente envia:

- tipo da ação;
- coordenadas da planta;
- XP de colheita calculada, em um caso específico.

O servidor:

- localiza a planta por `x`, `y`, `z`;
- valida o estado;
- concede a XP;
- ignora comandos inválidos.

Isso confirma que o fluxo cliente → Host é apropriado para nosso mod, mesmo com prioridade no modo Host.

#### Concessão de XP

O código usa duas alternativas:

```lua
addXp(player, Perks.Farming, amount)
```

ou:

```lua
player:getXp():AddXP(Perks.Farming, amount)
```

O mod B42 aplica um multiplicador interno igual a `4` aos valores configurados para sulco, semeadura, rega e fertilização:

```text
XP efetiva no motor = valor Sandbox × 4
```

Portanto, os valores exibidos pela configuração do mod B42 não devem ser copiados diretamente para B41 sem medir o comportamento da função de XP nessa build.

#### XP de colheita

Em vez de adicionar uma recompensa fixa sobre a XP vanilla, o mod B42:

1. intercepta `SFarmingSystem.gainXp`;
2. suprime temporariamente a XP vanilla durante a colheita;
3. calcula a XP vanilla a partir da saúde e do cuidado da planta;
4. devolve apenas uma porcentagem configurada.

Fórmula observada:

```text
base = health / 2

se badCare:
    base -= 15
senão:
    base += 25

base limitada entre 1 e 100
XP final = base × percentual configurado
```

Para nosso mod B41, há duas opções:

- preservar a XP vanilla e adicionar XP das outras ações;
- redistribuir a XP total, suprimindo parte da recompensa da colheita.

Para o MVP de uso próprio, a opção mais segura é:

```text
preservar a XP vanilla de colheita;
adicionar recompensas moderadas às demais interações;
não substituir SFarmingSystem.gainXp inicialmente.
```

Isso reduz o risco de conflito e permite validar os hooks antes de alterar o balanceamento vanilla.

#### Identificação do dono da planta

O mod B42 não cria um campo próprio para o plantador. Ele usa:

```lua
plant.owner
```

e compara com:

```text
player:getOnlineID()
player:getPlayerNum()
```

Na B41, deve-se verificar se `plant.owner` já existe, é persistido e funciona para Host e convidados. Se funcionar, não será necessário criar `planterUsername` no MVP.

#### Lógica de rega do mod B42

A recompensa de rega é concedida quando:

- a planta começou com água vazia ou menor/igual a zero;
- água foi efetivamente utilizada;
- o nível de água aumentou.

No servidor dedicado, o mod também intercepta diretamente:

```text
SFarmingSystemCommands.water
```

para comparar `waterLvl` antes e depois no lado servidor.

Essa abordagem é mais restritiva que o cooldown inicialmente planejado. Para nosso MVP Host, serão testadas duas estratégias:

```text
A. recompensa quando a planta começa vazia;
B. recompensa por rega efetiva com cooldown por planta.
```

A estratégia B é mais próxima do objetivo de recompensar manutenção recorrente, mas exige proteção contra micro-regas.

#### Validações de fertilização

O mod B42 valida:

- item de fertilização existente;
- item com usos disponíveis;
- planta não estando apenas no estado de sulco;
- ação concluída com sucesso.

Ele também protege todos os estágios da ação:

```text
isValid
start
update
stop
perform
complete
```

Essa proteção ampla parece ligada a correções específicas da B42. Na B41, começar apenas por `complete()` e por comparação de estado antes/depois será menos invasivo. Outros métodos só devem ser interceptados se testes revelarem falhas.

### Conclusão sobre o código B42

A referência confirma que o projeto é viável e que o desenho geral está correto:

```text
hooks em timed actions
→ comando cliente/Host
→ validação por coordenada
→ concessão de XP no Host
```

Entretanto, não convém portar literalmente:

- nomes de classes podem diferir;
- a lógica de XP do motor pode diferir;
- a B42 possui `ISSeedActionNew`;
- a agricultura e o sincronismo foram alterados;
- o mod da B42 também substitui partes extensas de colheita e crescimento que estão fora do nosso escopo.

## 4. Stack de desenvolvimento

### 4.1 Ferramentas

- Project Zomboid Studio;
- Visual Studio Code;
- Git;
- Node.js LTS;
- npm;
- Lua Language Server;
- Project Zomboid Build 41.78.16;
- Project Zomboid Dedicated Server B41 para testes futuros;
- Steam Workshop Uploader;
- modo Debug do Project Zomboid.

### 4.2 Linguagens e formatos

- Lua para lógica;
- arquivos `.txt` para definições e traduções;
- `mod.info` para metadados;
- PNG para poster e thumbnail;
- Markdown para documentação;
- JSON para configuração do Project Zomboid Studio.

### 4.3 Dependências iniciais

O MVP não terá dependências obrigatórias.

## 5. Estrutura sugerida do projeto

```text
B41FarmingInteractionXP/
├── pzstudio.json
├── README.md
├── CHANGELOG.md
├── LICENSE
├── docs/
│   ├── B41_FARMING_ACTION_MAP.md
│   ├── B42_BEHAVIOR_REFERENCE.md
│   ├── TEST_PLAN.md
│   └── COMPATIBILITY.md
└── mods/
    └── B41FarmingInteractionXP/
        ├── mod.info
        ├── poster.png
        └── media/
            └── lua/
                ├── shared/
                │   ├── B41FIX_Config.lua
                │   ├── B41FIX_Logger.lua
                │   └── B41FIX_Util.lua
                ├── client/
                │   ├── B41FIX_ActionHooks.lua
                │   └── B41FIX_Client.lua
                └── server/
                    └── B41FIX_Server.lua
```

## 6. Responsabilidade dos módulos

### 6.1 `B41FIX_Config.lua`

Responsável por:

- armazenar valores padrão;
- habilitar ou desabilitar ações;
- definir cooldowns;
- definir multiplicadores;
- controlar logging.

### 6.2 `B41FIX_Logger.lua`

Responsável por:

- mensagens de inicialização;
- logs de hooks;
- logs de XP;
- avisos de duplicação;
- erros de sincronização;
- diagnósticos de multiplayer.

### 6.3 `B41FIX_Util.lua`

Responsável por:

- identificação de jogadores;
- leitura de coordenadas;
- acesso a plantações;
- funções auxiliares;
- validações genéricas;
- manipulação segura de `modData`.

### 6.4 `B41FIX_ActionHooks.lua`

Responsável por:

- interceptar ações vanilla;
- detectar ações concluídas;
- ignorar ações canceladas;
- capturar estado antes e depois;
- enviar eventos ao Host.

### 6.5 `B41FIX_Client.lua`

Responsável por:

- receber dados dos hooks;
- enviar comandos ao Host;
- evitar duplicação local;
- emitir logs de cliente.

### 6.6 `B41FIX_Server.lua`

Responsável por:

- receber comandos dos jogadores;
- localizar a plantação;
- validar dados básicos;
- conceder XP;
- atualizar `modData`;
- sincronizar persistência.

## 7. Ambiente de desenvolvimento

### 7.1 Criar o projeto

```powershell
mkdir E:\Dev\PZMods
cd E:\Dev\PZMods

pzstudio new "B41 Farming Interaction XP" "B41FarmingInteractionXP"
```

### 7.2 Configurar saída

```powershell
cd "E:\Dev\PZMods\B41 Farming Interaction XP"

pzstudio outdir "C:\Users\Tiago\Zomboid\Workshop"
```

### 7.3 Desenvolvimento contínuo

```powershell
pzstudio watch
```

### 7.4 Build manual

```powershell
pzstudio build
```

### 7.5 Versionamento

```powershell
git init
git add .
git commit -m "Initial B41 Farming Interaction XP project"
```

Branches sugeridas:

```text
main
develop
feature/action-hooks
feature/basic-xp
feature/watering-xp
feature/host-sync
feature/configuration
feature/translations
```

## 8. Pesquisa técnica inicial

Antes de implementar XP, é necessário mapear as ações agrícolas vanilla da B41.

### 8.1 Diretórios relevantes

```text
ProjectZomboid/media/lua/client/Farming/
ProjectZomboid/media/lua/client/TimedActions/
ProjectZomboid/media/lua/server/Farming/
ProjectZomboid/media/lua/shared/Farming/
```

### 8.2 Classes e símbolos a localizar

A referência B42 confirmou estas classes:

```text
ISPlowAction
ISSeedActionNew
ISWaterPlantAction
ISFertilizeAction
ISHarvestPlantAction
SFarmingSystem
SFarmingSystemCommands.water
CFarmingSystem
farming_vegetableconf
SPlantGlobalObject
AddXP(Perks.Farming
```

Na B41, os nomes exatos devem ser confirmados nos arquivos vanilla. Em particular:

```text
ISSeedActionNew
```

pode não existir com o mesmo nome na Build 41.

Também devem ser inspecionados:

```text
Farming/farmingCommands
SFarmingSystem.gainXp
plant.owner
plant.waterLvl
plant.fertilizer
plant.state
plant.hasVegetable
plant.hasSeed
```

### 8.3 Pesquisa pelo PowerShell

```powershell
$luaRoot = "C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\media\lua"

Get-ChildItem $luaRoot -Recurse -Filter *.lua |
    Select-String -Pattern `
        "ISPlowAction",
        "ISSeedAction",
        "ISWaterPlantAction",
        "ISFertilizeAction",
        "ISHarvestPlantAction",
        "AddXP\(Perks.Farming"
```

### 8.4 Documento de mapeamento

Criar:

```text
docs/B41_FARMING_ACTION_MAP.md
```

Modelo:

```markdown
## Regar

Classe:
ISWaterPlantAction

Método final:
perform()

Campos:
- self.character
- self.plant
- self.item
- self.waterUnit

Estado antes:
- plant.waterLvl

Estado depois:
- plant.waterLvl

Sincronização:
- cliente
- host
- farming system

Possíveis hooks:
- perform
- start
- stop
```

A implementação de XP só deve começar depois que as cinco ações forem mapeadas.

## 9. Arquitetura para modo Host

Mesmo sendo um mod de uso próprio, é melhor que a XP seja concedida no lado Host.

```text
Jogador conclui a ação
        ↓
Hook detecta a conclusão
        ↓
Cliente envia comando
        ↓
Host recebe o comando
        ↓
Host valida a ação
        ↓
Host concede XP
```

Vantagens:

- XP persiste corretamente;
- reduz duplicação;
- funciona para convidados;
- evita diferença entre host e cliente;
- facilita migração futura para dedicated server.

### 9.1 Exemplo conceitual

```lua
sendClientCommand(
    character,
    "B41FarmingInteractionXP",
    "ActionCompleted",
    {
        action = "water",
        x = square:getX(),
        y = square:getY(),
        z = square:getZ()
    }
)
```

O cliente não deve informar a quantidade final de XP. O Host deve calcular a recompensa.

## 10. Estratégia de hooks

### 10.1 Não sobrescrever diretamente

Evitar:

```lua
ISWaterPlantAction.perform = function(self)
    -- nova lógica
end
```

### 10.2 Usar wrapping

```lua
local previousPerform = ISWaterPlantAction.perform

function ISWaterPlantAction:perform()
    local snapshot = B41FIX.captureWaterState(self)

    previousPerform(self)

    B41FIX.onWaterCompleted(self, snapshot)
end
```

### 10.3 Proteger contra hook duplicado

```lua
if B41FIX.Hooks.waterInstalled then
    return
end

B41FIX.Hooks.waterInstalled = true
```

### 10.4 Ordem de carregamento

Investigar:

```text
OnGameBoot
OnGameStart
OnServerStarted
OnCreatePlayer
```

## 11. Configuração inicial

```lua
B41FIX.Config = {
    EnableFurrowXP = true,
    EnableSowingXP = true,
    EnableWateringXP = true,
    EnableFertilizingXP = true,
    EnableHarvestXP = true,

    FurrowXP = 0.5,
    SowingXP = 2.0,
    WateringXP = 0.25,
    FertilizingXP = 1.0,
    # Recompensa adicional provisória.
    # A XP vanilla de colheita será preservada no MVP.
    HarvestBonusXP = 0.0,

    WateringCooldownHours = 6,
    GlobalXPMultiplier = 1.0,

    DebugLogging = true,
}
```

Depois da estabilização, essas opções podem ser migradas para SandboxVars.

## 12. Implementação por ação

### 12.1 Criar sulco

Recompensa inicial:

```text
0,5 XP
```

Critérios:

- ação concluída;
- sulco realmente criado;
- tile anteriormente vazio;
- coordenada válida.

Proteções possíveis:

- XP baixo;
- cooldown por coordenada;
- limite por dia;
- desativar XP de sulco por configuração.

Cooldown opcional:

```text
72 horas do jogo por coordenada
```

### 12.2 Semear

Recompensa inicial:

```text
2 XP
```

Critérios:

- sulco passou a conter plantação;
- sementes foram consumidas;
- tipo de cultivo foi definido;
- ação concluída.

Persistência opcional:

```lua
plant:getModData().B41FIX = {
    schemaVersion = 1,
    planterUsername = player:getUsername(),
    sowRewarded = true,
}
```

### 12.3 Regar

MVP recomendado:

```text
0,25 XP por rega válida
```

Critérios:

- ação concluída;
- água foi consumida;
- plantação não estava completamente regada;
- cooldown expirou.

Cooldown inicial:

```text
6 horas do jogo por planta
```

Persistência:

```lua
plant:getModData().B41FIX = {
    schemaVersion = 1,
    lastWaterRewardHour = 0,
}
```

Versão futura:

```text
0,25 XP por 10 unidades efetivas de água
```

Cuidados:

- não conceder XP com delta zero;
- evitar recompensa por ação sem efeito;
- não confiar apenas no estado imediato do cliente;
- validar após sincronização;
- impedir spam com pequenas quantidades.

### 12.4 Fertilizar

Recompensa inicial:

```text
1 XP
```

Critérios:

- fertilizante consumido;
- estado de fertilização alterado;
- ação concluída;
- aplicação teve efeito.

### 12.5 Colher

Recompensa inicial no MVP:

```text
0 XP adicional
```

A colheita continuará concedendo a XP vanilla. Uma recompensa adicional ou redistribuição da XP poderá ser ativada depois que a fórmula da B41 for medida.

Critérios:

- planta estava pronta;
- itens foram gerados;
- estado da planta mudou;
- recompensa ainda não concedida.

MVP: recompensar quem colheu.

Futuro:

```text
RestrictHarvestXPToPlanter
```

## 13. Persistência mínima

```lua
plant:getModData().B41FIX = {
    schemaVersion = 1,
    planterUsername = "becker",
    lastWaterRewardHour = 0,
    fertilizeRewardCount = 0,
    harvestRewarded = false,
}
```

Requisitos:

- aceitar plantas antigas sem `modData`;
- não gerar erro se campos estiverem ausentes;
- persistir após reiniciar o Host;
- não quebrar o save se o mod for removido.

## 14. Dependências externas

O MVP não terá dependências obrigatórias.

A implementação será feita diretamente sobre as classes e sistemas vanilla da Build 41, reduzindo conflitos e simplificando os testes no modo Host.

## 15. Logging

Níveis sugeridos:

```text
ERROR
WARN
INFO
DEBUG
TRACE
```

Exemplo:

```lua
B41FIX.Logger.debug("Water completed", {
    username = username,
    x = x,
    y = y,
    before = before,
    after = after,
    xp = xp,
})
```

Logs importantes:

- mod inicializado;
- hooks instalados;
- ação detectada;
- XP concedida;
- ação ignorada;
- cooldown ativo;
- planta não encontrada;
- comando inválido;
- erro de sincronização.

## 16. Testes

### 16.1 Single-player

- sulco normal;
- semeadura;
- rega;
- fertilização;
- colheita;
- cancelamento;
- falta de material;
- planta removida;
- save e reload.

### 16.2 Modo Host

Host:

- executa todas as ações;
- recebe XP correta;
- XP persiste;
- sem duplicação.

Convidado:

- executa todas as ações;
- recebe a própria XP;
- host não recebe XP indevida;
- progresso persiste após reconexão.

Interações simultâneas:

- host e convidado na mesma planta;
- dois jogadores tentando regar;
- ação cancelada;
- desconexão durante ação;
- reinício do Host após ação.

### 16.3 Save existente

- instalar com plantações em andamento;
- interagir com planta antiga;
- colher planta antiga;
- ausência de `modData`;
- desativar o mod;
- reabrir o save sem o mod.

### 16.4 Testes de exploit

- regar uma unidade por vez;
- criar e remover sulco;
- desconectar para tentar zerar cooldown;
- repetir ação rapidamente;
- enviar duas ações simultâneas;
- tentar obter XP de planta inexistente.

## 17. Matriz de testes

| Ação | Estado inicial | Resultado esperado |
|---|---|---|
| Criar sulco | tile vazio | XP |
| Criar sulco | sulco existente | sem XP |
| Semear | sulco vazio | XP |
| Semear | plantação existente | sem XP |
| Regar | planta seca | XP |
| Regar | planta cheia | sem XP |
| Regar | cooldown ativo | sem XP |
| Fertilizar | aplicação válida | XP |
| Fertilizar | aplicação sem efeito | sem XP |
| Colher | planta pronta | XP |
| Colher | planta já colhida | sem XP |
| Cancelar ação | qualquer | sem XP |

## 18. Roadmap

### 18.1 Versão 0.1.0 — Logging

- estrutura Project Zomboid Studio;
- carregamento do mod;
- hooks;
- logs das cinco ações;
- nenhum XP.

### 18.2 Versão 0.2.0 — Basic XP

- XP de sulco;
- XP de semeadura;
- XP de fertilização;
- XP de colheita;
- suporte ao host;
- suporte a convidados.

### 18.3 Versão 0.3.0 — Watering XP

- XP fixa de rega;
- cooldown por planta;
- persistência em `modData`;
- testes de repetição.

### 18.4 Versão 0.4.0 — Configuration

- arquivo central de configuração;
- multiplicador global;
- debug configurável;
- ações habilitáveis individualmente.

### 18.5 Versão 0.5.0 — Host Polish

- testes completos com convidados;
- correção de duplicações;
- instalação em save existente;
- tradução PT-BR;
- documentação.

### 18.6 Versão 1.0.0 — Stable Host Release

- opções Sandbox;
- README;
- changelog;
- poster;
- publicação privada ou não listada;
- dedicated server experimental.

## 19. Critérios de aceitação

A primeira versão estável estará pronta quando:

- carregar sem erros;
- funcionar em modo Host;
- host receber XP corretamente;
- convidados receberem XP corretamente;
- ações canceladas não concederem XP;
- rega sem efeito não conceder XP;
- XP não for duplicada;
- cooldown persistir;
- reinício do Host não apagar dados;
- instalação em save existente funcionar;
- remoção do mod não quebrar o save;
- logs permitirem diagnosticar problemas.

## 20. Estimativa de desenvolvimento

| Etapa | Estimativa |
|---|---:|
| Mapear ações B41 | 1 dia |
| Configurar Project Zomboid Studio | algumas horas |
| Criar hooks e logs | 1–2 dias |
| XP simples | 1 dia |
| Regar e cooldown | 1–2 dias |
| Testes no modo Host | 1–2 dias |
| Configuração e documentação | 1 dia |

Estimativa total:

```text
5 a 8 dias de trabalho parcial
```

A maior incerteza é a sincronização da rega entre cliente e Host.

## 21. Primeira tarefa de implementação

O primeiro recurso deve ser um sistema de diagnóstico.

Resultado esperado:

```text
[B41FIX] Furrow completed by becker at 8123,11670,0
[B41FIX] Sow completed by becker crop=Potatoes
[B41FIX] Water completed by becker amount=20
[B41FIX] Fertilize completed by becker
[B41FIX] Harvest completed by becker crop=Potatoes
```

Testar primeiro:

1. host executando ações;
2. convidado executando ações;
3. cancelamento;
4. reinício do Host;
5. reconexão;
6. planta antiga;
7. plantação nova.

Somente depois desses logs estarem corretos a XP deve ser implementada.

## 22. Direção técnica recomendada

A versão inicial deve ser pequena e previsível.

Prioridades:

```text
1. hooks confiáveis;
2. logs corretos;
3. XP concedida pelo Host;
4. ausência de duplicação;
5. rega com cooldown;
6. persistência mínima;
7. compatibilidade com save existente.
```

Dedicated server, novos cultivos e compatibilidade ampla devem permanecer como expansões futuras.

## 23. Organização das referências de terceiros

Os códigos fornecidos podem ser mantidos localmente para análise, mas não devem ser incluídos automaticamente no repositório público.

Estrutura recomendada:

```text
references/
└── VanillaAgricultureFix-B42/
```

Adicionar ao `.gitignore`:

```gitignore
references/VanillaAgricultureFix-B42/
```

Versionar apenas documentos produzidos durante a análise:

```text
docs/B42_BEHAVIOR_REFERENCE.md
docs/THIRD_PARTY_SOURCES.md
```

O arquivo `THIRD_PARTY_SOURCES.md` deve registrar:

- nome do mod;
- autor;
- Workshop ID;
- build;
- finalidade da consulta;
- política de uso;
- confirmação de que o código não integra o produto final sem autorização.

### Política de implementação

```text
Referência funcional e arquitetural: permitida para estudo privado.
Cópia ou adaptação direta: depende de autorização.
Código do nosso mod: implementação independente para B41.
```

## 24. Plano técnico revisado para o MVP

A ordem concreta passa a ser:

1. localizar as classes vanilla equivalentes na B41;
2. confirmar se as ações usam `complete()` ou `perform()`;
3. criar wrappers apenas para logging;
4. testar host e convidado;
5. confirmar `plant.owner`;
6. confirmar atualização de `waterLvl` no Host;
7. implementar sulco e semeadura;
8. implementar fertilização;
9. implementar rega;
10. preservar a XP vanilla de colheita inicialmente;
11. adicionar opções Sandbox somente após estabilizar os hooks.

### Primeiros experimentos obrigatórios

#### Experimento A — nomes das ações

Registrar em B41:

```text
classe
método chamado
resultado retornado
campos disponíveis em self
```

#### Experimento B — autoridade

Comparar logs para:

```text
host executando ação
convidado executando ação
cliente
servidor interno do Host
```

#### Experimento C — rega

Registrar:

```text
waterLvl antes
usesUsed
waterLvl imediatamente após complete()
waterLvl alguns ticks depois
valor observado pelo Host
```

#### Experimento D — dono da planta

Registrar:

```text
plant.owner
player:getOnlineID()
player:getPlayerNum()
player:getUsername()
```

para host e convidado.

#### Experimento E — XP vanilla

Medir:

```text
XP antes da colheita
saúde da planta
badCare
XP depois da colheita
```

Isso permitirá decidir se a redistribuição deve seguir a fórmula da B42 ou usar outro balanceamento.
