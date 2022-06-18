-- Item database
DT_ItemDb = {}

-- Unit database
DT_UnitDb = {}

-- Zones database
DT_ZoneDb = {}

-- Addon options
DT_Options = {}
DT_Options['MinLogLevel'] = DT_LogLevel.None

-- Current ZoneId. If nil call to DT_UpdateCurrentZone() is needed
DT_CURRENT_ZONE_ID = nil

-- Holds information if looting has already started because the event LOOT_READY occures multiple times
DT_LootingStarted = false

-- Returns the size for the given table.
function DT_TableSize(table)
    local size = 0
    for _ in pairs(table) do
        size = size + 1
    end

    return size
end

-- Initialisation of options. Called when the addon is loaded once
function DT_InitOptions()
    DT_Options['MinLogLevel'] = DT_LogLevel.Debug
end

-- Called when the addon is fully loaded and saved values are loaded from disk.
function DT_AddonLoaded(addonName)
    if (addonName == 'DataTracker') then
        local itemsCount = DT_TableSize(DT_ItemDb)
        local unitsCount = DT_TableSize(DT_UnitDb)

        DT_InitOptions()

        DT_LogInfo('DataTracker loaded, ' .. itemsCount .. ' items, ' .. unitsCount .. ' units')
    end
end

-- Converts a unit guid to an id
function DT_UnitGuidToId(unitGuid)
    return tonumber(select(6, strsplit('-', unitGuid)), 10)
end

-- Returns the itemId by slot link
function DT_GetLootId(itemSlot)
	local link = GetLootSlotLink(itemSlot)
	if link then
        DT_LogVerbose('DT_GetLootId, link = ', link)
		local _, _, idCode = string.find(link, "|Hitem:(%d*):(%d*):(%d*):")
		return tonumber(idCode) or -1
	end

	return 0
end

-- Called when a mob was killed and should be stored to db
function DT_MobKill(unitId, unitName)
    DT_LogTrace('DT_MobKill', unitId, unitName)

    if (DT_CURRENT_ZONE_ID == nil) then
        DT_UpdateCurrentZone()
    end

    -- get unit info
    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    -- update kill counter
    local kills = unitInfo['kills']
    if (kills == nil) then
        kills = 1
    else
        kills = kills + 1
    end
    unitInfo['kills'] = kills

    -- update zones
    local zones = unitInfo['zones']
    if (zones == nil) then
        zones = {}
        unitInfo['zones'] = zones
    end

    -- update zone kills counter
    local zoneKills = zones[DT_CURRENT_ZONE_ID]
    if (zoneKills == nil) then
        zoneKills = 1
    else
        zoneKills = zoneKills + 1
    end
    zones[DT_CURRENT_ZONE_ID] = zoneKills

    DT_LogDebug('Kill: ' .. unitName .. ' (' .. unitId .. '), total times killed: ' .. kills)
end

-- Called when copper was looted and should be added to db
function DT_AddGold(unitId, lootedCopper)
    DT_LogVerbose('DT_AddGold', unitId, lootedCopper)

    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    local currentCopper = tonumber(unitInfo['copper'])
    local newCopper = currentCopper + lootedCopper
    DT_LogVerbose('DT_AddGold', unitInfo.name, currentCopper, ' -> ', newCopper)

    unitInfo['copper'] = newCopper

    DT_LogDebug('Copper: ', unitInfo.name, ', total copper:', newCopper)
end

-- Called when a new item was looted and should be added to db
function DT_AddItem(itemId, itemName, itemQuantity, itemQuality, unitId)
    DT_LogVerbose('DT_AddItem', itemId, itemName, itemQuantity, itemQuality, unitId)

    -- store item info
    local itemInfo = DT_ItemDb[itemId]
    if (itemInfo == nil) then
        itemInfo = {}
        DT_ItemDb[itemId] = itemInfo
    end

    itemInfo['name'] = itemName
    itemInfo['quality'] = itemQuality

    local lootedCounter = itemInfo['looted']
    if (lootedCounter == nil) then
        lootedCounter = itemQuantity
    else
        lootedCounter = lootedCounter + itemQuantity
    end
    itemInfo['looted'] = lootedCounter

    -- store loot info
    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    local unitLootedInfo = unitInfo['looted']
    if (unitLootedInfo == nil) then
        unitLootedInfo = {}
        unitInfo['looted'] = unitLootedInfo
    end

    local unitItemLootedCounter = unitLootedInfo[itemId]
    if (unitItemLootedCounter == nil) then
        unitItemLootedCounter = itemQuantity
    else
        unitItemLootedCounter = unitItemLootedCounter + itemQuantity
    end
    unitLootedInfo[itemId] = unitItemLootedCounter

    DT_LogDebug('Item: ' .. itemName .. ' (' .. itemId .. '), total times looted: ' .. lootedCounter)
end

-- Occures when the target changes, used to store unit id and name
function DT_TargetChanged()
    DT_LogTrace('DT_TargetChanged')

    if (UnitIsPlayer('target') or not UnitCanAttack('player', 'target')) then
        DT_LogVerbose('Ignore none attackable target')
        return
    end

    local unitGuid = UnitGUID("target")
    local unitName = UnitName("target")

    if (unitGuid == nil or unitName == nil) then
        return
    end

    local unitType = select(1, strsplit('-', unitGuid))
    if (unitType == 'Creature') then
        local unitId = DT_UnitGuidToId(unitGuid)

        local mobInfo = DT_UnitDb[unitId]
        if (mobInfo == nil) then
            mobInfo = {}
            DT_UnitDb[unitId] = mobInfo
        end

        mobInfo['name'] = unitName
    end
end

function DT_ParseMoneyFromLootName(lootName)
    local startIndex = 0
    local lootedCopper = 0

    startIndex = string.find(lootName, ' ' .. DT_TXT_GOLD)
    if startIndex then
        local g = tonumber(string.sub(lootName,0,startIndex-1)) or 0
		lootName = string.sub(lootName,startIndex+5,string.len(lootName))
		lootedCopper = lootedCopper + ((g or 0) * COPPER_PER_GOLD)
        DT_LogVerbose('DT_ParseCopperFromLootnameText, Processing Gold', g)
	end

	startIndex = string.find(lootName, ' ' .. DT_TXT_SILVER)
	if startIndex then
		local s = tonumber(string.sub(lootName,0,startIndex-1)) or 0
		lootName = string.sub(lootName,startIndex+7,string.len(lootName))
		lootedCopper = lootedCopper + ((s or 0) * COPPER_PER_SILVER)
        DT_LogVerbose('DT_ParseCopperFromLootnameText, Processing Silver', s)
	end

	startIndex = string.find(lootName, ' ' .. DT_TXT_COPPER)
	if startIndex then
		local c = tonumber(string.sub(lootName,0,startIndex-1)) or 0
		lootedCopper = lootedCopper + (c or 0)
        DT_LogVerbose('DT_ParseCopperFromLootnameText, Processing Copper', c)
	end

	return lootedCopper
end

function DT_LootReady()
    DT_LogTrace('DT_LootReady')

    if (DT_LootingStarted) then
        return
    end

    DT_LootingStarted = true

    -- ensure current zone id is set
    if (DT_CURRENT_ZONE_ID == nil) then
        DT_UpdateCurrentZone()
    end

    for itemSlot = 1, GetNumLootItems() do
        local _, lootName, lootQuantity, currencyID, lootQuality, locked, 
            isQuestItem, questId = GetLootSlotInfo(itemSlot)

        local slotType = GetLootSlotType(itemSlot)
        -- 0: LOOT_SLOT_NONE - No contents

        -- 1: LOOT_SLOT_ITEM - A regular item
        if (slotType == LOOT_SLOT_ITEM) then
            local itemId = currencyID
            if (itemId == nil) then
                itemId = DT_GetLootId(itemSlot)
            end

            if (true) then
                DT_LogVerbose('--- > sources')
                local sources = {GetLootSourceInfo(itemSlot)}
                for j = 1, #sources, 2
                do
                    local guidType = select(1, strsplit("-", sources[j]))
                    if guidType == 'Creature' then
                        local unitId = DT_UnitGuidToId(sources[j])
                        if (unitId and unitId > 0 and not isQuestItem) then
                            DT_AddItem(itemId, lootName, lootQuantity, lootQuality, unitId)
                        end
                    end
                end
                DT_LogVerbose('--- < sources')
            end

        -- 2: LOOT_SLOT_MONEY - Gold/silver/copper coin
        elseif (slotType == LOOT_SLOT_MONEY) then
            local lootedCopper = DT_ParseMoneyFromLootName(lootName)
            if (lootedCopper) then
                DT_LogVerbose('LOOT_SLOT_MONEY', lootedCopper)

                local sources = {GetLootSourceInfo(itemSlot)}
                for j = 1, #sources, 2
                do
                    local guidType = select(1, strsplit("-", sources[j]))
                    if guidType == 'Creature' then
                        local unitId = DT_UnitGuidToId(sources[j])
                        if (unitId and unitId > 0 and not isQuestItem) then
                            DT_AddGold(unitId, lootedCopper)
                        end
                    end
                end
            end
        else
            DT_LogVerbose('Ignore item, slot type:', slotType)
        end
    end
end

function DT_LootOpened()
    DT_LogTrace('DT_LootOpened')
end

function DT_LootClosed()
    DT_LogTrace('DT_LootClosed')

    DT_LootingStarted = false
end

-- Temporarilly storage of UnitId <-> IsLooting mapping to remove duplicates in looting db
DT_AttackedUnits = {}

function DT_CombatLogEventUnfiltered()
    local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags,
        damage_spellid, overkill_spellname, school_spellSchool, resisted_amount,
        blocked_overkill = CombatLogGetCurrentEventInfo()

    DT_LogTrace('DT_CombatLogEventUnfiltered',
        timestamp, subEvent, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName)

    if destGUID ~= nil
	then
		local guidType = select(1, strsplit("-", destGUID))
        local isDamageSubEvent = subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE';
        local isPlayerAttack = sourceGUID == UnitGUID('player')
        local isPetAttack = sourceGUID == UnitGUID('pet')

        DT_LogVerbose(
            'isDamageSubEvent:', isDamageSubEvent,
            'isPlayerAttack:', isPlayerAttack,
            'isPetAttack:', isPetAttack)

        if (isDamageSubEvent and (isPlayerAttack or isPetAttack)) then
            DT_AttackedUnits[destGUID] = true

        -- TODO: PARTY_KILL
        -- elseif (subEvent=="PARTY_KILL") then
        -- DT_AttackedUnits[destGUID] = true

		elseif (guidType ~= "Player" and guidType ~= "Pet")
		then
			if (subEvent == 'UNIT_DIED' and destGUID ~= nil and DT_AttackedUnits[destGUID] == true) then
                local unitId = DT_UnitGuidToId(destGUID)
				DT_AttackedUnits[destGUID] = nil
                DT_MobKill(unitId, destName)
			end
		end
	end 
end

-- Updates the current zone id DT_CURRENT_ZONE_ID
function DT_UpdateCurrentZone()
    DT_LogTrace('DT_UpdateCurrentZone')

    local zoneText = GetZoneText()
    if (not zoneText or zoneText == '') then
        DT_LogWarning('Invalid ZoneText, text = "' .. zoneText .. '"')
        return
    end

	-- find zone ID in db if already known
	local zoneId = nil
	for id, name in pairs(DT_ZoneDb) do
		if zoneText == name then
			zoneId = id
            DT_LogVerbose('Found existing match for Zone in db, zoneId = ' .. zoneId .. ', zoneText = ' .. zoneText)
			break
		end
	end

	-- if zone is unknown add it to db
	if zoneId == nil then
        zoneId = 1000 + DT_TableSize(DT_ZoneDb)
        DT_LogVerbose('Write new ZoneText to db, zoneId = ' .. zoneId .. ', zoneText = ' .. zoneText)
		DT_ZoneDb[zoneId] = zoneText
	end

	DT_CURRENT_ZONE_ID = zoneId
    DT_LogDebug('ZoneID changed to ' .. zoneText .. ' (' .. zoneId .. ')')
end

function DT_Main(self, event, ...)
    --DT_LogTrace('EVENT', event, ...)
    if (event == 'ADDON_LOADED') then
        DT_AddonLoaded(...)
    elseif (event == 'PLAYER_TARGET_CHANGED') then
        DT_TargetChanged()
    elseif (event == 'ZONE_CHANGED_NEW_AREA') then
        DT_UpdateCurrentZone()
    elseif (event == 'LOOT_READY') then
        DT_LootReady()
    elseif (event == 'LOOT_OPENED') then
        DT_LootOpened()
    elseif (event == 'LOOT_CLOSED') then
        DT_LootClosed()
    elseif (event == 'COMBAT_LOG_EVENT_UNFILTERED') then
        DT_CombatLogEventUnfiltered()
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
f:SetScript('OnEvent', DT_Main)