---@class DTCore
local _, core = ...

---Returns the classificationId for the given classification name
---@param unitClassification string
---@return number
local function ResolveUnitClassificationId(unitClassification)
    local classificationId = DT_UnitClassifications[unitClassification]
    if (classificationId == nil) then
        classificationId = 1000 + core.helper:GetTableSize(DT_UnitClassifications)
        DT_UnitClassifications[unitClassification] = classificationId
        core.logging:Debug('New classification ' .. unitClassification .. ' (' .. classificationId .. ')')
    end

    return classificationId
end

---Holds temporary informations for targeted units
core.TmpUnitInformations = {}

---Occures when the target is changed (used to store units in db)
function core:OnTargetChanged()
    core.logging:Trace('OnTargetChanged')

    if (UnitIsPlayer('target') or not UnitCanAttack('player', 'target')) then
        core.logging:Verbose('Ignore none attackable target')
        return
    end

    local unitGuid = UnitGUID('target')
    local unitName = UnitName('target')
    if (unitGuid == nil or unitName == nil) then
        return
    end

    if (core.helper:IsTrackableUnit(unitGuid)) then
        local unitId = core.helper:GetUnitIdFromGuid(unitGuid)

        local mobInfo = DT_UnitDb[unitId]
        if (mobInfo == nil) then
            mobInfo = {}
            DT_UnitDb[unitId] = mobInfo

            core.bc:NewUnit(core.i18n.NEW_UNIT .. ': ' .. unitName)
        end

        local classification = UnitClassification('target')

        mobInfo['nam'] = unitName
        mobInfo['clf'] = ResolveUnitClassificationId(classification)

        local tmp_unit_info = core.TmpUnitInformations[unitGuid]
        if (tmp_unit_info == nil) then
            tmp_unit_info = {}
            core.TmpUnitInformations[unitGuid] = tmp_unit_info
        end

        tmp_unit_info.time = GetTime()
        tmp_unit_info.id = unitId
        tmp_unit_info.level = UnitLevel('target')
    end
end
