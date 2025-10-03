---@class DTCore
local _, core = ...

---Current MapId. If nil call to UpdateCurrentZone() is needed
---@type nil|number
core.CurrentMapId = nil

-- Updates the field DataTracker.CurrentZoneId
function core:UpdateCurrentZone()
    core.logging:Trace('UpdateCurrentZone')

    core.CurrentMapId = C_Map.GetBestMapForUnit('player')

    if (core.CurrentMapId == nil) then
        core.logging:Warning('Could not determine current map')
        return
    end

    core.logging:Debug('Changed current map (ID = ' .. (core.CurrentMapId or 0) .. ')')
end

---@param zoneId number
function core:GetZoneText(zoneId)
    local zone = DT_ZoneDb[zoneId]
    if (zone) then
        return zone
    end

    return nil
end
