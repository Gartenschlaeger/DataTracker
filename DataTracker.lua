---@class DataTracker_Core
local DataTracker = select(2, ...)

---Called when the addon is fully loaded and saved values are loaded from disk.
local function OnAddonLoaded(addonName)
    if (addonName == 'DataTracker') then
        DataTracker:InitOptions()
        DataTracker:InitOptionsPanel()
        DataTracker:InitSlashCommands()
        DataTracker:InitTooltipHooks()

        local itemsCount = DataTracker.helper:GetTableSize(DT_ItemDb)
        local unitsCount = DataTracker.helper:GetTableSize(DT_UnitDb)
        local loadingMessage = string.format(DataTracker.i18n.LOADING_MSG,
            FormatLargeNumber(itemsCount),
            FormatLargeNumber(unitsCount))

        DataTracker.logging:Info(loadingMessage)
    end
end

---Tracks general game related events
local function OnEvent(self, event, ...)
    --DataTracker:LogTrace('EVENT', event, ...)
    if (event == 'ADDON_LOADED') then
        OnAddonLoaded(...)
    elseif (event == 'PLAYER_TARGET_CHANGED') then
        DataTracker:OnTargetChanged()
    elseif (event == 'PLAYER_ENTERING_WORLD' or event == 'ZONE_CHANGED_NEW_AREA') then
        DataTracker.MapDb:TrackCurrentMap()
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

-- create a hidden frame to track game events
local eventsFrame = CreateFrame('Frame')
eventsFrame:RegisterEvent('ADDON_LOADED')
eventsFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
eventsFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
eventsFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
eventsFrame:RegisterEvent('LOOT_READY')
eventsFrame:RegisterEvent('LOOT_OPENED')
eventsFrame:RegisterEvent('LOOT_CLOSED')
eventsFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
eventsFrame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
eventsFrame:SetScript('OnEvent', OnEvent)
