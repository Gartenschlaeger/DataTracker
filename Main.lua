DataTracker = {}

-- Addon options
DT_Options = {}

-- Called when the addon is fully loaded and saved values are loaded from disk.
function DataTracker:OnAddonLoaded(addonName)
    if (addonName == 'DataTracker') then
        local itemsCount = DataTracker:GetTableSize(DT_ItemDb)
        local unitsCount = DataTracker:GetTableSize(DT_UnitDb)

        DataTracker:InitOptions()
        DataTracker:InitOptionsPanel()
        DataTracker:InitSlashCommands()
        DataTracker:InitTooltipHooks()

        local loadingMessage = string.format(DataTracker.i18n.LOADING_MSG, itemsCount, unitsCount)
        DataTracker:LogInfo(loadingMessage)
    end
end

function DataTracker.OnEvent(self, event, ...)
    --DataTracker:LogTrace('EVENT', event, ...)
    if (event == 'ADDON_LOADED') then
        DataTracker:OnAddonLoaded(...)
    elseif (event == 'PLAYER_TARGET_CHANGED') then
        DataTracker:OnTargetChanged()
    elseif (event == 'ZONE_CHANGED_NEW_AREA') then
        DataTracker:UpdateCurrentZone()
    elseif (event == 'UNIT_SPELLCAST_SUCCEEDED') then
        DataTracker:OnUnitSpellcastSucceeded(...)
    elseif (event == 'LOOT_READY') then
        DataTracker:OnLootReady()
    elseif (event == 'LOOT_CLOSED') then
        DataTracker:OnLootClosed()
    elseif (event == 'COMBAT_LOG_EVENT_UNFILTERED') then
        DataTracker:OnCombatLogEventUnfiltered()
    end
end

local f = CreateFrame('Frame')
f:RegisterEvent('ADDON_LOADED')
f:RegisterEvent('PLAYER_TARGET_CHANGED')
f:RegisterEvent('ZONE_CHANGED_NEW_AREA')
f:RegisterEvent('LOOT_READY')
f:RegisterEvent('LOOT_OPENED')
f:RegisterEvent('LOOT_CLOSED')
f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
f:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
f:SetScript('OnEvent', DataTracker.OnEvent)
