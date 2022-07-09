local function Cleanup()
    DT_Options.ShowMinimapButton = nil
    DT_Options.Tooltip.ShowTrashItems = nil
end

local DEFAULT_MIN_ITEM_QUALITY_LEVEL = 2

---Initialization of options. Called once the addon is loading.
function DataTracker:InitOptions()
    if (DT_Options.MinLogLevel == nil) then
        DT_Options.MinLogLevel = DataTracker.LogLevel.Info
    end

    DT_Options.Tooltip = DT_Options.Tooltip or {}

    DT_Options.Tooltip.ShowKills = DataTracker:IfNil(DT_Options.Tooltip.ShowKills, false)
    DT_Options.Tooltip.ShowLooted = DataTracker:IfNil(DT_Options.Tooltip.ShowLooted, false)

    DT_Options.Tooltip.ShowMoney = DataTracker:IfNil(DT_Options.Tooltip.ShowMoney, true)
    DT_Options.Tooltip.ShowMoneyAvg = DataTracker:IfNil(DT_Options.Tooltip.ShowMoneyAvg, true)
    DT_Options.Tooltip.ShowMoneyMM = DataTracker:IfNil(DT_Options.Tooltip.ShowMoneyMM, false)

    DT_Options.Tooltip.ShowItems = DataTracker:IfNil(DT_Options.Tooltip.ShowItems, true)
    DT_Options.Tooltip.ShowIcons = DataTracker:IfNil(DT_Options.Tooltip.ShowIcons, false)

    DT_Options.Tooltip.MinQualityLevel = DataTracker:IfNil(DT_Options.Tooltip.MinQualityLevel,
        DEFAULT_MIN_ITEM_QUALITY_LEVEL)

    if (DT_Options.Tooltip.MinQualityLevel < 0 or DT_Options.Tooltip.MinQualityLevel > 6) then
        DT_Options.Tooltip.MinQualityLevel = DEFAULT_MIN_ITEM_QUALITY_LEVEL
    end

    Cleanup()
end
