-- Current ZoneId. If nil call to UpdateCurrentZone() is needed
DataTracker.CurrentZoneId = nil

-- Updates the field DataTracker.CurrentZoneId
function DataTracker:UpdateCurrentZone()
    self:LogTrace('UpdateCurrentZone')

    local zoneText = GetZoneText()
    if (not zoneText or zoneText == '') then
        self:LogWarning('Invalid ZoneText, text = "' .. zoneText .. '"')
        return
    end

	-- find zone ID in db if already known
	local zoneId = nil
	for id, name in pairs(DT_ZoneDb) do
		if zoneText == name then
			zoneId = id
            self:LogVerbose('Found existing match for Zone in db, zoneId = ' .. zoneId .. ', zoneText = ' .. zoneText)
			break
		end
	end

	-- if zone is unknown add it to db
	if zoneId == nil then
        zoneId = 1000 + self:GetTableSize(DT_ZoneDb)
        self:LogVerbose('Write new ZoneText to db, zoneId = ' .. zoneId .. ', zoneText = ' .. zoneText)
		DT_ZoneDb[zoneId] = zoneText

        self:LogInfo(DataTracker.i18n.NEW_ZONE .. ': ' .. zoneText)
	end

	self.CurrentZoneId = zoneId
    self:LogDebug('Changed zone to ' .. zoneText .. ' (ID = ' .. zoneId .. ')')
end

---@param zoneId number
function DataTracker:GetZoneText(zoneId)
	local zone = DT_ZoneDb[zoneId]
	if (zone) then
		return zone
	end

	return nil
end