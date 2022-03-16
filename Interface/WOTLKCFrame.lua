local _, WOTLKC = ...

-- Variables.
local isScrollDisabled = false

-- Finds the next step from the current one that is not yet completed.
-- This will scroll from the given step index if given.
function WOTLKC.UI.Main:ScrollToNextIncomplete(fromStep)
    local index = 1
    for i = fromStep or WOTLKC.currentStep, #WOTLKC.currentGuide do
        if not WOTLKC:IsStepCompleted(i) and WOTLKC:IsStepAvailable(i) then
            index = i
            break
        end
    end
    WOTLKC:SetCurrentStep(index)
    -- Scroll to bottom if index is bigger than the number of steps, or to top if guide is done.
    index = index > #WOTLKC.currentGuide + 1 - WOTLKCOptions.nbrSteps and #WOTLKC.currentGuide + 1 - WOTLKCOptions.nbrSteps or index -- Upper bound for the slider.
    local oldSliderValue = WOTLKCSlider:GetValue()
    WOTLKCSlider:SetValue(index)
    if oldSliderValue == index then -- If we're not scrolling, then UpdateStepFrames won't be called because we're not changing the value of the slider, so update manually.
        WOTLKC.UI.StepFrame:UpdateStepFrames("ScrollToNextIncomplete")
    end
end

-- Finds and scrolls to the first relevant step in the guide. This might be any step since the player might've already completed some of them.
function WOTLKC.UI.Main:ScrollToFirstIncomplete()
    self:ScrollToNextIncomplete(1)
end

-- Scrolls to the step with the given index.
function WOTLKC.UI.Main:ScrollToIndex(index)
    self:ScrollToNextIncomplete(index)
end

-- Updates the slider max value.
function WOTLKC.UI.Main:UpdateSlider()
    local maxValue
    if #WOTLKC.currentGuide < WOTLKCOptions.nbrSteps then
        maxValue = 1
        WOTLKCSlider:SetValue(1)
        WOTLKCSlider.upButton:Disable()
        WOTLKCSlider.downButton:Disable()
        WOTLKCSlider:Disable()
        isScrollDisabled = true
    else
        maxValue = #WOTLKC.currentGuide - WOTLKCOptions.nbrSteps + 1
        local currentValue = WOTLKCSlider:GetValue()
        if currentValue > 1 then
            WOTLKCSlider.upButton:Enable()
        end
        if currentValue < maxValue then
            WOTLKCSlider.downButton:Enable()
        end
        WOTLKCSlider:Enable()
        isScrollDisabled = false
    end
    WOTLKCSlider:SetMinMaxValues(1, maxValue)
end

-- Called when user scrolls in the body frame.
function WOTLKC_OnScroll(_, delta)
    -- Dividing by delta is done only to achieve the correct sign (negative/positive). Delta is always 1.
    WOTLKCSlider:SetValue(WOTLKCSlider:GetValue() - WOTLKCSlider:GetValueStep() / delta)
end

-- Called when the slider value changes (either due to scroll, clicking the up/down buttons or manually dragging the knob).
function WOTLKC_Slider_OnValueChanged(self, value)
    WOTLKC.UI.StepFrame:UpdateStepFrames("WOTLKC_Slider_OnValueChanged")
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

-- Called when the options button was pressed by the player.
function WOTLKC_OptionsButton_OnClick()

end

-- Called when the size of the frame changes.
function WOTLKC_OnSizeChanged(self)
    WOTLKC.UI.StepFrame:ResizeStepFrames()
end

-- Initializes all the frames.
function WOTLKC.UI.Main:InitFrames()
    WOTLKC.UI.StepFrame:InitStepFrames()
end
