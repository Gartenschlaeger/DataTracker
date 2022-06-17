DT_ItemDb = {}
DT_UnitDb = {}

DT_Options = {}
DT_Options['MinLogLevel'] = DT_LogLevel.None

function DT_TableSize(table)
    local size = 0
    for _ in pairs(table) do
        size = size + 1
    end

    return size
end

function DT_InitOptions()
    DT_Options['MinLogLevel'] = DT_LogLevel.Debug
end

function DT_AddonLoaded(addonName)
    if (addonName == 'TestKai') then
        local itemsCount = DT_TableSize(DT_ItemDb)
        local unitsCount = DT_TableSize(DT_UnitDb)

        DT_InitOptions()

        DT_LogInfo('DataTracker loaded, ' .. itemsCount .. ' Gegenstände, ' .. unitsCount .. ' Gegner')
    end
end

function DT_UnitGuidToId(unitGuid)
    return tonumber(select(6, strsplit('-', unitGuid)), 10)
end

-- Called when a mob was killed and should be stored to db
function DT_MobKill(unitId, unitName)
    DT_LogTrace('DT_MobKill', unitId, unitName)

    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    local kills = unitInfo['kills']
    if (kills == nil) then
        kills = 1
    else
        kills = kills + 1
    end

    unitInfo['kills'] = kills

    DT_LogDebug('Kill: ' .. unitName .. ' (' .. unitId .. '), total kills: ' .. kills)
end

-- Called when copper was looted and should be added to db
function DT_AddGold(unitId, copperAmount)
    DT_LogVerbose('', unitId, copperAmount)

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

-- occures when the target changes, used to store unit id and name
function DT_TargetChanged()
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

-- holds information if looting has already started because the event LOOT_READY occures multiple times
DT_LootingStarted = false

function DT_LootReady()
    if (DT_LootingStarted) then
        return
    end

    DT_LootingStarted = true

    for itemSlot = 1, GetNumLootItems() do
        local _, itemName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questId = GetLootSlotInfo(itemSlot)

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
                            DT_AddItem(itemId, itemName, lootQuantity, lootQuality, unitId)
                        end
                    end
                end
                DT_LogVerbose('--- < sources')
            end

        -- 2: LOOT_SLOT_MONEY - Gold/silver/copper coin
        elseif (slotType == LOOT_SLOT_MONEY) then
            -- DT_AddGold()

        else
            DT_LogVerbose('Ignore item, slot type:', slotType)
        end
    end
end

function DT_LootOpened()
end

function DT_GetLootId(slot)
	local link = GetLootSlotLink(slot)
	if link then
        -- print('DT_GetLootId "', link, '"')
		local _, _, idCode = string.find(link, "|Hitem:(%d*):(%d*):(%d*):")
		return tonumber(idCode) or -1
	end

	return 0
end

function DT_LootClosed()
    DT_LootingStarted = false
end

DT_AttackedUnits = {}
function DT_CombatLogEventUnfiltered()
    local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, damage_spellid, overkill_spellname, school_spellSchool, resisted_amount, blocked_overkill = CombatLogGetCurrentEventInfo()
    -- print('CombatLogEventUnfiltered', destGUID, subEvent)

    if destGUID ~= nil
	then
		local guidType = select(1, strsplit("-", destGUID))

        if ((subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE') and (sourceGUID == UnitGUID('player') or sourceGUID == UnitGUID('pet'))) then
            DT_AttackedUnits[destGUID] = true
        -- elseif (subEvent=="PARTY_KILL" and (MobInfoConfig.SaveAllPartyKills or 0) == 1) then
        -- DT_AttackedUnits[destGUID] = true
		elseif (guidType ~= "Player" and guidType ~= "Pet")
		then
			if (subEvent == 'UNIT_DIED' and destGUID ~= nil and DT_AttackedUnits[destGUID] == true) then
                local unitId = DT_UnitGuidToId(destGUID)
                --print('Mob kill', unitId, destName)
				DT_AttackedUnits[destGUID] = nil
                DT_MobKill(unitId, destName)
			end
		end
	end 
end

function DT_Main(self, event, ...)
    DT_LogTrace('EVENT', event, ...)

    if (event == 'ADDON_LOADED') then
        DT_AddonLoaded(...)
    elseif (event == 'PLAYER_TARGET_CHANGED') then
        DT_TargetChanged()
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
f:RegisterEvent('LOOT_READY')
f:RegisterEvent('LOOT_OPENED')
f:RegisterEvent('LOOT_CLOSED')
f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
f:SetScript('OnEvent', DT_Main)