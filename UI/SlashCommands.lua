---@class DataTracker_Core
local DataTracker = select(2, ...)

SLASH_DT_SHOW1 = "/dts"
local function SlashCommand_Show()
    DataTracker.logging:Trace('DT_SlashCommand_Show')

    DataTrackerBrowser:Show()
end

SLASH_DT_HIDE1 = "/dth"
local function SlashCommand_Hide()
    DataTracker.logging:Trace('DT_SlashCommand_Hide')

    DataTrackerBrowser:Hide()
end

SLASH_DT_LOGLEVEL1 = "/dtll"
local function SlashCommand_LogLevel(msg)
    DataTracker.logging:Trace('DT_SlashCommand_DebugLogs', msg)

    local logLevel = tonumber(msg)
    for n, v in pairs(DataTracker.logging.LogLevel) do
        if (logLevel == n or logLevel == v) then
            DT_Options.MinLogLevel = logLevel
            DataTracker.logging:Info('Changed min log level to ' .. n)
        end
    end
end

SLASH_DT_UIDEBUG1 = '/dtuidebug'
local function SlashCommand_UIDebug()
    LoadAddOn('Blizzard_DebugTools')
    FrameStackTooltip_Toggle()
end

SLASH_DT_REMUNIT1 = '/dtru'
function SlashCommand_DataTrackerRemoveUnit(unitId)
    local id = tonumber(unitId)
    if (id) then
        DT_UnitDb[id] = nil
        DataTracker.logging:Info('Removed unit with id ' .. id)
    end
end

SLASH_DT_CLEANUPDB1 = '/dtcdb'
function SlashCommand_CleanupDatabase()
    DataTracker:CleanupDatabase()
end

function DataTracker:InitSlashCommands()
    SlashCmdList.DT_SHOW = SlashCommand_Show
    SlashCmdList.DT_HIDE = SlashCommand_Hide
    SlashCmdList.DT_LOGLEVEL = SlashCommand_LogLevel
    SlashCmdList.DT_UIDEBUG = SlashCommand_UIDebug
    SlashCmdList.DT_REMUNIT = SlashCommand_DataTrackerRemoveUnit
    SlashCmdList.DT_CLEANUPDB = SlashCommand_CleanupDatabase
end
