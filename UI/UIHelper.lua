---@class DTCore
local _, core = ...

---@class DT_UI
local ui = {}
core.ui = ui

---Creates a Checkbox control
---@param panel Frame
---@param x number
---@param y number
---@param text string
---@param initialValue any
---@param callback function
function ui:AddCheckbox(panel, x, y, text, initialValue, callback)
    local checkbox = CreateFrame("CheckButton", nil, panel, 'InterfaceOptionsCheckButtonTemplate')

    ---@diagnostic disable-next-line: undefined-field
    checkbox.Text:SetText(text)

    checkbox:SetPoint("TOPLEFT", x, y)

    checkbox:SetChecked(initialValue)
    checkbox.SetValue = function(_, value)
        callback(tonumber(value) == 1)
    end

    return checkbox
end
