--- Central configuration for B41 Farming Interaction XP.
--- Loaded in shared/ so both client and server have access to defaults.
--- SandboxVars overrides are applied here once they are added (v0.4.0+).

B41FIX = B41FIX or {}

B41FIX.Config = {
    -- Per-action toggles
    EnableFurrowXP    = true,
    EnableSowingXP    = true,
    EnableWateringXP  = true,
    EnableFertilizeXP = true,
    EnableHarvestXP   = true,

    -- XP awarded by the Host for each action (base values before engine multiplier).
    -- These defaults mirror the VanillaAgricultureFix action values.
    -- HarvestBonusXP = 0 means vanilla harvest XP is fully preserved.
    FurrowXP       = 1.0,
    SowingXP       = 2.0,
    WateringXP     = 2.0,
    FertilizeXP    = 4.0,
    HarvestBonusXP = 0.0,

    -- Minimum in-game hours between watering XP rewards for the same plant.
    WateringCooldownHours = 6,

    -- Multiplier applied to all mod-granted XP (does not affect vanilla XP).
    GlobalXPMultiplier = 1.0,

    -- Extra scale can be applied before handing the value to B41's XP system.
    EngineXPMultiplier = 1.0,

    -- Print DEBUG/TRACE messages to the PZ console. Set false for release.
    DebugLogging = true,
}
