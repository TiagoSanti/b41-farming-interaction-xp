--- Server-side handler for B41 Farming Interaction XP.
--- Listens for OnClientCommand events from the mod's client module.
--- Validates plant state and grants Farming XP to the requesting player.
---
--- Phase 1 (v0.1.0): receives and logs commands, no XP granted yet.
--- Phase 2 (v0.2.0): XP dispatch added per action handler below.
--- Phase 3 (v0.3.0): watering cooldown + modData added.

B41FIX = B41FIX or {}
B41FIX.Server = {}

local MODULE = "B41FarmingInteractionXP"

local function logInfo(msg, data)
    if B41FIX.Logger then
        B41FIX.Logger.info(msg, data)
    end
end

local function sendClientXpSync(player, amount, action)
    if not player or amount <= 0 then return end
    sendServerCommand(player, MODULE, "syncFarmingXP", {
        amount = amount,
        action = action,
    })
end

-- B41FIX.Logger, B41FIX.Util, B41FIX.Config are accessed directly via the global
-- table inside each function so that load-order is never a concern.

-- Plant lookup

--- Returns the SPlantGlobalObject at the given world coordinates, or nil.
--- Uses SGlobalObjectSystem:getLuaObjectAt() which is the standard B41 API.
---@param x integer
---@param y integer
---@param z integer
---@return SPlantGlobalObject?
local function getPlantAt(x, y, z)
    local system = SFarmingSystem.instance
    if not system then
        if B41FIX.Logger then B41FIX.Logger.warn("SFarmingSystem.instance is nil - cannot look up plant") end
        return nil
    end
    -- getLuaObjectAt is available on SGlobalObjectSystem (parent of SFarmingSystem)
    local ok, plant = pcall(function() return system:getLuaObjectAt(x, y, z) end)
    if not ok then
        if B41FIX.Logger then B41FIX.Logger.warn("getLuaObjectAt failed", { x = x, y = y, z = z }) end
        return nil
    end
    return plant
end

-- XP helper

--- Grants Farming XP to a player, scaled by the configured multipliers.
--- Prefers the B41/global addXp() path when available, then falls back to
--- Xp:AddXP() using a multiplayer-safe signature.
---@param player IsoPlayer
---@param amount number
---@param action string  Used only for logging.
local function grantXP(player, amount, action)
    local cfg = B41FIX.Config or {}
    local scaled = amount * (cfg.GlobalXPMultiplier or 1.0)
    local engineAmount = scaled * (cfg.EngineXPMultiplier or 1.0)
    if engineAmount <= 0 then return end

    if not player or not player.getXp then
        if B41FIX.Logger and B41FIX.Util then
            B41FIX.Logger.warn("XP grant skipped - player has no XP object", {
                to = B41FIX.Util.getPlayerUsername(player),
                action = action,
            })
        end
        return
    end

    local xp = player:getXp()
    if not xp then
        if B41FIX.Logger and B41FIX.Util then
            B41FIX.Logger.warn("XP grant skipped - XP object unavailable", {
                to = B41FIX.Util.getPlayerUsername(player),
                action = action,
            })
        end
        return
    end

    local before = nil
    local beforeLevel = nil
    if xp.getXP then
        before = xp:getXP(Perks.Farming)
    end
    if player.getPerkLevel then
        beforeLevel = player:getPerkLevel(Perks.Farming)
    end

    local method = nil
    local ok = false

    if addXp then
        ok = pcall(addXp, player, Perks.Farming, engineAmount)
        if ok then
            method = "addXp"
        end
    end

    if not ok and xp.AddXP then
        ok = pcall(function()
            xp:AddXP(Perks.Farming, engineAmount, false, false, true)
        end)
        if ok then
            method = "xp:AddXP(5 args)"
        end
    end

    if not ok and xp.AddXP then
        ok = pcall(function()
            xp:AddXP(Perks.Farming, engineAmount)
        end)
        if ok then
            method = "xp:AddXP(2 args)"
        end
    end

    if not ok then
        if B41FIX.Logger and B41FIX.Util then
            B41FIX.Logger.warn("XP grant skipped - no compatible XP API succeeded", {
                to = B41FIX.Util.getPlayerUsername(player),
                action = action,
                xp = engineAmount,
            })
        end
        return
    end

    if B41FIX.Logger and B41FIX.Util then
        local after = before
        local afterLevel = beforeLevel
        if xp.getXP then
            after = xp:getXP(Perks.Farming)
        end
        if player.getPerkLevel then
            afterLevel = player:getPerkLevel(Perks.Farming)
        end
        logInfo("XP granted", {
            to = B41FIX.Util.getPlayerUsername(player),
            action = action,
            xp = engineAmount,
            baseXp = amount,
            scaledXp = scaled,
            method = method,
            before = before,
            after = after,
            beforeLevel = beforeLevel,
            afterLevel = afterLevel,
        })
    end

    sendClientXpSync(player, engineAmount, action)
end

-- Action handlers (Phase 2 implementations)

--- Called when a player completes plowing a furrow.
---@param player IsoPlayer
---@param args table
local function handleFurrow(player, args)
    local cfg = B41FIX.Config or {}
    if not cfg.EnableFurrowXP then return end
    local plant = getPlantAt(args.x, args.y, args.z)
    if B41FIX.Util then
        logInfo("Furrow command accepted", {
            by = B41FIX.Util.getPlayerUsername(player),
            x = args.x,
            y = args.y,
            z = args.z,
        })
    end
    if not plant then
        if B41FIX.Logger then
            B41FIX.Logger.warn("Furrow XP skipped - plant plot not found", args)
        end
        return
    end
    grantXP(player, cfg.FurrowXP, "furrow")
end

--- Called when a player completes sowing a seed.
---@param player IsoPlayer
---@param args table
local function handleSow(player, args)
    local cfg = B41FIX.Config or {}
    if not cfg.EnableSowingXP then return end
    local plant = getPlantAt(args.x, args.y, args.z)
    if B41FIX.Util then
        logInfo("Sow command accepted", {
            by = B41FIX.Util.getPlayerUsername(player),
            crop = args.crop or "unknown",
            x = args.x,
            y = args.y,
            z = args.z,
        })
    end
    if not plant then
        if B41FIX.Logger then
            B41FIX.Logger.warn("Sow XP skipped - plant not found", args)
        end
        return
    end
    local crop = plant.typeOfSeed or args.crop
    if not crop or crop == "unknown" then
        if B41FIX.Logger then
            B41FIX.Logger.warn("Sow XP skipped - typeOfSeed missing", args)
        end
        return
    end
    grantXP(player, cfg.SowingXP, "sow")
end

--- Called when a player completes watering a plant.
---@param player IsoPlayer
---@param args table
local function handleWater(player, args)
    local cfg = B41FIX.Config or {}
    if not cfg.EnableWateringXP then return end
    local plant = getPlantAt(args.x, args.y, args.z)
    if B41FIX.Util then
        logInfo("Water command accepted", {
            by = B41FIX.Util.getPlayerUsername(player),
            usesConsumed = args.usesConsumed or 0,
            x = args.x,
            y = args.y,
            z = args.z,
        })
    end
    if not plant then
        if B41FIX.Logger then
            B41FIX.Logger.warn("Water XP skipped - plant not found", args)
        end
        return
    end
    if (args.usesConsumed or 0) <= 0 then
        if B41FIX.Logger then
            B41FIX.Logger.warn("Water XP skipped - no water consumed", args)
        end
        return
    end

    local Util = B41FIX.Util
    if not Util then
        return
    end
    local md = Util.getModData(plant)
    local now = Util.getGameHour()
    local last = md.lastWaterRewardHour or -9999
    local cooldown = cfg.WateringCooldownHours or 0
    if now >= 0 and cooldown > 0 and (now - last) < cooldown then
        if B41FIX.Logger then
            B41FIX.Logger.info("Water XP skipped - cooldown active", {
                by = Util.getPlayerUsername(player),
                x = args.x,
                y = args.y,
                z = args.z,
                hoursRemaining = cooldown - (now - last),
            })
        end
        return
    end

    md.lastWaterRewardHour = now
    grantXP(player, cfg.WateringXP, "water")
end

--- Called when a player completes fertilizing a plant.
---@param player IsoPlayer
---@param args table
local function handleFertilize(player, args)
    local cfg = B41FIX.Config or {}
    if not cfg.EnableFertilizeXP then return end
    local plant = getPlantAt(args.x, args.y, args.z)
    if B41FIX.Util then
        logInfo("Fertilize command accepted", {
            by = B41FIX.Util.getPlayerUsername(player),
            x = args.x,
            y = args.y,
            z = args.z,
        })
    end
    if not plant then
        if B41FIX.Logger then
            B41FIX.Logger.warn("Fertilize XP skipped - plant not found", args)
        end
        return
    end
    if not plant.fertilizer or plant.fertilizer <= 0 then
        if B41FIX.Logger then
            B41FIX.Logger.warn("Fertilize XP skipped - fertilizer state not updated", args)
        end
        return
    end
    grantXP(player, cfg.FertilizeXP, "fertilize")
end

--- Called when a player completes harvesting a plant.
--- Vanilla harvest XP from SFarmingSystem.gainXp is preserved in the MVP.
---@param player IsoPlayer
---@param args table
local function handleHarvest(player, args)
    local cfg = B41FIX.Config or {}
    if not cfg.EnableHarvestXP then return end
    if B41FIX.Util then
        logInfo("Harvest command accepted", {
            by = B41FIX.Util.getPlayerUsername(player),
            crop = args.crop or "unknown",
            x = args.x,
            y = args.y,
            z = args.z,
        })
    end
    -- Phase 2 (optional): HarvestBonusXP defaults to 0, so this is a no-op until tuned.
    -- if cfg.HarvestBonusXP > 0 then grantXP(player, cfg.HarvestBonusXP, "harvest") end
end

-- Dispatch table

local HANDLERS = {
    furrow    = handleFurrow,
    sow       = handleSow,
    water     = handleWater,
    fertilize = handleFertilize,
    harvest   = handleHarvest,
}

-- OnClientCommand listener

---@param module  string
---@param command string
---@param player  IsoPlayer
---@param args    table
local function onClientCommand(module, command, player, args)
    if module ~= MODULE then return end

    if B41FIX.Logger and B41FIX.Util then
        local username = B41FIX.Util.getPlayerUsername(player)
        logInfo("Command received", {
            cmd = command,
            by  = username,
            x   = args.x,
            y   = args.y,
            z   = args.z,
        })
    end

    local handler = HANDLERS[command]
    if handler then
        handler(player, args)
    else
        if B41FIX.Logger and B41FIX.Util then
            B41FIX.Logger.warn("Unknown command ignored", {
                cmd = command,
                by  = B41FIX.Util.getPlayerUsername(player),
            })
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)

if B41FIX.Logger then
    B41FIX.Logger.info("Server module loaded - listening for module '" .. MODULE .. "'")
end


