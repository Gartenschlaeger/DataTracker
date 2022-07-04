-- Item database
DT_ItemDb = {}

-- Units database
DT_UnitDb = {}
DT_UnitClassifications = {}

-- Zones database
DT_ZoneDb = {}

---Cleans up the databases (depricated or old data)
function DataTracker:CleanupDatabase()
    -- units db
    for _, unitInfos in pairs(DT_UnitDb) do
        unitInfos.cop = nil
        unitInfos.mnc = nil
        unitInfos.mxc = nil
    end
end
