function DataTracker:InitOptionsPanel()
	local panel = CreateFrame("Frame")
	panel.name = "DataTracker"

    -- debug logs checkbox
	DataTracker:AddCheckbox(panel, 20, -20, DataTracker.i18n.OP_DEBUG_LOGS,
        DT_Options.MinLogLevel == DataTracker.LogLevel.Debug, function(isEnabled)
            if (isEnabled) then
                DT_Options.MinLogLevel = DataTracker.LogLevel.Debug
            else
                DT_Options.MinLogLevel = DataTracker.LogLevel.Info
            end
        end)

    -- tooltip
    DataTracker:AddCheckbox(panel, 20, -65, DataTracker.i18n.OP_TT_SHOW_KILLS,
        DT_Options.Tooltip.ShowKills, function(isEnabled)
            DT_Options.Tooltip.ShowKills = isEnabled
        end)

    DataTracker:AddCheckbox(panel, 20, -90, DataTracker.i18n.OP_TT_SHOW_LOOTED,
        DT_Options.Tooltip.ShowLooted, function(isEnabled)
            DT_Options.Tooltip.ShowLooted = isEnabled
        end)

    DataTracker:AddCheckbox(panel, 20, -115, DataTracker.i18n.OP_TT_SHOW_MONEY,
        DT_Options.Tooltip.ShowMoney, function(isEnabled)
            DT_Options.Tooltip.ShowMoney = isEnabled
        end)

    DataTracker:AddCheckbox(panel, 20, -140, DataTracker.i18n.OP_TT_SHOW_ITEMS,
        DT_Options.Tooltip.ShowItems, function(isEnabled)
            DT_Options.Tooltip.ShowItems = isEnabled
        end)

    DataTracker:AddCheckbox(panel, 20, -165, DataTracker.i18n.OP_TT_SHOW_TRASH_ITEMS,
        DT_Options.Tooltip.ShowTrashItems, function(isEnabled)
            DT_Options.Tooltip.ShowTrashItems = isEnabled
        end)

	InterfaceOptions_AddCategory(panel)
end