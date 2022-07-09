local tooltipWasModified = nil

local function addTimesLooted(context)
    if (not DT_Options.Tooltip.ShowLooted) then
        return
    end

    local timesLooted = tonumber(context.unitInfo['ltd']) or 0
    if (timesLooted > 0) then
        if (context.shouldAddAnEmptyLine) then
            context.tooltip:AddLine(' ')
            context.shouldAddAnEmptyLine = false
        end

        context.tooltip:AddDoubleLine(DataTracker.i18n.TT_LOOTED, timesLooted, 1, 1, 1, 1, 1, 1)
    end
end

local function addTimesKilled(context)
    if (not DT_Options.Tooltip.ShowKills) then
        return
    end

    local timesKilled = tonumber(context.unitInfo['kls']) or 0
    if (timesKilled > 0) then
        if (context.shouldAddAnEmptyLine) then
            context.tooltip:AddLine(' ')
            context.shouldAddAnEmptyLine = false
        end

        context.tooltip:AddDoubleLine(DataTracker.i18n.TT_KILLS, timesKilled, 1, 1, 1, 1, 1, 1)
    end
end

local function addMoney(context)
    if (not DT_Options.Tooltip.ShowMoney) then
        return
    end

    local key = '_'
    if (context.unitLevel >= 1) then
        key = 'l:' .. context.unitLevel
    end

    local copperInfos = context.unitInfo.cpi
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
                    context.tooltip:AddDoubleLine(DataTracker.i18n.TT_AVG_COP, GetCoinTextureString(avarage),
                        1, 1, 1, 1, 1, 1)
                end
            end

            if (DT_Options.Tooltip.ShowMoneyMM) then
                local minCopper = levelInfos.min or 0
                local maxCopper = levelInfos.max or 0

                if (minCopper and minCopper > 0) then
                    context.tooltip:AddDoubleLine(DataTracker.i18n.TT_MIN_COP, GetCoinTextureString(minCopper),
                        1, 1, 1, 1, 1, 1)
                end
                if (maxCopper and maxCopper > 0) then
                    context.tooltip:AddDoubleLine(DataTracker.i18n.TT_MAX_COP, GetCoinTextureString(maxCopper),
                        1, 1, 1, 1, 1, 1)
                end
            end

        end
    end
end

local function addLoot(context)
    if (not DT_Options.Tooltip.ShowItems) then
        return
    end

    local lootInfos = context.unitInfo['its']
    if (lootInfos) then
        local ltd = tonumber(context.unitInfo['ltd']) or 0

        context.shouldAddAnEmptyLine = true
        for itemId, timesItemWasLooted in pairs(lootInfos) do
            local itemInfo = DT_ItemDb[itemId]
            if (itemInfo) then
                local itemQuality = tonumber(itemInfo['qlt'])
                if (itemQuality >= DT_Options.Tooltip.MinQualityLevel) then
                    local percentage = DataTracker:CalculatePercentage(ltd, timesItemWasLooted)
                    local r, g, b, _ = GetItemQualityColor(itemQuality)

                    if (context.shouldAddAnEmptyLine) then
                        context.tooltip:AddLine(' ')
                        context.shouldAddAnEmptyLine = false
                    end

                    local iconPrefix = ''
                    if (DT_Options.Tooltip.ShowIcons) then
                        local itemTextureId = GetItemIcon(itemId)
                        iconPrefix = '|T' .. itemTextureId .. ':14|t '

                    end

                    context.tooltip:AddDoubleLine(iconPrefix .. itemInfo['nam'],
                        DataTracker:FormatPercentage(percentage), r, g, b, 1, 1, 1)
                end
            end
        end
    end
end

local function addSkinningLoot(context)
    if (not DataTracker:PlayerHasSkinning()) then
        return
    end

    local itemsSkinning = context.unitInfo['its_sk']
    if (itemsSkinning) then
        context.shouldAddAnEmptyLine = true
        local ltd_sk = tonumber(context.unitInfo['ltd_sk']) or 0

        for itemId, itemCount in pairs(itemsSkinning) do
            local itemInfo = DT_ItemDb[itemId]
            if (itemInfo) then
                local itemQuality = tonumber(itemInfo['qlt'])
                if (itemQuality >= DT_Options.Tooltip.MinQualityLevel) then
                    local percentage = DataTracker:CalculatePercentage(ltd_sk, itemCount)
                    local r, g, b, _ = GetItemQualityColor(itemQuality)

                    if (context.shouldAddAnEmptyLine) then
                        context.tooltip:AddLine(' ')
                        context.shouldAddAnEmptyLine = false
                    end

                    local iconPrefix = ''
                    if (DT_Options.Tooltip.ShowIcons) then
                        local itemTextureId = GetItemIcon(itemId)
                        iconPrefix = '|T' .. itemTextureId .. ':14|t '

                    end

                    context.tooltip:AddDoubleLine(iconPrefix .. itemInfo['nam'],
                        DataTracker:FormatPercentage(percentage), r, g, b, 1, 1, 1)
                end
            end
        end
    end
end

local function addMiningLoot(context)
    if (not DataTracker:PlayerHasMining()) then
        return
    end

    local items = context.unitInfo.its_mn
    if (items) then
        context.shouldAddAnEmptyLine = true
        local ltd_mn = tonumber(context.unitInfo.ltd_mn) or 0

        for itemId, itemCount in pairs(items) do
            local itemInfo = DT_ItemDb[itemId]
            if (itemInfo) then
                local itemQuality = tonumber(itemInfo.qlt)
                if (itemQuality >= DT_Options.Tooltip.MinQualityLevel) then
                    local percentage = DataTracker:CalculatePercentage(ltd_mn, itemCount)
                    local r, g, b, _ = GetItemQualityColor(itemQuality)

                    if (context.shouldAddAnEmptyLine) then
                        context.tooltip:AddLine(' ')
                        context.shouldAddAnEmptyLine = false
                    end

                    local iconPrefix = ''
                    if (DT_Options.Tooltip.ShowIcons) then
                        local itemTextureId = GetItemIcon(itemId)
                        iconPrefix = '|T' .. itemTextureId .. ':14|t '

                    end

                    context.tooltip:AddDoubleLine(iconPrefix .. itemInfo.nam,
                        DataTracker:FormatPercentage(percentage), r, g, b, 1, 1, 1)
                end
            end
        end
    end
end

local function OnTooltipSetUnit(tooltip)
    local _, unit = tooltip:GetUnit();
    if (unit) then
        local unitGuid = UnitGUID(unit);
        local unitLevel = UnitLevel(unit)
        local unitId = DataTracker:UnitGuidToId(unitGuid);
        if (unitId and tooltipWasModified ~= unitId) then
            local unitInfo = DT_UnitDb[unitId]
            if (unitInfo) then
                local context = {
                    tooltip = tooltip,
                    unitInfo = unitInfo,
                    unitLevel = unitLevel,
                    shouldAddAnEmptyLine = true
                }

                addTimesLooted(context)
                addTimesKilled(context)
                addMoney(context)
                addLoot(context)
                addSkinningLoot(context)
                addMiningLoot(context)

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
