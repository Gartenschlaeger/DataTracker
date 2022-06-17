--local zoneTextReal = GetRealZoneText();
--local zoneText = GetZoneText()
--local zoneTextMinimap = GetMinimapZoneText()
--print(zoneTextReal, zoneText, zoneTextMinimap)

DT_ItemDb = {} -- stored item informations
DT_UnitDb = {} -- stored unit informations
DT_Options = {} -- stores options

function DT_TableSize(table)
    local size = 0
    for _ in pairs(table) do
        size = size + 1
    end

    return size
end

function DT_AddonLoaded(addonName)
    -- print('DT_AddonLoaded', addonName)
    if (addonName == 'TestKai') then
        local itemsCount = DT_TableSize(DT_ItemDb)
        local unitsCount = DT_TableSize(DT_UnitDb)

        print('DataTracker loaded, ' .. itemsCount .. ' Gegenstände, ' .. unitsCount .. ' Gegner')
    end
end

function DT_UnitGuidToUnitId(unitGuid)
    return tonumber(select(6, strsplit('-', unitGuid)), 10)
end

-- Called when a mob was killed and should be stored to db
function DT_MobKill(unitId, unitName)
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

    print('DataTracker Gegner: ' .. unitName .. ' (' .. unitId .. '), getötet: ' .. kills)
end

-- Called if a new item was looted and should be added to db
function DT_AddItem(itemId, itemName, itemQuantity, unitId)
    -- store item info
    local itemInfo = DT_ItemDb[itemId]
    if (itemInfo == nil) then
        itemInfo = {}
        DT_ItemDb[itemId] = itemInfo
    end

    itemInfo['name'] = itemName
    
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

    print('DataTracker Gegenstand: ' .. itemName .. ' (' .. itemId .. '), gelootet: ' .. lootedCounter)
end

-- called then the target changes. 
-- should store the target unit id and name
function DT_TargetChanged()
    local unitGuid = UnitGUID("target")
    local unitName = UnitName("target")
    if (unitGuid ~= nil and unitName ~= nil) then
        local unitType = select(1, strsplit('-', unitGuid))
        if (unitType == 'Creature') then
            local unitId = DT_UnitGuidToUnitId(unitGuid)
            --print('TargetChanged', unitId, unitName)

            local mobInfo = DT_UnitDb[unitId]
            if (mobInfo == nil or type(mobInfo) ~= 'table') then
                mobInfo = {}
            end

            mobInfo['name'] = unitName
            DT_UnitDb[unitId] = mobInfo
        end
    end
end

function DT_LootReady()
    DT_HandleLoot()
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

DT_LootingStarted = false

function DT_HandleLoot()
    -- print('HandleLoot')

    -- prevent to store the items multiple times
    -- unfortunatelly blizzard is calling the event LOOT_READY multiple times for unknown reasons
    if (DT_LootingStarted) then
        -- print('WARN', 'already looted')
        return
    end

    DT_LootingStarted = true

    for itemSlot = 1, GetNumLootItems() do
        local _, itemName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questId = GetLootSlotInfo(itemSlot)
        
        local slotType = GetLootSlotType(itemSlot)
        -- 0: LOOT_SLOT_NONE - No contents
        -- 1: LOOT_SLOT_ITEM - A regular item
        -- 2: LOOT_SLOT_MONEY - Gold/silver/copper coin
        -- 3: LOOT_SLOT_CURRENCY - Other currency amount, such as  [Valor Points]

        if (slotType == LOOT_SLOT_ITEM) then
            local itemId = currencyID
            if (itemId == nil) then
                itemId = DT_GetLootId(itemSlot)
            end
    
            if (true) then
                --print('--- > sources')
                local sources = {GetLootSourceInfo(itemSlot)}
                for j = 1, #sources, 2
                do
                    local guidType = select(1, strsplit("-", sources[j]))
                    if guidType == 'Creature' then
                        local unitId = tonumber(select(6, strsplit('-', sources[j])), 10)
                        -- print(GetUnitName(unitId))
                        -- print(sources[j], unitId)

                        DT_AddItem(itemId, itemName, lootQuantity, unitId)
                    end
                end
                --print('--- < sources')

                --DT_ChatMessage('- itemId', itemId)
                --DT_ChatMessage('- itemName', itemName)
                -- DT_ChatMessage('- lootQuantity', lootQuantity)
                -- DT_ChatMessage('- currencyID', currencyID)        
                -- DT_ChatMessage('- lootQuality', lootQuality)
                -- DT_ChatMessage('- locked', locked)
                -- DT_ChatMessage('- isQuestItem', isQuestItem)
                -- DT_ChatMessage('- questId', questId)
                -- DT_ChatMessage('- slotType', slotType)
            end
        else
            -- print('Ignore item', itemName)
        end
    end
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
                local unitId = DT_UnitGuidToUnitId(destGUID)
                --print('Mob kill', unitId, destName)
				DT_AttackedUnits[destGUID] = nil
                DT_MobKill(unitId, destName)
			end
		end
	end 
end

function DT_Main(self, event, ...)
    -- print('EVENT', event, ...)

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