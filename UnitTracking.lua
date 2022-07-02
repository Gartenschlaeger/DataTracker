-- Returns the classificationId for the given classification name
local function ResolveUnitClassificationId(unitClassification)
    local classificationId = DT_UnitClassifications[unitClassification]
    if (classificationId == nil) then
        classificationId = 1000 + DataTracker:GetTableSize(DT_UnitClassifications)
        DT_UnitClassifications[unitClassification] = classificationId
        DataTracker:LogDebug('New classification ' .. unitClassification .. ' (' .. classificationId .. ')')
    end

    return classificationId
end

DataTracker.TmpUnitInformations = {}

-- Occures when the target is changed (used to store units in db)
function DataTracker:OnTargetChanged()
    DataTracker:LogTrace('OnTargetChanged')

    if (UnitIsPlayer('target') or not UnitCanAttack('player', 'target')) then
        DataTracker:LogVerbose('Ignore none attackable target')
        return
    end

    local unitGuid = UnitGUID('target')
    local unitName = UnitName('target')
    local unitLevel = UnitLevel('target')

    if (unitGuid == nil or unitName == nil) then
        return
    end

    local unitType = select(1, strsplit('-', unitGuid))
    if (unitType == 'Creature') then
        local unitId = DataTracker:UnitGuidToId(unitGuid)

        local mobInfo = DT_UnitDb[unitId]
        if (mobInfo == nil) then
            mobInfo = {}
            DT_UnitDb[unitId] = mobInfo

            DataTracker:OnNewUnitBroadcast(DataTracker.i18n.NEW_UNIT .. ': ' .. unitName)
        end

        local classification = UnitClassification('target')

        mobInfo['nam'] = unitName
        mobInfo['clf'] = ResolveUnitClassificationId(classification)

        local tmp_unit_info = DataTracker.TmpUnitInformations[unitGuid]
        if (tmp_unit_info == nil) then
            tmp_unit_info = {}
            DataTracker.TmpUnitInformations[unitGuid] = tmp_unit_info
        end

        tmp_unit_info.time = GetTime()
        tmp_unit_info.id = unitId
        tmp_unit_info.level = unitLevel
    end
end

-- Converts a unit guid to an id
function DataTracker:UnitGuidToId(unitGuid)
    return tonumber(select(6, strsplit('-', unitGuid)), 10)
end
