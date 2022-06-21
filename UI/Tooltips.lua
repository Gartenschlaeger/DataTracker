local tooltipWasModified = nil

local function OnTooltipSetUnit(tooltip)
    local _, unit = tooltip:GetUnit();
    if (unit) then
        local unitGuid = UnitGUID(unit);
        local unitId = DataTracker:UnitGuidToId(unitGuid);
        if (unitId and tooltipWasModified ~= unitId) then
            local unitInfo = DT_UnitDb[unitId]
            if (unitInfo) then
                local shouldAddAnEmptyLine = true

                local timesLooted = tonumber(unitInfo['ltd']) or 0
                if (timesLooted > 0) then
                    if (shouldAddAnEmptyLine) then
                        tooltip:AddLine(' ')
                        shouldAddAnEmptyLine = false
                    end

                    tooltip:AddDoubleLine('Looted', timesLooted, 1, 1, 1, 1, 1, 1)
                end

                local timesKilled = tonumber(unitInfo['kls']) or 0
                if (timesKilled > 0) then
                    if (shouldAddAnEmptyLine) then
                        tooltip:AddLine(' ')
                        shouldAddAnEmptyLine = false
                    end

                    tooltip:AddDoubleLine('Killed', timesKilled, 1, 1, 1, 1, 1, 1)
                end

                local copper = tonumber(unitInfo['cop']) or 0
                if (timesLooted > 0 and copper > 0) then
                    if (shouldAddAnEmptyLine) then
                        tooltip:AddLine(' ')
                        shouldAddAnEmptyLine = false
                    end

                    tooltip:AddDoubleLine('Avg. coins', GetCoinTextureString(math.floor(copper / timesLooted)), 1, 1, 1, 1, 1, 1)
                end

                local lootInfos = unitInfo['its']
                if (lootInfos) then
                    shouldAddAnEmptyLine = true
                    for itemId, itemsAmount in pairs(lootInfos) do
                        local itemInfo = DT_ItemDb[itemId]
                        if (itemInfo) then
                            local itemQuality = tonumber(itemInfo['qlt'])
                            --if (itemQuality > 0) then
                                local percentage = 0
                                if (timesLooted > 0) then
                                    percentage = itemsAmount / timesLooted
                                    if (percentage > 1) then
                                        percentage = 1
                                    end

                                    percentage = math.floor(percentage * 100)
                                    if (percentage < 1) then
                                        percentage = 1
                                    end
                                end

                                local r, g, b, _ = GetItemQualityColor(itemQuality)

                                if (shouldAddAnEmptyLine) then
                                    tooltip:AddLine(' ')
                                    shouldAddAnEmptyLine = false
                                end

                                tooltip:AddDoubleLine(itemInfo['nam'], percentage .. '%', r, g, b, 1, 1, 1)
                            --end
                        end
                    end
                end

                tooltipWasModified = unitId
            end
        end
    end
end

local function OnTooltipCleared()
    tooltipWasModified = nil
end

function DataTracker:InitTooltipHooks()
    GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
    GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
end