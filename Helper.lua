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
