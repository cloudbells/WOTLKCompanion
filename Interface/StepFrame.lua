local _, WOTLKC = ...

-- Variables.
local stepFrames = {}
local framePool = {}
local isLoaded = false

-- Localized globals.
local IsOnQuest, GetQuestObjectives = C_QuestLog.IsOnQuest, C_QuestLog.GetQuestObjectives

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
function WOTLKC.UI.StepFrame:UpdateStepFrames(test)
    if isLoaded and WOTLKC.currentGuideName then
        print("|cFFFF0000[" .. date("%H:%M:%S") .. "]:|r Updated frames from: " .. test)
        local currentValue = WOTLKCSlider:GetValue()
        local text
        local index
        local currentStep
        for i = 1, #stepFrames do
            index = currentValue + i - 1
            currentStep = WOTLKC.currentGuide[index]
            if currentStep then
                text = currentStep.text
                if WOTLKC.currentStep == index and not WOTLKC:IsStepCompleted(index) and currentStep.type == WOTLKC.Types.Do then
                    local objText = ""
                    if currentStep.isMultiStep then
                        for j = 1, #currentStep.questIDs do
                            if IsOnQuest(currentStep.questIDs[j]) then
                                local objectives = GetQuestObjectives(currentStep.questIDs[j])
                                if objectives then
                                    for k = 1, #objectives do
                                        if objectives[k].text then
                                            objText = objText .. objectives[k].text .. "\n"
                                        end
                                    end
                                end
                            end
                        end
                    elseif IsOnQuest(questID) then
                        local objectives = GetQuestObjectives(currentStep.questID)
                        if objectives then
                            for j = 1, #objectives do
                                if objectives[j].text then
                                    objText = objText .. objectives[j].text .. "\n"
                                end
                            end
                        end
                    end
                    text = #objText > 0 and objText or text
                end
                stepFrames[i]:UpdateStep(index, text, WOTLKC:IsStepAvailable(index), WOTLKC:IsStepCompleted(index), index == WOTLKC.currentStep)
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
function WOTLKC_StepFrame_OnClick(self, button)
    if button == "LeftButton" then
        WOTLKC:SetCurrentStep(self:GetIndex())
        WOTLKC.UI.StepFrame:UpdateStepFrames("WOTLKC_StepFrame_OnClick")
    else
        local index = self:GetIndex()
        WOTLKC:MarkStepCompleted(index, not WOTLKC:IsStepCompleted(index))
        WOTLKC.UI.StepFrame:UpdateStepFrames("WOTLKC_StepFrame_OnClick")
    end
end
