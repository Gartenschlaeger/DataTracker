-- Creates a Checkbox control
function DataTracker:AddCheckbox(panel, x, y, text, initialValue, callback)
    local checkbox = CreateFrame("CheckButton", nil, panel, 'InterfaceOptionsCheckButtonTemplate')
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox.Text:SetText(text)
    checkbox:SetChecked(initialValue)
    checkbox.SetValue = function(_, value)
        callback(tonumber(value) == 1)
    end

    return checkbox
end
