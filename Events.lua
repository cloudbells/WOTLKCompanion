local _, CGM = ...

-- Variables.
local eventFrame
local hasRegistered = false
local callbacks = {}
local wowEvents, events

-- Called when any registered WoW event fires.
function CGM:OnEvent(event, ...)
    wowEvents[event](self, ...)
end

-- Registers all events.
function CGM:RegisterAllEvents(_eventFrame)
    if not hasRegistered then
        eventFrame = _eventFrame
        eventFrame:SetScript("OnEvent", CGM.OnEvent)
        events = {CGM_COORDINATES_REACHED = CGM.OnCoordinatesReached, ITEM_UPDATE = CGM.OnItemUpdate}
        wowEvents = {
            ADDON_LOADED = CGM.OnAddonLoaded,
            PLAYER_ENTERING_WORLD = CGM.OnPlayerEnteringWorld,
            ZONE_CHANGED_NEW_AREA = CGM.OnZoneChangedNewArea,
            QUEST_ACCEPTED = CGM.OnQuestAccepted,
            QUEST_TURNED_IN = CGM.OnQuestTurnedIn,
            UNIT_QUEST_LOG_CHANGED = CGM.OnUnitQuestLogChanged,
            QUEST_REMOVED = CGM.OnQuestRemoved,
            PLAYER_STARTED_MOVING = CGM.OnPlayerStartedMoving,
            PLAYER_STOPPED_MOVING = CGM.OnPlayerStoppedMoving,
            PLAYER_XP_UPDATE = CGM.OnPlayerXPUpdate,
            QUEST_ACCEPT_CONFIRM = CGM.OnQuestAcceptConfirm,
            GOSSIP_SHOW = CGM.OnGossipShow,
            QUEST_GREETING = CGM.OnQuestGreeting,
            QUEST_DETAIL = CGM.OnQuestDetail,
            QUEST_PROGRESS = CGM.OnQuestProgress,
            QUEST_COMPLETE = CGM.OnQuestComplete
        }
        for event, callback in pairs(wowEvents) do
            eventFrame:RegisterEvent(event, callback)
        end
        for event, callback in pairs(events) do
            CGM:RegisterEvent(event, callback)
        end
        hasRegistered = true
    end
end

-- Registers for the given WoW event.
function CGM:RegisterWowEvent(event, callback)
    wowEvents[event] = callback
    eventFrame:RegisterEvent(event, callback)
end

-- Unregisters the given WoW event.
function CGM:UnregisterWowEvent(event)
    eventFrame:UnregisterEvent(event)
    wowEvents[event] = nil
end

-- Register for the given event.
function CGM:RegisterEvent(event, callback)
    callbacks[event] = callbacks[event] or {}
    callbacks[event][#callbacks[event] + 1] = callback
end

-- Unregister for the given event.
function CGM:UnregisterEvent(event)
    callbacks[event] = nil
end

-- Call this to fire an event.
function CGM:Fire(event, ...)
    if callbacks[event] and #callbacks[event] > 0 then
        for i = 1, #callbacks[event] do
            callbacks[event][i](self, ...)
        end
    end
end
