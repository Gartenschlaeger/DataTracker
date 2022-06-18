function DT_DatabaseBrowser_OnLoad()
    DT_LogTrace('DT_DatabaseBrowser_OnLoad')

    DT_DatabaseBrowser.Title:SetText('DataTracker')
    DT_DatabaseBrowser:RegisterForDrag("LeftButton")

    DT_DatabaseBrowser_ScrollBar:Show()
end

function DT_DatabaseBrowser_OnDragStart(self)
    DT_LogTrace('DT_DatabaseBrowser_OnDragStart')

    if not self.isLocked then
        self:StartMoving()
    end
end

function DT_DatabaseBrowser_OnDragStop(self)
    DT_LogTrace('DT_DatabaseBrowser_OnDragStop')

    self:StopMovingOrSizing()
end

function DT_DatabaseBrowser_OnShow()
    DT_LogTrace('DT_DatabaseBrowser_OnShow')
end

function DT_DatabaseBrowser_OnHide()
    DT_LogTrace('DT_DatabaseBrowser_OnHide')
end

function DT_DatabaseBrowser_OnSearch()
    DT_LogTrace('DT_DatabaseBrowser_OnSearch')
    DT_DatabaseBrowser_ScrollBar_Update()
end

-- https://wowwiki-archive.fandom.com/wiki/Making_a_scrollable_list_using_FauxScrollFrameTemplate
-- FauxScrollFrame_OnVerticalScroll(self, value, itemHeight, updateFunction)
-- FauxScrollFrame_Update(frame, totalItems, numOfLines, pixelHeightPerLine)

local DT_RESULT_ITEMS_COUNT = 25
local DT_RESULT_PIXEL_HEIGHT = 18

function DT_DatabaseBrowser_ScrollBar_Update()
    DT_LogTrace('DT_DatabaseBrowser_ScrollBar_Update')

    FauxScrollFrame_Update(DT_DatabaseBrowser_ScrollBar, 150, DT_RESULT_ITEMS_COUNT, DT_RESULT_PIXEL_HEIGHT)

    local offet = FauxScrollFrame_GetOffset(DT_DatabaseBrowser_ScrollBar)
	for i = 1, DT_RESULT_ITEMS_COUNT do
        local indexString = _G["DT_DatabaseBrowser_Entry"..i..'Index']
        indexString:SetText('A ' .. i + offet)

        local valueString = _G["DT_DatabaseBrowser_Entry"..i..'Value']
        valueString:SetText('B ' .. i + offet)

        local nameString = _G["DT_DatabaseBrowser_Entry"..i..'Name']
        nameString:SetText('C ' .. i + offet)
	end
end