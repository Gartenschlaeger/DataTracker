---@class DTCore
local _, core = ...

-- Item database
DT_ItemDb = {}

-- Units database
DT_UnitDb = {}
DT_UnitClassifications = {}

-- Zones database
DT_ZoneDb = {}

---Clean up databases
function core:CleanupDatabase()
    -- units
    for _, unitInfos in pairs(DT_UnitDb) do

        -- remove old copper counters
        unitInfos.cop = nil
        unitInfos.mnc = nil
        unitInfos.mxc = nil

        -- remove mining loot from general loot
        if (unitInfos.its and unitInfos.its_mn) then
            for itemId, _ in pairs(unitInfos.its_mn) do
                if (unitInfos.its[itemId]) then
                    unitInfos.its[itemId] = nil
                    core.logging:Debug('RM: ItemID = ' .. itemId .. ', UnitID = ' .. unitInfos.nam)
                end
            end
        end

        -- remove herbalism loot from general loot
        if (unitInfos.its and unitInfos.its_hb) then
            for itemId, _ in pairs(unitInfos.its_hb) do
                if (unitInfos.its[itemId]) then
                    unitInfos.its[itemId] = nil
                    core.logging:Debug('RM: ItemID = ' .. itemId .. ', UnitID = ' .. unitInfos.nam)
                end
            end
        end

    end
end
