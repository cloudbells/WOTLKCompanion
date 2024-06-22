local _, CGM = ...

local CUI
local optionsFrame
local nbrStepsSlider
local lastValue
local guideDropdown
local isInitalized = false

-- Called when the number of steps slider's value is changed.
local function NbrStepsSlider_OnValueChanged(self, value)
    -- Throttle.
    if isInitalized and lastValue ~= value then
        lastValue = value
        CGM:SetNbrSteps(self, value)
    end
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
    optionsFrame = CUI:CreateConfig(
                       UIParent, "CGMOptionsFrame", "ClassicGuideMaker Options", "Interface/Addons/ClassicGuideMaker/Media/CloseButton", 1, 10,
                       "Interface/Addons/ClassicGuideMaker/Media/ThumbTexture", "Interface/Addons/ClassicGuideMaker/Media/UpButton",
                       "Interface/Addons/ClassicGuideMaker/Media/DownButton")

    local widgets = {}

    -- Guide dropdown.
    local values = {}
    for guideName in pairs(CGM.Guides) do
        values[#values + 1] = guideName
    end
    guideDropdown = CUI:CreateDropdown(optionsFrame.widgetFrame, "CGMGuideDropdown", {CGM.SetGuide}, values, values)
    guideDropdown:SetWidth(168)
    guideDropdown.helpString = "Select which guide to show."
    guideDropdown.desc = "Currrent guide"
    widgets[#widgets + 1] = guideDropdown
    CGM.guideDropdown = guideDropdown

    -- Number of steps.
    nbrStepsSlider = CUI:CreateSlider(
                         optionsFrame.widgetFrame, "CGMNbrStepsSlider", 1, CGM.MAX_STEPS, true,
                         "Interface/Addons/ClassicGuideMaker/Media/ThumbTexture", nil, nil, true, {NbrStepsSlider_OnValueChanged})
    nbrStepsSlider:SetValue(CGMOptions.settings.nbrSteps)
    nbrStepsSlider:SetHeight(20)
    nbrStepsSlider.helpString = "How many steps to show at once."
    nbrStepsSlider.desc = "Number of steps - " .. CGMOptions.settings.nbrSteps
    optionsFrame.nbrStepsSlider = nbrStepsSlider
    widgets[#widgets + 1] = nbrStepsSlider

    -- Auto accept modifier.
    local modifierDropdown = CUI:CreateDropdown(
                                 optionsFrame.widgetFrame, "CGMModifierDropdown", {CGM.SetModifier}, {1, 2, 3, 4}, {"SHIFT", "CTRL", "ALT", "NONE"})
    modifierDropdown:SetWidth(168)
    modifierDropdown:SetSelectedValue(CGM.Modifiers[CGMOptions.settings.modifier], CGMOptions.settings.modifier)
    modifierDropdown.helpString =
        "When auto accept is ON, holding this key down will disable it temporarily.\nWhen auto accept is OFF, holding this key down will enable it temporarily."
    modifierDropdown.desc = "Auto accept modifier"
    optionsFrame.modifierDropdown = modifierDropdown
    widgets[#widgets + 1] = modifierDropdown

    -- Auto accept default or not.
    local autoAcceptButton = CUI:CreateCheckButton(
                                 optionsFrame.widgetFrame, "CGMDebugCheckButton", {CGM.ToggleAuto},
                                 "Interface/Addons/ClassicGuideMaker/Media/CheckMark")
    autoAcceptButton:SetSize(20, 20)
    autoAcceptButton:SetChecked(CGMOptions.settings.autoAccept)
    autoAcceptButton.helpString = "Enable/disable auto accepting/handing in quests in the current step."
    autoAcceptButton.desc = "Auto accept/hand in quests"
    widgets[#widgets + 1] = autoAcceptButton

    -- Show debug messages.
    local debugButton = CUI:CreateCheckButton(
                            optionsFrame.widgetFrame, "CGMDebugCheckButton", {CGM.ToggleDebug}, "Interface/Addons/ClassicGuideMaker/Media/CheckMark")
    debugButton:SetSize(20, 20)
    debugButton:SetChecked(CGMOptions.settings.debug)
    debugButton.helpString = "Enable/disable debug messages."
    debugButton.desc = "Show debug messages"
    widgets[#widgets + 1] = debugButton

    for _, widget in pairs(widgets) do
        widget.OnEnter = Option_OnEnter
        widget.OnLeave = Option_OnLeave
    end
    optionsFrame:AddWidgets(widgets)

    isInitalized = true
    return optionsFrame
end

-- Toggles the options frame.
function CGM:ToggleOptionsFrame()
    if optionsFrame:IsVisible() then
        optionsFrame:Hide()
    else
        optionsFrame:Show()
    end
end
