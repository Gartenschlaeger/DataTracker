---@class DataTracker_Core
local DataTracker = select(2, ...)

---@class DataTracker_KillTracker
local killTracker = {}
DataTracker.killTracker = killTracker

---Temporarily storage for attacked unit guids
local attackedUnitGuids = {}

-- Increments the kill counter
function killTracker:Track(unitGuid, unitId, unitName)
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

    -- if unit was killed but has no loot, increment looting counter to have correct percentage calculations
    -- wait for a second because otherwise the call to CanLootUnit perhaps returns invalid values
    C_Timer.After(1, function()
        local hasLoot, canLoot = CanLootUnit(unitGuid)
        if (not hasLoot and not canLoot) then
            -- print('CanLootUnit', CanLootUnit(unitGuid))
            unitInfo.ltd = DataTracker.helper:IfNil(unitInfo.ltd, 0) + 1
            unitInfo.elt = DataTracker.helper:IfNil(unitInfo.elt, 0) + 1
        end
    end)

    -- map kill counter
    local mps = unitInfo.mps
    if (mps == nil) then
        mps = {}
        unitInfo.mps = mps
    end

    mps[DataTracker.MapDb:GetCurrentMapId()] = (mps[DataTracker.MapDb:GetCurrentMapId()] or 0) + 1

    DataTracker.logging:Debug('Kill: ' .. unitName .. ' (ID = ' .. unitId .. '), total kills = ' .. totalKills)
end

-- Occures for any combat log
function killTracker:OnCombatLogEventUnfiltered()
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()

    if (destGUID) then
        DataTracker.logging:Verbose('OnCombatLogEventUnfiltered', subEvent, sourceGUID, sourceName, destGUID, destName)

        local isDamageSubEvent = subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE';
        local isPlayerAttack = sourceGUID == UnitGUID('player')
        local isPetAttack = sourceGUID == UnitGUID('pet')

        if (isDamageSubEvent and (isPlayerAttack or isPetAttack)) then
            attackedUnitGuids[destGUID] = true
        elseif (subEvent == "PARTY_KILL") then
            attackedUnitGuids[destGUID] = true
        elseif (
            subEvent == 'UNIT_DIED' and DataTracker.helper:IsTrackableUnit(destGUID) and
                attackedUnitGuids[destGUID] == true) then
            attackedUnitGuids[destGUID] = nil
            local unitId = DataTracker.helper:GetUnitIdFromGuid(destGUID)
            self:Track(destGUID, unitId, destName)
        end
    end
end
