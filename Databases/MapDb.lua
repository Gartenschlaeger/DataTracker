---@class DTCore
local DataTracker = select(2, ...)

local currentMapId = nil

DT_MapDb = {}

---@class DTMapDatabase
local MapDatabase = {}
DataTracker.MapDb = MapDatabase

---Returns the id of the current map
---@return number?
function MapDatabase.GetCurrentMapId()
    return currentMapId
end

---Returns the map name by id
---@param mapId number
---@return string|nil
function MapDatabase.GetById(self, mapId)
    return DT_MapDb[mapId]
end

---Tracks the current map
function MapDatabase.TrackCurrentMap(self)
    DataTracker.logging:Trace('mapDb:TrackCurrentMap')

    currentMapId = C_Map.GetBestMapForUnit('player')
    if (currentMapId) then
        local cMapInfo = C_Map.GetMapInfo(currentMapId)

        -- store map informations to easier access it by ui
        if (DT_MapDb[currentMapId] == nil) then
            DataTracker.bc:NewMap(cMapInfo.mapID, cMapInfo.name)
        end

        DT_MapDb[currentMapId] = cMapInfo.name

        DataTracker.logging:Debug('Changed map to ' .. cMapInfo.name .. ' (ID = ' .. cMapInfo.mapID .. ')')
    else
        DataTracker.logging:Warning('C_Map.GetBestMapForUnit returned nil')
    end
end
