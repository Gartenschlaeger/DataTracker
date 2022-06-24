function DataTracker:InitOptionsPanel()
	local panel = CreateFrame("Frame")
	panel.name = "DataTracker"

    -- debug logs checkbox
	local cbDebugLogs = DataTracker:AddCheckbox(panel, 20, -20, 'Debug logs',
        function(isEnabled)
            if (isEnabled) then
                DT_Options.MinLogLevel = DataTracker.LogLevel.Debug
                DataTracker:LogInfo('Debug logs enabled')
            else
                DT_Options.MinLogLevel = DataTracker.LogLevel.Info
                DataTracker:LogInfo('Debug logs disabled')
            end
        end)

    -- local cbMinimap = DataTracker:AddCheckbox(panel, 20, -45, 'Show minimap button',
    --     function(isEnabled)
    --         DT_Options.ShowMinimapButton = isEnabled
    --     end)

    -- initial values
    cbDebugLogs:SetChecked(DT_Options.MinLogLevel == DataTracker.LogLevel.Debug)
    --cbMinimap:SetChecked(DT_Options.ShowMinimapButton)

	InterfaceOptions_AddCategory(panel)
end