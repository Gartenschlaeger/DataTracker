---@class DataTracker_Core
local DataTracker = select(2, ...)

---@class DataTracker_Helper
local helper = {}
DataTracker.helper = helper

---Returns the size for the given table
function helper.GetTableSize(self, table)
    local size = 0
    for _ in pairs(table) do
        size = size + 1
    end

    return size
end

---Returns value if not nil otherwise defaultValue
---@param value any
---@param defaultValue any
---@return any
function helper.IfNil(self, value, defaultValue)
    if (value == nil) then
        return defaultValue
    end

    return value
end

---Converts a boolean value to a number (true = 1, false = 0)
function helper.BoolToNumber(self, booleanValue)
    if (booleanValue) then
        return 1
    end

    return 0
end

---Calculates the percentage for loot
---@param timesLooted number
---@param foundItems number
---@return number
function helper.CalculatePercentage(self, timesLooted, foundItems)
    if (not timesLooted or timesLooted <= 0) then
        return 0
    end

    local percentage = foundItems / timesLooted
    if (percentage > 1) then
        percentage = 1
    end

    return percentage
end

---Returns the unit type from unit guid
---@param unitGuid string
---@return string
function helper.GetUnitTypeByGuid(self, unitGuid)
    -- Cast-[type]-[serverID]-[instanceID]-[zoneUID]-[spellID]-[castUID]
    return select(1, strsplit('-', unitGuid))
end

---Returns true if the unit should be tracked
---@param unitGuid string?
---@return boolean
function helper.IsTrackableUnit(self, unitGuid)
    if (unitGuid) then
        local type = self:GetUnitTypeByGuid(unitGuid)
        if (type == 'Creature' or type == 'Vehicle') then
            return true
        end
    end

    return false
end

---Parses the item id from item link
---@param link string
---@return number
function helper.GetItemIdFromLink(self, link)
    DataTracker.logging:Verbose('GetItemIdFromLink, link = ', link)

    if (link) then
        local _, _, idCode = string.find(link, "|Hitem:(%d*):(%d*):(%d*):")
        return tonumber(idCode) or -1
    end

    return -1
end

---Calculated the avarage gold amount for the given unit at given level.
---@param unitInfo table
---@param level number
---@return number|nil
function helper.CalculateAvgUnitGoldCount(self, unitInfo, level)
    local copperInfo = unitInfo.cpi
    if (not copperInfo) then
        return nil -- no copper info in general
    end

    local levelCopperInfo = nil

    if (level) then
        levelCopperInfo = copperInfo['l:' .. level]
    end

    -- fallback: none level based units e.g. boss
    if (levelCopperInfo == nil) then
        levelCopperInfo = copperInfo['_']
    end

    if (not levelCopperInfo) then
        return nil -- no copper info for level
    end

    local totalCopper = levelCopperInfo.tot
    local timesLooted = levelCopperInfo.ltd
    if (totalCopper > 0 and timesLooted > 0) then
        return math.floor(totalCopper / timesLooted)
    end

    return nil
end

---Converts UnitGuid to UnitID
---@param guid string
---@return integer
function helper.GetUnitIdFromGuid(self, guid)
    local id = select(6, strsplit('-', guid))
    return tonumber(id, 10)
end

---formats a percentage value
---@param percentage number percentage value between 1 and 100
---@return string
function helper.FormatPercentage(self, percentage)
    local result = ''
    if (percentage > 0) then
        local p = percentage * 100
        if (p < 1) then
            result = string.format('%.2f', p) .. ' %'
        else
            result = string.format('%u', p) .. ' %'
        end
    end

    return result
end

local mapInfoCache = {}

---Returns the mapname from map cache or nil, if map is not found.
---@param mapId number
---@return string|nil
function helper.GetMapNameById(self, mapId)
    local result = mapInfoCache[mapId]
    if (result == nil) then
        local mapInfo = C_Map.GetMapInfo(mapId)
        if (mapInfo) then
            mapInfoCache[mapId] = mapInfo.name
            result = mapInfo.name
        else
            DataTracker.logging:Warning('Could not find mapinfo for map id ' .. mapId)
        end
    end

    return result
end

local itemCache = {}

---Returns item informations from cache, or nil if no item with given id was found.
---@param itemId number
---@return table|nil
function helper.GetItemInfo(self, itemId)
    local itemInfo = itemCache[itemId]
    if (itemInfo == nil) then
        local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture, _, _, _, _, _, _, _ = GetItemInfo(itemId)
        if (itemName) then
            itemInfo = {
                name = itemName,
                quality = itemQuality,
                texture = itemTexture
            }

            itemCache[itemId] = itemInfo
        end
    end

    return itemInfo
end
