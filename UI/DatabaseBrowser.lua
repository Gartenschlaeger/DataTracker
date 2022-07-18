---@class DataTracker_Core
local DataTracker = select(2, ...)

local DT_RESULT_ITEMS_COUNT = 18
local DT_RESULT_DETAIL_ITEMS_COUNT = 17
local DT_RESULT_PIXEL_HEIGHT = 25

---@type Frame
local DatabaseBrowserFrame
---@type Frame
local ItemSearchFrame
---@type Frame
local ItemDetailsFrame

---@type Button
local searchBtn

---@type EditBox
local searchBox

---@type EditBox
local unitNameFilter

---@type EditBox
local zoneNameFilter

---@type EditBox
local minKillsFilter

---@type EditBox
local goldLevelFilter

---@type Button
local backBtn

local lastItemDetailsIndex = nil

function DT_DatabaseBrowser_OnLoad(self)
    DataTracker.logging:Trace('DT_DatabaseBrowser_OnLoad')

    DatabaseBrowserFrame = DT_DatabaseBrowserFrame
    DatabaseBrowserFrame.Title:SetText('DataTracker')
    DatabaseBrowserFrame:RegisterForDrag("LeftButton")

    ItemSearchFrame = DatabaseBrowserFrame.itemSearch
    searchBtn = ItemSearchFrame.searchBtn
    searchBtn:SetText(DataTracker.i18n.UI_SEARCH)

    local resetBtn = ItemSearchFrame.resetBtn
    resetBtn:SetText(DataTracker.i18n.UI_RESET)

    searchBox = ItemSearchFrame.SearchBox

    ItemDetailsFrame = DatabaseBrowserFrame.itemDetails

    minKillsFilter = ItemDetailsFrame.MinKillCount
    minKillsFilter.Instructions:SetText(DataTracker.i18n.UI_KILLS_PH)

    unitNameFilter = ItemDetailsFrame.UnitName
    unitNameFilter.Instructions:SetText(DataTracker.i18n.UI_UNIT_NAME)

    zoneNameFilter = ItemDetailsFrame.ZoneName
    zoneNameFilter.Instructions:SetText(DataTracker.i18n.UI_ZONE_NAME)

    goldLevelFilter = ItemDetailsFrame.GoldLevel
    goldLevelFilter.Instructions:SetText(DataTracker.i18n.UI_GOLD_LEVEL)

    backBtn = ItemDetailsFrame.backBtn
    backBtn:SetText(DataTracker.i18n.UI_BACK)

    -- disable by default
    for i = 1, DT_RESULT_ITEMS_COUNT do
        local btnEntry = _G['DT_DatabaseBrowser_Entry' .. i]
        btnEntry:Disable()
    end

    DT_DatabaseBrowser_ScrollBar_Update()
    ItemSearchFrame:Show()
end

function DT_DatabaseBrowser_OnDragStart(self)
    DataTracker.logging:Trace('DT_DatabaseBrowser_OnDragStart')

    if not self.isLocked then
        self:StartMoving()
    end
end

function DT_DatabaseBrowser_OnDragStop(self)
    DataTracker.logging:Trace('DT_DatabaseBrowser_OnDragStop')

    self:StopMovingOrSizing()
end

function DT_DatabaseBrowser_OnShow(self)
    DataTracker.logging:Trace('DT_DatabaseBrowser_OnShow')
end

function DT_DatabaseBrowser_OnHide(self)
    DataTracker.logging:Trace('DT_DatabaseBrowser_OnHide')
end

function DT_DatabaseBrowser_OnReset(self)
    DT_SearchResults = {}
    searchBox:SetText('')
    DT_DatabaseBrowser_ScrollBar_Update()
end

function DT_DatabaseBrowser_OnSearch(self)
    DataTracker.logging:Trace('DT_DatabaseBrowser_OnSearch')

    DT_SearchResults = {}

    local index = 1

    ---@type string
    ---@diagnostic disable-next-line: assign-type-mismatch
    local searchText = searchBox:GetText()
    searchText = strtrim(strlower(searchText))
    if (strlen(searchText) > 0) then
        for itemId, itemInfo in pairs(DT_ItemDb) do
            local nameMatches = strfind(strlower(itemInfo.nam), searchText, 1, true)
            if (nameMatches) then
                local result = {}
                result.itemId = itemId
                result.itemName = itemInfo.nam

                if (itemInfo.qlt) then
                    local icR, icG, icB = GetItemQualityColor(itemInfo.qlt)
                    result.color = { r = icR, g = icG, b = icB }
                else
                    result.color = { r = 1, g = 1, b = 1 }
                end

                DT_SearchResults[index] = result
                index = index + 1
            end
        end
    end

    DT_DatabaseBrowser_ScrollBar_Update()
end

DT_SearchResults = {}
DT_SearchUnitResults = {}

-- https://wowwiki-archive.fandom.com/wiki/Making_a_scrollable_list_using_FauxScrollFrameTemplate
-- FauxScrollFrame_OnVerticalScroll(self, value, itemHeight, updateFunction)
-- FauxScrollFrame_Update(frame, totalItems, numOfLines, pixelHeightPerLine)

function DT_DatabaseBrowser_OnBack(self)
    DataTracker.logging:Trace('DT_DatabaseBrowser_OnBack')

    lastItemDetailsIndex = nil

    ---@diagnostic disable-next-line: undefined-field
    DatabaseBrowserFrame.itemSearch:Show()
    ---@diagnostic disable-next-line: undefined-field
    DatabaseBrowserFrame.itemDetails:Hide()
end

local function createUnitResult(unitId, unitName, kills, gold, percent, colorR, colorG, colorB)
    return {
        unitId = unitId,
        unitName = unitName,
        maps = '',
        mapIds = {},
        kills = kills,
        gold = gold,
        percent = percent,
        color = { r = colorR, g = colorG, b = colorB }
    }
end

local function GetUnitColor(classification)
    if (classification == DT_UnitClassifications['rare']) then
        return { r = 0, g = 0.63, b = 1 }
    elseif (classification == DT_UnitClassifications['elite']) then
        return { r = 1, g = 0.81, b = 0 }
    end

    return { r = 1, g = 1, b = 1 }
end

local function LoadItemDetails(itemIndex)
    lastItemDetailsIndex = itemIndex
    local itemResult = DT_SearchResults[itemIndex]

    DataTracker.logging:Trace(itemResult.itemName, itemResult.itemId)

    DT_SearchUnitResults = {}

    ---@type FontString
    local title = DT_DatabaseBrowser_DetailTitle
    local itemTextureId = GetItemIcon(itemResult.itemId)
    local itemTexture = '|T' .. itemTextureId .. ':22|t'
    title:SetText(itemTexture .. ' ' .. itemResult.itemName)
    title:SetTextColor(itemResult.color.r, itemResult.color.g, itemResult.color.b)

    local unitName = unitNameFilter:GetText()
    local minKills = tonumber(minKillsFilter:GetText(), 10)
    local goldLevel = tonumber(goldLevelFilter:GetText(), 10)
    local zoneName = zoneNameFilter:GetText()

    local totalResults = 0
    for unitId, unitInfo in pairs(DT_UnitDb) do
        local result = nil

        local add = true

        -- filter by kill count
        if (minKills and unitInfo.kls and unitInfo.kls < minKills) then
            add = false
        end

        -- filter by unit name
        if (unitName and unitInfo.nam) then
            local fm = unitInfo.nam:find(unitName)
            if (not fm) then
                add = false
            end
        end

        if (add) then
            -- general loot items
            local its = unitInfo.its
            if (its) then
                local ltd = tonumber(unitInfo['ltd']) or 0
                for itemId, timesLooted in pairs(its) do
                    if (itemResult.itemId == itemId) then
                        local percent = DataTracker.helper:CalculatePercentage(ltd, timesLooted)
                        local color = GetUnitColor(unitInfo.clf)
                        result = createUnitResult(
                            unitId,
                            unitInfo.nam,
                            unitInfo.kls,
                            DataTracker.helper:CalculateAvgUnitGoldCount(unitInfo, goldLevel),
                            DataTracker.helper:FormatPercentage(percent),
                            color.r, color.g, color.b)
                        break
                    end
                end
            end

            -- skinning loot
            local unitItems = unitInfo.its_sk
            if (unitItems) then
                local ltd_sk = tonumber(unitInfo.ltd_sk) or 0
                for itemId, timesLooted in pairs(unitItems) do
                    if (itemResult.itemId == itemId) then
                        local percent = DataTracker.helper:CalculatePercentage(ltd_sk, timesLooted)
                        local color = GetUnitColor(unitInfo.clf)
                        result = createUnitResult(
                            unitId,
                            unitInfo.nam,
                            unitInfo.kls,
                            DataTracker.helper:CalculateAvgUnitGoldCount(unitInfo, goldLevel),
                            DataTracker.helper:FormatPercentage(percent),
                            color.r, color.g, color.b)
                        break
                    end
                end
            end

            if (result) then
                local maps = {}
                local mapIds = {}
                if (unitInfo.mps) then
                    for mapId, _ in pairs(unitInfo.mps) do
                        local mapName = DataTracker.helper:GetMapNameById(mapId)
                        if (mapName) then
                            table.insert(mapIds, mapId)
                            table.insert(maps, mapName)
                        end

                        result.maps = result.maps .. ' ' .. mapName
                    end
                end

                table.sort(maps)
                result.maps = table.concat(maps, ', ')
                result.mapIds = mapIds

                -- filter by map
                if (zoneName) then
                    local fm = result.maps:find(zoneName)
                    if (not fm) then
                        add = false
                    end
                end

                if (add) then
                    totalResults = totalResults + 1
                    DT_SearchUnitResults[totalResults] = result
                end
            end
        end

    end

    -- print(totalResults)
    DT_DatabaseBrowser_ScrollBarLoc_Update()

    ---@diagnostic disable-next-line: undefined-field
    DatabaseBrowserFrame.itemSearch:Hide()
    ---@diagnostic disable-next-line: undefined-field
    DatabaseBrowserFrame.itemDetails:Show()
end

function DT_AnyUnitFilter_TextChanged(self)
    InputBoxInstructions_OnTextChanged(self)
    if (lastItemDetailsIndex) then
        LoadItemDetails(lastItemDetailsIndex)
    end
end

function DT_DatabaseBrowser_ScrollBarLoc_Update()
    local totalResults = DataTracker.helper:GetTableSize(DT_SearchUnitResults)
    FauxScrollFrame_Update(DT_DatabaseBrowser_ScrollBarLoc,
        totalResults,
        DT_RESULT_DETAIL_ITEMS_COUNT,
        DT_RESULT_PIXEL_HEIGHT)

    local offset = FauxScrollFrame_GetOffset(DT_DatabaseBrowser_ScrollBarLoc)

    -- print('totalResults:', totalResults, ', from:', offset, 'to:', offset + DT_RESULT_ITEMS_COUNT)

    for i = 1, DT_RESULT_DETAIL_ITEMS_COUNT do
        local result = DT_SearchUnitResults[i + offset]

        local btn = _G['DT_DatabaseBrowser_EntryLoc' .. i]

        ---@type FontString
        local fsUnit = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Unit']

        ---@type FontString
        local fsMaps = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Zone']

        ---@type FontString
        local fsGold = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Gold']

        ---@type FontString
        local fsKills = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Kills']

        ---@type FontString
        local fsPercentage = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Percentage']

        if (result) then
            fsUnit:SetText(result.unitName)
            fsUnit:SetTextColor(result.color.r, result.color.g, result.color.b, 1)

            btn:Enable()
            btn:SetAttribute('unitIndex', i + offset)
            btn:SetScript("OnClick", function(self)
                local unitIndex = tonumber(self:GetAttribute('unitIndex'))
                local unitResult = DT_SearchUnitResults[unitIndex]
                for _, mapId in pairs(unitResult.mapIds) do
                    WorldMapFrame:Show()
                    WorldMapFrame:SetMapID(mapId)
                    break
                end
            end)

            fsMaps:SetText(result.maps)
            fsMaps:SetTextColor(1, 1, 1, 1)

            if (result.gold and result.gold > 0) then
                fsGold:SetText(GetCoinTextureString(result.gold))
            else
                fsGold:SetText('')
            end
            fsGold:SetTextColor(1, 1, 1, 1)

            fsKills:SetText(result.kills)
            fsKills:SetTextColor(1, 1, 1, 1)

            fsPercentage:SetText(result.percent)
            fsPercentage:SetTextColor(1, 1, 1, 1)
        else
            btn:Disable()
            fsUnit:SetText('')
            fsMaps:SetText('')
            fsGold:SetText('')
            fsKills:SetText('')
            fsPercentage:SetText('')
        end
    end
end

function DT_DatabaseBrowser_ScrollBar_Update()
    DataTracker.logging:Trace('DT_DatabaseBrowser_ScrollBar_Update')

    local totalResults = DataTracker.helper:GetTableSize(DT_SearchResults)
    FauxScrollFrame_Update(DT_DatabaseBrowser_ScrollBar, totalResults, DT_RESULT_ITEMS_COUNT, DT_RESULT_PIXEL_HEIGHT)

    local offset = FauxScrollFrame_GetOffset(DT_DatabaseBrowser_ScrollBar)

    --print('totalResults:', totalResults, 'from:', offset, 'to:', offset + DT_RESULT_ITEMS_COUNT)

    for i = 1, DT_RESULT_ITEMS_COUNT do
        local result = DT_SearchResults[i + offset]

        local btn = _G['DT_DatabaseBrowser_Entry' .. i]
        btn:SetAttribute('itemIndex', i + offset)
        btn:SetScript("OnClick", function(self)
            local itemIndex = tonumber(self:GetAttribute('itemIndex'))
            LoadItemDetails(itemIndex)
        end)

        local fsVal1 = _G["DT_DatabaseBrowser_Entry" .. i .. 'Val1']
        local fsVal2 = _G["DT_DatabaseBrowser_Entry" .. i .. 'Val2']
        local fsVal3 = _G["DT_DatabaseBrowser_Entry" .. i .. 'Val3']

        if (result) then
            btn:Enable()
            local textureId = GetItemIcon(result.itemId)
            local texture = '|T' .. textureId .. ':22|t'
            fsVal1:SetTextColor(result.color.r, result.color.g, result.color.b)
            fsVal1:SetText(texture .. ' ' .. result.itemName)
        else
            btn:Disable()
            fsVal1:SetText('')
            fsVal2:SetText('')
            fsVal3:SetText('')
        end
    end
end
