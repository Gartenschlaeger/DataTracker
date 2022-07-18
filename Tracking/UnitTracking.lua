---@class DataTracker_Core
local DataTracker = select(2, ...)

---Returns the classificationId for the given classification name
---@param unitClassification string
---@return number
local function ResolveUnitClassificationId(unitClassification)
    local classificationId = DT_UnitClassifications[unitClassification]
    if (classificationId == nil) then
        classificationId = 1000 + DataTracker.helper:GetTableSize(DT_UnitClassifications)
        DT_UnitClassifications[unitClassification] = classificationId
        DataTracker.logging:Debug('New classification ' .. unitClassification .. ' (' .. classificationId .. ')')
    end

    return classificationId
end

---Holds temporary informations for targeted units
DataTracker.TmpUnitInformations = {}

---Occures when the target is changed (used to store units in db)
function DataTracker:OnTargetChanged()
    DataTracker.logging:Trace('OnTargetChanged')

    if (UnitIsPlayer('target') or UnitIsPVP('target') or not UnitCanAttack('player', 'target')) then
        DataTracker.logging:Verbose('Ignore none attackable target')
        return
    end

    local unitGuid = UnitGUID('target')
    local unitName = UnitName('target')
    if (unitGuid == nil or unitName == nil) then
        return
    end

    if (DataTracker.helper:IsTrackableUnit(unitGuid)) then
        local unitId = DataTracker.helper:GetUnitIdFromGuid(unitGuid)

        local mobInfo = DT_UnitDb[unitId]
        if (mobInfo == nil) then
            mobInfo = {}
            DT_UnitDb[unitId] = mobInfo

            DataTracker.bc:NewUnit(unitId, unitName)
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
        tmp_unit_info.level = UnitLevel('target')
    end
end
