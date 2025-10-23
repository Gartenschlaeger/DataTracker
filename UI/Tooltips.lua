---@class DTCore
local _, core = ...

local _, _, _, TOC_VERSION = GetBuildInfo()
local IS_CLASSIC = TOC_VERSION < 20000

local function addEmptyLine(context)
    if (context.shouldAddAnEmptyLine) then
        context.tooltip:AddLine(' ')
        context.shouldAddAnEmptyLine = false
    end
end

local function addHeaderText(context)
    if (context.headerText) then
        context.tooltip:AddLine(context.headerText, nil, nil, nil, nil, true)
        context.headerText = nil
    end
end

local function addDoubleLineRGB(context, left, right, r, g, b)
    addEmptyLine(context)
    addHeaderText(context)
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
        addDoubleLine(context, core.i18n.TT_LOOTED, timesLooted)
    end
end

local function addTimesKilled(context)
    if (not DT_Options.Tooltip.ShowKills) then
        return
    end

    local timesKilled = tonumber(context.unitInfo['kls']) or 0
    if (timesKilled > 0) then
        addDoubleLine(context, core.i18n.TT_KILLS, timesKilled)
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
                    addDoubleLine(context, core.i18n.TT_AVG_COP, GetCoinTextureString(avarage))
                end
            end

            if (DT_Options.Tooltip.ShowMoneyMM) then
                local minCopper = levelInfos.min or 0
                local maxCopper = levelInfos.max or 0

                if (minCopper and minCopper > 0) then
                    addDoubleLine(context, core.i18n.TT_MIN_COP, GetCoinTextureString(minCopper))
                end
                if (maxCopper and maxCopper > 0) then
                    addDoubleLine(context, core.i18n.TT_MAX_COP, GetCoinTextureString(maxCopper))
                end
            end
        end
    end
end

local function shallAddItem(itemClassId)
    if DT_Options.Tooltip.ShowEquipmentItems ~= true and
        (itemClassId == Enum.ItemClass.Weapon or itemClassId == Enum.ItemClass.Armor) then
        return false
    end

    return true
end

local function addLoot(context)
    if (not DT_Options.Tooltip.ShowItems) then
        return
    end

    local lootInfos = context.unitInfo['its']
    if (lootInfos) then
        local ltd = tonumber(context.unitInfo['ltd']) or 0
        context.shouldAddAnEmptyLine = true

        local items = {}
        for itemId, timesItemWasLooted in pairs(lootInfos) do
            local itemInfo = DT_ItemDb[itemId]
            if (itemInfo) then
                local itemQuality = tonumber(itemInfo['qlt'])
                local itemClassID, itemSubClassID = select(6, GetItemInfoInstant(itemId))
                if (itemQuality and itemQuality >= DT_Options.Tooltip.MinQualityLevel) then
                    table.insert(items, {
                        id = itemId,
                        name = itemInfo['nam'],
                        quality = itemQuality,
                        classId = itemClassID,
                        timesLooted = timesItemWasLooted
                    })
                end
            end
        end

        table.sort(items, function(a, b)
            return string.lower(a.name) < string.lower(b.name)
        end)

        local itemsAdded = 0
        for _, item in ipairs(items) do
            if shallAddItem(item.classId) then
                local iconPrefix = ''
                if (DT_Options.Tooltip.ShowIcons) then
                    local itemTextureId = GetItemIcon(item.id)
                    iconPrefix = '|T' .. itemTextureId .. ':14|t '
                end

                local percentage = core.helper:CalculatePercentage(ltd, item.timesLooted)
                local r, g, b, _ = GetItemQualityColor(item.quality)
                addDoubleLineRGB(context,
                    iconPrefix .. item.name,
                    core.helper:FormatPercentage(percentage),
                    r, g, b)

                itemsAdded = itemsAdded + 1
                if (DT_Options.Tooltip.LimitItems and itemsAdded >= DT_Options.Tooltip.MaxItemsToShow) then
                    local remainingItems = #items - itemsAdded
                    context.tooltip:AddLine(string.format(core.i18n.OP_TT_MORE_ITEMS, remainingItems))
                    break
                end
            end
        end
    end
end

local function addSkinningLoot(context)
    if (not core:PlayerHasSkinning()) then
        return
    end

    local itemsSkinning = context.unitInfo['its_sk']
    if (itemsSkinning) then
        context.shouldAddAnEmptyLine = true
        context.headerText = core.i18n.TT_SKINNING

        local ltd_sk = tonumber(context.unitInfo['ltd_sk']) or 0

        for itemId, itemCount in pairs(itemsSkinning) do
            local itemInfo = DT_ItemDb[itemId]
            if (itemInfo) then
                local itemQuality = tonumber(itemInfo['qlt'])
                if (itemQuality and itemQuality >= DT_Options.Tooltip.MinQualityLevel) then
                    local percentage = core.helper:CalculatePercentage(ltd_sk, itemCount)

                    local iconPrefix = ''
                    if (DT_Options.Tooltip.ShowIcons) then
                        local itemTextureId = GetItemIcon(itemId)
                        iconPrefix = '|T' .. itemTextureId .. ':14|t '
                    end

                    local r, g, b, _ = GetItemQualityColor(itemQuality)
                    addDoubleLineRGB(context,
                        iconPrefix .. itemInfo['nam'],
                        core.helper:FormatPercentage(percentage),
                        r, g, b)
                end
            end
        end
    end
end

local function addMiningLoot(context)
    if (not core:PlayerHasMining()) then
        return
    end

    local items = context.unitInfo.its_mn
    if (items) then
        context.shouldAddAnEmptyLine = true
        context.headerText = core.i18n.TT_MINING

        local ltd_mn = tonumber(context.unitInfo.ltd_mn) or 0

        for itemId, itemCount in pairs(items) do
            local itemInfo = DT_ItemDb[itemId]
            if (itemInfo) then
                local itemQuality = tonumber(itemInfo.qlt)
                if (itemQuality and itemQuality >= DT_Options.Tooltip.MinQualityLevel) then
                    local percentage = core.helper:CalculatePercentage(ltd_mn, itemCount)

                    local iconPrefix = ''
                    if (DT_Options.Tooltip.ShowIcons) then
                        local itemTextureId = GetItemIcon(itemId)
                        iconPrefix = '|T' .. itemTextureId .. ':14|t '
                    end

                    local r, g, b, _ = GetItemQualityColor(itemQuality)
                    addDoubleLineRGB(context,
                        iconPrefix .. itemInfo.nam,
                        core.helper:FormatPercentage(percentage),
                        r, g, b)
                end
            end
        end
    end
end

local function addHerbalismLoot(context)
    if (not core:PlayerHasHerbalism()) then
        return
    end

    local items = context.unitInfo.its_hb
    if (items) then
        context.shouldAddAnEmptyLine = true
        context.headerText = core.i18n.TT_HERBALISM

        local timesLooted = tonumber(context.unitInfo.ltd_hb) or 0

        for itemId, itemCount in pairs(items) do
            local itemInfo = DT_ItemDb[itemId]
            if (itemInfo) then
                local itemQuality = tonumber(itemInfo.qlt)
                if (itemQuality and itemQuality >= DT_Options.Tooltip.MinQualityLevel) then
                    local percentage = core.helper:CalculatePercentage(timesLooted, itemCount)

                    local iconPrefix = ''
                    if (DT_Options.Tooltip.ShowIcons) then
                        local itemTextureId = GetItemIcon(itemId)
                        iconPrefix = '|T' .. itemTextureId .. ':14|t '
                    end

                    local r, g, b, _ = GetItemQualityColor(itemQuality)
                    addDoubleLineRGB(context,
                        iconPrefix .. itemInfo.nam,
                        core.helper:FormatPercentage(percentage),
                        r, g, b)
                end
            end
        end
    end
end

local unitTooltipLastUnitId = nil

local function OnTooltipSetUnit(tooltip)
    local unit
    if tooltip.GetUnit then
        _, unit = tooltip:GetUnit()
    end

    if (not unit) and IS_CLASSIC and GameTooltip:GetUnit() then
        _, unit = GameTooltip:GetUnit()
    end

    if not unit then
        return
    end

    local unitGuid = UnitGUID(unit)
    if (not unitGuid or not core.helper:IsTrackableUnit(unitGuid)) then
        return
    end

    local unitLevel = UnitLevel(unit)
    local unitId = core.helper:GetUnitIdFromGuid(unitGuid)

    if (unitId and unitTooltipLastUnitId ~= unitId) then
        local unitInfo = DT_UnitDb[unitId]
        if unitInfo then
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
            addLoot(context)

            if DT_Options.Tooltip.ShowProfessionItems then
                context.shouldAddAnEmptyLine = true
                addSkinningLoot(context)

                context.shouldAddAnEmptyLine = true
                addMiningLoot(context)

                context.shouldAddAnEmptyLine = true
                addHerbalismLoot(context)
            end

            unitTooltipLastUnitId = unitId
        end
    end
end

local function OnTooltipCleared()
    unitTooltipLastUnitId = nil
end

function core:InitTooltipHooks()
    if IS_RETAIL then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
            OnTooltipSetUnit(tooltip)
        end)
    else
        GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
    end

    GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
end
