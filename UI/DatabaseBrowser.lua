---@class DTCore
local _, core = ...

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
local minKillsFilter

---@type EditBox
local goldLevelFilter

---@type Button
local backBtn

local lastItemDetailsIndex = nil

function DT_DatabaseBrowser_OnLoad(self)
    core.logging:Trace('DT_DatabaseBrowser_OnLoad')

    DatabaseBrowserFrame = DT_DatabaseBrowserFrame
    DatabaseBrowserFrame.Title:SetText('DataTracker')
    DatabaseBrowserFrame:RegisterForDrag("LeftButton")

    ItemSearchFrame = DatabaseBrowserFrame.itemSearch
    searchBtn = ItemSearchFrame.searchBtn
    searchBtn:SetText(core.i18n.UI_SEARCH)

    local resetBtn = ItemSearchFrame.resetBtn
    resetBtn:SetText(core.i18n.UI_RESET)

    searchBox = ItemSearchFrame.SearchBox

    ItemDetailsFrame = DatabaseBrowserFrame.itemDetails

    minKillsFilter = ItemDetailsFrame.MinKillCount
    minKillsFilter.Instructions:SetText(core.i18n.UI_KILLS_PH)

    unitNameFilter = ItemDetailsFrame.UnitName
    unitNameFilter.Instructions:SetText(core.i18n.UI_UNIT_NAME)

    goldLevelFilter = ItemDetailsFrame.GoldLevel
    goldLevelFilter.Instructions:SetText(core.i18n.UI_GOLD_LEVEL)

    backBtn = ItemDetailsFrame.backBtn
    backBtn:SetText(core.i18n.UI_BACK)

    -- disable by default
    for i = 1, DT_RESULT_ITEMS_COUNT do
        local btnEntry = _G['DT_DatabaseBrowser_Entry' .. i]
        btnEntry:Disable()
    end

    DT_DatabaseBrowser_ScrollBar_Update()
    ItemSearchFrame:Show()
end

function DT_DatabaseBrowser_OnDragStart(self)
    core.logging:Trace('DT_DatabaseBrowser_OnDragStart')

    if not self.isLocked then
        self:StartMoving()
    end
end

function DT_DatabaseBrowser_OnDragStop(self)
    core.logging:Trace('DT_DatabaseBrowser_OnDragStop')

    self:StopMovingOrSizing()
end

function DT_DatabaseBrowser_OnShow(self)
    core.logging:Trace('DT_DatabaseBrowser_OnShow')
end

function DT_DatabaseBrowser_OnHide(self)
    core.logging:Trace('DT_DatabaseBrowser_OnHide')
end

function DT_DatabaseBrowser_OnReset(self)
    DT_SearchResults = {}
    searchBox:SetText('')
    DT_DatabaseBrowser_ScrollBar_Update()
end

function DT_DatabaseBrowser_OnSearch(self)
    core.logging:Trace('DT_DatabaseBrowser_OnSearch')

    DT_SearchResults = {}

    local index = 1

    ---@type string
    ---@diagnostic disable-next-line: assign-type-mismatch
    local searchText = searchBox:GetText()
    searchText = strtrim(strlower(searchText))
    if (strlen(searchText) > 0) then
        for itemId, itemInfo in pairs(DT_ItemDb) do
            local nameMatches = strfind(strlower(itemInfo.nam or ''), searchText, 1, true)
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
    core.logging:Trace('DT_DatabaseBrowser_OnBack')

    lastItemDetailsIndex = nil

    ---@diagnostic disable-next-line: undefined-field
    DatabaseBrowserFrame.itemSearch:Show()
    ---@diagnostic disable-next-line: undefined-field
    DatabaseBrowserFrame.itemDetails:Hide()
end

local function DT_CreateUnitResult(unitId, unitInfo, gold, percent, colorR, colorG, colorB)
    local result = {
        unitId = unitId,
        unitName = unitInfo.nam,
        zoneName = '',
        kills = unitInfo.kls,
        gold = gold,
        percent = percent,
        color = { r = colorR, g = colorG, b = colorB }
    }

    if unitInfo and unitInfo.mps then
        for mapId, _ in pairs(unitInfo.mps) do
            result.mapId = mapId
            break
        end
    end

    return result
end

local function DT_OpenWorldMap(mapId)
    if not WorldMapFrame:IsShown() then
        WorldMapFrame:SetParent(UIParent)
        WorldMapFrame:ClearAllPoints()
        WorldMapFrame:SetPoint("CENTER")
        WorldMapFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        WorldMapFrame:Show()
    end
    WorldMapFrame:SetMapID(mapId)
    WorldMapFrame:OnMapChanged()
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

    core.logging:Trace(itemResult.itemName, itemResult.itemId)

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
                        local percent = core.helper:CalculatePercentage(ltd, timesLooted)
                        local color = GetUnitColor(unitInfo.clf)
                        result = DT_CreateUnitResult(
                            unitId,
                            unitInfo,
                            core.helper:CalculateAvgUnitGoldCount(unitInfo, goldLevel),
                            core.helper:FormatPercentage(percent),
                            color.r, color.g, color.b)
                        break
                    end
                end
            end

            -- skinning loot
            local unitItems = unitInfo.its_sk
            if (unitItems) then
                local ltd_sk = tonumber(unitInfo['ltd_sk']) or 0
                for itemId, timesLooted in pairs(unitItems) do
                    if (itemResult.itemId == itemId) then
                        local percent = core.helper:CalculatePercentage(ltd_sk, timesLooted)
                        local color = GetUnitColor(unitInfo.clf)
                        result = DT_CreateUnitResult(
                            unitId,
                            unitInfo,
                            core.helper:CalculateAvgUnitGoldCount(unitInfo, goldLevel),
                            core.helper:FormatPercentage(percent),
                            color.r, color.g, color.b)
                        break
                    end
                end
            end

            if (result) then
                if (unitInfo.mps) then
                    for mapId, _ in pairs(unitInfo.mps) do
                        local mapinfo = C_Map.GetMapInfo(mapId)
                        if (mapinfo) then
                            result.zoneName = result.zoneName .. ' ' .. mapinfo.name
                            break
                        end
                    end
                elseif (unitInfo.zns) then
                    for zoneId, _ in pairs(unitInfo.zns) do
                        local text = core:GetZoneText(zoneId)
                        result.zoneName = result.zoneName .. ' ' .. text
                        break
                    end
                end

                if (add) then
                    totalResults = totalResults + 1
                    DT_SearchUnitResults[totalResults] = result
                end
            end
        end
    end

    table.sort(DT_SearchUnitResults, function(a, b)
        return a.zoneName < b.zoneName
    end)

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

-- updatefunction to handle item location results
function DT_DatabaseBrowser_ScrollBarLoc_Update()
    local totalResults = core.helper:GetTableSize(DT_SearchUnitResults)
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
        local fsZone = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Zone']

        ---@type FontString
        local fsGold = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Gold']

        ---@type FontString
        local fsKills = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Kills']

        ---@type FontString
        local fsPercentage = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Percentage']

        if (result) then
            btn:Enable()
            btn:SetAttribute('itemIndex', i + offset)

            btn:SetScript("OnClick", function(self)
                if result.mapId then
                    DT_OpenWorldMap(result.mapId)
                end
            end)

            btn:SetScript("OnEnter", function(self)
                if result.mapId then
                    _G[self:GetName() .. "Highlight"]:Show()
                end
            end)

            btn:SetScript("OnLeave", function(self)
                _G[self:GetName() .. "Highlight"]:Hide()
            end)

            fsUnit:SetText(result.unitName)
            fsUnit:SetTextColor(result.color.r, result.color.g, result.color.b, 1)

            fsZone:SetText(result.zoneName)

            if result.mapId then
                fsZone:SetTextColor(0, 0.63, 1)
            else
                fsZone:SetTextColor(1, 1, 1, 1)
            end

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
            fsZone:SetText('')
            fsGold:SetText('')
            fsKills:SetText('')
            fsPercentage:SetText('')
        end
    end
end

function DT_DatabaseBrowser_ScrollBar_Update()
    core.logging:Trace('DT_DatabaseBrowser_ScrollBar_Update')

    local totalResults = core.helper:GetTableSize(DT_SearchResults)
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

        btn:SetScript("OnEnter", function(self)
            local itemIndex = self:GetAttribute("itemIndex")
            if itemIndex then
                local result = DT_SearchResults[itemIndex]
                if result and result.itemId then
                    GameTooltip:SetOwner(self, "ANCHOR_NONE")

                    local screenWidth = UIParent:GetWidth()
                    local buttonLeft = self:GetLeft() or 0
                    if buttonLeft < screenWidth * 0.25 then
                        GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
                    else
                        GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0)
                    end

                    GameTooltip:SetItemByID(result.itemId)
                    GameTooltip:Show()
                end
            end

            _G[self:GetName() .. "Highlight"]:Show()
        end)

        btn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            _G[self:GetName() .. "Highlight"]:Hide()
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
