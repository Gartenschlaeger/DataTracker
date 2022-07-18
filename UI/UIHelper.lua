---@class DataTracker_Core
local DataTracker = select(2, ...)

---@class DataTracker_UIHelper
local ui = {}
DataTracker.ui = ui

---Creates a Checkbox control
---@param panel Frame
---@param x number
---@param y number
---@param text string
---@param initialValue any
---@param callback function
function ui.AddCheckbox(self, panel, x, y, text, initialValue, callback)
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
