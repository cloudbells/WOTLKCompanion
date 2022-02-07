local _, WOTLKC = ...

-- todo:
-- build separate slider template like the dropdown template, make a nicer down button

-- Variables.
local stepFrames = {}
local framePool = {}
local isLoaded = false
local isScrollDisabled = false

-- Resizes each step frame to fit the parent frame. Code shamelessly stolen from Gemt.
local function ResizeStepFrames()
    if isLoaded then
        local height = WOTLKCFrameBodyFrame:GetHeight()
        local nbrSteps = WOTLKCOptions.nbrSteps
        for i = 1, nbrSteps do
            local topOffset = (i - 1) * (height / nbrSteps)
            local bottomOffset = height - (i * (height / nbrSteps))
            stepFrames[i]:SetPoint("TOPLEFT", WOTLKCFrameBodyFrame, "TOPLEFT", 0, -topOffset)
            stepFrames[i]:SetPoint("BOTTOMRIGHT", WOTLKCFrameBodyFrame, "BOTTOMRIGHT", -19, bottomOffset)
        end
    end
end

-- Updates the slider max value.
local function UpdateSlider()
    local maxValue
    if #WOTLKCOptions.currentGuide < #stepFrames then
        maxValue = 1
    else
        maxValue = #WOTLKCOptions.currentGuide - #stepFrames + 1
    end
    WOTLKCSlider:SetMinMaxValues(1, maxValue)
    -- Disable slider if all steps can be displayed without scrolling.
    if #WOTLKCOptions.currentGuide <= #stepFrames then
        WOTLKCSlider:SetValue(1)
        WOTLKCSlider.upButton:Disable()
        WOTLKCSlider.downButton:Disable()
        WOTLKCSlider:Disable()
        isScrollDisabled = true
    else
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
end

-- Updates the step frames according to the slider's current value.
local function UpdateStepFrames()
    if isLoaded then
        if WOTLKCOptions.currentGuide then
            local currentValue = WOTLKCSlider:GetValue()
            for i = 1, #stepFrames do
                if WOTLKCOptions.currentGuide[i] then
                    stepFrames[i]:UpdateStep(WOTLKCOptions.currentGuide[currentValue + i - 1])
                else
                    stepFrames[i]:Clear()
                end
            end
        end
    end
end

-- Sets the currently displayed guide to the given guide.
function WOTLKC:SetGuide(guide)
    WOTLKCOptions.currentGuide = guide
    WOTLKCFrameTitleFrameText:SetText(WOTLKCOptions.currentGuide.title)
    WOTLKCSlider:SetValue(1)
    UpdateStepFrames()
    UpdateSlider()
end

-- Returns (or creates if there is none available) a step frame from the pool.
local function GetStepFrame()
    for i = 1, #framePool do
        if not framePool[i]:IsLocked() then
            framePool[i]:Lock()
            return framePool[i]
        end
    end
    -- No available button was found, so create a new one and add it to the pool.
    local frame = CreateFrame("Frame", "WOTLKCStepFrame" .. #framePool + 1, WOTLKCFrameBodyFrame, "WOTLKCStepFrameTemplate")
    frame.Lock = function(self)
        self.isUsed = true
    end
    frame.IsLocked = function(self)
        return self.isUsed
    end
    frame.Unlock = function(self)
        self.isUsed = false
    end
    frame:Lock()
    framePool[#framePool + 1] = frame
    return frame
end

-- Initializes the frames containing steps, getting frames from a frame pool.
local function InitStepFrames()
    for i = 1, WOTLKCOptions.nbrSteps do
        stepFrames[i] = GetStepFrame()
    end
end

-- Called when the slider value changes (either due to scroll, clicking the up/down buttons or manually dragging the knob).
function WOTLKC_Slider_OnValueChanged(self, value)
    if not isScrollDisabled then
        UpdateStepFrames()
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
end

-- Called when user scrolls in the body frame.
function WOTLKC_OnScroll(_, delta)
    -- Dividing by delta is done only to achieve the correct sign (negative/positive). Delta is always 1.
    WOTLKCSlider:SetValue(WOTLKCSlider:GetValue() - WOTLKCSlider:GetValueStep() / delta)
end

-- Called when the options button was pressed by the player.
function WOTLKC_OptionsButton_OnClick()
    if WOTLKCOptions.currentGuide == WOTLKC.TestGuide then
        WOTLKC:SetGuide(WOTLKC.TestGuide2)
    else
        WOTLKC:SetGuide(WOTLKC.TestGuide)
    end
end

function WOTLKC_OnSizeChanged(self)
    ResizeStepFrames()
end

-- Initializes all the frames.
function WOTLKC:InitFrames()
    InitStepFrames()
    isLoaded = true
    ResizeStepFrames() -- Needs to be called once on addon load.
end
