-- Increments the kill counter
function DataTracker:TrackKill(unitId, unitName)
    DataTracker:LogTrace('TrackKill', unitId, unitName)

    if (DataTracker.CurrentZoneId == nil) then
        DataTracker:UpdateCurrentZone()
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
    zones[DataTracker.CurrentZoneId] = (zones[DataTracker.CurrentZoneId] or 0) + 1

    DataTracker:LogDebug('Kill: ' .. unitName .. ' (ID = ' .. unitId .. '), total kills = ' .. totalKills)
end

-- Temporarilly storage of attacked unit guids
local tmp_attackedUnitGuids = {}

-- Occures for any combat log
function DataTracker:OnCombatLogEventUnfiltered()
    local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags,
        damage_spellid, overkill_spellname, school_spellSchool, resisted_amount,
        blocked_overkill = CombatLogGetCurrentEventInfo()

    if destGUID ~= nil
	then
		local guidType = select(1, strsplit("-", destGUID))
        local isDamageSubEvent = subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE';
        local isPlayerAttack = sourceGUID == UnitGUID('player')
        local isPetAttack = sourceGUID == UnitGUID('pet')

        DataTracker:LogVerbose('OnCombatLogEventUnfiltered', subEvent, sourceGUID, sourceName, destGUID, destName)

        if (isDamageSubEvent and (isPlayerAttack or isPetAttack)) then
            tmp_attackedUnitGuids[destGUID] = true
        elseif (subEvent=="PARTY_KILL") then
            tmp_attackedUnitGuids[destGUID] = true
	    elseif (subEvent == 'UNIT_DIED' and guidType == "Creature" and tmp_attackedUnitGuids[destGUID] == true) then
            tmp_attackedUnitGuids[destGUID] = nil
            local unitId = DataTracker:UnitGuidToId(destGUID)
            DataTracker:TrackKill(unitId, destName)
        end
	end
end