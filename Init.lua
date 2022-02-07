local ADDON_NAME, WOTLKC = ...

-- Variables.
local events

-- Loads all saved variables.
local function LoadVariables()
    WOTLKCOptions = WOTLKCOptions or {}
    -- Number of steps shown (default: 4)
    WOTLKCOptions.nbrSteps = 3 -- TODO: load variable
end

-- Called on ADDON_LOADED.
function WOTLKC:OnAddonLoaded(addonName)
    if addonName == ADDON_NAME then
        WOTLKCFrame:UnregisterEvent("ADDON_LOADED")
        LoadVariables()
        WOTLKC:InitFrames()
        WOTLKC:SetGuide(WOTLKC.TestGuide) -- temp
        print("|cFFFFFF00WOTLK Companion|r loaded! Do not share this with anyone outside Progress.")
    end
end

-- Called when any registered event fires.
function WOTLKCFrame_OnEvent(self, event, ...)
    events[event](self, ...)
end

-- Registers for events.
local function Initialize()
    WOTLKC.Types = WOTLKC:Enum{"Accept", "Do", "Deliver", "Grind", "Die", "Coordinate"} -- more?
    events = {
        ADDON_LOADED = WOTLKC.OnAddonLoaded,
    }
    for event, callback in pairs(events) do
        WOTLKCFrame:RegisterEvent(event, callback)
    end
end

-- Called when the main frame has loaded.
function WOTLKCFrame_OnLoad(self)
    Initialize()
end
