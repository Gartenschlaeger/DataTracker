-- Initialisation of options. Called when the addon is loaded once
function DataTracker:InitOptions()
    if (DT_Options.MinLogLevel == nil) then
        DT_Options.MinLogLevel = DataTracker.LogLevel.Info
    end

    DT_Options.Tooltip = DT_Options.Tooltip or {}
    DT_Options.Tooltip.ShowKills = DT_Options.Tooltip.ShowKills or true
    DT_Options.Tooltip.ShowLooted = DT_Options.Tooltip.ShowLooted or true
    DT_Options.Tooltip.ShowMoney = DT_Options.Tooltip.ShowMoney or true
    DT_Options.Tooltip.ShowItems = DT_Options.Tooltip.ShowItems or true

    DT_Options.Tooltip.ShowTrashItems = nil
    if (DT_Options.Tooltip.MinQualityLevel == nil) then
        DT_Options.Tooltip.MinQualityLevel = 2
    end
    if (DT_Options.Tooltip.MinQualityLevel < 0 or DT_Options.Tooltip.MinQualityLevel > 6) then
        DT_Options.Tooltip.MinQualityLevel = 2
    end
end
