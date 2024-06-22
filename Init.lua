local ADDON_NAME, CGM = ...

-- Variables.
local eventFrame
local CGMFrame
local minimapButton = LibStub("LibDBIcon-1.0")

-- Shows or hides the minimap button.
local function ToggleMinimapButton()
    CGMOptions.minimapTable.hide = not CGMOptions.minimapTable.hide
    if CGMOptions.minimapTable.hide then
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
                "Right click to hide this minimap button."
            }, "ANCHOR_LEFT")
        end,
        OnLeave = function()
            CGM:HideGameTooltip()
        end

    })
    -- Create minimap icon.
    minimapButton:Register("ClassicGuideMaker", LDB, CGMOptions.minimapTable)
end

-- Prints all available commands.
local function PrintHelp()
    CGM:Message("/CGM [command]")
    print("- |c0000FFFF[minimap]|r - toggles the minimap button on or off")
    print("- |c0000FFFF[options]|r - opens and closes the options window")
    print("- |c0000FFFF[steps]|r |c00AABBFF[nbrOfSteps]|r - change how many steps are showing at once (between 1 and 5 inclusive)")
    print("- |c0000FFFF[modifier]|r |c00AABBFF[key]|r - set modifier for auto accept/turn in (Shift/Ctrl/Alt/none)")
    print("- |c0000FFFF[debug]|r - toggle debug mode on or off")
    print("- |c0000FFFF[help]|r - show this message :)")
    print("- |c0000FFFF[secret]|r - type this if you dare")
end

-- Initializes slash commands.
local function InitSlash()
    SLASH_CGM1 = "/CGM"
    SLASH_CGM2 = "/ClassicGuideMaker"
    function SlashCmdList.CGM(text)
        local command = {strsplit(" ", text:lower())}
        if command[1] == "minimap" then
            ToggleMinimapButton()
        elseif command[1] == "options" then
            CGM:ToggleOptionsFrame()
        elseif command[1] == "steps" then
            command[2] = tonumber(command[2])
            if command[2] then
                if command[2] < 1 or command[2] > CGM.MAX_STEPS then
                    CGM:Message("steps have to be between 1 and 5 inclusive")
                else
                    CGM:SetNbrSteps(CGMFrame.optionsFrame.nbrStepsSlider, command[2])
                    CGMFrame.optionsFrame.nbrStepsSlider:SetValue(command[2])
                end
            else
                CGM:Message("specify the number of steps, between 1 and 5 inclusive.")
            end
        elseif command[1] == "modifier" then
            if command[2] == "shift" or command[2] == "ctrl" or command[2] == "alt" or command[2] == "none" then
                CGM:SetModifier(CGM.Modifiers[command[2]:upper()])
                CGMFrame.optionsFrame.modifierDropdown:SetSelectedValue(CGM.Modifiers[CGMOptions.settings.modifier], CGMOptions.settings.modifier,
                                                                        true)
            else
                CGM:Message("specify a valid modifier (shift/ctrl/alt/none)")
            end
        elseif command[1] == "debug" then
            CGM:ToggleDebug()
        elseif command[1] == "help" then
            PrintHelp()
        elseif command[1] == "secret" then
            CGM:Message("hi")
        else
            CGM:Message("unknown command.")
        end
    end
end

-- Initializes enums.
local function InitEnums()
    CGM.Types = CGM:Enum({"Accept", "Do", "Item", "Deliver", "Bank", "MailGet", "Buy", "Grind", "Coordinate", "Train", "Fly"})
    CGM.Modifiers = CGM:Enum({"SHIFT", "CTRL", "ALT", "NONE"})
    CGM.GuideFormats = CGM:Enum({"ClassicGuideMaker", "ClassicLeveler", "RestedXP"}) -- temp, update with new
end

-- Initializes debug stuff
local function InitDebugStuff()
    if not CGM.debugQuestFrameIDLbl then
        CGM.debugQuestFrameIDLbl = QuestFrameDetailPanel:CreateFontString("CGMDebugFontString", "OVERLAY", "GameTooltipText")
        CGM.debugQuestFrameIDLbl:SetPoint("TOP", 0, -50)
        CGM.debugQuestFrameIDLbl:SetText("Quest ID: -")
    end
    if not CGMOptions.settings.debug then
        CGM.debugQuestFrameIDLbl:Hide()
    end
end

-- Registers for events.
local function Initialize()
    GameTooltip:HookScript("OnTooltipSetItem", function()
        local itemLink = select(2, GameTooltip:GetItem())
        if itemLink then
            GameTooltip:AddLine("\nID " .. itemLink:match(":(%d+)"), 1, 1, 1, true)
        end
    end) -- temp
    eventFrame = CreateFrame("Frame")
    CGM.eventFrame = eventFrame
    CGM:RegisterAllEvents(eventFrame)
    InitEnums()
    CGM.Guides = {}
end

-- Loads all saved variables.
local function LoadVariables()
    CGMOptions = CGMOptions or {}
    CGMOptions.guides = CGMOptions.guides or {}
    CGMOptions.minimapTable = CGMOptions.minimapTable or {}
    CGMOptions.completedSteps = CGMOptions.completedSteps or {}
    CGMOptions.savedStepIndex = CGMOptions.savedStepIndex or {}
    CGMOptions.isCGMFrameHidden = CGMOptions.isCGMFrameHidden or false
    CGMOptions.isArrowHidden = CGMOptions.isArrowHidden or false
    CGM.MAX_STEPS = 5
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
        CGM:Debug("debugging is on, you can disable this by typing \"/CGM debug\"")
        eventFrame:UnregisterEvent("ADDON_LOADED")
        if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
            CGM:Message("this addon is for classic versions of the game only. It will not work with retail.")
            return
        end
        -- Initialize stuff.
        CGMFrame = CGM:InitFrames()
        InitMinimapButton()
        InitSlash()
        InitDebugStuff()
        CGM:InitTranslator()
        CGM:Message("addon loaded! Type /CGM help for some commands.")
        CGM:Debug("game version is " ..
                      (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and "Classic" or WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC and "TBC" or
                          WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC and "WOTLK"))
    end
end

Initialize()
