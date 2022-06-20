SLASH_DT_SHOW1 = "/dts"
local function SlashCommand_Show()
    DataTracker:LogTrace('DT_SlashCommand_Show')

    DT_DatabaseBrowser:Show()
end

SLASH_DT_HIDE1 = "/dth"
local function SlashCommand_Hide()
    DataTracker:LogTrace('DT_SlashCommand_Hide')

    DT_DatabaseBrowser:Hide()
end

SLASH_DT_LOGLEVEL1 = "/dtll"
local function SlashCommand_LogLevel(msg)
    DataTracker:LogTrace('DT_SlashCommand_DebugLogs', msg)

    local logLevel = tonumber(msg)
    for n, v in pairs(DataTracker.LogLevel) do
        if (logLevel == n or logLevel == v) then
            DT_Options.MinLogLevel = logLevel
            DataTracker:LogInfo('Changed min log level to ' .. n)
        end
    end
end

SLASH_DT_UIDEBUG1 = '/dtuidebug'
local function SlashCommand_UIDebug()
    LoadAddOn('Blizzard_DebugTools')
    FrameStackTooltip_Toggle()
end

function DataTracker:InitSlashCommands()
    SlashCmdList.DT_SHOW = SlashCommand_Show
    SlashCmdList.DT_HIDE = SlashCommand_Hide
    SlashCmdList.DT_LOGLEVEL = SlashCommand_LogLevel
    SlashCmdList.DT_UIDEBUG = SlashCommand_UIDebug
end