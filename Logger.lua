local _, CGM = ...

-- Variables.
local _messageType = CGM:Enum({"Debug", "Message"})

-- Logs a message to chat.
local function LogMessage(messageType, message)
    if messageType == _messageType.Debug then
        print("|cFFFF0000CGM_DEBUG|r: [" .. date("%H:%M:%S") .. "]: " .. message)
    elseif messageType == _messageType.Message then
        print("|cFFFFFF00ClassicGuideMaker|r: " .. message)
    end
end

-- Prints the given message to chat as a debug message.
function CGM:Debug(message)
    LogMessage(_messageType.Debug, message)
end

-- Prints the given message to chat as a message.
function CGM:Message(message)
    LogMessage(_messageType.Message, message)
end
