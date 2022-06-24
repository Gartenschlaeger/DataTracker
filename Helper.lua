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

function DataTracker:CalculatePercentage(timesLooted, foundItems)
    if (timesLooted <= 0) then
        return 0
    end

    local percentage = foundItems / timesLooted
    if (percentage > 1) then
        percentage = 1
    end

    percentage = math.floor(percentage * 100)
    if (percentage < 1) then
        percentage = 1
    end

    return percentage
end

function DataTracker:FormatPercentage(percentage)
    if (percentage > 0) then
        return percentage .. '%'
    end

    return ''
end