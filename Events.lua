local _, WOTLKC = ...

-- Variables.
local callbacks = {}

-- Register for the given event.
function WOTLKC.Events:RegisterEvent(event, callback)
    callbacks[event] = callbacks[event] or {}
    callbacks[event][#callbacks[event] + 1] = callback
end

-- Call this to fire an event.
function WOTLKC.Events:Fire(event, ...)
    if callbacks[event] and #callbacks[event] > 0 then
        for i = 1, #callbacks[event] do
            callbacks[event][i](...)
        end
    end
end
