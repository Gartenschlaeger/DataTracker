DataTracker.LogLevel = {
    None = 0,

    Info = 1,
    Warning = 2,

    Debug = 3,
    Verbose = 4,
    Trace = 5,

    All = 99,
}

-- Logs a Trace message to the chat
function DataTracker:LogTrace(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DataTracker.LogLevel.Trace) then
        print('[DT]', msg, ...)
    end
end

-- Logs a Verbose message to the chat
function DataTracker:LogVerbose(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DataTracker.LogLevel.Verbose) then
        print('[DT]', msg, ...)
    end
end

-- true if debug logging is enabled
function DataTracker:IsDebugLogEnabled()
    return DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DataTracker.LogLevel.Debug
end

-- Logs a Debug message to the chat
function DataTracker:LogDebug(msg, ...)
    if (DataTracker:IsDebugLogEnabled()) then
        print('[DT]', msg, ...)
    end
end

-- Logs a Warning message to the chat
function DataTracker:LogWarning(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DataTracker.LogLevel.Warning) then
        print('[DT]', msg, ...)
    end
end

-- Logs a Info message to the chat
function DataTracker:LogInfo(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DataTracker.LogLevel.Info) then
        print(msg, ...)
    end
end
