---@class DTCore
local _, core = ...

---Called when the addon is fully loaded and saved values are loaded from disk.
local function OnAddonLoaded(addonName)
    if (addonName == 'DataTracker') then
        core:InitOptions()
        core:InitOptionsPanel()
        core:InitSlashCommands()
        core:InitTooltipHooks()

        local itemsCount = core.helper:GetTableSize(DT_ItemDb)
        local unitsCount = core.helper:GetTableSize(DT_UnitDb)
        local loadingMessage = string.format(core.i18n.LOADING_MSG,
            FormatLargeNumber(itemsCount),
            FormatLargeNumber(unitsCount))

        core.logging:Info(loadingMessage)
    end
end

---Tracks general game related events
local function OnEvent(self, event, ...)
    core.logging:Trace('EVENT', event, ...)

    if (event == 'ADDON_LOADED') then
        OnAddonLoaded(...)
    elseif (event == 'PLAYER_TARGET_CHANGED') then
        core:OnTargetChanged()
    elseif (event == 'ZONE_CHANGED_NEW_AREA') then
        core:UpdateCurrentZone()
    elseif (event == 'UNIT_SPELLCAST_SUCCEEDED') then
        core:OnUnitSpellcastSucceeded(...)
    elseif (event == 'LOOT_OPENED') then
        core:OnLootReady()
    elseif (event == 'LOOT_CLOSED') then
        core:OnLootClosed()
    elseif (event == 'COMBAT_LOG_EVENT_UNFILTERED') then
        core:OnCombatLogEventUnfiltered()
    end
end

-- create a hidden frame to track game events
local eventsFrame = CreateFrame('Frame')
eventsFrame:RegisterEvent('ADDON_LOADED')
eventsFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
eventsFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
eventsFrame:RegisterEvent('LOOT_READY')
eventsFrame:RegisterEvent('LOOT_OPENED')
eventsFrame:RegisterEvent('LOOT_CLOSED')
eventsFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
eventsFrame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
eventsFrame:SetScript('OnEvent', OnEvent)
