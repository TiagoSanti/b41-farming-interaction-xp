--- Action hooks for B41 Farming Interaction XP.
--- Wraps the relevant B41 farming timed actions and forwards successful
--- interactions to the Host for authoritative XP handling.

B41FIX = B41FIX or {}
B41FIX.Hooks = B41FIX.Hooks or {}

require "Farming/TimedActions/ISPlowAction"
require "Farming/TimedActions/ISSeedAction"
require "Farming/TimedActions/ISWaterPlantAction"
require "Farming/TimedActions/ISFertilizeAction"
require "Farming/TimedActions/ISHarvestPlantAction"

-- Resolve shared modules lazily inside hook bodies. In B41, client files can be
-- evaluated before every shared file has finished loading.

-- Some B41 timed-action classes inherit perform()/start() only from the base
-- prototype. Accessing the method from the class table can therefore return nil.
local function safeOrig(fn)
    return fn or function() return true end
end

local function logInfo(msg, data)
    if B41FIX.Logger then
        B41FIX.Logger.info(msg, data)
    end
end

local function installHooksReport()
    logInfo("Action hooks installation pass finished", {
        plow = B41FIX.Hooks.plowInstalled == true,
        sow = B41FIX.Hooks.sowInstalled == true,
        water = B41FIX.Hooks.waterInstalled == true,
        fertilize = B41FIX.Hooks.fertilizeInstalled == true,
        harvest = B41FIX.Hooks.harvestInstalled == true,
    })
end

Events.OnGameBoot.Add(installHooksReport)
Events.OnCreatePlayer.Add(installHooksReport)
installHooksReport()

-- ISPlowAction

if not B41FIX.Hooks.plowInstalled then
    B41FIX.Hooks.plowInstalled = true

    local _orig = safeOrig(ISPlowAction.perform)
    function ISPlowAction:perform()
        local result = _orig(self)
        local Logger = B41FIX.Logger
        local Util = B41FIX.Util
        if Logger and Util then
            local username = Util.getPlayerUsername(self.character)
            local x, y, z = Util.getSquareCoords(self.gridSquare)
            logInfo("Furrow completed", { by = username, x = x, y = y, z = z })
            if B41FIX.Client and B41FIX.Client.sendCmd then
                B41FIX.Client.sendCmd(self.character, "furrow", x, y, z)
            end
        end
        return result
    end
end

-- ISSeedAction

if not B41FIX.Hooks.sowInstalled then
    B41FIX.Hooks.sowInstalled = true

    local _orig = safeOrig(ISSeedAction.perform)
    function ISSeedAction:perform()
        local result = _orig(self)
        local Logger = B41FIX.Logger
        local Util = B41FIX.Util
        if Logger and Util then
            local username = Util.getPlayerUsername(self.character)
            local crop = self.typeOfSeed or "unknown"
            local x, y, z = 0, 0, 0
            if self.plant then
                x, y, z = Util.getPlantCoords(self.plant)
            end
            logInfo("Sow completed", { by = username, crop = crop, x = x, y = y, z = z })
            if B41FIX.Client and B41FIX.Client.sendCmd then
                B41FIX.Client.sendCmd(self.character, "sow", x, y, z, { crop = crop })
            end
        end
        return result
    end
end

-- ISWaterPlantAction

if not B41FIX.Hooks.waterInstalled then
    B41FIX.Hooks.waterInstalled = true

    local _origStart = safeOrig(ISWaterPlantAction.start)
    function ISWaterPlantAction:start()
        self._b41fix_preUses = self.usesUsed or 0
        _origStart(self)
    end

    local _origPerform = safeOrig(ISWaterPlantAction.perform)
    function ISWaterPlantAction:perform()
        local result = _origPerform(self)
        local Logger = B41FIX.Logger
        local Util = B41FIX.Util
        if Logger and Util then
            local username = Util.getPlayerUsername(self.character)
            local pre = self._b41fix_preUses or 0
            local post = self.usesUsed or self.uses or 0
            local delta = post - pre
            local x, y, z = Util.getSquareCoords(self.sq)
            logInfo("Water completed", {
                by = username,
                usesConsumed = delta,
                x = x,
                y = y,
                z = z,
            })
            if delta > 0 and B41FIX.Client and B41FIX.Client.sendCmd then
                B41FIX.Client.sendCmd(self.character, "water", x, y, z, { usesConsumed = delta })
            end
        end
        return result
    end
end

-- ISFertilizeAction

if not B41FIX.Hooks.fertilizeInstalled then
    B41FIX.Hooks.fertilizeInstalled = true

    local _orig = safeOrig(ISFertilizeAction.perform)
    function ISFertilizeAction:perform()
        local result = _orig(self)
        local Logger = B41FIX.Logger
        local Util = B41FIX.Util
        if Logger and Util then
            local username = Util.getPlayerUsername(self.character)
            local x, y, z = 0, 0, 0
            if self.plant then
                x, y, z = Util.getPlantCoords(self.plant)
            end
            logInfo("Fertilize completed", { by = username, x = x, y = y, z = z })
            if B41FIX.Client and B41FIX.Client.sendCmd then
                B41FIX.Client.sendCmd(self.character, "fertilize", x, y, z)
            end
        end
        return result
    end
end

-- ISHarvestPlantAction

if not B41FIX.Hooks.harvestInstalled then
    B41FIX.Hooks.harvestInstalled = true

    local _orig = safeOrig(ISHarvestPlantAction.perform)
    function ISHarvestPlantAction:perform()
        local result = _orig(self)
        local Logger = B41FIX.Logger
        local Util = B41FIX.Util
        if Logger and Util then
            local username = Util.getPlayerUsername(self.character)
            local crop = (self.plant and self.plant.typeOfSeed) or "unknown"
            local x, y, z = 0, 0, 0
            if self.plant then
                x, y, z = Util.getPlantCoords(self.plant)
            end
            logInfo("Harvest completed", { by = username, crop = crop, x = x, y = y, z = z })
            if B41FIX.Client and B41FIX.Client.sendCmd then
                B41FIX.Client.sendCmd(self.character, "harvest", x, y, z, { crop = crop })
            end
        end
        return result
    end
end

if B41FIX.Logger then
    B41FIX.Logger.info("All action hooks installed")
end
