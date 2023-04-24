local _, CGM = ...

local CUI
local optionsFrame
local nbrStepsSlider
local lastValue
local guideDropdown

-- Called when the size of the frame changes.
local function CGMOptionsFrame_OnSizeChanged(self)
    CGM:ResizeStepFrames()
end

-- Called when the mouse is down on the frame.
local function CGMOptionsFrame_OnMouseDown(self)
    optionsFrame:StartMoving()
end

-- Called when the mouse has been released from the frame.
local function CGMOptionsFrame_OnMouseUp(self)
    optionsFrame:StopMovingOrSizing()
end

-- Called when the main frame is shown.
local function CGMOptionsFrame_OnShow(self)
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
end

-- Called when the main frame is hidden.
local function CGMOptionsFrame_OnHide(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
end

-- Called when the resize button is held.
local function ResizeButton_OnMouseDown(self)
    optionsFrame:StartSizing()
end

-- Called when the resize button is released.
local function ResizeButton_OnMouseUp(self)
    optionsFrame:StopMovingOrSizing()
end

-- Called when the number of steps slider's value is changed.
local function NbrStepsSlider_OnValueChanged(self, value)
    if lastValue ~= value then -- Throttle.
        lastValue = value
        self.nbrStepsText:SetText(value)
        CGMOptions.settings.nbrSteps = value
        CGM:ResizeStepFrames()
        CGM:UpdateStepFrames()
    end
end

-- Called when the player selects a value in the dropdown.
local function CGMDropdown_OnValueChanged(self, value)
    CGM:SetGuide(value)
end

-- Called when the close button is clicked.
local function CloseButton_OnClick()
    optionsFrame:Hide()
end

-- Initializes the options frame.
function CGM.InitOptionsFrame()
    CUI = LibStub("CloudUI-1.0")
    local fontInstance = CUI:GetFontNormal()
    -- Main frame.
    optionsFrame = CreateFrame("Frame", "CGMOptionsFrame", UIParent)
    optionsFrame:SetMovable(true)
    optionsFrame:SetResizable(true)
    optionsFrame:SetSize(400, 300)
    optionsFrame:SetClampedToScreen(true)
    optionsFrame:SetFrameStrata("MEDIUM")
    CUI:ApplyTemplate(optionsFrame, CUI.templates.BorderedFrameTemplate)
    CUI:ApplyTemplate(optionsFrame, CUI.templates.BackgroundFrameTemplate)
    optionsFrame:HookScript("OnSizeChanged", CGMOptionsFrame_OnSizeChanged)
    optionsFrame:HookScript("OnMouseDown", CGMOptionsFrame_OnMouseDown)
    optionsFrame:HookScript("OnMouseUp", CGMOptionsFrame_OnMouseUp)
    optionsFrame:HookScript("OnShow", CGMOptionsFrame_OnShow)
    optionsFrame:HookScript("OnHide", CGMOptionsFrame_OnHide)
    tinsert(UISpecialFrames, optionsFrame:GetName())
    optionsFrame:SetPoint("CENTER")
    optionsFrame:SetBackgroundColor(0, 0, 0, 0.5)
    optionsFrame:Hide()
    -- Title fontstring.
    local title = optionsFrame:CreateFontString(nil, "BACKGROUND", CUI:GetFontBig():GetName())
    title:SetText("ClassicGuideMaker Options")
    title:SetPoint("TOPLEFT", 5, -4)
    -- Separator.
    local separator = optionsFrame:CreateTexture(nil, "OVERLAY")
    separator:SetHeight(1)
    separator:SetColorTexture(1, 1, 1, 1)
    separator:SetPoint("TOPLEFT", 0, -20)
    separator:SetPoint("TOPRIGHT", 0, -20)
    -- Close button.
    local closeButton = CreateFrame("Button", "CGMOptionsFrameCloseButton", optionsFrame)
    CUI:ApplyTemplate(closeButton, CUI.templates.HighlightFrameTemplate)
    CUI:ApplyTemplate(closeButton, CUI.templates.PushableFrameTemplate)
    CUI:ApplyTemplate(closeButton, CUI.templates.BorderedFrameTemplate)
    closeButton:SetSize(20, 20)
    local texture = closeButton:CreateTexture(nil, "ARTWORK")
    texture:SetTexture("Interface/Addons/ClassicGuideMaker/Media/CloseButton")
    texture:SetAllPoints()
    closeButton.texture = texture
    closeButton:SetPoint("TOPRIGHT")
    closeButton:HookScript("OnClick", CloseButton_OnClick)
    -- Resize button.
    -- local resizeButton = CreateFrame("Button", "CGMOptionsResizeButton", optionsFrame)
    -- resizeButton:SetFrameLevel(3)
    -- resizeButton:SetSize(16, 16)
    -- resizeButton:SetPoint("BOTTOMRIGHT")
    -- resizeButton:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
    -- resizeButton:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
    -- resizeButton:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")
    -- resizeButton:HookScript("OnMouseDown", ResizeButton_OnMouseDown)
    -- resizeButton:HookScript("OnMouseUp", ResizeButton_OnMouseUp)
    -- Guide dropdown.
    local guideDropdownDescription = optionsFrame:CreateFontString(nil, "BACKGROUND", fontInstance:GetName())
    guideDropdownDescription:SetText("Currrent guide")
    guideDropdownDescription:SetPoint("TOPLEFT", 5, -32)
    local values = {}
    for guideName in pairs(CGM.Guides) do
        values[#values + 1] = guideName
    end
    guideDropdown = CUI:CreateDropdown(CGMOptionsFrame, "CGMGuideDropdown", {CGMDropdown_OnValueChanged}, values, values)
    guideDropdown:SetPoint("TOPLEFT", guideDropdownDescription, "BOTTOMLEFT", 2, -4)
    guideDropdown:SetWidth(168)
    -- Number of steps.
    local nbrStepsDescription = optionsFrame:CreateFontString(nil, "BACKGROUND", fontInstance:GetName())
    nbrStepsDescription:SetPoint("TOPLEFT", guideDropdownDescription, "BOTTOMLEFT", 0, -32)
    nbrStepsDescription:SetText("Number of steps")
    nbrStepsSlider = CUI:CreateSlider(optionsFrame, "CGMNbrStepsSlider", 1, 5, true, "Interface/Addons/ClassicGuideMaker/Media/ThumbTexture", nil, nil, true)
    nbrStepsSlider:HookScript("OnValueChanged", NbrStepsSlider_OnValueChanged)
    nbrStepsSlider:SetPoint("TOPLEFT", nbrStepsDescription, "BOTTOMLEFT", 2, -4)
    local nbrStepsText = nbrStepsSlider:CreateFontString(nil, "BACKGROUND", fontInstance:GetName())
    nbrStepsText:SetPoint("BOTTOM", 0, -14)
    nbrStepsSlider.nbrStepsText = nbrStepsText
    nbrStepsSlider:SetValue(CGMOptions.settings.nbrSteps)
    nbrStepsSlider:SetHeight(20)
end

-- Toggles the options frame.
function CGM:ToggleOptionsFrame()
    if optionsFrame:IsVisible() then
        optionsFrame:Hide()
    else
        optionsFrame:Show()
    end
end
