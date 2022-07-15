---@class DTCore
local _, core = ...

-- Increments the kill counter
function core:TrackKill(unitId, unitName)
    core.logging:Trace('TrackKill', unitId, unitName)

    if (core.CurrentZoneId == nil) then
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

    -- update zones
    local zones = unitInfo['zns']
    if (zones == nil) then
        zones = {}
        unitInfo['zns'] = zones
    end

    -- update zone kills counter
    zones[core.CurrentZoneId] = (zones[core.CurrentZoneId] or 0) + 1

    core.logging:Debug('Kill: ' .. unitName .. ' (ID = ' .. unitId .. '), total kills = ' .. totalKills)
end

---Temporarily storage for attacked unit guids
core.TmpAttackedUnitGuids = {}

-- Occures for any combat log
function core:OnCombatLogEventUnfiltered()
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()

    if destGUID ~= nil
    then
        local guidType = select(1, strsplit("-", destGUID))
        local isDamageSubEvent = subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE';
        local isPlayerAttack = sourceGUID == UnitGUID('player')
        local isPetAttack = sourceGUID == UnitGUID('pet')

        core.logging:Verbose('OnCombatLogEventUnfiltered', subEvent, sourceGUID, sourceName, destGUID, destName)

        if (isDamageSubEvent and (isPlayerAttack or isPetAttack)) then
            core.TmpAttackedUnitGuids[destGUID] = true
        elseif (subEvent == "PARTY_KILL") then
            core.TmpAttackedUnitGuids[destGUID] = true
        elseif (subEvent == 'UNIT_DIED' and guidType == "Creature" and core.TmpAttackedUnitGuids[destGUID] == true) then
            core.TmpAttackedUnitGuids[destGUID] = nil
            local unitId = core.helper:GetUnitIdFromGuid(destGUID)
            core:TrackKill(unitId, destName)
        end
    end
end
