local _, CGM = ...

local CUI
local optionsFrame
local nbrStepsSlider
local lastValue
local guideDropdown
local isInitalized = false

-- Called when the size of the frame changes.
local function CGMOptionsFrame_OnSizeChanged(self)
    -- nyi
end

-- Called when the mouse is down on the frame.
local function CGMOptionsFrame_OnMouseDown(self)
    self:StartMoving()
end

-- Called when the mouse has been released from the frame.
local function CGMOptionsFrame_OnMouseUp(self)
    self:StopMovingOrSizing()
end

-- Called when the number of steps slider's value is changed.
local function NbrStepsSlider_OnValueChanged(self, value)
    -- Throttle.
    if isInitalized and lastValue ~= value then
        lastValue = value
        self.fontString:SetText("Number of steps - " .. value)
        CGMOptions.settings.nbrSteps = value
        CGM:Debug("set nbrSteps to " .. value)
        CGM:UpdateSlider()
        CGM:ResizeStepFrames()
        CGM:UpdateStepFrames()
    end
end

-- Called when the player selects a value in the guide dropdown.
local function CGMGuideDropdown_OnValueChanged(self, value)
    CGM:SetGuide(value)
end

-- Called when the player selects a value in the modifier dropdown.
local function CGMModifierDropdown_OnValueChanged(self, value)
    CGMOptions.settings.modifier = value
    CGM:Debug("auto accept modifier is " .. CGM.Modifiers[value])
end

-- Called when the close button is clicked.
local function CloseButton_OnClick()
    optionsFrame:Hide()
end

-- Called when the debug check button is clicked.
local function DebugButton_OnClick()
    CGMOptions.settings.debug = not CGMOptions.settings.debug
    if CGMOptions.settings.debug then
        CGM:Debug("debug mode is ON")
    else
        CGM:Message("debug mod is OFF")
    end
end

-- Called when the auto accept check button is clicked.
local function AutoAcceptButton_OnClick()
    CGMOptions.settings.autoAccept = not CGMOptions.settings.autoAccept
    CGM:Debug("auto accept is " .. (CGMOptions.settings.autoAccept and "ON" or "OFF"))
end

-- Called when any option is hovered over.
local function Option_OnEnter(self)
    CGM:ShowGameTooltip(self, {self.helpString}, "ANCHOR_RIGHT")
end

-- Called when mouse leaves an option.
local function Option_OnLeave()
    CGM:HideGameTooltip()
end

-- Initializes the options frame.
function CGM:InitOptionsFrame()
    CGM:Debug("initializing OptionsFrame")
    CUI = LibStub("CloudUI-1.0")

    -- Main frame.
    optionsFrame = CUI:CreateConfig(UIParent, "CGMOptionsFrame", "ClassicGuideMaker Options", "Interface/Addons/ClassicGuideMaker/Media/CloseButton")

    local options = {}

    -- Guide dropdown.
    local values = {}
    for guideName in pairs(CGM.Guides) do
        values[#values + 1] = guideName
    end
    guideDropdown = CUI:CreateDropdown(CGMOptionsFrame, "CGMGuideDropdown", {CGMGuideDropdown_OnValueChanged}, values, values)
    guideDropdown:SetWidth(168)
    guideDropdown.helpString = "Select which guide to show."
    guideDropdown.desc = "Currrent guide"
    options[#options + 1] = guideDropdown
    CGM.guideDropdown = guideDropdown

    -- Number of steps.
    nbrStepsSlider = CUI:CreateSlider(optionsFrame, "CGMNbrStepsSlider", 1, 5, true, "Interface/Addons/ClassicGuideMaker/Media/ThumbTexture", nil, nil, true,
                                      {NbrStepsSlider_OnValueChanged})
    nbrStepsSlider:SetValue(CGMOptions.settings.nbrSteps)
    nbrStepsSlider:SetHeight(20)
    nbrStepsSlider.helpString = "How many steps to show at once."
    nbrStepsSlider.desc = "Number of steps - " .. CGMOptions.settings.nbrSteps
    options[#options + 1] = nbrStepsSlider

    -- Auto accept modifier.
    local modifierDropdown = CUI:CreateDropdown(CGMOptionsFrame, "CGMModifierDropdown", {CGMModifierDropdown_OnValueChanged}, {1, 2, 3, 4},
                                                {"SHIFT", "CTRL", "ALT", "None"})
    modifierDropdown:SetWidth(168)
    modifierDropdown:SetSelectedValue(CGM.Modifiers[CGMOptions.settings.modifier], CGMOptions.settings.modifier)
    modifierDropdown.helpString =
        "When auto accept is ON, holding this key down will disable it temporarily.\nWhen auto accept is OFF, holding this key down will enable it temporarily."
    modifierDropdown.desc = "Auto accept modifier"
    options[#options + 1] = modifierDropdown

    -- Auto accept default or not.
    local autoAcceptButton = CUI:CreateCheckButton(optionsFrame, "CGMDebugCheckButton", {AutoAcceptButton_OnClick},
                                                   "Interface/Addons/ClassicGuideMaker/Media/CheckMark")
    autoAcceptButton:SetSize(20, 20)
    autoAcceptButton:SetChecked(CGMOptions.settings.autoAccept)
    autoAcceptButton.helpString = "Enable/disable auto accepting/handing in quests in the current step."
    autoAcceptButton.desc = "Auto accept/hand in quests"
    options[#options + 1] = autoAcceptButton

    -- Show debug messages.
    local debugButton = CUI:CreateCheckButton(optionsFrame, "CGMDebugCheckButton", {DebugButton_OnClick}, "Interface/Addons/ClassicGuideMaker/Media/CheckMark")
    debugButton:SetSize(20, 20)
    debugButton:SetChecked(CGMOptions.settings.debug)
    debugButton.helpString = "Enable/disable debug messages."
    debugButton.desc = "Show debug messages"
    options[#options + 1] = debugButton

    for _, widget in pairs(options) do
        widget.OnEnter = Option_OnEnter
        widget.OnLeave = Option_OnLeave
    end

    optionsFrame.AddWidgets(options)

    isInitalized = true
end

-- Toggles the options frame.
function CGM:ToggleOptionsFrame()
    if optionsFrame:IsVisible() then
        optionsFrame:Hide()
    else
        optionsFrame:Show()
    end
end
