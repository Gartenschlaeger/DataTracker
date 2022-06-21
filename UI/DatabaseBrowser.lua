function DT_DatabaseBrowser_OnLoad()
    DataTracker:LogTrace('DT_DatabaseBrowser_OnLoad')

    DT_DatabaseBrowser.Title:SetText('DataTracker')
    DT_DatabaseBrowser:RegisterForDrag("LeftButton")

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

function DT_DatabaseBrowser_OnShow()
    DataTracker:LogTrace('DT_DatabaseBrowser_OnShow')
end

function DT_DatabaseBrowser_OnHide()
    DataTracker:LogTrace('DT_DatabaseBrowser_OnHide')
end

function DT_DatabaseBrowser_OnSearch()
    DataTracker:LogTrace('DT_DatabaseBrowser_OnSearch')

    DT_SearchResults = {}

    local index = 1
    local searchText = strtrim(DT_DatabaseBrowser_SearchBox:GetText())
    searchText = strlower(searchText)

    if (searchText and strlen(searchText) > 0) then
        for itemId, itemInfo in pairs(DT_ItemDb) do
            local nameMatches = strfind(strlower(itemInfo['nam']), searchText, 1, true)
            if (nameMatches) then
                local result = {}
                result['itemId'] = itemId
                result['itemName'] = itemInfo['nam']

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

function DT_DatabaseBrowser_ScrollBar_Update()
    DataTracker:LogTrace('DT_DatabaseBrowser_ScrollBar_Update')

    local totalResults = DataTracker:GetTableSize(DT_SearchResults)
    FauxScrollFrame_Update(DT_DatabaseBrowser_ScrollBar, totalResults, DT_RESULT_ITEMS_COUNT, DT_RESULT_PIXEL_HEIGHT)

    local offset = FauxScrollFrame_GetOffset(DT_DatabaseBrowser_ScrollBar)
	for i = 1, DT_RESULT_ITEMS_COUNT do
        local result = DT_SearchResults[i + offset]

        local indexString = _G["DT_DatabaseBrowser_Entry"..i..'Index']
        local valueString = _G["DT_DatabaseBrowser_Entry"..i..'Value']
        local nameString = _G["DT_DatabaseBrowser_Entry"..i..'Name']

        if (result) then
            indexString:SetText(result.itemName)
            valueString:SetText(result.itemId)
            nameString:SetText('') -- TODO: zone name
        else
            indexString:SetText('')
            valueString:SetText('')
            nameString:SetText('')
        end

	end
end