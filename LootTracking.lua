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

-- Determines if looting is in progress to avoid to handle the event twice
local tmp_isLooting = false

-- Holds the looting informations for already attacked units to avoid collecting twice
local tmp_lootedUnits = {}

local function ProcessItemLootSlot(itemSlot)
    local _, lootName, _, currencyID, lootQuality, _, isQuestItem, _ = GetLootSlotInfo(itemSlot)

    local itemId = currencyID
    if (itemId == nil) then
        itemId = GetLootId(itemSlot)
    end

    local sources = {GetLootSourceInfo(itemSlot)}
    for sourceIndex = 1, #sources, 2 do
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

end

local function ProcessMoneyLoolSlot(itemSlot)
    local _, lootName = GetLootSlotInfo(itemSlot)

    local lootedCopper = ParseMoneyFromLootName(lootName)
    if (lootedCopper) then
        DataTracker:LogVerbose('LOOT_SLOT_MONEY', lootedCopper)

        local sources = {GetLootSourceInfo(itemSlot)}
        for j = 1, #sources, 2 do
            local guidType = select(1, strsplit("-", sources[j]))
            if guidType == 'Creature' then
                local unitId = DataTracker:UnitGuidToId(sources[j])
                if (unitId and unitId > 0) then
                    AddGold(unitId, lootedCopper)
                end
            end
        end
    end
end

-- Called when loot window is open and loot is ready
function DataTracker:OnLootReady()
    DataTracker:LogTrace('OnLootReady')

    -- ignore if event is already handled
    if (tmp_isLooting) then
        return
    end

    tmp_isLooting = true

    -- ensure current zone id is set
    if (DataTracker.CurrentZoneId == nil) then
        DataTracker:UpdateCurrentZone()
    end

    -- track loot
    for itemSlot = 1, GetNumLootItems() do
        local slotType = GetLootSlotType(itemSlot)
        if (slotType == LOOT_SLOT_ITEM) then
            ProcessItemLootSlot(itemSlot)
        elseif (slotType == LOOT_SLOT_MONEY) then
            ProcessMoneyLoolSlot(itemSlot)
        end
    end
end

function DataTracker:OnLootClosed()
    DataTracker:LogVerbose('OnLootClosed')

    tmp_isLooting = false

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