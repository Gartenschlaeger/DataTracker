function DataTracker:GetTableSize(table)
    local size = 0
    for _ in pairs(table) do
        size = size + 1
    end

    return size
end

function DataTracker:BoolToNumber(booleanValue)
    if (booleanValue) then
        return 1
    end

    return 0
end

---Calculates the percentage for loot
---@param timesLooted number
---@param foundItems number
---@return number
function DataTracker:CalculatePercentage(timesLooted, foundItems)
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
function DataTracker:FormatPercentage(percentage)
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
