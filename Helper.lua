-- Returns the size for the given table.
function DT_TableSize(table)
    local size = 0
    for _ in pairs(table) do
        size = size + 1
    end

    return size
end

-- Creates a Checkbox control
function DT_AddCheckbox(panel, x, y, text, callback)
    local checkbox = CreateFrame("CheckButton", nil, panel, 'InterfaceOptionsCheckButtonTemplate')
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox.Text:SetText(text)
    checkbox.SetValue = function(_, value)
        callback(tonumber(value) == 1)
    end

    return checkbox
end

function DT_BoolToNumber(booleanValue)
    if (booleanValue) then
        return 1
    end

    return 0
end