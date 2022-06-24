-- time in seconds to store lootinginfos for looted units
-- needed to prevent duplicates and to calculate the counter correct
local TIME_TO_STORE_LOOTINGINFOS = 60 * 5

-- Called when copper was looted and should be added to db
local function TrackLootedCopper(unitId, lootedCopper)
    DataTracker:LogVerbose('TrackLootedCopper', unitId, lootedCopper)

    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    local totalLootedCopper = (unitInfo.cop or 0) + lootedCopper
    unitInfo.cop = totalLootedCopper

    local minCopper = unitInfo.mnc
    if (minCopper == nil or minCopper > lootedCopper) then
        minCopper = lootedCopper
        unitInfo.mnc = minCopper
    end

    local maxCopper = unitInfo.mxc
    if (maxCopper == nil or maxCopper < lootedCopper) then
        maxCopper = lootedCopper
        unitInfo.mxc = maxCopper
    end

    DataTracker:LogDebug('Copper: ' .. lootedCopper .. ', (' .. unitInfo.nam .. ' ID = ' .. unitId .. ')')
end

-- Called when a new item was looted and should be added to db
local function TrackItem(itemId, itemName, itemQuantity, itemQuality, unitId, isSkinningItem)
    DataTracker:LogVerbose('TrackItem', itemId, itemName, itemQuantity, itemQuality, unitId, isSkinningItem)

    -- store item info
    local itemInfo = DT_ItemDb[itemId]
    if (itemInfo == nil) then
        itemInfo = {}
        DT_ItemDb[itemId] = itemInfo

        DataTracker:LogInfo(DataTracker.i18n.NEW_ITEM .. ': ' .. itemName)
    end

    itemInfo.nam = itemName
    itemInfo.qlt = itemQuality

    -- store loot info
    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    local unitItemsInfo
    if (isSkinningItem) then
        unitItemsInfo = unitInfo.its_sk
        if (unitItemsInfo == nil) then
            unitItemsInfo = {}
            unitInfo.its_sk = unitItemsInfo
        end
    else
        unitItemsInfo = unitInfo.its
        if (unitItemsInfo == nil) then
            unitItemsInfo = {}
            unitInfo.its = unitItemsInfo
        end
    end

    local unitItemLootedCounter = unitItemsInfo[itemId]
    if (unitItemLootedCounter == nil) then
        unitItemLootedCounter = 1 --itemQuantity
    else
        unitItemLootedCounter = unitItemLootedCounter + 1 --itemQuantity
    end
    unitItemsInfo[itemId] = unitItemLootedCounter

    if (DataTracker:IsDebugLogEnabled()) then
        local prefix
        if (isSkinningItem) then
            prefix = 'S:Item'
        else
            prefix = 'G:Item'
        end

        DataTracker:LogDebug(prefix ..  ': ' .. itemQuantity .. ' ' .. itemName .. ' (ID = ' .. itemId .. '), ' .. (unitInfo.nam or '') .. ' (ID = ' .. unitId .. ')')
    end
end

-- Increments the loot counter for the given unitId
local function IncrementLootCounter(lootingInfos)
    DataTracker:LogTrace('IncrementLootCounter', lootingInfos.unitId, lootingInfos.skinningStarted)

    -- get unit info
    local unitInfo = DT_UnitDb[lootingInfos.unitId]
    if (unitInfo == nil) then
        DataTracker:LogWarning('Cannot find unit with id ' .. lootingInfos.unitId)
        return
    end

    if (lootingInfos.skinningStarted) then
        if (not lootingInfos.skinningCounterIncreased) then
            unitInfo.ltd_sk = (unitInfo.ltd_sk or 0) + 1
            lootingInfos.skinningCounterIncreased = true

            DataTracker:LogDebug('S:Count: ' .. (unitInfo.nam or '') .. ' (ID = ' .. lootingInfos.unitId .. ')')
        end
    else
        if (not lootingInfos.lootingCounterWasIncremented) then
            unitInfo.ltd = (unitInfo.ltd or 0) + 1
            lootingInfos.lootingCounterWasIncremented = true

            DataTracker:LogDebug('L:Count: ' .. (unitInfo.nam or '') .. ' (ID = ' .. lootingInfos.unitId .. ')')
        end
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

local function ParseMoneyFromLootName(lootName)
    local startIndex = 0
    local lootedCopper = 0

    startIndex = string.find(lootName, ' ' .. DataTracker.i18n.GOLD)
    if startIndex then
        local g = tonumber(string.sub(lootName,0,startIndex-1)) or 0
		lootName = string.sub(lootName,startIndex+5,string.len(lootName))
		lootedCopper = lootedCopper + ((g or 0) * COPPER_PER_GOLD)
        DataTracker:LogVerbose('ParseMoneyFromLootName, Processing Gold', g)
	end

	startIndex = string.find(lootName, ' ' .. DataTracker.i18n.SILVER)
	if startIndex then
		local s = tonumber(string.sub(lootName,0,startIndex-1)) or 0
		lootName = string.sub(lootName,startIndex+7,string.len(lootName))
		lootedCopper = lootedCopper + ((s or 0) * COPPER_PER_SILVER)
        DataTracker:LogVerbose('ParseMoneyFromLootName, Processing Silver', s)
	end

	startIndex = string.find(lootName, ' ' .. DataTracker.i18n.COPPER)
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

local function GetLootingInformations(unitGuid, unitId)
    local lootingInfos = tmp_lootedUnits[unitGuid]
    if (lootingInfos == nil) then
        DataTracker:LogTrace('Create looting informations for unit ' .. unitId)

        lootingInfos = {
            -- id of unit
            unitId = unitId,
            -- time when looting was started first time
            time = GetTime(),

            -- general items
            items = {},
            -- items from skinning
            skinningItems = {},

            -- was copper already tracked?
            hasCopperTracked = false,

            -- true if general looting counter was increased
            lootingCounterWasIncremented = false,

            -- true if skinning was already started
            skinningStarted = false,
            -- true if skinng counter was increased
            skinningCounterIncreased = false
        }

        tmp_lootedUnits[unitGuid] = lootingInfos
    end

    return lootingInfos
end

local function ProcessItemLootSlot(itemSlot)
    local _, lootName, _, currencyID, lootQuality, _, isQuestItem, _ = GetLootSlotInfo(itemSlot)

    local itemId = currencyID
    if (itemId == nil) then
        itemId = GetLootId(itemSlot)
    end

    local sources = {GetLootSourceInfo(itemSlot)}
    for sourceIndex = 1, #sources, 2 do
        local guid = sources[sourceIndex]
        local guidType = select(1, strsplit("-", guid))
        if guidType == 'Creature' then
            local unitId = DataTracker:UnitGuidToId(guid)

            local lootingInfos = GetLootingInformations(guid, unitId)

            local lootedItems
            if (lootingInfos.skinningStarted) then
                lootedItems = lootingInfos.skinningItems
            else
                lootedItems = lootingInfos.items
            end

            if (lootedItems[itemId] == nil) then
                local sourceQuantity = tonumber(sources[sourceIndex + 1])
                if (unitId and unitId > 0) then
                    if (not isQuestItem) then
                        TrackItem(itemId, lootName, sourceQuantity, lootQuality, unitId, lootingInfos.skinningStarted)
                    end

                    lootedItems[itemId] = sourceQuantity
                    IncrementLootCounter(lootingInfos)
                end
            end

        end
    end

end

local function ProcessMoneyLoolSlot(itemSlot)
    local _, lootName = GetLootSlotInfo(itemSlot)

    -- unfortunately the looted copper amount is part of the text for so we need to parse it
    local lootedCopper = ParseMoneyFromLootName(lootName)

    if (lootedCopper) then
        DataTracker:LogVerbose('LOOT_SLOT_MONEY', lootedCopper)

        local sources = {GetLootSourceInfo(itemSlot)}
        local sourcesCount = #sources

        -- track copper only if we have exactly one source
        -- otherwise its the sum of all and we don't know which unit has dropped how much
        -- to avoid invalid calculations we skip in case of multiple units
        if (sourcesCount == 2) then
            for j = 1, sourcesCount, 2 do
                local unitGuid = sources[j]
                local guidType = select(1, strsplit("-", unitGuid))

                if guidType == 'Creature' then
                    local unitId = DataTracker:UnitGuidToId(sources[j])
                    if (unitId and unitId > 0) then
                        local lootingInfos = GetLootingInformations(unitGuid, unitId)
                        if (not lootingInfos.hasCopperTracked) then
                            TrackLootedCopper(unitId, lootedCopper)
                            lootingInfos.hasCopperTracked = true

                            IncrementLootCounter(lootingInfos)
                        end
                    end
                end
            end
        end
    end
end

function DataTracker:OnUnitSpellcastSucceeded(unitTarget, castGUID, spellID)
    if (unitTarget == 'player' and spellID == 8613) then
        local unitGuid = UnitGUID("target")
        local unitId = DataTracker:UnitGuidToId(unitGuid)
        local lootingInfo = GetLootingInformations(unitGuid, unitId)
        lootingInfo.skinningStarted = true
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
        if (currentTime - info.time > TIME_TO_STORE_LOOTINGINFOS) then
            tmp_lootedUnits[unitGuid] = nil
            DataTracker:LogVerbose('Cleaned up looted unit ' .. unitGuid)
        end
    end

    DataTracker:LogVerbose('lootedUnits size:', DataTracker:GetTableSize(tmp_lootedUnits))
end