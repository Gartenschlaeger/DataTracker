DT_LogLevel = {
    None = 0,

    Info = 1,
    Warning = 2,

    Debug = 3,
    Verbose = 4,
    Trace = 5,

    All = 99,
}

-- Logs a Trace message to the chat
function DT_LogTrace(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DT_LogLevel.Trace) then
        print('[TRAC]', msg, ...)
    end
end

-- Logs a Verbose message to the chat
function DT_LogVerbose(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DT_LogLevel.Verbose) then
        print('[VERB]', msg, ...)
    end
end

-- Logs a Debug message to the chat
function DT_LogDebug(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DT_LogLevel.Debug) then
        print('[DEBG]', msg, ...)
    end
end

-- Logs a Warning message to the chat
function DT_LogWarning(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DT_LogLevel.Warning) then
        print('[WARN]', msg, ...)
    end
end

-- Logs a Info message to the chat
function DT_LogInfo(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= DT_LogLevel.Info) then
        print(msg, ...)
    end
end