---@class DTCore
local _, core = ...

---@class DTHelper
local helper = {}
core.helper = helper

---Returns the size for the given table
function helper:GetTableSize(table)
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
function helper:IfNil(value, defaultValue)
    if (value == nil) then
        return defaultValue
    end

    return value
end

---Converts a boolean value to a number (true = 1, false = 0)
function helper:BoolToNumber(booleanValue)
    if (booleanValue) then
        return 1
    end

    return 0
end

---Calculates the percentage for loot
---@param timesLooted number
---@param foundItems number
---@return number
function helper:CalculatePercentage(timesLooted, foundItems)
    if (not timesLooted or timesLooted <= 0) then
        return 0
    end

    local percentage = foundItems / timesLooted
    if (percentage > 1) then
        percentage = 1
    end

    return percentage
end

---Parses the item id from item link
---@param link string
---@return integer
function helper:GetItemIdFromLink(link)
    local id = link:match("item:(%d+):")
    if (id) then
        return tonumber(id, 10)
    end

    return -1
end

---Calculated the avarage gold amount for the given unit at given level.
---@param unitInfo table
---@param level number
---@return number|nil
function helper:CalculateAvgUnitGoldCount(unitInfo, level)
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
function helper:GetUnitIdFromGuid(guid)
    local id = select(6, strsplit('-', guid))
    return tonumber(id, 10)
end

---formats a percentage value
---@param percentage number percentage value between 1 and 100
---@return string
function helper:FormatPercentage(percentage)
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
