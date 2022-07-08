local tooltipWasModified = nil

local function OnTooltipSetUnit(tooltip)
    local _, unit = tooltip:GetUnit();
    if (unit) then
        local unitGuid = UnitGUID(unit);
        local unitLevel = UnitLevel(unit)
        local unitId = DataTracker:UnitGuidToId(unitGuid);
        if (unitId and tooltipWasModified ~= unitId) then
            local unitInfo = DT_UnitDb[unitId]
            if (unitInfo) then
                local shouldAddAnEmptyLine = true

                -- times looted --

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

                -- times killed --

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

                -- money --

                if (DT_Options.Tooltip.ShowMoney) then
                    local key = '_'
                    if (unitLevel >= 1) then
                        key = 'l:' .. unitLevel
                    end

                    local copperInfos = unitInfo.cpi
                    if (copperInfos ~= nil) then
                        local levelInfos = copperInfos[key]
                        if (levelInfos == nil) then
                            levelInfos = copperInfos['_']
                        end

                        if (levelInfos ~= nil) then
                            if (DT_Options.Tooltip.ShowMoneyAvg) then
                                local timesLooted = levelInfos.ltd or 0
                                local totalCopper = levelInfos.tot or 0

                                if (timesLooted > 1 and totalCopper > 0) then
                                    local avarage = math.floor(totalCopper / timesLooted)
                                    tooltip:AddDoubleLine(DataTracker.i18n.TT_AVG_COP, GetCoinTextureString(avarage),
                                        1, 1, 1, 1, 1, 1)
                                end
                            end

                            if (DT_Options.Tooltip.ShowMoneyMM) then
                                local minCopper = levelInfos.min or 0
                                local maxCopper = levelInfos.max or 0

                                if (minCopper and minCopper > 0) then
                                    tooltip:AddDoubleLine(DataTracker.i18n.TT_MIN_COP, GetCoinTextureString(minCopper),
                                        1, 1, 1, 1, 1, 1)
                                end
                                if (maxCopper and maxCopper > 0) then
                                    tooltip:AddDoubleLine(DataTracker.i18n.TT_MAX_COP, GetCoinTextureString(maxCopper),
                                        1, 1, 1, 1, 1, 1)
                                end
                            end

                        end
                    end
                end

                -- general items --

                if (DT_Options.Tooltip.ShowItems) then
                    local lootInfos = unitInfo['its']
                    if (lootInfos) then
                        local ltd = tonumber(unitInfo['ltd']) or 0

                        shouldAddAnEmptyLine = true
                        for itemId, timesItemWasLooted in pairs(lootInfos) do
                            local itemInfo = DT_ItemDb[itemId]
                            if (itemInfo) then
                                local itemQuality = tonumber(itemInfo['qlt'])
                                if (itemQuality >= DT_Options.Tooltip.MinQualityLevel) then
                                    local percentage = DataTracker:CalculatePercentage(ltd, timesItemWasLooted)
                                    local r, g, b, _ = GetItemQualityColor(itemQuality)

                                    if (shouldAddAnEmptyLine) then
                                        tooltip:AddLine(' ')
                                        shouldAddAnEmptyLine = false
                                    end

                                    local iconPrefix = ''
                                    if (DT_Options.Tooltip.ShowIcons) then
                                        local itemTextureId = GetItemIcon(itemId)
                                        iconPrefix = '|T' .. itemTextureId .. ':14|t '

                                    end

                                    tooltip:AddDoubleLine(iconPrefix .. itemInfo['nam'],
                                        DataTracker:FormatPercentage(percentage), r, g, b, 1, 1, 1)
                                end
                            end
                        end
                    end
                end

                -- skinning items --

                if (DataTracker:PlayerHasSkinning()) then
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

                                local iconPrefix = ''
                                if (DT_Options.Tooltip.ShowIcons) then
                                    local itemTextureId = GetItemIcon(itemId)
                                    iconPrefix = '|T' .. itemTextureId .. ':14|t '

                                end

                                tooltip:AddDoubleLine(iconPrefix .. itemInfo['nam'],
                                    DataTracker:FormatPercentage(percentage), r, g, b, 1, 1, 1)
                            end
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
