local _, WOTLKC = ...

-- Called when the player has accepted a quest.
function WOTLKC.EventHandlers:OnQuestAccepted(_, questID)
    -- No need to check all steps for the quest ID since we check for step completion dynamically when scrolling. Just update current step.
    local step = WOTLKC.Guides[WOTLKC.currentGuideName][WOTLKC.currentStep]
    if step.type == WOTLKC.Types.Accept and step.questID == questID then
        WOTLKCOptions.completedSteps[WOTLKC.currentGuideName][WOTLKC.currentStep] = true
        WOTLKC.UI.StepFrame:ScrollToNextIncomplete()
    end
end

-- Called when the player has handed in a quest.
function WOTLKC.EventHandlers:OnQuestTurnedIn(questID)
    local step = WOTLKC.Guides[WOTLKC.currentGuideName][WOTLKC.currentStep]
    if step.type == WOTLKC.Types.Deliver and step.questID == questID then
        WOTLKCOptions.completedSteps[WOTLKC.currentGuideName][WOTLKC.currentStep] = true
        WOTLKC.UI.StepFrame:ScrollToNextIncomplete()
    end
end

-- Register a new guide for the addon.
function WOTLKC:RegisterGuide(guide)
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
        WOTLKC.currentGuideName = guideName
        WOTLKCOptions.completedSteps[WOTLKC.currentGuideName] = WOTLKCOptions.completedSteps[WOTLKC.currentGuideName] or {}
        WOTLKCFrame:SetTitleText(WOTLKC.currentGuideName)
        print("scrolling to first incomplete")
        WOTLKC.UI.Main:UpdateSlider()
        WOTLKC.UI.StepFrame:UpdateStepFrames()
        WOTLKC.UI.StepFrame:ScrollToFirstIncomplete()
    else
        print("WOTLKCompanion: guide \"" .. guideName .. "\" hasn't been registered yet! Can't set the guide.")
    end
end
