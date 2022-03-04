local ADDON_NAME, WOTLKC = ...

WOTLKC.UI = {
    Main = {},
    StepFrame = {},
    Arrow = {}
}
WOTLKC.EventHandlers = {}

-- Variables.
local events

-- Loads all saved variables.
local function LoadVariables()
    WOTLKCOptions = WOTLKCOptions or {}
    WOTLKCOptions.completedSteps = {}
    -- Number of steps shown (default: 4)
    WOTLKCOptions.nbrSteps = 3 -- TODO: load variable
end

-- Called when most game data is available.
function WOTLKC.EventHandlers:OnPlayerEnteringWorld()
    WOTLKCFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    WOTLKC.UI.Arrow:InitArrow()
    WOTLKCOptions.currentGuideName = "Elwynn Forest 1-10" -- temp
    if WOTLKCOptions.currentGuideName then
        WOTLKC:SetGuide(WOTLKCOptions.currentGuideName)
    end
end

-- Called on ADDON_LOADED.
function WOTLKC.EventHandlers:OnAddonLoaded(addonName)
    if addonName == ADDON_NAME then
        WOTLKCFrame:UnregisterEvent("ADDON_LOADED")
        LoadVariables()
        WOTLKC.UI.Main:InitFrames()
        print("|cFFFFFF00WOTLK Companion|r loaded! Do not share this with anyone outside Progress.")
    end
end

-- Called when any registered event fires.
function WOTLKCFrame_OnEvent(self, event, ...)
    events[event](self, ...)
end

-- Registers for events.
local function Initialize()
    WOTLKC.Types = WOTLKC:Enum{"Accept", "Do", "Deliver", "Grind", "Coordinate"}
    WOTLKC.Guides = {}
    events = {
        ADDON_LOADED = WOTLKC.EventHandlers.OnAddonLoaded,
        PLAYER_ENTERING_WORLD = WOTLKC.EventHandlers.OnPlayerEnteringWorld,
        ZONE_CHANGED_NEW_AREA = WOTLKC.EventHandlers.OnZoneChangedNewArea,
        QUEST_ACCEPTED = WOTLKC.EventHandlers.OnQuestAccepted,
        QUEST_TURNED_IN = WOTLKC.EventHandlers.OnQuestTurnedIn
    }
    for event, callback in pairs(events) do
        WOTLKCFrame:RegisterEvent(event, callback)
    end
end

-- Called when the main frame has loaded.
function WOTLKCFrame_OnLoad(self)
    Initialize()
end
