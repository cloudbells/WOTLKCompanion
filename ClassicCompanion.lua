local ADDON_NAME, ClassicCompanion = ...

-- Variables.
local stepFrames = {}
local events

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
        if i ~= ClassicCompanionOptions.nbrSteps then
            stepFrames[i].index = i
            stepFrames[i].border = stepFrames[i]:CreateTexture(nil, "BORDER")
            stepFrames[i].border:SetColorTexture(0, 0, 0, 1)
            stepFrames[i].border:SetPoint("TOPRIGHT", stepFrames[i], "BOTTOMRIGHT")
            stepFrames[i].border:SetPoint("TOPLEFT", stepFrames[i], "BOTTOMLEFT")
        end
    end
    ResizeStepFrames() -- Needs to be called once on addon load.
end

-- Loads all saved variables.
local function LoadVariables()
    ClassicCompanionOptions = ClassicCompanionOptions or {}
    -- Number of steps shown (default: 5)
    ClassicCompanionOptions.nbrSteps = 5 -- TODO: load variable
    ClassicCompanionOptions.currentGuide = ClassicCompanion.TestGuide -- TODO: load variable
    print(ClassicCompanionOptions.currentGuide.title)
end

-- Called on ADDON_LOADED.
function ClassicCompanion:OnAddonLoaded(addonName)
    if addonName == ADDON_NAME then
        ClassicCompanionFrame:UnregisterEvent("ADDON_LOADED")
        LoadVariables()
        InitStepFrames()
        ClassicCompanionFrameTitleFrameText:SetText(ClassicCompanionOptions.currentGuide.title)
        print("|cFFFFFF00Classic Companion|r loaded!")
    end
end

-- Called when player clicks the title.
local function OnTitleClick()
    print("clicked")
end

-- Called when events occur - self is the frame, event is the event, and ... are the event arguments
local function OnEvent(_, event, ...)
    events[event](ClassicCompanion, ...)
end

-- Registers for events.
local function Initialize()
    ClassicCompanionFrame:SetScript("OnEvent", OnEvent)
    ClassicCompanionFrame:SetScript("OnSizeChanged", ResizeStepFrames)
    ClassicCompanionFrameTitleFrame:SetScript("OnClick", OnTitleClick)
    ClassicCompanionFrame:RegisterForDrag("LeftButton")
    events = {
        ADDON_LOADED = ClassicCompanion.OnAddonLoaded,
    }
    for event, callback in pairs(events) do
        ClassicCompanionFrame:RegisterEvent(event, callback)
    end
end

Initialize()
