-- Returns the size for the given table.
function DT_TableSize(table)
    local size = 0
    for _ in pairs(table) do
        size = size + 1
    end

    return size
end

-- Creates a Checkbox control
function DT_AddCheckbox(panel, x, y, text)
    local checkbox = CreateFrame("CheckButton", nil, panel, 'InterfaceOptionsCheckButtonTemplate')
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox.Text:SetText(text)
    return checkbox
end