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
                if (DT_Options.Tooltip.ShowLooted) then
                    local timesLooted = tonumber(unitInfo['ltd']) or 0
                    if (timesLooted > 0) then
                        if (shouldAddAnEmptyLine) then
                            tooltip:AddLine(' ')
                            shouldAddAnEmptyLine = false
                        end

                        tooltip:AddDoubleLine(DataTracker.i18n.TT_LOOTED, timesLooted, 1, 1, 1, 1, 1, 1)
                    end
                end

                -- times killed
                if (DT_Options.Tooltip.ShowKills) then
                    local timesKilled = tonumber(unitInfo['kls']) or 0
                    if (timesKilled > 0) then
                        if (shouldAddAnEmptyLine) then
                            tooltip:AddLine(' ')
                            shouldAddAnEmptyLine = false
                        end

                        tooltip:AddDoubleLine(DataTracker.i18n.TT_KILLS, timesKilled, 1, 1, 1, 1, 1, 1)
                    end
                end

                -- money: min/max
                if (DT_Options.Tooltip.ShowMoney) then
                    local minCopper = tonumber(unitInfo['mnc']) or 0
                    local maxCopper = tonumber(unitInfo['mxc']) or 0
                    if (minCopper and minCopper > 0) then
                        tooltip:AddDoubleLine(DataTracker.i18n.TT_MIN_COP, GetCoinTextureString(minCopper), 1, 1, 1, 1, 1
                            , 1)
                    end
                    if (maxCopper and maxCopper > 0) then
                        tooltip:AddDoubleLine(DataTracker.i18n.TT_MAX_COP, GetCoinTextureString(maxCopper), 1, 1, 1, 1, 1
                            , 1)
                    end
                end

                -- general items
                if (DT_Options.Tooltip.ShowItems) then
                    local minQuality = 1
                    if (DT_Options.Tooltip.ShowTrashItems) then
                        minQuality = 0
                    end

                    local lootInfos = unitInfo['its']
                    if (lootInfos) then
                        local ltd = tonumber(unitInfo['ltd']) or 0

                        shouldAddAnEmptyLine = true
                        for itemId, timesItemWasLooted in pairs(lootInfos) do
                            local itemInfo = DT_ItemDb[itemId]
                            if (itemInfo) then
                                local itemQuality = tonumber(itemInfo['qlt'])
                                if (itemQuality >= minQuality) then
                                    local percentage = DataTracker:CalculatePercentage(ltd, timesItemWasLooted)
                                    local r, g, b, _ = GetItemQualityColor(itemQuality)

                                    if (shouldAddAnEmptyLine) then
                                        tooltip:AddLine(' ')
                                        shouldAddAnEmptyLine = false
                                    end

                                    tooltip:AddDoubleLine(itemInfo['nam'], DataTracker:FormatPercentage(percentage), r, g
                                        , b, 1, 1, 1)
                                end
                            end
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

                            tooltip:AddDoubleLine(itemInfo['nam'], DataTracker:FormatPercentage(percentage), r, g, b, 1,
                                1, 1)
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
