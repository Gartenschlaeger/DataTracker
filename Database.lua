-- Item database
DT_ItemDb = {}

-- Unit database
DT_UnitDb = {}
DT_UnitClassifications = {}

-- Zones database
DT_ZoneDb = {}

function DataTracker:CleanupDatabase()
    -- units
    for _, unitInfos in pairs(DT_UnitDb) do
        unitInfos.cop = nil
        unitInfos.mnc = nil
        unitInfos.mxc = nil
    end
end
