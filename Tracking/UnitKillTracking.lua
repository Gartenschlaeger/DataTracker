---@class DataTracker_Core
local DataTracker = select(2, ...)

-- Increments the kill counter
function DataTracker:TrackKill(unitId, unitName)
    DataTracker.logging:Trace('TrackKill', unitId, unitName)

    -- get unit info
    local unitInfo = DT_UnitDb[unitId]
    if (unitInfo == nil) then
        unitInfo = {}
        DT_UnitDb[unitId] = unitInfo
    end

    -- total kill counter
    local totalKills = (unitInfo.kls or 0) + 1
    unitInfo.kls = totalKills

    -- map kill counter
    local mps = unitInfo.mps
    if (mps == nil) then
        mps = {}
        unitInfo.mps = mps
    end

    mps[DataTracker.MapDb:GetCurrentMapId()] = (mps[DataTracker.MapDb:GetCurrentMapId()] or 0) + 1

    DataTracker.logging:Debug('Kill: ' .. unitName .. ' (ID = ' .. unitId .. '), total kills = ' .. totalKills)
end

---Temporarily storage for attacked unit guids
DataTracker.TmpAttackedUnitGuids = {}

-- Occures for any combat log
function DataTracker:OnCombatLogEventUnfiltered()
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()

    if (destGUID) then
        DataTracker.logging:Verbose('OnCombatLogEventUnfiltered', subEvent, sourceGUID, sourceName, destGUID, destName)

        local isDamageSubEvent = subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE';
        local isPlayerAttack = sourceGUID == UnitGUID('player')
        local isPetAttack = sourceGUID == UnitGUID('pet')

        if (isDamageSubEvent and (isPlayerAttack or isPetAttack)) then
            DataTracker.TmpAttackedUnitGuids[destGUID] = true
        elseif (subEvent == "PARTY_KILL") then
            DataTracker.TmpAttackedUnitGuids[destGUID] = true
        elseif (
            subEvent == 'UNIT_DIED' and DataTracker.helper:IsTrackableUnit(destGUID) and
                DataTracker.TmpAttackedUnitGuids[destGUID] == true) then
            DataTracker.TmpAttackedUnitGuids[destGUID] = nil
            local unitId = DataTracker.helper:GetUnitIdFromGuid(destGUID)
            DataTracker:TrackKill(unitId, destName)
        end
    end
end
