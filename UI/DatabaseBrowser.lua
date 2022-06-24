function DT_DatabaseBrowser_OnLoad(self)
    DataTracker:LogTrace('DT_DatabaseBrowser_OnLoad')

    DT_DatabaseBrowser.Title:SetText('DataTracker')
    DT_DatabaseBrowser:RegisterForDrag("LeftButton")

    -- disable by default
    for i = 1, 25 do
        _G['DT_DatabaseBrowser_Entry' .. i]:Disable()
    end

    DT_DatabaseBrowser_ScrollBar:Show()
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

-- https://wowwiki-archive.fandom.com/wiki/Making_a_scrollable_list_using_FauxScrollFrameTemplate
-- FauxScrollFrame_OnVerticalScroll(self, value, itemHeight, updateFunction)
-- FauxScrollFrame_Update(frame, totalItems, numOfLines, pixelHeightPerLine)

local DT_RESULT_ITEMS_COUNT = 25
local DT_RESULT_PIXEL_HEIGHT = 18

function DT_DatabaseBrowser_ScrollBar_Update(self)
    DataTracker:LogTrace('DT_DatabaseBrowser_ScrollBar_Update')

    local totalResults = DataTracker:GetTableSize(DT_SearchResults)
    FauxScrollFrame_Update(DT_DatabaseBrowser_ScrollBar, totalResults, DT_RESULT_ITEMS_COUNT, DT_RESULT_PIXEL_HEIGHT)

    local offset = FauxScrollFrame_GetOffset(DT_DatabaseBrowser_ScrollBar)
	for i = 1, DT_RESULT_ITEMS_COUNT do
        local result = DT_SearchResults[i + offset]

        local btn = _G['DT_DatabaseBrowser_Entry' .. i]
        btn:SetAttribute('itemIndex', i + offset)
        btn:SetScript("OnClick", function(self)
            local itemIndex = tonumber(self:GetAttribute('itemIndex'))
            local result = DT_SearchResults[itemIndex]

            -- TODO: show where the item can be found (zone, unit, chance)
            DataTracker:LogDebug(result.itemName, result.itemId)
        end)

        local fsVal1 = _G["DT_DatabaseBrowser_Entry" .. i .. 'Val1']
        local fsVal2 = _G["DT_DatabaseBrowser_Entry" .. i .. 'Val2']
        local fsVal3 = _G["DT_DatabaseBrowser_Entry" .. i .. 'Val3']

        if (result) then
            btn:Enable()
            fsVal1:SetText(result.itemName)
            fsVal1:SetTextColor(result.color.r, result.color.g, result.color.b)
        else
            btn:Disable()
            fsVal1:SetText('')
            fsVal2:SetText('')
            fsVal3:SetText('')
        end
	end
end