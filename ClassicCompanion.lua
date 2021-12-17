local ADDON_NAME, ClassicCompanion = ...

-- Variables.
local stepFrames = {}
local events

-- Sets the currently displayed guide to the given guide.
function ClassicCompanion:SetGuide(guide)
    ClassicCompanionOptions.currentGuide = guide
    ClassicCompanionFrameTitleFrameText:SetText(ClassicCompanionOptions.currentGuide.title)
    stepFrames[1]:UpdateStep(guide[1])
    stepFrames[2]:UpdateStep(guide[2])
    stepFrames[3]:UpdateStep(guide[3])
end

-- Resizes each step frame to fit the parent frame. Code shamelessly stolen from Gemt.
local function ResizeStepFrames()
    local height = ClassicCompanionFrameBodyFrame:GetHeight()
    local nbrSteps = ClassicCompanionOptions.nbrSteps
    for i = 1, nbrSteps do
        local topOffset = (i - 1) * (height / nbrSteps)
        local bottomOffset = height - (i * (height / nbrSteps))
        stepFrames[i]:SetPoint("TOPLEFT", ClassicCompanionFrameBodyFrame, "TOPLEFT", 0, -topOffset)
        stepFrames[i]:SetPoint("BOTTOMRIGHT", ClassicCompanionFrameBodyFrame, "BOTTOMRIGHT", 0, bottomOffset)
    end
end

-- Initializes the frames containing steps, getting frames from a frame pool.
local function InitStepFrames()
    -- Reclaim all used frames.
    for _, frame in pairs(stepFrames) do
        frame.used = false
    end
    for i = 1, ClassicCompanionOptions.nbrSteps do
        stepFrames[i] = ClassicCompanion:GetFrame()
        if i <= ClassicCompanionOptions.nbrSteps then
            stepFrames[i].index = i
            local text = stepFrames[i]:CreateFontString(nil, "BACKGROUND", "ClassicCompanionTextTemplate")
            text:SetPoint("TOPLEFT")
            stepFrames[i].text = text
            stepFrames[i].border = stepFrames[i]:CreateTexture(nil, "BORDER")
            stepFrames[i].border:SetColorTexture(0, 0, 0, 1)
            stepFrames[i].border:SetPoint("TOPRIGHT", stepFrames[i], "BOTTOMRIGHT")
            stepFrames[i].border:SetPoint("TOPLEFT", stepFrames[i], "BOTTOMLEFT")
            stepFrames[i].UpdateStep = function(self, step)
                self.text:SetText(step.text)
            end
        end
    end
    ResizeStepFrames() -- Needs to be called once on addon load.
end

-- Loads all saved variables.
local function LoadVariables()
    ClassicCompanionOptions = ClassicCompanionOptions or {}
    -- Number of steps shown (default: 4)
    ClassicCompanionOptions.nbrSteps = 3 -- TODO: load variable
end

-- Called on ADDON_LOADED.
function ClassicCompanion:OnAddonLoaded(addonName)
    if addonName == ADDON_NAME then
        ClassicCompanionFrame:UnregisterEvent("ADDON_LOADED")
        LoadVariables()
        InitStepFrames()
        ClassicCompanion:SetGuide(ClassicCompanion.TestGuide)
        print("|cFFFFFF00Classic Companion|r loaded!")
    end
end

-- Called when events occur - self is the frame, event is the event, and ... are the event arguments
local function OnEvent(_, event, ...)
    events[event](ClassicCompanion, ...)
end

-- Registers for events.
local function Initialize()
    ClassicCompanionFrameOptionsButton:SetScript("OnClick", function()
        ClassicCompanion:SetGuide(ClassicCompanion.TestGuide2)
    end)
    ClassicCompanionFrame:SetScript("OnEvent", OnEvent)
    ClassicCompanionFrame:SetScript("OnSizeChanged", ResizeStepFrames)
    ClassicCompanionFrame:RegisterForDrag("LeftButton")
    events = {
        ADDON_LOADED = ClassicCompanion.OnAddonLoaded,
    }
    for event, callback in pairs(events) do
        ClassicCompanionFrame:RegisterEvent(event, callback)
    end
end

Initialize()
