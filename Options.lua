-- Initialisation of options. Called when the addon is loaded once
function DataTracker:InitOptions()
    if (DT_Options.MinLogLevel == nil) then
       DT_Options.MinLogLevel = DataTracker.LogLevel.Info
    end
    if (DT_Options.ShowMinimapButton == nil) then
        DT_Options.ShowMinimapButton = true
    end
end