function DT_DatabaseBrowser_OnLoad()
    DT_LogTrace('DT_DatabaseBrowser_OnLoad')

    DT_DatabaseBrowser.Title:SetText('DataTracker')
    DT_DatabaseBrowser:RegisterForDrag("LeftButton")
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
end
