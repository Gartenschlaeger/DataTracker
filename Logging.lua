DT_LogLevel = {
    None = 0,

    Info = 1,
    Warning = 2,

    Debug = 3,
    Verbose = 4,
    Trace = 5,

    All = 99,
}

-- DT_ChatColor_Red = "|cffff1010"
-- DT_ChatColor_Green = "|cff00ff00"
-- DT_ChatColor_Blue = "|cff0000ff"
-- DT_ChatColor_White = "|cffffffff"
-- DT_ChatColor_Gray = "|cff888888"
-- DT_ChatColor_Yellow  = "|cffffff00"
-- DT_ChatColor_Cyan   = "|cff00ffff"
-- DT_ChatColor_Orange = "|cffff7000"
-- DT_ChatColor_Gold = "|cffffcc00"
-- DT_ChatColor_Mageta = "|cffe040ff"
-- DT_ChatColor_ItemBlue = "|cff2060ff"
-- DT_ChatColor_LightBlue = "|cff00e0ff"
-- DT_ChatColor_LightGreen = "|cff60ff60"
-- DT_ChatColor_LightRed = "|cffff5050"
-- DT_ChatColor_SubWhite = "|cffbbbbbb"
-- DT_ChatColor_Artifact = "|cffe6cc80"
-- DT_ChatColor_Heirloom = "|cff00ccff"

function DT_LogTrace(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DT_LogLevel.Trace) then
        print('[TRAC]', msg, ...)
    end
end

function DT_LogVerbose(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DT_LogLevel.Verbose) then
        print('[VERB]', msg, ...)
    end
end

function DT_LogDebug(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DT_LogLevel.Debug) then
        print('[DEBG]', msg, ...)
    end
end

function DT_LogWarning(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DT_LogLevel.Warning) then
        print('[WARN]', msg, ...)
    end
end

function DT_LogInfo(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DT_LogLevel.Info) then
        print(msg, ...)
    end
end