local _, CGM = ...

-- Variables.
local messageType = CGM:Enum({"Debug", "Message"})

-- Logs a message to chat.
local function LogMessage(_messageType, message)
    if _messageType == messageType.Debug and CGMOptions.settings.debug then
        print("|cFFFF0000[" .. string.format("%.3f", GetTime()) .. "]: CGM|r: " .. (message and message or "nil"))
    elseif _messageType == messageType.Message then
        print("|cFFFFFF00ClassicGuideMaker|r: " .. message)
    end
end

-- Prints the given message to chat as a debug message.
function CGM:Debug(message)
    if CGMOptions.settings.debug then
        LogMessage(messageType.Debug, message)
    end
end

-- Prints the given message to chat as a message.
function CGM:Message(message)
    if CGMOptions.settings.debug then
        LogMessage(messageType.Debug, "(message): " .. message)
    else
        LogMessage(messageType.Message, message)
    end
end
