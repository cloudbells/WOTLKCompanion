local _, WOTLKC = ...

-- Variables.
local isScrollDisabled = false

-- Updates the slider max value.
function WOTLKC.UI.Main:UpdateSlider()
    local maxValue
    local nbrStepFrames = WOTLKC.UI.StepFrame:GetNumberStepFrames()
    if #WOTLKC.Guides[WOTLKC.currentGuideName] < nbrStepFrames then
        maxValue = 1
        WOTLKCSlider:SetValue(1)
        WOTLKCSlider.upButton:Disable()
        WOTLKCSlider.downButton:Disable()
        WOTLKCSlider:Disable()
        isScrollDisabled = true
    else
        maxValue = #WOTLKC.Guides[WOTLKC.currentGuideName] - nbrStepFrames + 1
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
    WOTLKC.UI.StepFrame:UpdateStepFrames()
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
