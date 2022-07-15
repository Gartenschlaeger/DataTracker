---@class DTCore
local _, core = ...

---Current ZoneId. If nil call to UpdateCurrentZone() is needed
---@type nil|number
core.CurrentZoneId = nil

-- Updates the field DataTracker.CurrentZoneId
function core:UpdateCurrentZone()
	core.logging:Trace('UpdateCurrentZone')

	local zoneText = GetZoneText()
	if (not zoneText or zoneText == '') then
		core.logging:Warning('Invalid ZoneText, text = "' .. zoneText .. '"')
		return
	end

	-- find zone ID in db if already known
	local zoneId = nil
	for id, name in pairs(DT_ZoneDb) do
		if zoneText == name then
			zoneId = id
			core.logging:Verbose('Found existing match for Zone in db, zoneId = ' .. zoneId .. ', zoneText = ' .. zoneText)
			break
		end
	end

	-- if zone is unknown add it to db
	if zoneId == nil then
		zoneId = 1000 + core.helper:GetTableSize(DT_ZoneDb)
		core.logging:Verbose('Write new ZoneText to db, zoneId = ' .. zoneId .. ', zoneText = ' .. zoneText)
		DT_ZoneDb[zoneId] = zoneText

		core.bc:NewZone(core.i18n.NEW_ZONE .. ': ' .. zoneText)
	end

	core.CurrentZoneId = zoneId
	core.logging:Debug('Changed zone to ' .. zoneText .. ' (ID = ' .. zoneId .. ')')
end

---@param zoneId number
function core:GetZoneText(zoneId)
	local zone = DT_ZoneDb[zoneId]
	if (zone) then
		return zone
	end

	return nil
end
