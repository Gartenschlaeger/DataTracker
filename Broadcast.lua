---@class DTCore
local _, core = ...

---@class DTBroadcast
local broadcast = {}
core.bc = broadcast

---New item was found
---@param itemId number
---@param itemName string
---@param itemQuality number
function broadcast.NewItem(self, itemId, itemName, itemQuality)
    core.logging:Info(core.i18n.NEW_ITEM .. ': ' .. itemName)
end

---New zone detected
---@param mapId number
---@param mapName string
function broadcast.NewMap(self, mapId, mapName)
    core.logging:Info(core.i18n.NEW_MAP .. ': ' .. mapName)
end

---New unit detected
---@param unitId number
---@param unitName string
function broadcast.NewUnit(self, unitId, unitName)
    core.logging:Info(core.i18n.NEW_UNIT .. ': ' .. unitName)
end
