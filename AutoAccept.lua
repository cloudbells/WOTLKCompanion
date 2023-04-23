local _, CGM = ...

-- Called on QUEST_ACCEPT_CONFIRM. Fires when an escort quest is started nearby.
function CGM.OnQuestAcceptConfirm(_, questTitle)
    if C_QuestLog.GetQuestInfo(CGM.currentStep.questID) == questTitle then
        ConfirmAcceptQuest()
    end
end

-- Called on QUEST_DETAIL. Fires when you're able to accept or decline a quest from an NPC.
function CGM:OnQuestDetail(...)
    -- temp
    if QuestFrame:IsVisible() then
        if not QuestFrameDetailPanel.questIDLbl then
            QuestFrameDetailPanel.questIDLbl = QuestFrameDetailPanel:CreateFontString("CGM_Temporary_FontString", "OVERLAY", "GameTooltipText")
            QuestFrameDetailPanel.questIDLbl:SetPoint("TOP", 0, -50)
        end
        QuestFrameDetailPanel.questIDLbl:SetText("Quest ID: " .. GetQuestID())
    end
    -- end of temp
    if not IsShiftKeyDown() then -- todo: change to chosen modifier by user in options -- temp
        if CGM.currentStep.type == CGM.Types.Accept then
            if CGM.currentStep.questID == GetQuestID() then -- GetQuestID returns the quest ID of the currently offered quest.
                AcceptQuest()
            end
        end
    end
end

-- Called on QUEST_PROGRESS. Fires when the player is able to click the "Continue" button (right after choosing a quest in the menu and right before being able to pick a quest reward).
function CGM:OnQuestProgress()
    if not IsShiftKeyDown() and CGM.currentStepIndex then
        local currentStep = CGM.currentStep
        if currentStep.type == CGM.Types.Deliver then
            if currentStep.questID == GetQuestID() then
                CompleteQuest()
            end
        end
    end
end

-- Called on QUEST_COMPLETE. Fires when the player is able to finally complete a quest (and choose a reward if there is any).
function CGM:OnQuestComplete()
    if not IsShiftKeyDown() then
        if CGM.currentStep.type == CGM.Types.Deliver then
            local nbrOfChoices = GetNumQuestChoices()
            if nbrOfChoices == 1 then -- Not sure if this is possible but just in case.
                GetQuestReward(1)
            elseif nbrOfChoices > 1 then
                if CGM.currentStep.rewardID then
                    for i = 1, nbrOfChoices do
                        local itemLink = GetQuestItemLink("choice", i)
                        local itemID = CGM:ParseIDFromLink(itemLink)
                        if itemID == CGM.currentStep.rewardID then
                            CGM:Message("Picking quest reward: " .. itemLink)
                            GetQuestReward(i)
                            break
                        end
                    end
                    CGM:Message("No quest reward found with the specified item ID: " .. CGM.currentStep.rewardID)
                end
            else
                GetQuestReward()
            end
        end
    end
end

-- Called on GOSSIP_SHOW. Fires when the gossip frame shows. (Different from an NPC that only gives quests since gossip can be shown regardless of if there are quests or not.)
function CGM:OnGossipShow()
    if not IsShiftKeyDown() then
        if UnitExists("npc") then -- Check if player is currently interacting with an NPC.
            if CGM.currentStep.type == CGM.Types.Accept then
                local availableQuests = {GetGossipAvailableQuests()}
                for i = 1, #availableQuests, 7 do
                    if C_QuestLog.GetQuestInfo(CGM.currentStep.questID) == availableQuests[i] then
                        SelectGossipAvailableQuest(i % 6)
                    end
                end
            elseif CGM.currentStep.type == CGM.Types.Deliver then
                local completableQuests = {GetGossipActiveQuests()}
                for i = 1, #completableQuests, 6 do
                    if C_QuestLog.GetQuestInfo(CGM.currentStep.questID) == completableQuests[i] and IsQuestComplete(CGM.currentStep.questID) then
                        SelectGossipActiveQuest(i % 5)
                    end
                end
            elseif CGM.currentStep.type == CGM.Types.Train then
                local gossipInfo = {GetGossipOptions()}
                for i = 2, #gossipInfo, 2 do
                    if gossipInfo[i] == "trainer" then
                        SelectGossipOption(i / 2)
                    end
                end
            end
        end
    end
end

-- Called on QUEST_GREETING.
function CGM:OnQuestGreeting(...)
    if not IsShiftKeyDown() then
        if UnitExists("npc") then
            if CGM.currentStep.type == CGM.Types.Accept then
                local availableQuests = GetNumAvailableQuests()
                for i = 1, availableQuests do
                    if GetAvailableTitle(i) == C_QuestLog.GetQuestInfo(CGM.currentStep.questID) then
                        SelectAvailableQuest(i)
                    end
                end
            elseif CGM.currentStep.type == CGM.Types.Deliver then
                local completableQuests = GetNumActiveQuests()
                for i = 1, completableQuests do
                    if GetActiveTitle(i) == C_QuestLog.GetQuestInfo(CGM.currentStep.questID) and IsQuestComplete(CGM.currentStep.questID) then
                        SelectActiveQuest(i)
                    end
                end
            end
        end
    end
end
