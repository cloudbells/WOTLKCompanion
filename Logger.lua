local _, CGM = ...

-- Variables.
local messageType = CGM:Enum({"Debug", "Message"})

-- Logs a message to chat.
local function LogMessage(_messageType, message)
    if _messageType == messageType.Debug and CGMOptions.settings.debug then
        print("|cFFFF0000CGM_DEBUG|r: [" .. date("%H:%M:%S") .. "]: " .. (message and message or "nil"))
    elseif _messageType == messageType.Message then
        print("|cFFFFFF00ClassicGuideMaker|r: " .. message)
    end
end

-- Prints the given message to chat as a debug message.
function CGM:Debug(message)
    LogMessage(messageType.Debug, message)
end

-- Prints the given message to chat as a message.
function CGM:Message(message)
    LogMessage(messageType.Message, message)
end
