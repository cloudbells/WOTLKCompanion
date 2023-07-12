local _, CGM = ...

--[[ Returns true if we should auto accept quests.
Will be true if:
    * Auto accept is on and modifier key is set to None (auto accept no matter what).
    * Auto accept is NOT on and modifier key is set to SHIFT/CTRL/ALT and that key IS down (don't auto accept unless modifier key is down).
Will be false if:
    * Auto accept is on and modifier key is set to SHIFT/CTRL/ALT and that key is down (auto accept except if modifier key is down).
    * Auto accept is NOT on and modifier key is set to None (DON'T auto accept no matter what). --]]
local function ShouldAutoAccept()
    local mod = CGMOptions.settings.modifier
    if CGMOptions.settings.autoAccept then
        if mod == CGM.Modifiers.None then
            return true
        else
            return not CGM:IsModifierDown()
        end
    else
        -- Auto accept only if modifier key is not "None" and is down.
        if mod == CGM.Modifiers.None then
            return false
        else
            return CGM:IsModifierDown()
        end
    end
end

-- Called on QUEST_ACCEPT_CONFIRM. Fires when an escort quest is started nearby.
function CGM.OnQuestAcceptConfirm(_, questTitle)
    -- if C_QuestLog.GetQuestInfo(CGM.currentStep.questID) == questTitle then
    -- Auto accept always for safety. If you don't want the quest after, just abandon it.
    ConfirmAcceptQuest()
    -- end
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
    if ShouldAutoAccept() and CGM.currentStep.type == CGM.Types.Accept and CGM.currentStep.questID == GetQuestID() then
        AcceptQuest()
    end
end

-- Called on QUEST_PROGRESS. Fires when the player is able to click the "Continue" button (right after choosing a quest in the menu and right before being able
-- to pick a quest reward).
function CGM:OnQuestProgress()
    if ShouldAutoAccept() and CGM.currentStepIndex then
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
    if ShouldAutoAccept() and CGM.currentStep.type == CGM.Types.Deliver then
        local nbrOfChoices = GetNumQuestChoices()
        -- Not sure if this is possible but just in case.
        if nbrOfChoices == 1 then
            GetQuestReward(1)
        elseif nbrOfChoices > 1 then
            if CGM.currentStep.rewardID then
                for i = 1, nbrOfChoices do
                    local itemLink = GetQuestItemLink("choice", i)
                    local itemID = CGM:ParseIDFromLink(itemLink)
                    if itemID == CGM.currentStep.rewardID then
                        CGM:Message("picking quest reward: " .. itemLink)
                        GetQuestReward(i)
                        break
                    end
                end
                CGM:Message("no quest reward found with the specified item ID: " .. CGM.currentStep.rewardID)
            end
        else
            GetQuestReward()
        end
    end
end

-- Called on GOSSIP_SHOW. Fires when the gossip frame shows. (Different from an NPC that only gives quests since gossip can be shown regardless of if there are
-- quests or not.)
function CGM:OnGossipShow()
    if ShouldAutoAccept() and UnitExists("npc") then
        if CGM.currentStep.type == CGM.Types.Accept then
            local availableQuests = C_GossipInfo.GetAvailableQuests()
            for i = 1, #availableQuests do
                local questID = availableQuests[i].questID
                if CGM.currentStep.questID == questID then
                    C_GossipInfo.SelectAvailableQuest(questID)
                end
            end
        elseif CGM.currentStep.type == CGM.Types.Deliver then
            local completableQuests = C_GossipInfo.GetActiveQuests()
            for i = 1, #completableQuests do
                local questID = completableQuests[i].questID
                if CGM.currentStep.questID == questID and IsQuestComplete(questID) then
                    C_GossipInfo.SelectActiveQuest(questID)
                end
            end
        end
    end
end

-- Called on QUEST_GREETING.
function CGM:OnQuestGreeting(...)
    if ShouldAutoAccept() and UnitExists("npc") then
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
