---@class DTCore
local _, core = ...

-- time in seconds to store lootinginfos for looted units
-- needed to prevent duplicates and to calculate the counter correct
local TIME_TO_STORE_LOOTINGINFOS = 60 * 5

-- time in seconds to store unit infos for targeted units
-- needed to get additional unit related informations in looting events
local TIME_TO_STORE_UNIT_INFOS = 60

local SPELLID_SKINNING = 8613
local SPELLID_MINING = 32606
local SPELLID_HERBALISM = 32605

function core:PlayerHasSkinning()
    return IsPlayerSpell(SPELLID_SKINNING)
end

function core:PlayerHasMining()
    return IsPlayerSpell(SPELLID_MINING)
end

function core:PlayerHasHerbalism()
    return IsPlayerSpell(SPELLID_HERBALISM)
end

-- Called when copper was looted and should be added to db
local function TrackLootedCopper(unitGuid, unitId, lootedCopper)
    core.logging:Verbose('TrackLootedCopper', unitId, lootedCopper)

    local unitLevel = -1
    local tmp_infos = core.TmpUnitInformations[unitGuid]
    if (tmp_infos ~= nil) then
        unitLevel = tmp_infos.level or -1
    end

    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    local unitCopperInfo = unitInfo.cpi
    if (unitCopperInfo == nil) then
        unitCopperInfo = {}
        unitInfo.cpi = unitCopperInfo
    end

    local key
    if (unitLevel < 1) then
        key = '_'
    else
        key = 'l:' .. unitLevel
    end

    local levelInfo = unitCopperInfo[key]
    if (levelInfo == nil) then
        levelInfo = {}
        unitCopperInfo[key] = levelInfo
    end

    levelInfo.ltd = (levelInfo.ltd or 0) + 1
    levelInfo.tot = (levelInfo.tot or 0) + lootedCopper

    local minCopper = levelInfo.min
    if (minCopper == nil or lootedCopper < minCopper) then
        --print('TrackLootedCopper, NEW MIN ' .. (minCopper or 'nil') .. ' -> ' .. lootedCopper)
        minCopper = lootedCopper
        levelInfo.min = lootedCopper
    end

    local maxCopper = levelInfo.max
    if (maxCopper == nil or lootedCopper > maxCopper) then
        --print('TrackLootedCopper, NEW MAX ' .. (maxCopper or 'nil') .. ' -> ' .. lootedCopper)
        maxCopper = lootedCopper
        levelInfo.max = lootedCopper
    end

    core.logging:Debug('Copper: ' .. lootedCopper .. ', (' .. unitInfo.nam .. ' ID = ' .. unitId .. ')')
end

-- Called when a new item was looted and should be added to db
local function TrackItem(itemId, itemName, itemQuantity, itemQuality, unitId, sourceType)
    core.logging:Verbose('TrackItem', itemId, itemName, itemQuantity, itemQuality, unitId, sourceType)

    -- store item info
    local itemInfo = DT_ItemDb[itemId]
    if (itemInfo == nil) then
        itemInfo = {}
        DT_ItemDb[itemId] = itemInfo

        core.bc:NewItem(itemId, itemName, itemQuality)
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
    if (sourceType == 'skinning') then
        unitItemsInfo = unitInfo.its_sk
        if (unitItemsInfo == nil) then
            unitItemsInfo = {}
            unitInfo.its_sk = unitItemsInfo
        end
    elseif (sourceType == 'mining') then
        unitItemsInfo = unitInfo.its_mn
        if (unitItemsInfo == nil) then
            unitItemsInfo = {}
            unitInfo.its_mn = unitItemsInfo
        end
    elseif (sourceType == 'herbalism') then
        unitItemsInfo = unitInfo.its_hb
        if (unitItemsInfo == nil) then
            unitItemsInfo = {}
            unitInfo.its_hb = unitItemsInfo
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

    if (core.logging:IsDebugEnabled()) then
        core.logging:Debug(sourceType .. ': ' .. itemQuantity ..
            ' ' .. itemName .. ' (ID = ' .. itemId .. '), ' .. (unitInfo.nam or '') .. ' (ID = ' .. unitId .. ')')
    end
end

-- Increments the loot counter for the given unitId
local function IncrementLootCounter(lootingInfos)
    core.logging:Trace('IncrementLootCounter', lootingInfos.unitId, lootingInfos.skinningStarted)

    -- get unit info
    local unitInfo = DT_UnitDb[lootingInfos.unitId]
    if (unitInfo == nil) then
        core.logging:Warning('Cannot find unit with id ' .. lootingInfos.unitId)
        return
    end

    if (lootingInfos.skinningStarted) then
        if (not lootingInfos.skinningCounterIncreased) then
            unitInfo.ltd_sk = (unitInfo.ltd_sk or 0) + 1
            lootingInfos.skinningCounterIncreased = true

            core.logging:Debug('S:Count: ' .. (unitInfo.nam or '') .. ' (ID = ' .. lootingInfos.unitId .. ')')
        end
    elseif (lootingInfos.isMiningStarted) then
        if (not lootingInfos.miningCounterIncreased) then
            unitInfo.ltd_mn = (unitInfo.ltd_mn or 0) + 1
            lootingInfos.miningCounterIncreased = true

            core.logging:Debug('M:Count: ' .. (unitInfo.nam or '') .. ' (ID = ' .. lootingInfos.unitId .. ')')
        end
    elseif (lootingInfos.isHerbalismStarted) then
        if (not lootingInfos.herbalismCounterIncreased) then
            unitInfo.ltd_hb = (unitInfo.ltd_hb or 0) + 1
            lootingInfos.herbalismCounterIncreased = true

            core.logging:Debug('H:Count: ' .. (unitInfo.nam or '') .. ' (ID = ' .. lootingInfos.unitId .. ')')
        end
    else
        if (not lootingInfos.lootingCounterWasIncremented) then
            unitInfo.ltd = (unitInfo.ltd or 0) + 1
            lootingInfos.lootingCounterWasIncremented = true

            core.logging:Debug('L:Count: ' .. (unitInfo.nam or '') .. ' (ID = ' .. lootingInfos.unitId .. ')')
        end
    end
end

local function ParseMoneyFromLootName(lootName)
    local startIndex = 0
    local lootedCopper = 0

    startIndex = string.find(lootName, ' ' .. core.i18n.GOLD)
    if startIndex then
        local g = tonumber(string.sub(lootName, 0, startIndex - 1)) or 0
        lootName = string.sub(lootName, startIndex + 5, string.len(lootName))
        lootedCopper = lootedCopper + ((g or 0) * COPPER_PER_GOLD)
        core.logging:Verbose('ParseMoneyFromLootName, Processing Gold', g)
    end

    startIndex = string.find(lootName, ' ' .. core.i18n.SILVER)
    if startIndex then
        local s = tonumber(string.sub(lootName, 0, startIndex - 1)) or 0
        lootName = string.sub(lootName, startIndex + 7, string.len(lootName))
        lootedCopper = lootedCopper + ((s or 0) * COPPER_PER_SILVER)
        core.logging:Verbose('ParseMoneyFromLootName, Processing Silver', s)
    end

    startIndex = string.find(lootName, ' ' .. core.i18n.COPPER)
    if startIndex then
        local c = tonumber(string.sub(lootName, 0, startIndex - 1)) or 0
        lootedCopper = lootedCopper + (c or 0)
        core.logging:Verbose('ParseMoneyFromLootName, Processing Copper', c)
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
        core.logging:Trace('Create looting informations for unit ' .. unitId)

        lootingInfos = {
            -- id of unit
            unitId = unitId,
            -- time when looting was started first time
            time = GetTime(),

            -- general items
            items = {},

            -- was copper already tracked?
            hasCopperTracked = false,

            -- true if general looting counter was increased
            lootingCounterWasIncremented = false,

            -- skinning
            skinningStarted = false,
            skinningItems = {},
            skinningCounterIncreased = false,

            -- mining
            isMiningStarted = false,
            miningItems = {},
            miningCounterIncreased = false,

            -- herbalism
            isHerbalismStarted = false,
            herbalismItems = {},
            herbalismCounterIncreased = false
        }

        tmp_lootedUnits[unitGuid] = lootingInfos
    end

    return lootingInfos
end

local function ProcessItemLootSlot(itemSlot)
    local _, lootName, _, currencyID, lootQuality, _, isQuestItem, _ = GetLootSlotInfo(itemSlot)

    ---@type number|nil
    local itemId = currencyID
    if (itemId == nil) then
        local link = GetLootSlotLink(itemSlot)
        itemId = core.helper:GetItemIdFromLink(link)
    end

    local sources = { GetLootSourceInfo(itemSlot) }
    for sourceIndex = 1, #sources, 2 do
        local guid = sources[sourceIndex]
        if (core.helper:IsTrackableUnit(guid)) then
            local unitId = core.helper:GetUnitIdFromGuid(guid)

            local lootingInfos = GetLootingInformations(guid, unitId)

            local lootedItems, sourceType
            if (lootingInfos.skinningStarted) then
                lootedItems = lootingInfos.skinningItems
                sourceType = 'skinning'
            elseif (lootingInfos.isMiningStarted) then
                lootedItems = lootingInfos.miningItems
                sourceType = 'mining'
            elseif (lootingInfos.isHerbalismStarted) then
                lootedItems = lootingInfos.herbalismItems
                sourceType = 'herbalism'
            else
                lootedItems = lootingInfos.items
                sourceType = 'general'
            end

            if (lootedItems[itemId] == nil) then
                local sourceQuantity = tonumber(sources[sourceIndex + 1])
                if (unitId and unitId > 0) then
                    if (not isQuestItem) then
                        TrackItem(itemId, lootName, sourceQuantity, lootQuality, unitId, sourceType)
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
        core.logging:Verbose('LOOT_SLOT_MONEY', lootedCopper)

        local sources = { GetLootSourceInfo(itemSlot) }
        local sourcesCount = #sources

        -- track copper only if we have exactly one source
        -- otherwise its the sum of all and we don't know which unit has dropped how much
        -- to avoid invalid calculations we skip in case of multiple units
        if (sourcesCount == 2) then
            for j = 1, sourcesCount, 2 do
                local unitGuid = sources[j]
                if (core.helper:IsTrackableUnit(unitGuid)) then
                    local unitId = core.helper:GetUnitIdFromGuid(unitGuid)
                    if (unitId and unitId > 0) then
                        local lootingInfos = GetLootingInformations(unitGuid, unitId)
                        if (not lootingInfos.hasCopperTracked) then
                            TrackLootedCopper(unitGuid, unitId, lootedCopper)
                            lootingInfos.hasCopperTracked = true

                            IncrementLootCounter(lootingInfos)
                        end
                    end
                end
            end
        end
    end
end

---Occured when a spell is casted (used to track when skinning is started)
function core:OnUnitSpellcastSucceeded(unitTarget, castGUID, spellID)
    if (unitTarget == 'player') then
        --print(GetSpellInfo(spellID))

        local unitGuid = UnitGUID("target")
        if (not unitGuid) then
            return
        end

        if (spellID == SPELLID_SKINNING) then
            local lootingInfo = GetLootingInformations(unitGuid, core.helper:GetUnitIdFromGuid(unitGuid))
            lootingInfo.skinningStarted = true
        elseif (spellID == SPELLID_MINING) then
            local lootingInfo = GetLootingInformations(unitGuid, core.helper:GetUnitIdFromGuid(unitGuid))
            lootingInfo.isMiningStarted = true
        elseif (spellID == SPELLID_HERBALISM) then
            local lootingInfo = GetLootingInformations(unitGuid, core.helper:GetUnitIdFromGuid(unitGuid))
            lootingInfo.isHerbalismStarted = true
        end
    end
end

---Called when loot window is opened and loot is ready
function core:OnLootReady()
    core.logging:Trace('OnLootReady')

    -- ignore if event is already handled
    if (tmp_isLooting) then
        return
    end

    tmp_isLooting = true

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

---Occures when the loot window was closed
function core:OnLootClosed()
    core.logging:Verbose('OnLootClosed')

    tmp_isLooting = false

    -- clean up temporary data
    local currentTime = GetTime()

    for unitGuid, info in pairs(tmp_lootedUnits) do
        if (currentTime - info.time > TIME_TO_STORE_LOOTINGINFOS) then
            tmp_lootedUnits[unitGuid] = nil
            core.logging:Verbose('Clean up looting informations, unit = ' .. unitGuid)
        end
    end

    for unitGuid, info in pairs(core.TmpUnitInformations) do
        if (currentTime - info.time > TIME_TO_STORE_UNIT_INFOS) then
            core.TmpUnitInformations[unitGuid] = nil
            core.logging:Verbose('Clean up unit informations, unit = ' .. unitGuid)
        end
    end

    core.logging:Verbose('lootedUnits size:', core.helper:GetTableSize(tmp_lootedUnits))
end
