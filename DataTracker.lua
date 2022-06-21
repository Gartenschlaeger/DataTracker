-- Current ZoneId. If nil call to UpdateCurrentZone() is needed
DataTracker.CurrentZoneId = nil

-- Initialisation of options. Called when the addon is loaded once
local function InitOptions()
    if (DT_Options.MinLogLevel == nil) then
       DT_Options.MinLogLevel = DataTracker.LogLevel.Info
    end
    if (DT_Options.ShowMinimapButton == nil) then
        DT_Options.ShowMinimapButton = true
    end
end

local function InitOptionsPanel()
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

    local cbMinimap = DataTracker:AddCheckbox(panel, 20, -45, 'Show minimap button',
        function(isEnabled)
            DT_Options.ShowMinimapButton = isEnabled
        end)

    -- initial values
    cbDebugLogs:SetChecked(DT_Options.MinLogLevel == DataTracker.LogLevel.Debug)
    cbMinimap:SetChecked(DT_Options.ShowMinimapButton)

	InterfaceOptions_AddCategory(panel)
end

-- Called when the addon is fully loaded and saved values are loaded from disk.
local function OnAddonLoaded(addonName)
    if (addonName == 'DataTracker') then
        local itemsCount = DataTracker:GetTableSize(DT_ItemDb)
        local unitsCount = DataTracker:GetTableSize(DT_UnitDb)

        InitOptions()
        InitOptionsPanel()
        DataTracker:InitSlashCommands()
        DataTracker:InitTooltipHooks()

        DataTracker:LogInfo('DataTracker loaded, ' .. itemsCount .. ' items, ' .. unitsCount .. ' units')
    end
end

-- Returns the itemId by slot link
local function GetLootId(itemSlot)
	local link = GetLootSlotLink(itemSlot)
	if link then
        DataTracker:LogVerbose('GetLootId, link = ', link)
		local _, _, idCode = string.find(link, "|Hitem:(%d*):(%d*):(%d*):")
		return tonumber(idCode) or -1
	end

	return 0
end

local function ResolveUnitClassificationId(unitClassification)
    local classificationId = DT_UnitClassifications[unitClassification]
    if (classificationId == nil) then
        classificationId = 1000 + DataTracker:GetTableSize(DT_UnitClassifications)
        DT_UnitClassifications[unitClassification] = classificationId
        DataTracker:LogDebug('New classification ' .. unitClassification .. ' (' .. classificationId .. ')')
    end

    return classificationId
end

-- Called when a mob was killed and should be stored to db
local function MobKill(unitId, unitName)
    DataTracker:LogTrace('MobKill', unitId, unitName)

    if (DataTracker.CurrentZoneId == nil) then
        DataTracker:UpdateCurrentZone()
    end

    -- get unit info
    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    -- update kill counter
    local kills = unitInfo['kls']
    if (kills == nil) then
        kills = 1
    else
        kills = kills + 1
    end
    unitInfo['kls'] = kills

    -- update zones
    local zones = unitInfo['zns']
    if (zones == nil) then
        zones = {}
        unitInfo['zns'] = zones
    end

    -- update zone kills counter
    local zoneKills = zones[DataTracker.CurrentZoneId]
    if (zoneKills == nil) then
        zoneKills = 1
    else
        zoneKills = zoneKills + 1
    end
    zones[DataTracker.CurrentZoneId] = zoneKills

    DataTracker:LogDebug('MobKill: ' .. unitName .. ' (ID = ' .. unitId .. '), total kills = ' .. kills)
end

-- Increments the loot counter for the given unitId
local function IncrementLootCounter(unitId)
    DataTracker:LogTrace('IncrementLootCounter', unitId)

    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        DataTracker:LogWarning('Cannot find unit with id ' .. unitId)
        return
    end

    DataTracker:LogDebug('LootCount: ' .. unitInfo['nam'] .. ' (ID = ' .. unitId .. ')')

    unitInfo['ltd'] = (unitInfo['ltd'] or 0) + 1
end

-- Called when copper was looted and should be added to db
local function AddGold(unitId, lootedCopper)
    DataTracker:LogVerbose('AddGold', unitId, lootedCopper)

    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    local currentCopper = tonumber(unitInfo['cop']) or 0
    local newCopper = currentCopper + lootedCopper
    DataTracker:LogVerbose('AddGold', unitInfo['nam'], currentCopper, ' -> ', newCopper)

    unitInfo['cop'] = newCopper

    DataTracker:LogDebug('AddGold: ' .. lootedCopper .. ', (' .. unitInfo['nam'] .. ' ID = ' .. unitId .. ')')
end

-- Called when a new item was looted and should be added to db
local function AddItem(itemId, itemName, itemQuantity, itemQuality, unitId)
    DataTracker:LogVerbose('AddItem', itemId, itemName, itemQuantity, itemQuality, unitId)

    -- store item info
    local itemInfo = DT_ItemDb[itemId]
    if (itemInfo == nil) then
        itemInfo = {}
        DT_ItemDb[itemId] = itemInfo

        DataTracker:LogInfo(DataTracker.l18n.NEW_ITEM .. ': ' .. itemName)
    end

    itemInfo['nam'] = itemName
    itemInfo['qlt'] = itemQuality

    local lootedCounter = itemInfo['ltd']
    if (lootedCounter == nil) then
        lootedCounter = itemQuantity
    else
        lootedCounter = lootedCounter + itemQuantity
    end
    itemInfo['ltd'] = lootedCounter

    -- store loot info
    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    local unitItemsInfo = unitInfo['its']
    if (unitItemsInfo == nil) then
        unitItemsInfo = {}
        unitInfo['its'] = unitItemsInfo
    end

    local unitItemLootedCounter = unitItemsInfo[itemId]
    if (unitItemLootedCounter == nil) then
        unitItemLootedCounter = itemQuantity
    else
        unitItemLootedCounter = unitItemLootedCounter + itemQuantity
    end
    unitItemsInfo[itemId] = unitItemLootedCounter

    DataTracker:LogDebug('AddItem: ' .. itemQuantity .. ' ' .. itemName .. ' (ID = ' .. itemId .. '), ' .. unitInfo['nam'] .. ' (ID = ' .. unitId .. ')')
end

-- Occures when the target changes, used to store unit id and name
local function OnTargetChanged()
    DataTracker:LogTrace('OnTargetChanged')

    if (UnitIsPlayer('target') or not UnitCanAttack('player', 'target')) then
        DataTracker:LogVerbose('Ignore none attackable target')
        return
    end

    local unitGuid = UnitGUID("target")
    local unitName = UnitName("target")

    if (unitGuid == nil or unitName == nil) then
        return
    end

    local unitType = select(1, strsplit('-', unitGuid))
    if (unitType == 'Creature') then
        local unitId = DataTracker:UnitGuidToId(unitGuid)

        local mobInfo = DT_UnitDb[unitId]
        if (mobInfo == nil) then
            mobInfo = {}
            DT_UnitDb[unitId] = mobInfo

            DataTracker:LogInfo(DataTracker.l18n.NEW_UNIT .. ': ' .. unitName)
        end

        local classification = UnitClassification('target')

        mobInfo['nam'] = unitName
        mobInfo['clf'] = ResolveUnitClassificationId(classification)
    end
end

local function ParseMoneyFromLootName(lootName)
    local startIndex = 0
    local lootedCopper = 0

    startIndex = string.find(lootName, ' ' .. DataTracker.l18n.GOLD)
    if startIndex then
        local g = tonumber(string.sub(lootName,0,startIndex-1)) or 0
		lootName = string.sub(lootName,startIndex+5,string.len(lootName))
		lootedCopper = lootedCopper + ((g or 0) * COPPER_PER_GOLD)
        DataTracker:LogVerbose('ParseMoneyFromLootName, Processing Gold', g)
	end

	startIndex = string.find(lootName, ' ' .. DataTracker.l18n.SILVER)
	if startIndex then
		local s = tonumber(string.sub(lootName,0,startIndex-1)) or 0
		lootName = string.sub(lootName,startIndex+7,string.len(lootName))
		lootedCopper = lootedCopper + ((s or 0) * COPPER_PER_SILVER)
        DataTracker:LogVerbose('ParseMoneyFromLootName, Processing Silver', s)
	end

	startIndex = string.find(lootName, ' ' .. DataTracker.l18n.COPPER)
	if startIndex then
		local c = tonumber(string.sub(lootName,0,startIndex-1)) or 0
		lootedCopper = lootedCopper + (c or 0)
        DataTracker:LogVerbose('ParseMoneyFromLootName, Processing Copper', c)
	end

	return lootedCopper
end

-- Holds information if looting has already been started
local isLooting = false

-- Holds the looting informations for units already looted to avoid to collect it twice
local tmp_lootedUnits = {}

-- Called when loot window is open and loot is ready
local function OnLootReady()
    DataTracker:LogTrace('OnLootReady')

    -- ignore if event is already handled
    if (isLooting) then
        return
    end
    isLooting = true

    -- ensure current zone id is set
    if (DataTracker.CurrentZoneId == nil) then
        DataTracker:UpdateCurrentZone()
    end

    for itemSlot = 1, GetNumLootItems() do
        local lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questId = GetLootSlotInfo(itemSlot)
        local slotType = GetLootSlotType(itemSlot)

        if (slotType == LOOT_SLOT_ITEM) then
            local itemId = currencyID
            if (itemId == nil) then
                itemId = GetLootId(itemSlot)
            end

            local sources = {GetLootSourceInfo(itemSlot)}
            for sourceIndex = 1, #sources, 2
            do
                local unitGuid = sources[sourceIndex]
                local unitId = DataTracker:UnitGuidToId(sources[sourceIndex])

                local sourceType = select(1, strsplit("-", unitGuid))
                if sourceType == 'Creature' then

                    local lootingInfos = tmp_lootedUnits[unitGuid]
                    local hasAlreadyTracked = lootingInfos ~= nil

                    if (lootingInfos == nil) then
                        lootingInfos = {
                            ['unitId'] = unitId,
                            ['time'] = GetTime(),
                            ['items'] = {},
                        }

                        tmp_lootedUnits[unitGuid] = lootingInfos
                    end

                    local lootedItems = lootingInfos['items']
                    if (lootedItems[itemId] == nil) then
                        local sourceQuantity = tonumber(sources[sourceIndex + 1])
                        if (unitId and unitId > 0) then
                            if (not isQuestItem) then
                                AddItem(itemId, lootName, sourceQuantity, lootQuality, unitId)
                            end

                            lootedItems[itemId] = sourceQuantity

                            if (not hasAlreadyTracked) then
                                IncrementLootCounter(unitId)
                            end
                        end
                    end

                end
            end

        -- 2: LOOT_SLOT_MONEY - Gold/silver/copper coin
        elseif (slotType == LOOT_SLOT_MONEY) then
            local lootedCopper = ParseMoneyFromLootName(lootName)
            if (lootedCopper) then
                DataTracker:LogVerbose('LOOT_SLOT_MONEY', lootedCopper)

                local sources = {GetLootSourceInfo(itemSlot)}
                for j = 1, #sources, 2
                do
                    local guidType = select(1, strsplit("-", sources[j]))
                    if guidType == 'Creature' then
                        local unitId = DataTracker:UnitGuidToId(sources[j])
                        if (unitId and unitId > 0 and not isQuestItem) then
                            AddGold(unitId, lootedCopper)
                        end
                    end
                end
            end
        end
    end
end

local function OnLootClosed()
    DataTracker:LogVerbose('OnLootClosed')

    isLooting = false

    -- cleanup looted units table
    local currentTime = GetTime()
    for unitGuid, info in pairs(tmp_lootedUnits) do
        if (currentTime - info.time > 60) then
            tmp_lootedUnits[unitGuid] = nil
            DataTracker:LogVerbose('Cleaned up looted unit ' .. unitGuid)
        end
    end

    DataTracker:LogVerbose('lootedUnits size:', DataTracker:GetTableSize(tmp_lootedUnits))
end

-- Temporarilly storage of UnitId <-> IsLooting mapping to remove duplicates in looting db
local AttackedUnits = {}

-- Occures for any combat log
local function OnCombatLogEventUnfiltered()
    local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags,
        damage_spellid, overkill_spellname, school_spellSchool, resisted_amount,
        blocked_overkill = CombatLogGetCurrentEventInfo()

    if destGUID ~= nil
	then
		local guidType = select(1, strsplit("-", destGUID))
        local isDamageSubEvent = subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE';
        local isPlayerAttack = sourceGUID == UnitGUID('player')
        local isPetAttack = sourceGUID == UnitGUID('pet')

        DataTracker:LogVerbose('OnCombatLogEventUnfiltered', subEvent, sourceGUID, sourceName, destGUID, destName)

        if (isDamageSubEvent and (isPlayerAttack or isPetAttack)) then
            AttackedUnits[destGUID] = true
        elseif (subEvent=="PARTY_KILL") then
            AttackedUnits[destGUID] = true
	    elseif (subEvent == 'UNIT_DIED' and guidType == "Creature" and AttackedUnits[destGUID] == true) then
            AttackedUnits[destGUID] = nil
            local unitId = DataTracker:UnitGuidToId(destGUID)
            MobKill(unitId, destName)
        end
	end
end

-- Updates the current zone id
function DataTracker:UpdateCurrentZone()
    DataTracker:LogTrace('UpdateCurrentZone')

    local zoneText = GetZoneText()
    if (not zoneText or zoneText == '') then
        DataTracker:LogWarning('Invalid ZoneText, text = "' .. zoneText .. '"')
        return
    end

	-- find zone ID in db if already known
	local zoneId = nil
	for id, name in pairs(DT_ZoneDb) do
		if zoneText == name then
			zoneId = id
            DataTracker:LogVerbose('Found existing match for Zone in db, zoneId = ' .. zoneId .. ', zoneText = ' .. zoneText)
			break
		end
	end

	-- if zone is unknown add it to db
	if zoneId == nil then
        zoneId = 1000 + DataTracker:GetTableSize(DT_ZoneDb)
        DataTracker:LogVerbose('Write new ZoneText to db, zoneId = ' .. zoneId .. ', zoneText = ' .. zoneText)
		DT_ZoneDb[zoneId] = zoneText

        DataTracker:LogInfo(DataTracker.l18n.NEW_ZONE .. ': ' .. zoneText)
	end

	DataTracker.CurrentZoneId = zoneId
    DataTracker:LogDebug('Changed zone to ' .. zoneText .. ' (ID = ' .. zoneId .. ')')
end

local function OnEvent(self, event, ...)
    --DataTracker:LogTrace('EVENT', event, ...)
    if (event == 'ADDON_LOADED') then
        OnAddonLoaded(...)
    elseif (event == 'PLAYER_TARGET_CHANGED') then
        OnTargetChanged()
    elseif (event == 'ZONE_CHANGED_NEW_AREA') then
        DataTracker:UpdateCurrentZone()
    elseif (event == 'LOOT_READY') then
        OnLootReady()
    elseif (event == 'LOOT_CLOSED') then
        OnLootClosed()
    elseif (event == 'COMBAT_LOG_EVENT_UNFILTERED') then
        OnCombatLogEventUnfiltered()
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
f:SetScript('OnEvent', OnEvent)