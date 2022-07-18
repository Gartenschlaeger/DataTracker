---@class DataTracker_Core
local DataTracker = select(2, ...)

local function addEmptyLine(context)
    if (context.shouldAddAnEmptyLine) then
        context.tooltip:AddLine(' ')
        context.shouldAddAnEmptyLine = false
    end
end

local function addDoubleLineRGB(context, left, right, r, g, b)
    addEmptyLine(context)
    context.tooltip:AddDoubleLine(left, right, r, g, b, 1, 1, 1)
end

local function addDoubleLine(context, left, right)
    addDoubleLineRGB(context, left, right, 1, 1, 1)
end

local function addTimesLooted(context)
    if (not DT_Options.Tooltip.ShowLooted) then
        return
    end

    local timesLooted = tonumber(context.unitInfo['ltd']) or 0
    if (timesLooted > 0) then
        addDoubleLine(context, DataTracker.i18n.TT_LOOTED, timesLooted)
    end
end

local function addTimesKilled(context)
    if (not DT_Options.Tooltip.ShowKills) then
        return
    end

    local timesKilled = tonumber(context.unitInfo['kls']) or 0
    if (timesKilled > 0) then
        addDoubleLine(context, DataTracker.i18n.TT_KILLS, timesKilled)
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

                if (timesLooted > 0 and totalCopper > 0) then
                    local avarage = math.floor(totalCopper / timesLooted)
                    addDoubleLine(context, DataTracker.i18n.TT_AVG_COP, GetCoinTextureString(avarage))
                end
            end

            if (DT_Options.Tooltip.ShowMoneyMM) then
                local minCopper = levelInfos.min or 0
                local maxCopper = levelInfos.max or 0

                if (minCopper and minCopper > 0) then
                    addDoubleLine(context, DataTracker.i18n.TT_MIN_COP, GetCoinTextureString(minCopper))
                end
                if (maxCopper and maxCopper > 0) then
                    addDoubleLine(context, DataTracker.i18n.TT_MAX_COP, GetCoinTextureString(maxCopper))
                end
            end

        end
    end
end

local function addGeneralLoot(context)
    if (not DT_Options.Tooltip.ShowItems) then
        return
    end

    local lootInfos = context.unitInfo['its']
    if (lootInfos) then
        local ltd = tonumber(context.unitInfo['ltd']) or 0

        --local kls = tonumber(context.unitInfo['kls']) or 0
        --ltd = math.max(ltd, kls)

        context.shouldAddAnEmptyLine = true
        for itemId, timesItemWasLooted in pairs(lootInfos) do
            local itemInfo = DataTracker.helper:GetItemInfo(itemId) -- DT_ItemDb[itemId]
            if (itemInfo) then
                -- local itemQuality = tonumber(itemInfo['qlt'])
                if (itemInfo.quality >= DT_Options.Tooltip.MinQualityLevel) then
                    local percentage = DataTracker.helper:CalculatePercentage(ltd, timesItemWasLooted)
                    local r, g, b, _ = GetItemQualityColor(itemInfo.quality)

                    local iconPrefix = ''
                    if (DT_Options.Tooltip.ShowIcons) then
                        iconPrefix = '|T' .. itemInfo.texture .. ':14|t '
                    end

                    addDoubleLineRGB(context,
                        iconPrefix .. itemInfo.name,
                        DataTracker.helper:FormatPercentage(percentage),
                        r, g, b)
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
                if (itemQuality and itemQuality >= DT_Options.Tooltip.MinQualityLevel) then
                    local percentage = DataTracker.helper:CalculatePercentage(ltd_sk, itemCount)

                    local iconPrefix = ''
                    if (DT_Options.Tooltip.ShowIcons) then
                        local itemTextureId = GetItemIcon(itemId)
                        iconPrefix = '|T' .. itemTextureId .. ':14|t '

                    end

                    local r, g, b, _ = GetItemQualityColor(itemQuality)
                    addDoubleLineRGB(context,
                        iconPrefix .. itemInfo['nam'],
                        DataTracker.helper:FormatPercentage(percentage),
                        r, g, b)
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
                if (itemQuality and itemQuality >= DT_Options.Tooltip.MinQualityLevel) then
                    local percentage = DataTracker.helper:CalculatePercentage(ltd_mn, itemCount)

                    local iconPrefix = ''
                    if (DT_Options.Tooltip.ShowIcons) then
                        local itemTextureId = GetItemIcon(itemId)
                        iconPrefix = '|T' .. itemTextureId .. ':14|t '

                    end

                    local r, g, b, _ = GetItemQualityColor(itemQuality)
                    addDoubleLineRGB(context,
                        iconPrefix .. itemInfo.nam,
                        DataTracker.helper:FormatPercentage(percentage),
                        r, g, b)
                end
            end
        end
    end
end

local function addHerbalismLoot(context)
    if (not DataTracker:PlayerHasHerbalism()) then
        return
    end

    local items = context.unitInfo.its_hb
    if (items) then
        context.shouldAddAnEmptyLine = true
        local timesLooted = tonumber(context.unitInfo.ltd_hb) or 0

        for itemId, itemCount in pairs(items) do
            local itemInfo = DT_ItemDb[itemId]
            if (itemInfo) then
                local itemQuality = tonumber(itemInfo.qlt)
                if (itemQuality and itemQuality >= DT_Options.Tooltip.MinQualityLevel) then
                    local percentage = DataTracker.helper:CalculatePercentage(timesLooted, itemCount)

                    local iconPrefix = ''
                    if (DT_Options.Tooltip.ShowIcons) then
                        local itemTextureId = GetItemIcon(itemId)
                        iconPrefix = '|T' .. itemTextureId .. ':14|t '

                    end

                    local r, g, b, _ = GetItemQualityColor(itemQuality)
                    addDoubleLineRGB(context,
                        iconPrefix .. itemInfo.nam,
                        DataTracker.helper:FormatPercentage(percentage),
                        r, g, b)
                end
            end
        end
    end
end

local unitTooltipLastUnitId = nil
local itemTooltipLastItemId = nil

local function OnTooltipSetUnit(tooltip)
    local _, unit = tooltip:GetUnit();
    if (unit) then
        local unitGuid = UnitGUID(unit);
        if (not unitGuid or not DataTracker.helper:IsTrackableUnit(unitGuid)) then
            return
        end

        local unitLevel = UnitLevel(unit)
        local unitId = DataTracker.helper:GetUnitIdFromGuid(unitGuid);
        if (unitId and unitTooltipLastUnitId ~= unitId) then
            local unitInfo = DT_UnitDb[unitId]
            if (unitInfo) then
                local context = {
                    tooltip = tooltip,
                    unitInfo = unitInfo,
                    unitLevel = unitLevel,
                    shouldAddAnEmptyLine = true
                }

                context.shouldAddAnEmptyLine = true
                addTimesLooted(context)
                addTimesKilled(context)

                context.shouldAddAnEmptyLine = true
                addMoney(context)

                context.shouldAddAnEmptyLine = true
                addGeneralLoot(context)

                context.shouldAddAnEmptyLine = true
                addSkinningLoot(context)
                context.shouldAddAnEmptyLine = true
                addMiningLoot(context)
                context.shouldAddAnEmptyLine = true
                addHerbalismLoot(context)

                unitTooltipLastUnitId = unitId
            end
        end
    end
end

local function OnTooltipSetItem(tooltip)
    local _, link = tooltip:GetItem()
    if (link == nil) then
        return
    end

    local itemId = DataTracker.helper:GetItemIdFromLink(link)
    if (itemId == -1) then
        return
    end

    if (itemTooltipLastItemId ~= itemId) then
        itemTooltipLastItemId = itemId

        -- TODO: implement item tooltip infos
    end
end

local function OnTooltipCleared()
    unitTooltipLastUnitId = nil
    itemTooltipLastItemId = nil
end

function DataTracker:InitTooltipHooks()
    GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
    GameTooltip:HookScript('OnTooltipSetItem', OnTooltipSetItem)
    GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
end
