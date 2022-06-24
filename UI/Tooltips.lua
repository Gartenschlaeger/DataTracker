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

                -- times looted
                local timesLooted = tonumber(unitInfo['ltd']) or 0
                if (timesLooted > 0) then
                    if (shouldAddAnEmptyLine) then
                        tooltip:AddLine(' ')
                        shouldAddAnEmptyLine = false
                    end

                    tooltip:AddDoubleLine('Looted', timesLooted, 1, 1, 1, 1, 1, 1)
                end

                -- times killed
                local timesKilled = tonumber(unitInfo['kls']) or 0
                if (timesKilled > 0) then
                    if (shouldAddAnEmptyLine) then
                        tooltip:AddLine(' ')
                        shouldAddAnEmptyLine = false
                    end

                    tooltip:AddDoubleLine('Killed', timesKilled, 1, 1, 1, 1, 1, 1)
                end

                local totalCopper = tonumber(unitInfo['cop']) or 0
                local minCopper = tonumber(unitInfo['mnc']) or 0
                local maxCopper = tonumber(unitInfo['mxc']) or 0

                -- money: avg
                if (timesLooted > 0 and totalCopper > 0) then
                    if (shouldAddAnEmptyLine) then
                        tooltip:AddLine(' ')
                        shouldAddAnEmptyLine = false
                    end

                    tooltip:AddDoubleLine('Avg. coins', GetCoinTextureString(math.floor(totalCopper / timesLooted)), 1, 1, 1, 1, 1, 1)
                end

                -- money: min/max
                if (minCopper and maxCopper and minCopper ~= maxCopper) then
                    tooltip:AddDoubleLine('Coins', GetCoinTextureString(minCopper) .. ' / ' .. GetCoinTextureString(maxCopper), 1, 1, 1, 1, 1, 1)
                end

                -- general items
                local lootInfos = unitInfo['its']
                if (lootInfos) then
                    shouldAddAnEmptyLine = true
                    for itemId, timesItemWasLooted in pairs(lootInfos) do
                        local itemInfo = DT_ItemDb[itemId]
                        if (itemInfo) then
                            local itemQuality = tonumber(itemInfo['qlt'])
                            --if (itemQuality > 0) then
                                local percentage = DataTracker:CalculatePercentage(timesLooted, timesItemWasLooted)
                                local r, g, b, _ = GetItemQualityColor(itemQuality)

                                if (shouldAddAnEmptyLine) then
                                    tooltip:AddLine(' ')
                                    shouldAddAnEmptyLine = false
                                end

                                tooltip:AddDoubleLine(itemInfo['nam'], DataTracker:FormatPercentage(percentage), r, g, b, 1, 1, 1)
                            --end
                        end
                    end
                end

                -- skinning items
                local itemsSkinning = unitInfo['its_sk']
                if (itemsSkinning) then
                    shouldAddAnEmptyLine = true
                    local ltd_sk = tonumber(unitInfo['ltd_sk']) or 0

                    for itemId, itemCount in pairs(itemsSkinning) do
                        local itemInfo = DT_ItemDb[itemId]
                        if (itemInfo) then
                            local percentage = DataTracker:CalculatePercentage(ltd_sk, itemCount)

                            local itemQuality = tonumber(itemInfo['qlt'])
                            local r, g, b, _ = GetItemQualityColor(itemQuality)

                            if (shouldAddAnEmptyLine) then
                                tooltip:AddLine(' ')
                                shouldAddAnEmptyLine = false
                            end

                            tooltip:AddDoubleLine(itemInfo['nam'], DataTracker:FormatPercentage(percentage), r, g, b, 1, 1, 1)
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