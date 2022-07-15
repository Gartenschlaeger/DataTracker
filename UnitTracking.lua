---@class DTCore
local _, core = ...

---Converts UnitGuid to UnitID
---@param unitGuid string
---@return integer
function core:UnitGuidToId(unitGuid)
    return tonumber(select(6, strsplit('-', unitGuid)), 10)
end

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
    local unitLevel = UnitLevel('target')

    if (unitGuid == nil or unitName == nil) then
        return
    end

    local unitType = select(1, strsplit('-', unitGuid))
    if (unitType == 'Creature') then
        local unitId = core:UnitGuidToId(unitGuid)

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
        tmp_unit_info.level = unitLevel
    end
end
