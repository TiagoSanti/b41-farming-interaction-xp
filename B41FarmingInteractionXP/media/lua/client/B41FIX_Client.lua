--- Client-side command dispatcher for B41 Farming Interaction XP.
--- Sends validated farming events to the Host for XP processing.
---
--- In Host mode and single-player the PZ engine routes sendClientCommand through
--- the internal server listener, so no special-casing is needed.
--- Phase 1 (v0.1.0): module defined but sendCmd is not yet called by the hooks.
--- Phase 2 (v0.2.0): hooks will call sendCmd for each completed action.

B41FIX = B41FIX or {}
B41FIX.Client = {}

local MODULE = "B41FarmingInteractionXP"

local function logInfo(msg, data)
    if B41FIX.Logger then
        B41FIX.Logger.info(msg, data)
    end
end

--- Sends a farming action event to the Host/server.
--- The server is responsible for validating plant state and granting XP.
--- Never pass the desired XP amount from the client - the server calculates it.
---@param character IsoPlayer  The player who performed the action.
---@param action    string     Action identifier: "furrow"|"sow"|"water"|"fertilize"|"harvest"
---@param x         integer    Grid X coordinate of the affected tile.
---@param y         integer    Grid Y coordinate of the affected tile.
---@param z         integer    Grid Z (floor) coordinate.
---@param extras    table?     Optional extra fields merged into the args table.
function B41FIX.Client.sendCmd(character, action, x, y, z, extras)
    local Logger = B41FIX.Logger
    if not character then
        if Logger then
            Logger.warn("sendCmd called with nil character", { action = action })
        end
        return
    end

    local args = { action = action, x = x, y = y, z = z }
    if extras then
        for k, v in pairs(extras) do
            args[k] = v
        end
    end

    if Logger then
        Logger.trace("Sending command to Host", { action = action, x = x, y = y, z = z })
    end
    sendClientCommand(character, MODULE, action, args)
end

local function onServerCommand(module, command, args)
    if module ~= MODULE or command ~= "syncFarmingXP" then return end

    local player = getPlayer()
    local xp = player and player.getXp and player:getXp() or nil
    local amount = tonumber(args and args.amount) or 0
    if not player or not xp or not xp.AddXP or amount <= 0 then
        return
    end

    xp:AddXP(Perks.Farming, amount, false, false, true)

    if ISPlayerStatsUI and ISPlayerStatsUI.instance and ISPlayerStatsUI.instance.loadPerks then
        ISPlayerStatsUI.instance:loadPerks()
    end

    logInfo("Client farming XP synced", {
        action = args and args.action or "unknown",
        amount = amount,
        total = xp.getXP and xp:getXP(Perks.Farming) or nil,
    })
end

Events.OnServerCommand.Add(onServerCommand)

if B41FIX.Logger then
    B41FIX.Logger.info("Client module loaded")
end

