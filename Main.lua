local _, WOTLKC = ...

-- Localized globals.
local IsQuestFlaggedCompleted, IsOnQuest, GetQuestObjectives = C_QuestLog.IsQuestFlaggedCompleted, C_QuestLog.IsOnQuest, C_QuestLog.GetQuestObjectives

-- Sets the current step to the given index.
function WOTLKC:SetCurrentStep(index, shouldScroll)
    if WOTLKC:IsStepAvailable(index) and not WOTLKC:IsStepCompleted(index) and WOTLKC.currentStep ~= index then
        WOTLKC.currentStep = index
        WOTLKCOptions.savedStepIndex[WOTLKC.currentGuideName] = index
        local step = WOTLKC.currentGuide[WOTLKC.currentStep]
        WOTLKC.UI.Arrow:SetGoal(step.x / 100, step.y / 100, step.map)
        WOTLKC.UI.StepFrame:UpdateStepFrames()
        if shouldScroll then
            WOTLKCSlider:SetValue(index)
        end
    end
end

-- Checks if the step with the given index in the currently selected guide is completed. Returns true if so, false otherwise.
function WOTLKC:IsStepCompleted(index)
    if WOTLKCOptions.completedSteps[WOTLKC.currentGuideName][index] then
        return true
    end
    local step = WOTLKC.currentGuide[index]
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
    elseif type == WOTLKC.Types.Grind then -- Check for level/xp.
        if not (UnitLevel("player") >= step.level and UnitXP("player") >= step.xp) then
            return false
        end
    elseif type == WOTLKC.Types.Coordinate then -- First check if the quest has been completed, then check if the next step has been completed and return that.
        if not (IsQuestFlaggedCompleted(questID) or (WOTLKC.currentGuideName[index + 1] and WOTLKC:IsStepCompleted(index + 1))) then
            return false
        end
    end
    WOTLKCOptions.completedSteps[WOTLKC.currentGuideName][index] = true
    return true
end

-- Returns true if the given step index is available to the player, false otherwise.
function WOTLKC:IsStepAvailable(index)
    local step = WOTLKC.currentGuide[index]
    local questID = step.questID or step.questIDs
    local requiredSteps = step.requires
    local lockedBySteps = step.lockedBy
    if lockedBySteps then
        for i = 1, #lockedBySteps do
            if WOTLKC:IsStepCompleted(lockedBySteps[i]) then
                return false
            end
        end
    end
    -- This should always be checking backward, never forward.
    if step.type == WOTLKC.Types.Deliver then -- If the quest isn't marked "complete" in the quest log, return false.
        return IsQuestComplete(questID)
    elseif step.type == WOTLKC.Types.Do then
        if step.isMultiStep then
            for i = 1, #questID do
                if IsOnQuest(questID[i]) then
                    return true
                end
            end
            return false
        else
            return IsOnQuest(questID)
        end
    elseif step.type == WOTLKC.Types.Accept and requiredSteps then
        for i = 1, #requiredSteps do
            if not self:IsStepCompleted(requiredSteps[i]) then
                return false
            end
        end
    end
    return true -- No requirements for this step.
end

-- Called when the player has accepted a quest.
function WOTLKC.Events:OnQuestAccepted(_, questID)
    -- No need to check any steps for the quest ID since we check for step completion dynamically when scrolling. Just update current steps.
    -- We should only scroll if the current step is of type Accept and has the same questID as this one.
    local step = WOTLKC.currentGuide[WOTLKC.currentStep]
    if step.type == WOTLKC.Types.Accept and step.questID == questID then
        WOTLKC.UI.StepFrame:ScrollToNextIncomplete()
    else
        WOTLKC.UI.StepFrame:UpdateStepFrames()
    end
    
    -- local stepIndex = WOTLKC.GetStepIndexFromQuestID[questID]
    -- if type(stepIndex) == "table" then
        -- for i = 1, #stepIndex do
            -- local step = WOTLKC.currentGuide[stepIndex[i]]
            -- if step.questID == questID and step.type == WOTLKC.Types.Accept then
                -- print("test1")
                -- WOTLKC.UI.StepFrame:ScrollToNextIncomplete()
                -- break
            -- end
        -- end
        -- WOTLKC.UI.StepFrame:UpdateStepFrames()
    -- else
        -- local step = WOTLKC.currentGuide[stepIndex]
        -- if step.questID == questID and step.type == WOTLKC.Types.Accept then
            -- print("test2")
            -- WOTLKC.UI.StepFrame:ScrollToNextIncomplete() -- Won't scroll if current step is incomplete.
        -- else -- ScrollToNextIncomplete already updates the step frames.
            -- WOTLKC.UI.StepFrame:UpdateStepFrames()
        -- end
    -- end
end

-- Called when the player has handed in a quest.
function WOTLKC.Events:OnQuestTurnedIn(questID)
    -- Quests aren't instantly marked as complete so need to manually mark them.
    -- Should simply just mark all steps containing this quest ID to completed, except if its a multi-step, in which case we check all the quests in that step before marking.
    local stepIndex = WOTLKC.GetStepIndexFromQuestID[questID]
    local count = stepIndex and (type(stepIndex) == "table" and #stepIndex or 1) or 0 -- If the quest ID is contained in multiple steps.
    for i = 1, count do
        local step = WOTLKC.currentGuide[stepIndex[i]]
        if step.isMultiStep then
            local isComplete = true
            for j = 1, #step.questIDs do
                local currQuestID = step.questIDs[j]
                isComplete = currQuestID ~= questID and not IsQuestFlaggedCompleted(currQuestID) and nil or true -- Important to not check given quest ID since it will not be completed yet.
            end
            WOTLKCOptions.completedSteps[WOTLKC.currentGuideName][stepIndex[i]] = isComplete
        else
            WOTLKCOptions.completedSteps[WOTLKC.currentGuideName][stepIndex[i]] = true
        end
    end
    WOTLKC.UI.StepFrame:ScrollToNextIncomplete() -- Won't scroll if current step is incomplete.
end

-- Called when a quest has been removed from the player's quest log.
function WOTLKC.Events:OnQuestRemoved(questID)
    -- this needs an update
    -- isquestfflaggedcompleted doesnt return true for recently handed in quests so this could be bugged
    -- also needs to check if the current step we're on is available anymore, and if it isnt then scroll to next available
    if not IsQuestFlaggedCompleted(questID) then -- This event fires when a player hands in a quest as well.
        local index = WOTLKC.GetStepIndexFromQuestID[questID]
        if type(index) == "number" then
            WOTLKCOptions.completedSteps[index] = nil
        else
            for i = 1, #index do
                WOTLKCOptions.completedSteps[WOTLKC.currentGuideName][index[i]] = nil
            end
        end
        WOTLKC.UI.StepFrame:UpdateStepFrames()
    end
end

function WOTLKC.Events:OnQuestWatchUpdate(questID)
    local objectives = GetQuestObjectives(questID)
    if objectives then
        for i = 1, #objectives do
            WOTLKC.Util:PrintTable(objectives[i])
        end
    end
end

-- Register a new guide for the addon.
function WOTLKC:RegisterGuide(guide)
    -- this function should check each step to make sure it has legal fields (i.e. there cant be any multistep Deliver steps etc)
    if guide.name then
        if WOTLKC.Guides[guide.name] then
            print("WOTLKCompanion: Guide with that name is already registered. Name must be unique.")
        else
            WOTLKC.Guides[guide.name] = guide
        end
    else
        print("WOTLKCompanion: The guide has no name! To help you identify which guide it is, here is the first step description:\n" .. guide[1].text)
    end
end

-- Sets the currently displayed guide to the given guide (has to have been registered first).
function WOTLKC:SetGuide(guideName)
    if WOTLKC.Guides[guideName] then
        WOTLKCOptions.completedSteps[guideName] = WOTLKCOptions.completedSteps[guideName] or {}
        WOTLKCOptions.savedStepIndex[guideName] = WOTLKCOptions.savedStepIndex[guideName]
        WOTLKC.currentGuideName = guideName
        WOTLKC.currentGuide = WOTLKC.Guides[guideName]
        WOTLKCFrame:SetTitleText(WOTLKC.currentGuideName)
        WOTLKC.UI.Main:UpdateSlider()
        WOTLKC.UI.StepFrame:UpdateStepFrames()
        if WOTLKCOptions.savedStepIndex[guideName] then
            WOTLKC:SetCurrentStep(WOTLKCOptions.savedStepIndex[guideName], true)
        else
            WOTLKC.UI.StepFrame:ScrollToFirstIncomplete()
        end
        -- Map quest IDs to step indeces so we don't have to iterate all steps to find quest IDs.
        local GetStepIndexFromQuestID = {}
        for i = 1, #WOTLKC.currentGuide do
            local questID = WOTLKC.currentGuide[i].questID or WOTLKC.currentGuide[i].questIDs
            if questID then
                if WOTLKC.currentGuide[i].isMultiStep then
                    for j = 1, #questID do
                        local current = GetStepIndexFromQuestID[questID[j]]
                        if current then
                            if type(current) == "number" then
                                GetStepIndexFromQuestID[questID[j]] = {
                                    current,
                                    i
                                }
                            else
                                current[#current + 1] = i
                            end
                        else
                            GetStepIndexFromQuestID[questID[j]] = i
                        end
                    end
                else
                    local current = GetStepIndexFromQuestID[questID]
                    if current then -- It already has a mapping, merge into a table.
                        if type(current) == "number" then
                            GetStepIndexFromQuestID[questID] = {
                                current,
                                i
                            }
                        else -- It's already a table so just append.
                            current[#current + 1] = i
                        end
                    else -- No mapping found so just assign.
                        GetStepIndexFromQuestID[questID] = i
                    end
                end
            end
        end
        WOTLKC.GetStepIndexFromQuestID = GetStepIndexFromQuestID
    else
        print("WOTLKCompanion: guide \"" .. guideName .. "\" hasn't been registered yet! Can't set the guide.")
    end
end
