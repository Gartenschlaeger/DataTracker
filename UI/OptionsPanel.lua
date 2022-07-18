---@class DataTracker_Core
local DataTracker = select(2, ...)

DT_Options = {}

local DEFAULT_MIN_ITEM_QUALITY_LEVEL = 1

---Initialization of options. Called once the addon is loading.
function DataTracker.InitOptions(self)
    if (DT_Options.MinLogLevel == nil) then
        DT_Options.MinLogLevel = DataTracker.logging.LogLevel.Info
    end

    DT_Options.Tooltip = DT_Options.Tooltip or {}

    DT_Options.Tooltip.ShowKills = DataTracker.helper:IfNil(DT_Options.Tooltip.ShowKills, true)
    DT_Options.Tooltip.ShowLooted = DataTracker.helper:IfNil(DT_Options.Tooltip.ShowLooted, false)

    DT_Options.Tooltip.ShowMoney = DataTracker.helper:IfNil(DT_Options.Tooltip.ShowMoney, true)
    DT_Options.Tooltip.ShowMoneyAvg = DataTracker.helper:IfNil(DT_Options.Tooltip.ShowMoneyAvg, true)
    DT_Options.Tooltip.ShowMoneyMM = DataTracker.helper:IfNil(DT_Options.Tooltip.ShowMoneyMM, false)

    DT_Options.Tooltip.ShowItems = DataTracker.helper:IfNil(DT_Options.Tooltip.ShowItems, true)
    DT_Options.Tooltip.ShowIcons = DataTracker.helper:IfNil(DT_Options.Tooltip.ShowIcons, true)

    DT_Options.Tooltip.MinQualityLevel = DataTracker.helper:IfNil(DT_Options.Tooltip.MinQualityLevel,
        DEFAULT_MIN_ITEM_QUALITY_LEVEL)

    if (DT_Options.Tooltip.MinQualityLevel < 0 or DT_Options.Tooltip.MinQualityLevel > 6) then
        DT_Options.Tooltip.MinQualityLevel = DEFAULT_MIN_ITEM_QUALITY_LEVEL
    end
end

function DataTracker.InitOptionsPanel(self)
    local panel = CreateFrame("Frame")
    panel.name = "DataTracker"

    ---@diagnostic disable-next-line: undefined-global
    InterfaceOptions_AddCategory(panel)

    -- general
    local titleGeneral = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    titleGeneral:SetText("Allgemeines")
    titleGeneral:SetPoint("TOPLEFT", 12, -15)

    DataTracker.ui:AddCheckbox(panel, 10, -40, DataTracker.i18n.OP_DEBUG_LOGS,
        DT_Options.MinLogLevel == DataTracker.logging.LogLevel.Debug, function(isEnabled)
        if (isEnabled) then
            DT_Options.MinLogLevel = DataTracker.logging.LogLevel.Debug
        else
            DT_Options.MinLogLevel = DataTracker.logging.LogLevel.Info
        end
    end)

    -- tooltip
    local titleTooltip = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    titleTooltip:SetText("Tooltip")
    titleTooltip:SetPoint("TOPLEFT", 12, -95)

    DataTracker.ui:AddCheckbox(panel, 10, -120, DataTracker.i18n.OP_TT_SHOW_KILLS,
        DT_Options.Tooltip.ShowKills,
        function(isEnabled)
            DT_Options.Tooltip.ShowKills = isEnabled
        end)

    DataTracker.ui:AddCheckbox(panel, 10, -150, DataTracker.i18n.OP_TT_SHOW_LOOTED,
        DT_Options.Tooltip.ShowLooted,
        function(isEnabled)
            DT_Options.Tooltip.ShowLooted = isEnabled
        end)

    -- money --

    local cbAvgGold = DataTracker.ui:AddCheckbox(panel, 25, -210, DataTracker.i18n.OP_TT_SHOW_MONEY_AVG,
        DT_Options.Tooltip.ShowMoneyAvg,
        function(isEnabled)
            DT_Options.Tooltip.ShowMoneyAvg = isEnabled
        end)

    local cbMMGold = DataTracker.ui:AddCheckbox(panel, 25, -240, DataTracker.i18n.OP_TT_SHOW_MONEY_MM,
        DT_Options.Tooltip.ShowMoneyMM,
        function(isEnabled)
            DT_Options.Tooltip.ShowMoneyMM = isEnabled
        end)

    DataTracker.ui:AddCheckbox(panel, 10, -180, DataTracker.i18n.OP_TT_SHOW_MONEY,
        DT_Options.Tooltip.ShowMoney,
        function(isEnabled)
            DT_Options.Tooltip.ShowMoney = isEnabled
            cbAvgGold:SetEnabled(isEnabled)
            cbMMGold:SetEnabled(isEnabled)
        end)

    -- items --

    local cbShowIcons = DataTracker.ui:AddCheckbox(panel, 25, -300, DataTracker.i18n.OP_TT_SHOW_ICONS,
        DT_Options.Tooltip.ShowIcons,
        function(isEnabled)
            DT_Options.Tooltip.ShowIcons = isEnabled
        end)

    DataTracker.ui:AddCheckbox(panel, 10, -270, DataTracker.i18n.OP_TT_SHOW_ITEMS,
        DT_Options.Tooltip.ShowItems,
        function(isEnabled)
            DT_Options.Tooltip.ShowItems = isEnabled
            cbShowIcons:SetEnabled(isEnabled)
        end)

    -- min item quality level
    local lblMinQualityItems = panel:CreateFontString("ARTWORK", nil, "GameFontNormal")
    lblMinQualityItems:SetText(DataTracker.i18n.OP_TT_MIN_ITEM_QLT)
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
