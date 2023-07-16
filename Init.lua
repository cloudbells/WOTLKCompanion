local ADDON_NAME, CGM = ...

-- Variables.
local eventFrame
local minimapButton = LibStub("LibDBIcon-1.0")

-- Shows or hides the minimap button.
local function ToggleMinimapButton()
    CGMOptions.minimapTable.show = not CGMOptions.minimapTable.show
    if not CGMOptions.minimapTable.show then
        minimapButton:Hide("ClassicGuideMaker")
        CGM:Message("minimap button hidden - type /CGM minimap to show it again.")
    else
        minimapButton:Show("ClassicGuideMaker")
    end
end

-- Initializes the minimap button.
local function InitMinimapButton()
    -- Register for eventual data brokers.
    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("ClassicGuideMaker", {
        type = "data source",
        text = "ClassicGuideMaker",
        icon = "Interface/Addons/ClassicGuideMaker/Media/MinimapButton",
        OnClick = function(self, button)
            if button == "LeftButton" then
                if IsShiftKeyDown() then
                    CGM:ToggleArrow()
                elseif IsControlKeyDown() then
                    CGM:ToggleOptionsFrame()
                elseif IsAltKeyDown() then
                    CGM:ToggleEditFrame()
                else
                    CGM:ToggleCGMFrame()
                end
            elseif button == "RightButton" then
                ToggleMinimapButton()
            end
        end,
        OnEnter = function(self)
            CGM:ShowGameTooltip(self, {
                "Left click to toggle the main window.",
                "Shift-left click to toggle the arrow.",
                "Ctrl-left click to open options.",
                "Alt-left click to open the guide creation window.",
                "Right click to hide this minimap button.",
            }, "ANCHOR_LEFT")
        end,
        OnLeave = function()
            CGM:HideGameTooltip()
        end,
    })
    -- Create minimap icon.
    minimapButton:Register("ClassicGuideMaker", LDB, CGMOptions.minimapTable)
end

-- Poor man's switch.
local function default()
    CGM:Message("unknown command.")
end

-- Initializes slash commands.
local function InitSlash()
    SLASH_CGM1 = "/CGM"
    SLASH_CGM3 = "/ClassicGuideMaker"
    function SlashCmdList.CGM(text)
        local split = {strsplit(" ", text:lower())}
        if split[1] == "minimap" then
            ToggleMinimapButton()
        elseif split[1] == "options" then
            CGM:ToggleOptionsFrame()
        elseif split[1] == "debug" then
            CGM:ToggleDebug()
        else
            default()
        end
    end
end

-- Registers for events.
local function Initialize()
    CGM.Types = CGM:Enum({"Accept", "Do", "Item", "Deliver", "Bank", "MailGet", "Buy", "Grind", "Coordinate", "Train"})
    CGM.Modifiers = CGM:Enum({"SHIFT", "CTRL", "ALT", "None"})
    CGM.Guides = {}
    GameTooltip:HookScript("OnTooltipSetItem", function()
        local itemLink = select(2, GameTooltip:GetItem())
        if itemLink then
            GameTooltip:AddLine("\nID " .. itemLink:match(":(%d+)"), 1, 1, 1, true)
        end
    end) -- temp
    eventFrame = CreateFrame("Frame")
    CGM:RegisterAllEvents(eventFrame)
end

-- Loads all saved variables.
local function LoadVariables()
    CGMOptions = CGMOptions or {}
    CGMOptions.guides = CGMOptions.guides or {}
    CGMOptions.minimapTable = CGMOptions.minimapTable or {}
    CGMOptions.minimapTable.show = CGMOptions.minimapTable.show or true
    CGMOptions.completedSteps = CGMOptions.completedSteps or {}
    CGMOptions.savedStepIndex = CGMOptions.savedStepIndex or {}
    CGMOptions.isCGMFrameHidden = CGMOptions.isCGMFrameHidden or false
    CGMOptions.isArrowHidden = CGMOptions.isArrowHidden or false
end

-- Called when most game data is available.
function CGM:OnPlayerEnteringWorld()
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    CGM:SetGuide(CGMOptions.settings.currentGuide or CGM.defaultGuide)
end

-- Called on ADDON_LOADED.
function CGM:OnAddonLoaded(addonName)
    if addonName == ADDON_NAME then
        LoadVariables()
        CGM:LoadSettings()
        CGM:Debug("debugging is on, you can disable this in /cgm options")
        eventFrame:UnregisterEvent("ADDON_LOADED")
        if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            CGM:Message("this addon is for classic versions of the game only. It will not work with retail.")
            return
        end
        -- Initialize stuff.
        CGM:InitFrames()
        InitMinimapButton()
        InitSlash()
        CGM:Message("addon loaded!")
        CGM:Debug("game version is " ..
                      (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and "Classic" or WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC and "TBC" or WOW_PROJECT_ID ==
                          WOW_PROJECT_WRATH_CLASSIC and "WOTLK"))
    end
end

Initialize()
