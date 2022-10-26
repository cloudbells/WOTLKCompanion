local _, CGM = ...

-- Variables.
local CUI
local CGMFrame
local isScrollDisabled = false

-- Sets the title text.
local function CGMFrame_SetTitleText(self, text)
    self.titleFrame.text:SetText(text)
end

-- Called when the size of the frame changes.
local function CGMFrame_OnSizeChanged(self)
    CGM:ResizeStepFrames()
end

-- Called when user scrolls in the body frame.
function CGMFrame_OnMouseWheel(_, delta)
    -- Dividing by delta is done only to achieve the correct sign (negative/positive). Delta is always 1.
    CGMSlider:SetValue(CGMSlider:GetValue() - CGMSlider:GetValueStep() / delta)
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

-- Initializes the main frame.
local function InitCGMFrame()
    -- Main frame.
    CUI = LibStub("CloudUI-1.0")
    CGMFrame = CreateFrame("Frame", "CGMFrame", UIParent)
    CGMFrame:SetMovable(true)
    CGMFrame:SetResizable(true)
    CGMFrame:SetSize(300, 200)
    CGMFrame:SetMinResize(300, 200)
    CGMFrame:SetMaxResize(500, 400)
    CGMFrame:SetClampedToScreen(true)
    CGMFrame:SetFrameStrata("MEDIUM")
    CUI:ApplyTemplate(CGMFrame, CUI.templates.BorderedFrameTemplate)
    CUI:ApplyTemplate(CGMFrame, CUI.templates.BackgroundFrameTemplate)
    CGMFrame:HookScript("OnSizeChanged", CGMFrame_OnSizeChanged)
    CGMFrame:HookScript("OnMouseWheel", CGMFrame_OnMouseWheel)
    CGMFrame.SetTitleText = CGMFrame_SetTitleText
    -- Title frame.
    local titleFrame = CreateFrame("Frame", "CGMTitleFrame", CGMFrame)
    titleFrame:SetSize(1, 24)
    titleFrame:SetPoint("TOPLEFT")
    titleFrame:SetPoint("TOPRIGHT")
    local fontInstance = CUI:GetFontNormal()
    fontInstance:SetJustifyH("LEFT")
    local text = titleFrame:CreateFontString(nil, "BACKGROUND", fontInstance:GetName())
    text:SetWidth(200) -- temp
    text:SetPoint("LEFT", 4, 0)
    titleFrame.text = text
    titleFrame.SetText = TitleFrame_SetText
    titleFrame:HookScript("OnMouseDown", TitleFrame_OnMouseDown)
    titleFrame:HookScript("OnMouseUp", TitleFrame_OnMouseUp)
    CGMFrame.titleFrame = titleFrame
    -- Body frame.
    local bodyFrame = CreateFrame("Frame", "CGMBodyFrame", CGMFrame)
    bodyFrame:SetPoint("TOPLEFT", titleFrame, "BOTTOMLEFT")
    bodyFrame:SetPoint("BOTTOMRIGHT")
    -- Slider.
    local slider = CUI:CreateSlider(bodyFrame, "CGMSlider", 1, 1, true, "Interface/Addons/ClassicGuideMaker/Media/ThumbTexture", "Interface/Addons/ClassicGuideMaker/Media/UpButton",
        "Interface/Addons/ClassicGuideMaker/Media/DownButton", false)
    slider:SetPoint("BOTTOMRIGHT", 0, 18)
    slider:SetPoint("TOPRIGHT", 0, -18)
    slider:HookScript("OnValueChanged", Slider_OnValueChanged)
    bodyFrame.slider = slider
    -- Resize button.
    local resizeButton = CreateFrame("Button", "CGMResizeButton", bodyFrame)
    resizeButton:SetFrameLevel(3)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", -17, -1)
    resizeButton:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")
    resizeButton:HookScript("OnMouseDown", ResizeButton_OnMouseDown)
    resizeButton:HookScript("OnMouseUp", ResizeButton_OnMouseUp)
    bodyFrame.resizeButton = resizeButton
    CGMFrame.bodyFrame = bodyFrame
    CGMFrame:SetPoint("CENTER")
end

-- Finds the next step from the current one that is not yet completed.
-- This will scroll from the given step index if given.
function CGM:ScrollToNextIncomplete(fromStep)
    local index = 1
    for i = fromStep or CGM.currentStepIndex, #CGM.currentGuide do
        if not CGM:IsStepCompleted(i) and CGM:IsStepAvailable(i) then
            index = i
            break
        end
    end
    CGM:SetCurrentStep(index)
    -- Scroll to bottom if index is bigger than the number of steps, or to top if guide is done.
    index = index - 1 > #CGM.currentGuide + 1 - CGMOptions.nbrSteps and #CGM.currentGuide + 1 - CGMOptions.nbrSteps or index - 1 -- Upper bound for the slider.
    local oldSliderValue = CGMSlider:GetValue()
    CGMSlider:SetValue(index)
    if oldSliderValue == index then -- If we're not scrolling, then UpdateStepFrames won't be called because we're not changing the value of the slider, so update manually.
        CGM:UpdateStepFrames()
    end
end

-- Finds and scrolls to the first relevant step in the guide. This might be any step since the player might've already completed some of them.
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
    if #CGM.currentGuide < CGMOptions.nbrSteps then
        maxValue = 1
        CGMSlider:SetValue(1)
        CGMSlider.upButton:Disable()
        CGMSlider.downButton:Disable()
        CGMSlider:Disable()
        isScrollDisabled = true
    else
        maxValue = #CGM.currentGuide - CGMOptions.nbrSteps + 1
        local currentValue = CGMSlider:GetValue()
        if currentValue > 1 then
            CGMSlider.upButton:Enable()
        end
        if currentValue < maxValue then
            CGMSlider.downButton:Enable()
        end
        CGMSlider:Enable()
        isScrollDisabled = false
    end
    CGMSlider:SetMinMaxValues(1, maxValue)
end

-- Called when the options button was pressed by the player.
function CGM_OptionsButton_OnClick()
    print("options clicked, NYI")
end

-- Initializes all the frames.
function CGM:InitFrames()
    InitCGMFrame()
    CGM.InitDeleteFrame()
    CGM:InitStepFrames()
    CGM:InitArrow()
end
