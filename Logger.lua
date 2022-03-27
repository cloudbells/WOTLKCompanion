local _, WOTLKC = ...

-- Variables.
local _messageType = WOTLKC.Util:Enum({"Debug", "Message"})

-- Logs a message to chat.
local function LogMessage(messageType, message)
    if messageType == _messageType.Debug then
        print("|cFFFF0000WOTLKC_DEBUG|r: [" .. date("%H:%M:%S") .. "]: " .. message)
    elseif messageType == _messageType.Message then
        print("|cFFFFFF00WOTLKCompanion|r: " .. message)
    end
end

-- Prints the given message to chat as a debug message.
function WOTLKC.Logging:Debug(message)
    LogMessage(_messageType.Debug, message)
end

-- Prints the given message to chat as a message.
function WOTLKC.Logging:Message(message)
    LogMessage(_messageType.Message, message)
end
