---@class DTCore
local _, core = ...

DT_Options = {}

local function Cleanup()
    DT_Options.ShowMinimapButton = nil
    DT_Options.Tooltip.ShowTrashItems = nil
end

local DEFAULT_MIN_ITEM_QUALITY_LEVEL = 2

---Initialization of options. Called once the addon is loading.
function core:InitOptions()
    if (DT_Options.MinLogLevel == nil) then
        DT_Options.MinLogLevel = core.logging.LogLevel.Info
    end

    DT_Options.Tooltip = DT_Options.Tooltip or {}

    DT_Options.Tooltip.ShowKills = core.helper:IfNil(DT_Options.Tooltip.ShowKills, false)
    DT_Options.Tooltip.ShowLooted = core.helper:IfNil(DT_Options.Tooltip.ShowLooted, false)

    DT_Options.Tooltip.ShowMoney = core.helper:IfNil(DT_Options.Tooltip.ShowMoney, true)
    DT_Options.Tooltip.ShowMoneyAvg = core.helper:IfNil(DT_Options.Tooltip.ShowMoneyAvg, true)
    DT_Options.Tooltip.ShowMoneyMM = core.helper:IfNil(DT_Options.Tooltip.ShowMoneyMM, false)

    DT_Options.Tooltip.ShowItems = core.helper:IfNil(DT_Options.Tooltip.ShowItems, true)
    DT_Options.Tooltip.ShowIcons = core.helper:IfNil(DT_Options.Tooltip.ShowIcons, false)

    DT_Options.Tooltip.MinQualityLevel = core.helper:IfNil(DT_Options.Tooltip.MinQualityLevel,
        DEFAULT_MIN_ITEM_QUALITY_LEVEL)

    if (DT_Options.Tooltip.MinQualityLevel < 0 or DT_Options.Tooltip.MinQualityLevel > 6) then
        DT_Options.Tooltip.MinQualityLevel = DEFAULT_MIN_ITEM_QUALITY_LEVEL
    end

    DT_Options.Tooltip.LimitItems = core.helper:IfNil(DT_Options.Tooltip.LimitItems, true)
    DT_Options.Tooltip.MaxItemsToShow = core.helper:IfNil(DT_Options.Tooltip.MaxItemsToShow, 25)
    DT_Options.Tooltip.ShowEquipmentItems = core.helper:IfNil(DT_Options.Tooltip.ShowEquipmentItems, false)
    DT_Options.Tooltip.ShowProfessionItems = core.helper:IfNil(DT_Options.Tooltip.ShowProfessionItems, true)

    Cleanup()
end
