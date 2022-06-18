SLASH_DT_SHOW1 = "/dts"
function DT_SlashCommand_Show()
    DT_LogTrace('DT_SlashCommand_Show')
    
    DT_DatabaseBrowser:Show()
end

SLASH_DT_HIDE1 = "/dth"
function DT_SlashCommand_Hide()
    DT_LogTrace('DT_SlashCommand_Hide')
    
    DT_DatabaseBrowser:Hide()
end

SLASH_DT_LOGLEVEL1 = "/dtll"
function DT_SlashCommand_LogLevel(msg)
    DT_LogTrace('DT_SlashCommand_DebugLogs', msg)
    
    local logLevel = tonumber(msg)
    for n, v in pairs(DT_LogLevel) do
        if (logLevel == n or logLevel == v) then
            DT_Options.MinLogLevel = logLevel
            DT_LogInfo('Changed min log level to ' .. n)
        end
    end
end

SLASH_DT_UIDEBUG1 = '/dtuidebug'
function DT_SlashCommand_UIDebug()
    LoadAddOn('Blizzard_DebugTools')
    FrameStackTooltip_Toggle()
end

function DT_InitSlashCommands()
    SlashCmdList.DT_SHOW = DT_SlashCommand_Show
    SlashCmdList.DT_HIDE = DT_SlashCommand_Hide
    SlashCmdList.DT_LOGLEVEL = DT_SlashCommand_LogLevel
    SlashCmdList.DT_UIDEBUG = DT_SlashCommand_UIDebug
end