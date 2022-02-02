local _, WOTLKC = ...

-- Variables.
local stepFrames = {}
local framePool = {}
local isLoaded = false

-- Sets the currently displayed guide to the given guide.
function WOTLKC:SetGuide(guide)
    WOTLKCOptions.currentGuide = guide
    WOTLKCFrameTitleFrameText:SetText(WOTLKCOptions.currentGuide.title)
    for i = 1, #stepFrames do
        local step = guide[i]
        if step then
            stepFrames[i]:UpdateStep(step)
        end
    end
end

-- Resizes each step frame to fit the parent frame. Code shamelessly stolen from Gemt.
local function ResizeStepFrames()
    if isLoaded then
        local height = WOTLKCFrameBodyFrame:GetHeight()
        local nbrSteps = WOTLKCOptions.nbrSteps
        for i = 1, nbrSteps do
            local topOffset = (i - 1) * (height / nbrSteps)
            local bottomOffset = height - (i * (height / nbrSteps))
            stepFrames[i]:SetPoint("TOPLEFT", WOTLKCFrameBodyFrame, "TOPLEFT", 0, -topOffset)
            stepFrames[i]:SetPoint("BOTTOMRIGHT", WOTLKCFrameBodyFrame, "BOTTOMRIGHT", 0, bottomOffset)
        end
    end
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
    ResizeStepFrames() -- Needs to be called once on addon load.
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
end
