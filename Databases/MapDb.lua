---@class DTCore
local _, core = ...

local currentMapId = nil

DT_MapDb = {}

---@class DTMapDatabase
local mapDb = {}
core.mapDb = mapDb

---Returns the id of the current map
---@return number?
function mapDb.GetCurrentMapId()
    return currentMapId
end

---Returns the map name by id
---@param mapId number
---@return string|nil
function mapDb.GetById(self, mapId)
    return DT_MapDb[mapId]
end

---Tracks the current map
function mapDb.TrackCurrentMap(self)
    core.logging:Trace('mapDb:TrackCurrentMap')

    currentMapId = C_Map.GetBestMapForUnit('player')
    if (currentMapId) then
        local cMapInfo = C_Map.GetMapInfo(currentMapId)

        -- store map informations to easier access it by ui
        if (DT_MapDb[currentMapId] == nil) then
            core.bc:NewMap(cMapInfo.mapID, cMapInfo.name)
        end

        DT_MapDb[currentMapId] = cMapInfo.name

        core.logging:Debug('Changed map to ' .. cMapInfo.name .. ' (ID = ' .. cMapInfo.mapID .. ')')
    else
        core.logging:Warning('C_Map.GetBestMapForUnit returned nil')
    end
end
