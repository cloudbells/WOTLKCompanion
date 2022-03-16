local ADDON_NAME, WOTLKC = ...

-- Namespaces.
WOTLKC.UI = {
    Main = {},
    StepFrame = {},
    Arrow = {}
}
WOTLKC.Events = {}
WOTLKC.Util = {}

-- Variables.
local wowEvents, events
local minimapButton = LibStub("LibDBIcon-1.0")

-- Shows or hides the minimap button.
local function ToggleMinimapButton()
    WOTLKCOptions.minimapTable.show = not WOTLKCOptions.minimapTable.show
    if not WOTLKCOptions.minimapTable.show then
        minimapButton:Hide("WOTLKCompanion")
        print("|cFFFFFF00WOTLK Companion:|r Minimap button hidden. Type /wotlkc minimap to show it again.")
    else
        minimapButton:Show("WOTLKCompanion")
    end
end

-- Initializes the minimap button.
local function InitMinimapButton()
    -- Register for eventual data brokers.
    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("WOTLKCompanion", {
        type = "data source",
        text = "WOTLKCompanion",
        icon = "Interface/Addons/WOTLKCompanion/Media/FrostPresence", -- TEMP
        OnClick = function(self, button)
            if button == "LeftButton" then
                -- toggle options here
            elseif button == "RightButton" then
                ToggleMinimapButton()
            end
        end,
        OnEnter = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:AddLine("|cFFFFFFFFWOTLK Companion|r")
            GameTooltip:AddLine("TEMP BLABLA") -- temp
            GameTooltip:Show()
        end,
        OnLeave = function(self)
            GameTooltip:Hide()
        end
    })
    -- Create minimap icon.
    minimapButton:Register("WOTLKCompanion", LDB, WOTLKCOptions.minimapTable)
end

-- Initializes slash commands.
local function InitSlash()
    SLASH_WOTLKC1 = "/wotlkc"
    SLASH_WOTLKC2 = "/wotlkcompanion"
    SLASH_WOTLKC3 = "/wrathofthelichkingcompanion"
    function SlashCmdList.WOTLKC(text)
        if text == "minimap" then
            ToggleMinimapButton()
        else
            -- toggle options here
        end
    end
end

-- Registers for events.
local function Initialize()
    WOTLKC.Types = WOTLKC.Util:Enum{"Accept", "Do", "Deliver", "Bank", "MailGet", "Grind", "Coordinate"}
    WOTLKC.Guides = {}
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
        QUEST_DETAIL = WOTLKC.Events.OnQuestDetail,
    }
    events = {
        WOTLKC_COORDINATES_REACHED = WOTLKC.Events.OnCoordinatesReached
    }
    for event, callback in pairs(wowEvents) do
        WOTLKCFrame:RegisterEvent(event, callback)
    end
    for event, callback in pairs(events) do
        WOTLKC.Events:RegisterEvent(event, callback)
    end
    GameTooltip:HookScript("OnTooltipSetItem", function()
        local itemLink = select(2, GameTooltip:GetItem())
        if itemLink then
            GameTooltip:AddLine("\nID " .. itemLink:match(":(%d+)"), 1, 1, 1, true)
        end
    end) -- temp
end

-- Loads all saved variables.
local function LoadVariables()
    WOTLKCOptions = WOTLKCOptions or {}
    WOTLKCOptions.minimapTable = WOTLKCOptions.minimapTable or {}
    WOTLKCOptions.minimapTable.show = WOTLKCOptions.minimapTable.show or true
    WOTLKCOptions.completedSteps = WOTLKCOptions.completedSteps or {}
    WOTLKCOptions.savedStepIndex = WOTLKCOptions.savedStepIndex or {}
    WOTLKCOptions.nbrSteps = 3 -- TODO: load variable
end

-- Called when most game data is available.
function WOTLKC.Events:OnPlayerEnteringWorld()
    WOTLKCFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    WOTLKC:Init()
    WOTLKCOptions.currentGuideName = "Elwynn Forest 1-10" -- temp
    if WOTLKCOptions.currentGuideName then
        WOTLKC:SetGuide(WOTLKCOptions.currentGuideName)
    end
end

-- Called on ADDON_LOADED.
function WOTLKC.Events:OnAddonLoaded(addonName)
    if addonName == ADDON_NAME then
        WOTLKCFrame:UnregisterEvent("ADDON_LOADED")
        LoadVariables()
        -- Initialize stuff.
        InitMinimapButton()
        InitSlash()
        WOTLKC.UI.Main:InitFrames()
        print("|cFFFFFF00WOTLK Companion|r loaded! Do not share this with anyone outside Progress.")
    end
end

-- Called when any registered event fires.
function WOTLKCFrame_OnEvent(self, event, ...)
    wowEvents[event](self, ...)
end

-- Called when the main frame has loaded.
function WOTLKCFrame_OnLoad(self)
    Initialize()
end
