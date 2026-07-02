--- Logging module for B41 Farming Interaction XP.
--- Requires B41FIX_Config.lua to be loaded first (alphabetical load order guarantees this).
--- DEBUG and TRACE messages are suppressed when Config.DebugLogging is false.

B41FIX = B41FIX or {}
B41FIX.Logger = {}

local PREFIX = "[B41FIX] "

---@param level string
---@return boolean
local function shouldLog(level)
    if level == "DEBUG" or level == "TRACE" then
        return B41FIX.Config ~= nil and B41FIX.Config.DebugLogging == true
    end
    return true
end

---@param level string
---@param msg string
---@param data table?
local function log(level, msg, data)
    if not shouldLog(level) then return end
    local line = PREFIX .. "[" .. level .. "] " .. tostring(msg)
    if data then
        local parts = {}
        for k, v in pairs(data) do
            parts[#parts + 1] = tostring(k) .. "=" .. tostring(v)
        end
        if #parts > 0 then
            line = line .. " {" .. table.concat(parts, ", ") .. "}"
        end
    end
    print(line)
end

---@param msg string
---@param data table?
function B41FIX.Logger.error(msg, data) log("ERROR", msg, data) end

---@param msg string
---@param data table?
function B41FIX.Logger.warn(msg, data) log("WARN", msg, data) end

---@param msg string
---@param data table?
function B41FIX.Logger.info(msg, data) log("INFO", msg, data) end

---@param msg string
---@param data table?
function B41FIX.Logger.debug(msg, data) log("DEBUG", msg, data) end

---@param msg string
---@param data table?
function B41FIX.Logger.trace(msg, data) log("TRACE", msg, data) end

B41FIX.Logger.info("Logger initialised")
