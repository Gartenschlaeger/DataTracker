---@class DTCore
local _, core = ...

---@class DTLogging
local logging = {}
core.logging = logging

logging.LogLevel = {
    None = 0,
    Info = 1,
    Warning = 2,
    Debug = 3,
    Verbose = 4,
    Trace = 5,
    All = 99,
}

-- Logs a Trace message to the chat
function logging:Trace(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= logging.LogLevel.Trace) then
        print('[DT]', msg, ...)
    end
end

-- Logs a Verbose message to the chat
function logging:Verbose(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= logging.LogLevel.Verbose) then
        print('[DT]', msg, ...)
    end
end

-- true if debug logging is enabled
function logging:IsDebugEnabled()
    return DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= logging.LogLevel.Debug
end

-- Logs a Debug message to the chat
function logging:Debug(msg, ...)
    if (logging:IsDebugEnabled()) then
        print('[DT]', msg, ...)
    end
end

-- Logs a Warning message to the chat
function logging:Warning(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= logging.LogLevel.Warning) then
        print('[DT]', msg, ...)
    end
end

-- Logs a Info message to the chat
function logging:Info(msg, ...)
    if (DT_Options['MinLogLevel'] and DT_Options['MinLogLevel'] >= logging.LogLevel.Info) then
        print(msg, ...)
    end
end
