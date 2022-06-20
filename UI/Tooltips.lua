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

                local killsCount = tonumber(unitInfo.kills) or 0
                if (killsCount > 0) then
                    if (shouldAddAnEmptyLine) then
                        tooltip:AddLine(' ')
                        shouldAddAnEmptyLine = false
                    end

                    tooltip:AddDoubleLine('Kills', killsCount, 1, 1, 1, 1, 1, 1)
                end

                local copper = tonumber(unitInfo['copper']) or 0
                if (killsCount > 0 and copper > 0) then
                    if (shouldAddAnEmptyLine) then
                        tooltip:AddLine(' ')
                        shouldAddAnEmptyLine = false
                    end

                    tooltip:AddDoubleLine('Copper', copper / killsCount, 1, 1, 1, 1, 1, 1)
                end

                local lootInfos = unitInfo['looted']
                if (lootInfos) then
                    shouldAddAnEmptyLine = true
                    for itemId, itemsAmount in pairs(lootInfos) do
                        local itemInfo = DT_ItemDb[itemId]
                        if (itemInfo) then
                            local itemQuality = tonumber(itemInfo['quality'])
                            --if (itemQuality > 0) then
                                local percentage = 0
                                if (killsCount > 0) then
                                    percentage = itemsAmount / killsCount
                                    if (percentage > 1) then
                                        percentage = 1
                                    end

                                    percentage = math.floor(percentage * 100)
                                    if (percentage < 1) then
                                        percentage = 1
                                    end

                                    -- DataTracker:LogDebug(
                                    --     'killsCount', killsCount,
                                    --     'itemsAmount', itemsAmount,
                                    --     'percentage', percentage)
                                end

                                local r, g, b, _ = GetItemQualityColor(itemQuality)

                                if (shouldAddAnEmptyLine) then
                                    tooltip:AddLine(' ')
                                    shouldAddAnEmptyLine = false
                                end

                                tooltip:AddDoubleLine(itemInfo['name'], percentage .. '%', r, g, b, 1, 1, 1)
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