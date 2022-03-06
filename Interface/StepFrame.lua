local _, WOTLKC = ...

-- Variables.
local stepFrames = {}
local framePool = {}
local isLoaded = false

-- Constants.
local STEP_TEXT_MARGIN = 28

-- Returns (or creates if there is none available) a step frame from the pool.
local function GetStepFrame()
    for i = 1, #framePool do
        if not framePool[i]:IsLocked() then
            framePool[i]:Lock()
            return framePool[i]
        end
    end
    -- No available button was found, so create a new one and add it to the pool.
    local frame = CreateFrame("Button", "WOTLKCStepFrame" .. #framePool + 1, WOTLKCFrameBodyFrame, "WOTLKCStepFrameTemplate")
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

-- Updates the step frames according to the slider's current value.
function WOTLKC.UI.StepFrame:UpdateStepFrames()
    if isLoaded and WOTLKC.currentGuideName then
        local currentValue = WOTLKCSlider:GetValue()
        for i = 1, #stepFrames do
            local index = currentValue + i - 1
            if WOTLKC.currentGuide[index] then
                stepFrames[i]:UpdateStep(index, WOTLKC.currentGuide[index], WOTLKC:IsStepAvailable(index), WOTLKC:IsStepCompleted(index), index == WOTLKC.currentStep)
            else
                stepFrames[i]:Clear()
            end
        end
    end
end

-- Resizes each step frame to fit the parent frame. Code shamelessly stolen from Gemt.
function WOTLKC.UI.StepFrame:ResizeStepFrames()
    if isLoaded then
        local height = WOTLKCFrameBodyFrame:GetHeight()
        local nbrSteps = #stepFrames
        for i = 1, nbrSteps do
            local topOffset = (i - 1) * (height / nbrSteps)
            local bottomOffset = height - (i * (height / nbrSteps))
            stepFrames[i]:SetPoint("TOPLEFT", WOTLKCFrameBodyFrame, "TOPLEFT", 0, -topOffset)
            stepFrames[i]:SetPoint("BOTTOMRIGHT", WOTLKCFrameBodyFrame, "BOTTOMRIGHT", -19, bottomOffset)
            stepFrames[i]:ResizeText(stepFrames[i]:GetWidth() - STEP_TEXT_MARGIN)
        end
    end
end

-- Initializes the frames containing steps, getting frames from a frame pool.
function WOTLKC.UI.StepFrame:InitStepFrames()
    for i = 1, WOTLKCOptions.nbrSteps do
        stepFrames[i] = GetStepFrame()
    end
    isLoaded = true
    WOTLKC.UI.StepFrame:ResizeStepFrames() -- Needs to be called once on addon load.
end

-- Called when the player clicks a step.
function WOTLKC_StepFrame_OnClick(self)
    WOTLKC:SetCurrentStep(self:GetIndex())
end
