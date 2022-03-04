local _, WOTLKC = ...

-- Localized globals.
local IsQuestFlaggedCompleted, IsOnQuest, GetQuestObjectives = C_QuestLog.IsQuestFlaggedCompleted, C_QuestLog.IsOnQuest, C_QuestLog.GetQuestObjectives

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

-- Checks if the step with the given index in the currently selected guide is completed. Returns true if so, false otherwise.
local function IsStepCompleted(index)
    if WOTLKCOptions.completedSteps[WOTLKC.currentGuideName][index] then
        return true
    end
    local step = WOTLKC.Guides[WOTLKC.currentGuideName][index]
    local type = step.type
    local questID = step.questID
    if type == WOTLKC.Types.Accept then -- Check if the quest(s) is completed, if it isn't, check if it's in the quest log.
        if step.isMultiStep then
            for i = 1, #step.questIDs do
                if not (IsQuestFlaggedCompleted(step.questIDs[i]) or IsOnQuest(step.questIDs[i])) then
                    return false
                end
            end
            return true -- Player has either completed all quests or is on them.
        elseif not (IsQuestFlaggedCompleted(questID) or IsOnQuest(questID)) then
            return false
        end
    elseif type == WOTLKC.Types.Do then -- Check if quest is complete, and if not then check if the player has completed all objectives of the quest(s).
        local questObjectives
        if step.isMultiStep then
            for i = 1, #step.questIDs do
                if not IsQuestFlaggedCompleted(step.questIDs[i]) then -- Not all quests have been completed.
                    return false
                else
                    questObjectives = GetQuestObjectives(step.questIDs[i])
                    if questObjectives then -- If this is nil, can assume the quest is a simple "go talk to this guy" quest.
                        -- Need to explicitly check for nil AND false since if questObjectives isn't nil but empty, we can assume the same as above.
                        if questObjectives.finished ~= nil and not questObjectives.finished then
                            return false
                        end
                    end
                end
            end
        else
            questObjectives = GetQuestObjectives(questID)
            if not (IsQuestFlaggedCompleted(questID) or (questObjectives and questObjectives.finished ~= nil and questObjectives.finished)) then
                return false
            end
        end
    elseif type == WOTLKC.Types.Deliver then -- Simply check if the quest has been completed.
        if step.isMultiStep then
            for i = 1, #step.questIDs do
                if not IsQuestFlaggedCompleted(step.questIDs[i]) then
                    return false
                end
            end
        elseif not IsQuestFlaggedCompleted(questID) then
            return false
        end
    elseif type == WOTLKC.Types.Grind then -- Check if next step has been completed (means player has ignored this step most likely), then check for level/xp.
        if not ((WOTLKC.currentGuideName[index + 1] and IsStepCompleted(index + 1)) or (UnitLevel("player") >= step.level and UnitXP("player") >= step.xp)) then
            return false
        end
    elseif type == WOTLKC.Types.Coordinate then -- Check if the next step has been completed and return that.
        if not (WOTLKC.currentGuideName[index + 1] and IsStepCompleted(index + 1)) then
            return false
        end
    end
    WOTLKCOptions.completedSteps[WOTLKC.currentGuideName][index] = true
    return true
end

-- Sets the current step to the given index.
local function SetCurrentStep(index)
    if not IsStepCompleted(index) then
        WOTLKC.currentStep = index
        local step = WOTLKC.Guides[WOTLKC.currentGuideName][WOTLKC.currentStep]
        WOTLKC.UI.Arrow:SetGoal(step.x / 100, step.y / 100, step.map)
        WOTLKC.UI.StepFrame:UpdateStepFrames()
    end
end

-- Returns the current number of step frames.
function WOTLKC.UI.StepFrame:GetNumberStepFrames()
    return #stepFrames
end

-- Finds and scrolls to the first relevant step in the guide.
-- This might be any step since the player might've already completed some of them.
function WOTLKC.UI.StepFrame:ScrollToFirstIncomplete()
    local index = 1
    for i = 1, #WOTLKC.Guides[WOTLKC.currentGuideName] do
        if not IsStepCompleted(i) then
            index = i
            break
        end
    end
    SetCurrentStep(index)
    WOTLKCSlider:SetValue(index > #WOTLKC.currentGuideName + 1 - WOTLKCOptions.nbrSteps and #WOTLKC.currentGuideName or index)
end

-- Finds the next step from the current one that is not yet completed.
function WOTLKC.UI.StepFrame:ScrollToNextIncomplete()
    local index = 1
    for i = WOTLKC.currentStep, #WOTLKC.Guides[WOTLKC.currentGuideName] do
        if not IsStepCompleted(i) then
            index = i
            break
        end
    end
    SetCurrentStep(index)
    WOTLKCSlider:SetValue(index > #WOTLKC.currentGuideName + 1 - WOTLKCOptions.nbrSteps and #WOTLKC.currentGuideName or index)
end

-- Updates the step frames according to the slider's current value.
function WOTLKC.UI.StepFrame:UpdateStepFrames()
    if isLoaded and WOTLKC.currentGuideName then
        local currentValue = WOTLKCSlider:GetValue()
        for i = 1, #stepFrames do
            local index = currentValue + i - 1
            if WOTLKC.Guides[WOTLKC.currentGuideName][index] then
                stepFrames[i]:UpdateStep(index, WOTLKC.Guides[WOTLKC.currentGuideName][index], index == WOTLKC.currentStep, IsStepCompleted(index))
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
        local nbrSteps = WOTLKCOptions.nbrSteps
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
    SetCurrentStep(self:GetIndex())
end
