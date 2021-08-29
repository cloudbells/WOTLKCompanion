local ADDON_NAME, ClassicCompanion = ...

-- Variables.
local addonLoaded = false
local stepFrames = {}

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
    -- Number of steps shown (default: 6)
    ClassicCompanionOptions.nbrSteps = ClassicCompanionOptions.nbrSteps or 6
end

-- Called on PLAYER_ENTERING_WORLD.
function ClassicCompanion:OnPlayerEnteringWorld()
    InitStepFrames()
    ClassicCompanionFrameTitleFrameText:SetText("Current Guide Name")
    addonLoaded = true
end

-- Called on ADDON_LOADED.
function ClassicCompanion:OnAddonLoaded(addonName)
    if addonName == ADDON_NAME then
        ClassicCompanionFrame:UnregisterEvent("ADDON_LOADED")
        LoadVariables()
        print("|cFFFFFF00Classic Companion|r loaded!")
    end
end

--[[------------------------------------
|          SCRIPT FUNCTIONS            |
------------------------------------]]--

-- Called when player clicks the title.
local function OnTitleClick()
    print("clicked")
end

-- Called when the player changes the size of the frame.
local function OnSizeChanged()
    if addonLoaded then
        ResizeStepFrames()
    end
end

-- Called when events occur - self is the frame, event is the event, and ... are the event arguments
local function OnEvent(frame, event, ...)
    if event == "ADDON_LOADED" then
        ClassicCompanion:OnAddonLoaded(...)
    elseif event == "PLAYER_ENTERING_WORLD" then
        ClassicCompanion:OnPlayerEnteringWorld(...)
    end
end

-- Set script functions.
ClassicCompanionFrame:SetScript("OnEvent", OnEvent)
ClassicCompanionFrame:SetScript("OnSizeChanged", OnSizeChanged)
ClassicCompanionFrameTitleFrame:SetScript("OnClick", OnTitleClick)
ClassicCompanionFrame:RegisterForDrag("LeftButton")
-- Register for events.
ClassicCompanionFrame:RegisterEvent("ADDON_LOADED")
ClassicCompanionFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
