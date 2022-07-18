---@class DataTracker_Core
local DataTracker = select(2, ...)

---@class DataTracker_Broadcast
local broadcast = {}
DataTracker.bc = broadcast

---New item was found
---@param itemId number
---@param itemName string
---@param itemQuality number
function broadcast.NewItem(self, itemId, itemName, itemQuality)
    DataTracker.logging:Info(DataTracker.i18n.NEW_ITEM .. ': ' .. itemName)
end

---New zone detected
---@param mapId number
---@param mapName string
function broadcast.NewMap(self, mapId, mapName)
    DataTracker.logging:Info(DataTracker.i18n.NEW_MAP .. ': ' .. mapName)
end

---New unit detected
---@param unitId number
---@param unitName string
function broadcast.NewUnit(self, unitId, unitName)
    DataTracker.logging:Info(DataTracker.i18n.NEW_UNIT .. ': ' .. unitName)
end
