---@class DTCore
local _, core = ...

---@class DTBroadcast
local broadcast = {}
core.bc = broadcast

---New item found
---@param text string
function broadcast:NewItem(text)
    core.logging:Info(text)
end

---New zone detected
---@param text string
function broadcast:NewZone(text)
    core.logging:Info(text)
end

---New unit detected
---@param text string
function broadcast:NewUnit(text)
    core.logging:Info(text)
end
