local function debugTable(tbl)
    for k,v in pairs(tbl) do
        print(k, type(v))
    end
end

local DT_RESULT_ITEMS_COUNT = 18
local DT_RESULT_PIXEL_HEIGHT = 25

---@type Frame
local DatabaseBrowserFrame

function DT_DatabaseBrowser_OnLoad(self)
    DataTracker:LogTrace('DT_DatabaseBrowser_OnLoad')

    ---@diagnostic disable-next-line: undefined-global
    DatabaseBrowserFrame = DT_DatabaseBrowserFrame
    DatabaseBrowserFrame.Title:SetText('DataTracker')
    DatabaseBrowserFrame:RegisterForDrag("LeftButton")

    -- disable by default
    for i = 1, DT_RESULT_ITEMS_COUNT do
        local btnEntry = _G['DT_DatabaseBrowser_Entry' .. i]
        btnEntry:Disable()
    end

    ---@type Frame
    local itemSearchFrame = DatabaseBrowserFrame.itemSearch
    itemSearchFrame:Show()
end

function DT_DatabaseBrowser_OnDragStart(self)
    DataTracker:LogTrace('DT_DatabaseBrowser_OnDragStart')

    if not self.isLocked then
        self:StartMoving()
    end
end

function DT_DatabaseBrowser_OnDragStop(self)
    DataTracker:LogTrace('DT_DatabaseBrowser_OnDragStop')

    self:StopMovingOrSizing()
end

function DT_DatabaseBrowser_OnShow(self)
    DataTracker:LogTrace('DT_DatabaseBrowser_OnShow')
end

function DT_DatabaseBrowser_OnHide(self)
    DataTracker:LogTrace('DT_DatabaseBrowser_OnHide')
end

function DT_DatabaseBrowser_OnSearch(self)
    DataTracker:LogTrace('DT_DatabaseBrowser_OnSearch')

    DT_SearchResults = {}

    local index = 1
    local searchText = strtrim(DT_DatabaseBrowser_SearchBox:GetText())
    searchText = strlower(searchText)

    if (searchText and strlen(searchText) > 0) then
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
    DataTracker:LogTrace('DT_DatabaseBrowser_OnBack')

    DatabaseBrowserFrame.itemSearch:Show()
    DatabaseBrowserFrame.itemDetails:Hide()
end

local function createUnitResult(unitId, unitName)
    return {
        unitId = unitId,
        unitName = unitName,
        zoneName = '',
        percent = ''
    }
end

local function LoadItemDetails(itemIndex)
    local itemResult = DT_SearchResults[itemIndex]

    DataTracker:LogTrace(itemResult.itemName, itemResult.itemId)

    DT_SearchUnitResults = {}

    ---@type FontString
    local title = DT_DatabaseBrowser_DetailTitle
    local itemTextureId = GetItemIcon(itemResult.itemId)
    local itemTexture = '|T' .. itemTextureId .. ':22|t'
    title:SetText(itemTexture .. ' ' .. itemResult.itemName)
    title:SetTextColor(itemResult.color.r, itemResult.color.g, itemResult.color.b)

    local totalResults = 0
    for unitId, unitInfos in pairs(DT_UnitDb) do
        local result = nil

        -- general loot items
        local unitItems = unitInfos.its
        if (unitItems) then
            for itemId, _ in pairs(unitItems) do
                if (itemResult.itemId == itemId) then
                    result = createUnitResult(unitId, unitInfos.nam)
                    break
                end
            end
        end

        -- skinning loot
        local unitItems = unitInfos.its_sk
        if (unitItems) then
            for itemId, _ in pairs(unitItems) do
                if (itemResult.itemId == itemId) then
                    result = createUnitResult(unitId, unitInfos.nam)
                    break
                end
            end
        end

        if (result) then
            if (unitInfos.zns) then
                for zoneId, _ in pairs(unitInfos.zns) do
                    local text = DataTracker:GetZoneText(zoneId)
                    result.zoneName = result.zoneName .. ' ' .. text
                end
            end

            totalResults = totalResults + 1
            DT_SearchUnitResults[totalResults] = result
        end

    end

    -- print(totalResults)
    DT_DatabaseBrowser_ScrollBarLoc_Update()

    DatabaseBrowserFrame.itemSearch:Hide()
    DatabaseBrowserFrame.itemDetails:Show()
end

function DT_DatabaseBrowser_ScrollBarLoc_Update()
    local totalResults = DataTracker:GetTableSize(DT_SearchUnitResults)
    FauxScrollFrame_Update(DT_DatabaseBrowser_ScrollBarLoc, totalResults, DT_RESULT_ITEMS_COUNT, DT_RESULT_PIXEL_HEIGHT)

    local offset = FauxScrollFrame_GetOffset(DT_DatabaseBrowser_ScrollBarLoc)

    -- print('totalResults:', totalResults, ', from:', offset, 'to:', offset + DT_RESULT_ITEMS_COUNT)

    for i = 1, DT_RESULT_ITEMS_COUNT do
        local result = DT_SearchUnitResults[i + offset]

        local btn = _G['DT_DatabaseBrowser_EntryLoc' .. i]
        local fsVal1 = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Val1']
        local fsVal2 = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Val2']
        local fsVal3 = _G["DT_DatabaseBrowser_EntryLoc" .. i .. 'Val3']

        if (result) then
            btn:Enable()
            fsVal1:SetText(result.unitName)
            fsVal2:SetText(result.zoneName)
            fsVal3:SetText(result.percent)
        else
            btn:Disable()
            fsVal1:SetText('')
            fsVal2:SetText('')
            fsVal3:SetText('')
        end
    end
end

function DT_DatabaseBrowser_ScrollBar_Update()
    DataTracker:LogTrace('DT_DatabaseBrowser_ScrollBar_Update')

    local totalResults = DataTracker:GetTableSize(DT_SearchResults)
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