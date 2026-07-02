--- Utility functions for B41 Farming Interaction XP.
--- Used by both client and server modules.

B41FIX = B41FIX or {}
B41FIX.Util = {}

local MOD_KEY = "B41FIX"
local SCHEMA_VERSION = 1

--- Returns the username of a player, or "unknown" if unavailable.
---@param player IsoPlayer
---@return string
function B41FIX.Util.getPlayerUsername(player)
    if player and player.getUsername then
        return player:getUsername() or "unknown"
    end
    return "unknown"
end

--- Returns x, y, z from an IsoGridSquare, or 0, 0, 0 on nil.
---@param square IsoGridSquare
---@return integer, integer, integer
function B41FIX.Util.getSquareCoords(square)
    if not square then return 0, 0, 0 end
    return square:getX(), square:getY(), square:getZ()
end

--- Returns x, y, z from a plant's underlying IsoObject, or 0, 0, 0 on failure.
--- Works for both CPlantGlobalObject (client) and SPlantGlobalObject (server).
---@param plant table
---@return integer, integer, integer
function B41FIX.Util.getPlantCoords(plant)
    if not plant then return 0, 0, 0 end
    local ok, obj = pcall(function() return plant:getObject() end)
    if not ok or not obj then return 0, 0, 0 end
    local sq = obj:getSquare()
    if not sq then return 0, 0, 0 end
    return sq:getX(), sq:getY(), sq:getZ()
end

--- Returns the mod-data sub-table for a plant (server-side SPlantGlobalObject).
--- Initialises missing fields with safe defaults so callers never get nil.
---@param plant SPlantGlobalObject
---@return table
function B41FIX.Util.getModData(plant)
    if not plant or not plant.getModData then return {} end
    local md = plant:getModData()
    if not md[MOD_KEY] then
        md[MOD_KEY] = {
            schemaVersion        = SCHEMA_VERSION,
            lastWaterRewardHour  = -9999,
            fertilizeRewardCount = 0,
            harvestRewarded      = false,
        }
    end
    return md[MOD_KEY]
end

--- Returns the in-game hour from the world calendar, or -1 on failure.
---@return integer
function B41FIX.Util.getGameHour()
    local cal = getGameTime and getGameTime()
    if cal and cal.getWorldAgeHours then
        return cal:getWorldAgeHours()
    end
    return -1
end

if B41FIX.Logger then
    B41FIX.Logger.debug("Util module loaded")
end
