local _, CGM = ...

-- Variables.
local CUI
local CGMFrame
local slider

-- Called when user scrolls in the body frame.
function CGMFrame_OnMouseWheel(_, delta)
    -- Dividing by delta is done only to achieve the correct sign (negative/positive). Delta is always 1.
    CGMSlider:SetValue(CGMSlider:GetValue() - CGMSlider:GetValueStep() / delta)
end

-- Sets the title text.
local function CGMFrame_SetTitleText(self, text)
    self.titleFrame.title:SetText(text)
end

-- Sets the step counter text.
local function CGMFrame_SetStepCounterText(self, text)
    self.titleFrame.stepCounter:SetText(text)
end

-- Called when the size of the frame changes.
local function CGMFrame_OnSizeChanged(self)
    CGM:ResizeStepFrames()
end

-- Sets the text of the title frame.
local function TitleFrame_SetText(self, text)
    self.text:SetText(text)
end

-- Called when the mouse is down on the frame.
local function TitleFrame_OnMouseDown(self)
    CGMFrame:StartMoving()
end

-- Called when the mouse has been released from the frame.
local function TitleFrame_OnMouseUp(self)
    CGMFrame:StopMovingOrSizing()
end

-- Called when the slider value changes (either due to scroll, clicking the up/down buttons or manually dragging the knob).
local function Slider_OnValueChanged(self, value)
    CGM:UpdateStepFrames()
    -- Disable/enable buttons.
    local _, maxValue = self:GetMinMaxValues()
    if value <= 1 then
        self.upButton:Disable()
        self.downButton:Enable()
    elseif value >= maxValue then
        self.downButton:Disable()
        self.upButton:Enable()
    else
        self.upButton:Enable()
        self.downButton:Enable()
    end
end

-- Called when the resize button is held.
local function ResizeButton_OnMouseDown(self)
    CGMFrame:StartSizing()
end

-- Called when the resize button is released.
local function ResizeButton_OnMouseUp(self)
    CGMFrame:StopMovingOrSizing()
end

-- Called when the close button is clicked.
local function CloseButton_OnClick()
    CGM:ToggleCGMFrame()
end

-- Initializes the main frame.
local function InitCGMFrame()
    CGM:Debug("initializing CGMFrame")

    -- Main frame.
    CUI = LibStub("CloudUI-1.0")
    CGMFrame = CreateFrame("Frame", "CGMFrame", UIParent)
    CGMFrame:SetMovable(true)
    CGMFrame:SetResizable(true)
    CGMFrame:SetSize(300, 200)
    CGMFrame:SetResizeBounds(300, 200, 500, 400)
    CGMFrame:SetClampedToScreen(true)
    CGMFrame:SetFrameStrata("MEDIUM")
    CUI:ApplyTemplate(CGMFrame, CUI.templates.BorderedFrameTemplate)
    CUI:ApplyTemplate(CGMFrame, CUI.templates.BackgroundFrameTemplate)
    CGMFrame:HookScript("OnSizeChanged", CGMFrame_OnSizeChanged)
    CGMFrame:HookScript("OnMouseWheel", CGMFrame_OnMouseWheel)
    CGMFrame.SetTitleText = CGMFrame_SetTitleText
    CGMFrame.SetStepCounterText = CGMFrame_SetStepCounterText

    -- Title frame.
    local titleFrame = CreateFrame("Frame", "CGMFrameTitleFrame", CGMFrame)
    titleFrame:SetSize(1, 24)
    titleFrame:SetPoint("TOPLEFT")
    titleFrame:SetPoint("TOPRIGHT")
    local fontInstance = CUI:GetFontNormal()
    fontInstance:SetJustifyH("LEFT")

    -- Title text.
    local title = titleFrame:CreateFontString(nil, "BACKGROUND", fontInstance:GetName())
    title:SetWidth(200) -- temp
    title:SetPoint("LEFT", 4, 0)
    titleFrame.title = title

    -- Close button.
    local closeButton = CreateFrame("Button", "CGMFrameCloseButton", titleFrame)
    CUI:ApplyTemplate(closeButton, CUI.templates.HighlightFrameTemplate)
    CUI:ApplyTemplate(closeButton, CUI.templates.PushableFrameTemplate)
    CUI:ApplyTemplate(closeButton, CUI.templates.BorderedFrameTemplate)
    local size = titleFrame:GetHeight() - 1
    closeButton:SetSize(size, size)
    local texture = closeButton:CreateTexture(nil, "ARTWORK")
    texture:SetTexture("Interface/Addons/ClassicGuideMaker/Media/CloseButton")
    texture:SetAllPoints()
    closeButton.texture = texture
    closeButton:SetPoint("TOPRIGHT")
    closeButton:HookScript("OnClick", CloseButton_OnClick)

    -- Step counter.
    local stepCounter = titleFrame:CreateFontString(nil, "BACKGROUND", fontInstance:GetName())
    stepCounter:SetPoint("RIGHT", -closeButton:GetWidth() - 4, 0)
    titleFrame.stepCounter = stepCounter
    titleFrame.SetStepCount = TitleFrame_SetStepCount
    titleFrame:HookScript("OnMouseDown", TitleFrame_OnMouseDown)
    titleFrame:HookScript("OnMouseUp", TitleFrame_OnMouseUp)
    CGMFrame.titleFrame = titleFrame

    -- Body frame.
    local bodyFrame = CreateFrame("Frame", "CGMBodyFrame", CGMFrame)
    bodyFrame:SetPoint("TOPLEFT", titleFrame, "BOTTOMLEFT")
    bodyFrame:SetPoint("BOTTOMRIGHT")

    -- Slider.
    slider = CUI:CreateSlider(bodyFrame, "CGMSlider", 1, 1, true, "Interface/Addons/ClassicGuideMaker/Media/ThumbTexture",
                              "Interface/Addons/ClassicGuideMaker/Media/UpButton", "Interface/Addons/ClassicGuideMaker/Media/DownButton", false,
                              {Slider_OnValueChanged})
    slider:SetPoint("BOTTOMRIGHT", 0, 18)
    slider:SetPoint("TOPRIGHT", 0, -18)
    bodyFrame.slider = slider

    -- Resize button.
    local resizeButton = CreateFrame("Button", "CGMResizeButton", bodyFrame)
    resizeButton:SetFrameLevel(3)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", -16, -1)
    resizeButton:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")
    resizeButton:HookScript("OnMouseDown", ResizeButton_OnMouseDown)
    resizeButton:HookScript("OnMouseUp", ResizeButton_OnMouseUp)
    bodyFrame.resizeButton = resizeButton
    CGMFrame.bodyFrame = bodyFrame
    CGMFrame:SetPoint("CENTER")
    CGM.CGMFrame = CGMFrame
    if CGMOptions.isCGMFrameHidden then
        CGMFrame:Hide()
    end
end

-- Toggles the main frame on or off.
function CGM:ToggleCGMFrame()
    if CGMOptions.isCGMFrameHidden then
        CGMFrame:Show()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    else
        CGMFrame:Hide()
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    end
    CGMOptions.isCGMFrameHidden = not CGMOptions.isCGMFrameHidden
end

-- Finds the next step from the current one that is not yet completed.
-- This will scroll from the given step index if given.
function CGM:ScrollToNextIncomplete(fromStep)
    CGM:Debug("scrolling to next incomplete" .. (fromStep and " from " .. fromStep or ""))
    -- Find first available step starting from 1 (or fromStep).
    local index = 1
    for i = fromStep or CGM.currentStepIndex, #CGM.currentGuide do
        if not CGM:IsStepCompleted(i) and CGM:IsStepAvailable(i) then
            index = i
            break
        end
    end
    CGM:SetCurrentStep(index)
    -- Then scroll to it. Scroll to bottom if index is bigger than the number of steps, or to top if guide is done.
    -- Upper bound for the slider.
    if index - 1 > #CGM.currentGuide + 1 - CGMOptions.settings.nbrSteps then
        index = #CGM.currentGuide + 1 - CGMOptions.settings.nbrSteps
    else
        index = index - 1
    end
    index = index < 1 and 1 or index
    local oldSliderValue = slider:GetValue()
    slider:SetValue(index)
    -- If we're not scrolling, then UpdateStepFrames won't be called because we're not changing the value of the slider, so update manually.
    if oldSliderValue == index then
        CGM:UpdateStepFrames()
    end
end

-- Finds and scrolls to the first incomplete step in the guide.
function CGM:ScrollToFirstIncomplete()
    self:ScrollToNextIncomplete(1)
end

-- Scrolls to the step with the given index.
function CGM:ScrollToIndex(index)
    self:ScrollToNextIncomplete(index)
end

-- Updates the slider max value.
function CGM:UpdateSlider()
    local maxValue
    if #CGM.currentGuide < CGMOptions.settings.nbrSteps then
        maxValue = 1
        slider:SetValue(1)
        slider.upButton:Disable()
        slider.downButton:Disable()
        slider:Disable()
    else
        maxValue = #CGM.currentGuide - CGMOptions.settings.nbrSteps + 1
        local currentValue = slider:GetValue()
        if currentValue > 1 then
            slider.upButton:Enable()
        end
        if currentValue < maxValue then
            slider.downButton:Enable()
        end
        slider:Enable()
    end
    slider:SetMinMaxValues(1, maxValue)
end

-- Initializes all the frames.
function CGM:InitFrames()
    InitCGMFrame()
    CGM:InitOptionsFrame()
    CGM:InitDeleteFrame()
    CGM:InitStepFrames()
    CGM:InitEditFrame()
    CGM:InitArrow()
end
