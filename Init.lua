local ADDON_NAME, CGM = ...

-- Variables.
local eventFrame
local minimapButton = LibStub("LibDBIcon-1.0")

-- Shows or hides the minimap button.
local function ToggleMinimapButton()
    CGMOptions.minimapTable.show = not CGMOptions.minimapTable.show
    if not CGMOptions.minimapTable.show then
        minimapButton:Hide("ClassicGuideMaker")
        CGM:Message("|cFFFFFF00ClassicGuideMaker:|r Minimap button hidden. Type /CGM minimap to show it again.")
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
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:AddLine("|cFFFFFFFFClassicGuideMaker|r")
            GameTooltip:AddLine("Left click to toggle the main window.")
            GameTooltip:AddLine("Shift-left click to toggle the arrow.")
            GameTooltip:AddLine("Ctrl-left click to open options.")
            GameTooltip:AddLine("Alt-left click to open the guide creation window.")
            GameTooltip:AddLine("Right click to hide this minimap button.")
            GameTooltip:Show()
        end,
        OnLeave = function(self)
            GameTooltip:Hide()
        end
    })
    -- Create minimap icon.
    minimapButton:Register("ClassicGuideMaker", LDB, CGMOptions.minimapTable)
end

-- Initializes slash commands.
local function InitSlash()
    SLASH_CGM1 = "/CGM"
    SLASH_CGM3 = "/ClassicGuideMaker"
    function SlashCmdList.CGM(text)
        if text == "minimap" then
            ToggleMinimapButton()
        else
            CGM:ToggleOptionsFrame()
        end
    end
end

-- Registers for events.
local function Initialize()
    CGM.Types = CGM:Enum({"Accept", "Do", "Item", "Deliver", "Bank", "MailGet", "Buy", "Grind", "Coordinate", "Train"})
    CGM.Modifiers = CGM:Enum({"SHIFT", "CTRL", "ALT", "None"})
    CGM:PrintTable(CGM.Modifiers) -- temp
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
    CGMOptions.settings = CGMOptions.settings or {}
    CGMOptions.settings.nbrSteps = CGMOptions.settings.nbrSteps or 4
    CGMOptions.settings.debug = CGMOptions.settings.debug or false
    CGMOptions.settings.modifier = CGMOptions.settings.modifier or CGM.Modifiers.SHIFT
end

-- Called when most game data is available.
function CGM:OnPlayerEnteringWorld()
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    CGM:SetGuide(CGMOptions.settings.currentGuide or CGM.defaultGuide)
end

-- Called on ADDON_LOADED.
function CGM:OnAddonLoaded(addonName)
    if addonName == ADDON_NAME then
        if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            CGM:Message("This addon is for classic versions of the game only. It may not work properly with retail.")
        end
        eventFrame:UnregisterEvent("ADDON_LOADED")
        LoadVariables()
        -- Initialize stuff.
        CGM:InitFrames()
        InitMinimapButton()
        InitSlash()
        CGM:Message("|cFFFFFF00ClassicGuideMaker|r loaded!")
    end
end

Initialize()
