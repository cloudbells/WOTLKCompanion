local _, WOTLKC = ...

-- Variables.
local hasRegistered = false
local callbacks = {}
local wowEvents = {}
local events = {}

-- Registers all events.
function WOTLKC:RegisterAllEvents()
    if not hasRegistered then
        hasRegistered = true
        events = {
            WOTLKC_COORDINATES_REACHED = WOTLKC.Events.OnCoordinatesReached
        }
        wowEvents = {
            ADDON_LOADED = WOTLKC.Events.OnAddonLoaded,
            PLAYER_ENTERING_WORLD = WOTLKC.Events.OnPlayerEnteringWorld,
            ZONE_CHANGED_NEW_AREA = WOTLKC.Events.OnZoneChangedNewArea,
            QUEST_ACCEPTED = WOTLKC.Events.OnQuestAccepted,
            QUEST_TURNED_IN = WOTLKC.Events.OnQuestTurnedIn,
            UNIT_QUEST_LOG_CHANGED = WOTLKC.Events.OnUnitQuestLogChanged,
            QUEST_REMOVED = WOTLKC.Events.OnQuestRemoved,
            PLAYER_STARTED_MOVING = WOTLKC.Events.OnPlayerStartedMoving,
            PLAYER_STOPPED_MOVING = WOTLKC.Events.OnPlayerStoppedMoving,
            PLAYER_XP_UPDATE = WOTLKC.Events.OnPlayerXPUpdate,
            QUEST_ACCEPT_CONFIRM = WOTLKC.Events.OnQuestAcceptConfirm,
            GOSSIP_SHOW = WOTLKC.Events.OnGossipShow,
            QUEST_GREETING = WOTLKC.Events.OnQuestGreeting,
            QUEST_DETAIL = WOTLKC.Events.OnQuestDetail,
            QUEST_PROGRESS = WOTLKC.Events.OnQuestProgress,
            QUEST_COMPLETE = WOTLKC.Events.OnQuestComplete
        }
        for event, callback in pairs(wowEvents) do
            WOTLKCFrame:RegisterEvent(event, callback)
        end
        for event, callback in pairs(events) do
            WOTLKC.Events:RegisterEvent(event, callback)
        end
    end
end

-- Registers for the given WoW event.
function WOTLKC.Events:RegisterWowEvent(event, callback)
    WOTLKCFrame:RegisterEvent(event, callback)
    wowEvents[event] = callback
end

-- Unregisters the given WoW event.
function WOTLKC.Events:UnregisterWowEvent(event)
    WOTLKCFrame:UnregisterEvent(event)
    wowEvents[event] = nil
end

-- Called when any registered WoW event fires.
function WOTLKCFrame_OnEvent(self, event, ...)
    wowEvents[event](self, ...)
end

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
