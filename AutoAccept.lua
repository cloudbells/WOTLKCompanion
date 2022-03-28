local _, WOTLKC = ...

-- Called on QUEST_ACCEPT_CONFIRM. Fires when an escort quest is started nearby.
function WOTLKC.Events.OnQuestAcceptConfirm(_, questTitle)
    local currentStep = WOTLKC.currentStep
    if C_QuestLog.GetQuestInfo(currentStep.questID) == questTitle then
        ConfirmAcceptQuest()
    end
end

-- Called on QUEST_DETAIL. Fires when you're able to accept or decline a quest from an NPC.
function WOTLKC.Events:OnQuestDetail(...)
    -- temp
    if QuestFrame:IsVisible() then
        if not QuestFrameDetailPanel.questIDLbl then
            QuestFrameDetailPanel.questIDLbl = QuestFrameDetailPanel:CreateFontString("WOTLKC_Temporary_FontString", "OVERLAY", "GameTooltipText")
            QuestFrameDetailPanel.questIDLbl:SetPoint("TOP", 0, -50)
        end
        QuestFrameDetailPanel.questIDLbl:SetText("Quest ID: " .. GetQuestID())
    end
    -- end of temp
    if not IsShiftKeyDown() then -- todo: change to chosen modifier by user in options
        local currentStep = WOTLKC.currentStep
        if currentStep.type == WOTLKC.Types.Accept then
            if currentStep.questID == GetQuestID() then -- GetQuestID returns the quest ID of the currently offered quest.
                AcceptQuest()
            end
        end
    end
end

-- Called on QUEST_PROGRESS. Fires when the player is able to click the "Continue" button (right after choosing a quest in the menu and right before being able to pick a quest reward).
function WOTLKC.Events:OnQuestProgress()
    if not IsShiftKeyDown() and WOTLKC.currentStepIndex then
        local currentStep = WOTLKC.currentStep
        if currentStep.type == WOTLKC.Types.Deliver then
            if currentStep.questID == GetQuestID() then
                CompleteQuest()
            end
        end
    end
end

-- Called on QUEST_COMPLETE. Fires when the player is able to finally complete a quest (and choose a reward if there is any).
function WOTLKC.Events:OnQuestComplete()
    if not IsShiftKeyDown() then
        local currentStep = WOTLKC.currentStep
        if currentStep.type == WOTLKC.Types.Deliver then
            local nbrOfChoices = GetNumQuestChoices()
            if nbrOfChoices == 1 then -- Not sure if this is possible but just in case.
                GetQuestReward(1)
            elseif nbrOfChoices > 1 then
                if currentStep.rewardID then
                    for i = 1, nbrOfChoices do
                        local itemLink = GetQuestItemLink("choice", i)
                        local itemID = WOTLKC.Util:ParseIDFromLink(itemLink)
                        if itemID == currentStep.rewardID then
                            WOTLKC.Logging:Message("Picking quest reward: " .. itemLink)
                            GetQuestReward(i)
                            return
                        end
                    end
                    WOTLKC.Logging:Message("No quest reward found with the specified item ID: " .. currentStep.rewardID)
                end
            else
                GetQuestReward()
            end
        end
    end
end

-- Called on GOSSIP_SHOW. Fires when the gossip frame shows. (Different from an NPC that only gives quests since gossip can be shown regardless of if there are quests or not.)
function WOTLKC.Events:OnGossipShow()
    if not IsShiftKeyDown() then
        if UnitExists("npc") then -- Check if player is currently interacting with an NPC.
            local currentStep = WOTLKC.currentStep
            if currentStep.type == WOTLKC.Types.Accept then
                local availableQuests = {GetGossipAvailableQuests()}
                for i = 1, #availableQuests, 7 do
                    if C_QuestLog.GetQuestInfo(currentStep.questID) == availableQuests[i] then
                        SelectGossipAvailableQuest(i % 6)
                    end
                end
            elseif currentStep.type == WOTLKC.Types.Deliver then
                local completableQuests = {GetGossipActiveQuests()}
                for i = 1, #completableQuests, 6 do
                    if C_QuestLog.GetQuestInfo(currentStep.questID) == completableQuests[i] and IsQuestComplete(currentStep.questID) then
                        SelectGossipActiveQuest(i % 5)
                    end
                end
            end
        end
    end
end

-- Called on QUEST_GREETING.
function WOTLKC.Events:OnQuestGreeting(...)
    if not IsShiftKeyDown() then
        if UnitExists("npc") then
            local currentStep = WOTLKC.currentStep
            if currentStep.type == WOTLKC.Types.Accept then
                local availableQuests = GetNumAvailableQuests()
                for i = 1, availableQuests do
                    if GetAvailableTitle(i) == C_QuestLog.GetQuestInfo(currentStep.questID) then
                        SelectAvailableQuest(i)
                    end
                end
            elseif currentStep.type == WOTLKC.Types.Deliver then
                local completableQuests = GetNumActiveQuests()
                for i = 1, completableQuests do
                    if GetActiveTitle(i) == C_QuestLog.GetQuestInfo(currentStep.questID) and IsQuestComplete(currentStep.questID) then
                        SelectActiveQuest(i)
                    end
                end
            end
        end
    end
end
