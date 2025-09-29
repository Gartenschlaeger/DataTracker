---@class DTCore
local _, core = ...

-- Increments the kill counter
function core:TrackKill(unitId, unitName)
    core.logging:Trace('TrackKill', unitId, unitName)

    if (core.CurrentMapId == nil) then
        core:UpdateCurrentZone()
    end

    -- get unit info
    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    -- update kill counter
    local totalKills = (unitInfo['kls'] or 0) + 1
    unitInfo['kls'] = totalKills

    -- update maps
    local maps = unitInfo['mps']
    if (maps == nil) then
        maps = {}
        unitInfo['mps'] = maps
    end

    maps[core.CurrentMapId] = (maps[core.CurrentMapId] or 0) + 1

    -- cleanup old data
    unitInfo['zns'] = nil

    core.logging:Debug('Kill: ' .. unitName .. ' (ID = ' .. unitId .. '), total kills = ' .. totalKills)
end

---Temporarily storage for attacked unit guids
core.TmpAttackedUnitGuids = {}

-- Occures for any combat log
function core:OnCombatLogEventUnfiltered()
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()

    if (destGUID) then
        core.logging:Verbose('OnCombatLogEventUnfiltered', subEvent, sourceGUID, sourceName, destGUID, destName)

        local isDamageSubEvent = subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE';
        local isPlayerAttack = sourceGUID == UnitGUID('player')
        local isPetAttack = sourceGUID == UnitGUID('pet')

        if (isDamageSubEvent and (isPlayerAttack or isPetAttack)) then
            core.TmpAttackedUnitGuids[destGUID] = true
        elseif (subEvent == "PARTY_KILL") then
            core.TmpAttackedUnitGuids[destGUID] = true
        elseif (
                subEvent == 'UNIT_DIED' and core.helper:IsTrackableUnit(destGUID) and
                core.TmpAttackedUnitGuids[destGUID] == true) then
            core.TmpAttackedUnitGuids[destGUID] = nil
            local unitId = core.helper:GetUnitIdFromGuid(destGUID)
            core:TrackKill(unitId, destName)
        end
    end
end
