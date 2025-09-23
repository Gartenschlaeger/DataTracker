---@class DTCore
local _, core = ...

function core:InitOptionsPanel()
    local panel = CreateFrame("Frame")
    panel.name = "DataTracker"

    local category = Settings.RegisterCanvasLayoutCategory(panel, "DataTracker")
    category.ID = "DataTracker"
    Settings.RegisterAddOnCategory(category)

    -- general
    local titleGeneral = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    titleGeneral:SetText("Allgemeines")
    titleGeneral:SetPoint("TOPLEFT", 12, -15)

    core.ui:AddCheckbox(panel, 10, -40, core.i18n.OP_DEBUG_LOGS,
        DT_Options.MinLogLevel == core.logging.LogLevel.Debug, function(isEnabled)
            if (isEnabled) then
                DT_Options.MinLogLevel = core.logging.LogLevel.Debug
            else
                DT_Options.MinLogLevel = core.logging.LogLevel.Info
            end
        end)

    -- tooltip
    local titleTooltip = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    titleTooltip:SetText("Tooltip")
    titleTooltip:SetPoint("TOPLEFT", 12, -95)

    core.ui:AddCheckbox(panel, 10, -120, core.i18n.OP_TT_SHOW_KILLS,
        DT_Options.Tooltip.ShowKills,
        function(isEnabled)
            DT_Options.Tooltip.ShowKills = isEnabled
        end)

    core.ui:AddCheckbox(panel, 10, -150, core.i18n.OP_TT_SHOW_LOOTED,
        DT_Options.Tooltip.ShowLooted,
        function(isEnabled)
            DT_Options.Tooltip.ShowLooted = isEnabled
        end)

    -- money --

    local cbAvgGold = core.ui:AddCheckbox(panel, 25, -210, core.i18n.OP_TT_SHOW_MONEY_AVG,
        DT_Options.Tooltip.ShowMoneyAvg,
        function(isEnabled)
            DT_Options.Tooltip.ShowMoneyAvg = isEnabled
        end)

    local cbMMGold = core.ui:AddCheckbox(panel, 25, -240, core.i18n.OP_TT_SHOW_MONEY_MM,
        DT_Options.Tooltip.ShowMoneyMM,
        function(isEnabled)
            DT_Options.Tooltip.ShowMoneyMM = isEnabled
        end)

    core.ui:AddCheckbox(panel, 10, -180, core.i18n.OP_TT_SHOW_MONEY,
        DT_Options.Tooltip.ShowMoney,
        function(isEnabled)
            DT_Options.Tooltip.ShowMoney = isEnabled
            cbAvgGold:SetEnabled(isEnabled)
            cbMMGold:SetEnabled(isEnabled)
        end)

    -- items --

    local cbShowIcons = core.ui:AddCheckbox(panel, 25, -300, core.i18n.OP_TT_SHOW_ICONS,
        DT_Options.Tooltip.ShowIcons,
        function(isEnabled)
            DT_Options.Tooltip.ShowIcons = isEnabled
        end)

    core.ui:AddCheckbox(panel, 10, -270, core.i18n.OP_TT_SHOW_ITEMS,
        DT_Options.Tooltip.ShowItems,
        function(isEnabled)
            DT_Options.Tooltip.ShowItems = isEnabled
            cbShowIcons:SetEnabled(isEnabled)
        end)

    -- min item quality level
    local lblMinQualityItems = panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
    lblMinQualityItems:SetText(core.i18n.OP_TT_MIN_ITEM_QLT)
    lblMinQualityItems:SetPoint("TOPLEFT", 30, -340)

    local ddMinItemQuality = CreateFrame("Frame", nil, panel, "UIDropDownMenuTemplate")
    ddMinItemQuality:SetPoint('TOPLEFT', 13, -355)
    UIDropDownMenu_SetWidth(ddMinItemQuality, 130)

    local function SetMinQualityLevelText(minQualityLevel)
        local _, _, _, hex = GetItemQualityColor(minQualityLevel)
        local t = '|c' .. hex .. _G['ITEM_QUALITY' .. minQualityLevel .. '_DESC']
        UIDropDownMenu_SetText(ddMinItemQuality, t)
    end

    local function OnMinItemQualityLevelItemClicked(self, minQualityLevel)
        SetMinQualityLevelText(minQualityLevel)
        DT_Options.Tooltip.MinQualityLevel = minQualityLevel
    end

    UIDropDownMenu_Initialize(ddMinItemQuality, function(dropDown, level, menuList)
        for qualityLevel = 0, 6 do
            local _, _, _, hex = GetItemQualityColor(qualityLevel)
            local item = UIDropDownMenu_CreateInfo();
            item.text = '|c' .. hex .. _G['ITEM_QUALITY' .. qualityLevel .. '_DESC'];
            item.value = qualityLevel;
            item.arg1 = qualityLevel
            item.func = OnMinItemQualityLevelItemClicked
            item.checked = DT_Options.Tooltip.MinQualityLevel == qualityLevel;
            UIDropDownMenu_AddButton(item, level);
        end
    end)

    SetMinQualityLevelText(DT_Options.Tooltip.MinQualityLevel)
end
