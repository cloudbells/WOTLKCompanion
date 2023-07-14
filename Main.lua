local _, CGM = ...

-- Variables.
local GetStepIndexFromQuestID = {}

-- Localized globals.
local IsQuestFlaggedCompleted, IsOnQuest, GetQuestObjectives, GetQuestInfo = C_QuestLog.IsQuestFlaggedCompleted, C_QuestLog.IsOnQuest,
                                                                             C_QuestLog.GetQuestObjectives, C_QuestLog.GetQuestInfo
local UnitXP, UnitLevel = UnitXP, UnitLevel
local GetItemCount, GetItemInfo = GetItemCount, GetItemInfo
local GetContainerNumSlots, GetContainerItemInfo, UseContainerItem = C_Container.GetContainerNumSlots, C_Container.GetContainerItemInfo,
                                                                     C_Container.UseContainerItem

-- Processes all tags in the given guide and replaces them with the proper strings.
local function ProcessTags(guide)
    for i = 1, #guide do
        local step = guide[i]
        if step.text then
            for tag in step.text:gmatch("{(%w+)}") do
                local tagLower = tag:lower()
                if tagLower:find("questname") then
                    if step.isMultiStep then
                        local n = tonumber(tag:match("%a+(%d+)"))
                        if n then
                            local questID = step.questIDs[n]
                            if questID then
                                local questName = GetQuestInfo(questID)
                                if questName then
                                    step.text = step.text:gsub("{" .. tag .. "}", questName)
                                end
                            end
                        end
                    elseif step.questID then
                        local questName = GetQuestInfo(step.questID)
                        if questName then
                            step.text = step.text:gsub("{" .. tag .. "}", questName)
                        end
                    end
                elseif tagLower:find("itemname") then
                    local n = tonumber(tag:match("%a+(%d+)"))
                    if n then
                        local itemID = step.items[n]
                        if itemID then
                            local item = Item:CreateFromItemID(itemID)
                            item:ContinueOnItemLoad(function()
                                local itemName = item:GetItemName()
                                if itemName then
                                    step.text = step.text:gsub("{" .. tag .. "}", itemName)
                                end
                            end)
                        end
                    end
                elseif tagLower == "x" then
                    if step.x then
                        step.text = step.text:gsub("{" .. tag .. "}", step.x)
                    end
                elseif tagLower == "y" then
                    if step.y then
                        step.text = step.text:gsub("{" .. tag .. "}", step.y)
                    end
                elseif tagLower == "cost" then
                    local cost = step.cost
                    step.text = step.text:gsub("{" .. tag .. "}",
                                               cost < 100 and cost .. "c" or (cost >= 100 and cost < 10000 and cost / 100 .. "s") or cost / 10000 .. "g")
                elseif tagLower == "spells" then
                    if step.spells then
                        local str = ""
                        for _, info in pairs(step.spells) do
                            str = str .. info.name .. ", "
                        end
                        step.text = step.text:gsub("{" .. tag .. "}", str:gsub(", $", ""))
                    end
                else
                    CGM:Debug("unknown tag in " .. guide.name)
                end
            end
        end
    end
end

-- Shows the GameTooltip on the given frame with the given lines and anchor.
function CGM:ShowGameTooltip(frame, lines, anchor)
    GameTooltip:SetOwner(frame, anchor or "ANCHOR_RIGHT")
    GameTooltip:AddLine("|cFFFFFFFFClassicGuideMaker|r")
    for _, line in ipairs(lines) do
        GameTooltip:AddLine(line)
    end
    GameTooltip:Show()
end

-- Hides the GameTooltip.
function CGM:HideGameTooltip()
    GameTooltip:Hide()
end

-- Sets the current step to the given index.
function CGM:SetCurrentStep(index, shouldScroll)
    if CGM:IsStepAvailable(index) and not CGM:IsStepCompleted(index) then
        CGM.currentStepIndex = index
        CGMOptions.savedStepIndex[CGM.currentGuideName] = index
        local step = CGM.currentGuide[index]
        CGM.currentStep = step
        CGM:SetGoal(step.x / 100, step.y / 100, step.mapID)
        if shouldScroll then
            CGM.CGMFrame.bodyFrame.slider:SetValue(index - 1)
        end
        CGM:Debug("set step to " .. index)
    end
end

-- Attempts to mark the step with the given index as completed.
function CGM:MarkStepCompleted(index, completed, isManual)
    -- TODO: check that it can be marked incomplete here (i.e. if its been handed in already etc) -- temp
    -- if marking a step incomplete here makes the current step unavailable, should go back to step index #currentStep.requiredSteps (the last step in that
    -- table) or if that is unvailable then go to #currentStep.requiredSteps - 1 etc. (see OnItemUpdate)
    CGM:Debug("marked " .. index .. " as " .. (completed and "completed" or "not completed"))
    CGMOptions.completedSteps[CGM.currentGuideName][index] = completed or nil
    if completed and isManual then
        CGM:ScrollToNextIncomplete()
    end
end

-- Checks if the step with the given index in the currently selected guide is completed. Returns true if so, false otherwise.
function CGM:IsStepCompleted(index)
    -- CGM:Debug("checking if " .. index .. " is completed...")
    if CGMOptions.completedSteps[CGM.currentGuideName][index] then
        return true
    end
    local step = CGM.currentGuide[index]
    local type = step.type
    local questID = step.questID
    -- Check if the quest is completed, if it isn't, check if it's in the quest log.
    if type == CGM.Types.Accept then
        if not (IsQuestFlaggedCompleted(questID) or IsOnQuest(questID)) then
            return false
        end
    elseif type == CGM.Types.Item and not IsQuestFlaggedCompleted(questID) then
        -- First check if the player has completed the associated quest, then check if the items are in the player's bags.
        if IsQuestFlaggedCompleted(step.questID) then
            return true
        else
            for itemID, itemCount in pairs(step.items) do
                if GetItemCount(itemID) < itemCount then
                    return false
                end
            end
        end
    elseif type == CGM.Types.Do then
        -- Check if quest is complete in quest log, and if not then check if the player has completed all objectives of the quest(s).
        local questObjectives
        if step.isMultiStep then
            for i = 1, #step.questIDs do
                -- Not all quests have been completed.
                if not (IsQuestComplete(step.questIDs[i]) or IsQuestFlaggedCompleted(step.questIDs[i])) then
                    return false
                else
                    questObjectives = GetQuestObjectives(step.questIDs[i])
                    -- If this is nil, can assume the quest is a simple "go talk to this guy" quest.
                    if questObjectives then
                        -- Need to explicitly check for nil AND false since if questObjectives isn't nil but empty, we can assume the same as above.
                        if questObjectives.finished ~= nil and not questObjectives.finished then
                            return false
                        end
                    end
                end
            end
        else
            questObjectives = GetQuestObjectives(questID)
            if not (IsQuestComplete(questID) or IsQuestFlaggedCompleted(questID) or
                (questObjectives and questObjectives.finished ~= nil and questObjectives.finished)) then
                return false
            end
        end
    elseif type == CGM.Types.Deliver then
        -- Simply check if the quest has been completed.
        if not IsQuestFlaggedCompleted(questID) then
            return false
        end
    elseif type == CGM.Types.Grind then
        -- Check for level/xp.
        if not (UnitLevel("player") >= step.level and UnitXP("player") >= step.xp) then
            return false
        end
    elseif type == CGM.Types.Coordinate then
        -- First check if the quest has been completed, then check if the next step has been completed and return that.
        if not questID or not (IsQuestFlaggedCompleted(questID) or (CGM.currentGuideName[index + 1] and CGM:IsStepCompleted(index + 1))) then
            return false
        end
    elseif type == CGM.Types.Buy then
        -- Can't check if player already has item in case the guide asks them to buy a duplicate item so just return false by default.
        return false
    elseif type == CGM.Types.Train then
        -- If just one of the spells in the list isn't known, return false.
        local spells = step.spells
        for spellID in pairs(spells) do
            if not IsSpellKnown(spellID) then
                return false
            end
        end
    end
    -- If the player removes an item from bags, this should return false.
    if type ~= CGM.Types.Item or (type == CGM.Types.Item and IsQuestFlaggedCompleted(questID)) then
        CGM:MarkStepCompleted(index, true)
    end
    -- CGM:Debug(index .. " is completed")
    return true
end

-- Returns true if the given step index is available to the player, false otherwise.
function CGM:IsStepAvailable(index)
    -- CGM:Debug("checking if " .. index .. " is available...")
    local step = CGM.currentGuide[index]
    local questID = step.questID or step.questIDs
    if step.requiresLevel then
        if UnitLevel("player") < step.requiresLevel then
            return false
        end
    end
    if step.lockedBySteps then
        for i = 1, #step.lockedBySteps do
            if CGM:IsStepCompleted(step.lockedBySteps[i]) then
                return false
            end
        end
    end
    local type = step.type
    -- This should always be checking backward, never forward.
    -- If the quest isn't marked "complete" in the quest log, return false.
    if type == CGM.Types.Deliver then
        return IsQuestComplete(questID)
    elseif type == CGM.Types.Do then
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
    elseif step.requiresSteps and (type == CGM.Types.Accept or type == CGM.Types.Item) then
        for i = 1, #step.requiresSteps do
            if not self:IsStepCompleted(step.requiresSteps[i]) then
                return false
            end
        end
    elseif type == CGM.Types.Buy or type == CGM.Types.Train then
        if GetMoney() < step.cost then
            return false
        end
    end
    -- CGM:Debug(index .. " is available")
    -- No requirements for this step.
    return true
end

-- Called on ITEM_UPDATE. Checks if the item that was just added or removed was an item required by the current step.
function CGM:OnItemUpdate()
    if CGM.currentStep.type == CGM.Types.Item and CGM:IsStepCompleted(CGM.currentStepIndex) then
        CGM:ScrollToNextIncomplete() -- Calls UpdateStepFrames.
    else
        CGM:UpdateStepFrames()
    end
    -- If by deleting an item, it made another step unavailable.
    local requiresSteps = CGM.currentStep.requiresSteps
    if not CGM:IsStepAvailable(CGM.currentStepIndex) then
        if requiresSteps then
            -- Go backwards until the first available step in requiredSteps.
            for i = #requiresSteps, 1, -1 do
                if CGM:IsStepAvailable(requiresSteps[i]) then
                    -- Calls UpdateStepFrames.
                    CGM:ScrollToIndex(requiresSteps[i])
                end
            end
        end
    end
end

-- Called on QUEST_ACCEPTED (when the player has accepted a quest).
function CGM:OnQuestAccepted(_, questID)
    CGM:Debug("quest accepted: " .. GetQuestInfo(questID) .. " (id: " .. questID .. ")")
    -- No need to check any steps for the quest ID since we check for step completion dynamically when scrolling. Just update current steps.
    -- We should only scroll if the current step is of type Accept and has the same questID as this one.
    local currentStep = CGM.currentStep
    if currentStep.type == CGM.Types.Accept and currentStep.questID == questID then
        CGM:ScrollToNextIncomplete() -- Calls UpdateStepFrames().
    else
        if CGM:IsStepAvailable(CGM.currentStepIndex) then
            CGM:UpdateStepFrames()
        else
            -- If the current step gets locked because the player picked up another quest, should scroll to next.
            CGM:ScrollToNextIncomplete()
        end
    end
    CGM:UpdateStepFrames()
end

-- Called on QUEST_TURNED_IN (when the player has handed in a quest).
function CGM:OnQuestTurnedIn(questID)
    CGM:Debug("quest turned in: " .. GetQuestInfo(questID) .. " (id: " .. questID .. ")")
    -- Quests aren't instantly marked as complete so need to manually mark them.
    -- Should simply just mark all steps containing this quest ID to completed, except if its a multi-step, in which case we check all the quests in that step
    -- before marking.
    local stepIndeces = GetStepIndexFromQuestID(questID)
    if stepIndeces then -- If the quest actually exists in the guide.
        for i = 1, #stepIndeces do
            local step = CGM.currentGuide[stepIndeces[i]]
            if step.isMultiStep then
                local isComplete = true
                for j = 1, #step.questIDs do
                    local currQuestID = step.questIDs[j]
                    -- Important to not check given quest ID since it will not be completed yet.
                    isComplete = currQuestID ~= questID and not IsQuestFlaggedCompleted(currQuestID)
                end
                CGM:MarkStepCompleted(stepIndeces[i], isComplete)
            else
                CGM:MarkStepCompleted(stepIndeces[i], true)
            end
        end
        -- Won't scroll if current step is incomplete.
        CGM:ScrollToNextIncomplete()
    end
end

-- Called on QUEST_REMOVED (when a quest has been removed from the player's quest log).
function CGM:OnQuestRemoved(questID)
    CGM:Debug("quest removed: " .. GetQuestInfo(questID) .. " (id: " .. questID .. ")")
    -- If the player abandonded a quest, it's assumed the player didn't want to do that part of the guide, so skip ahead to the next available quest (if the
    -- current step is now unavailable).
    local stepIndeces = GetStepIndexFromQuestID(questID)
    -- If the quest actually exists in the guide.
    if stepIndeces then
        for i = 1, #stepIndeces do
            local step = CGM.currentGuide[stepIndeces[i]]
            if step.type == CGM.Types.Accept then
                if not IsQuestFlaggedCompleted(step.questID) then
                    CGM:MarkStepCompleted(stepIndeces[i], false)
                end
            elseif step.type == CGM.Types.Do then
                CGM:MarkStepCompleted(stepIndeces[i], CGM:IsStepCompleted(stepIndeces[i]))
            end
        end
        if not CGM:IsStepAvailable(CGM.currentStepIndex) then
            -- Calls UpdateStepFrames.
            CGM:ScrollToNextIncomplete()
        else
            CGM:UpdateStepFrames()
        end
    end
end

-- Called on UNIT_QUESTLOG_CHANGED (when a quest's objectives are changed [and at other times]).
function CGM:OnUnitQuestLogChanged(unit)
    -- This function is a special case. If the player is not on all quests of the step (if multistep) then scroll to next, except don't mark the step as
    -- completed.
    if unit == "player" then
        local currentStep = CGM.currentStep
        if currentStep.type == CGM.Types.Do then
            if CGM:IsStepCompleted(CGM.currentStepIndex) then
                CGM:ScrollToNextIncomplete() -- Calls UpdateStepFrames.
            else
                -- Updates the objective text on the step frame. Gets called for a second time here if picking up a quest while on "Do" step, but that's fine.
                CGM:UpdateStepFrames()
            end
        end
    end
end

-- Called on PLAYER_XP_UPDATE (when the player receives XP).
function CGM:OnPlayerXPUpdate()
    local currentStep = CGM.currentStep
    if currentStep.type == CGM.Types.Grind and CGM:IsStepCompleted(CGM.currentStepIndex) then
        if CGM:IsStepCompleted(CGM.currentStepIndex) then
            CGM:ScrollToNextIncomplete()
        end
    else
        CGM:UpdateStepFrames()
    end
end

-- Called on COORDINATES_REACHED (when the player has reached the current step coordinates).
function CGM:OnCoordinatesReached()
    local currentStep = CGM.currentStep
    if currentStep.type == CGM.Types.Coordinate then
        CGM:MarkStepCompleted(CGM.currentStepIndex, true)
        CGM:ScrollToNextIncomplete()
    end
end

-- Called on MERCHANT_SHOW (whenever the player visits a vendor). Sells any items in the player's bags that are specified by the guide.
function CGM:OnMerchantShow()
    local itemsToSell = CGM.currentGuide.itemsToSell
    if itemsToSell then
        for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
            for slot = 1, GetContainerNumSlots(bag) do
                local slotInfo = GetContainerItemInfo(bag, slot)
                local itemID
                if slotInfo then
                    itemID = slotInfo.itemID
                end
                if itemID and itemsToSell[itemID] then
                    CGM:Message("selling " .. slotInfo.hyperlink .. (slotInfo.stackCount > 1 and "x" .. slotInfo.stackCount or ""))
                    UseContainerItem(bag, slot)
                end
            end
        end
    end
    local npcID = CGM:UnitID("npc")
    if npcID == CGM.currentStep.unitID and CGM.currentStep.type == CGM.Types.Buy then
        for i = 1, GetMerchantNumItems() do
            local itemID = GetMerchantItemID(i)
            if CGM.currentStep.items[itemID] then
                for j = 1, CGM.currentStep.items[itemID] do
                    local _, itemLink = GetItemInfo(itemID)
                    CGM:Message("buying " .. (itemLink and itemLink or itemID))
                    BuyMerchantItem(i)
                end
            end
        end
        CGM:MarkStepCompleted(CGM.currentStepIndex, true)
        CGM:ScrollToNextIncomplete()
    end
end

-- Called on TRAINER_SHOW (whenever the trainer window shows). Trains any spells specified in the current step, if any.
function CGM:OnTrainerShow()
    local currentStep = CGM.currentStep
    if currentStep.type == CGM.Types.Train and currentStep.spells then
        for i = 1, GetNumTrainerServices() do
            local name, rank = GetTrainerServiceInfo(i)
            rank = rank and tonumber(rank:match("(%d+)")) or rank
            for _, info in pairs(currentStep.spells) do
                if info.name == name and info.rank == rank then
                    BuyTrainerService(i)
                    break
                end
            end
        end
        CGM:IsStepCompleted(CGM.currentStepIndex)
    end
end

-- Register a new guide for the addon.
function CGM:RegisterGuide(guide)
    -- TODO: This function should check each step to make sure it has legal fields (i.e. there cant be any multistep Deliver steps etc)
    if guide.name then
        -- Default to first registered.
        CGM.defaultGuide = CGM.defaultGuide or guide.name
        if CGM.Guides[guide.name] then
            CGM:Message("guide with that name is already registered - name must be unique.")
        else
            ProcessTags(guide)
            CGM.Guides[guide.name] = guide
        end
    else
        CGM:Message(guide[1] and "the guide has no name. To help you identify which guide it is, here is the first step description:\n" .. guide[1].text or
                        "the guide has no name!")
    end
end

-- Sets the currently displayed guide to the given guide (has to have been registered first).
function CGM:SetGuide(guideName)
    if CGM.Guides[guideName] then
        CGM:Debug("setting guide to " .. guideName)
        CGMOptions.settings.currentGuide = guideName
        CGM.guideDropdown:SetText(guideName) -- This hurts.
        CGMOptions.completedSteps[guideName] = CGMOptions.completedSteps[guideName] or {}
        CGM.currentGuideName = guideName
        CGM.currentGuide = CGM.Guides[guideName]
        if CGM.currentGuide.itemsToSell then
            CGM:RegisterWowEvent("MERCHANT_SHOW", CGM.OnMerchantShow)
        else
            CGM:UnregisterWowEvent("MERCHANT_SHOW")
        end
        if CGM.currentGuide.itemsToDelete then
            CGM:RegisterWowEvent("BAG_UPDATE", CGM.OnBagUpdate)
            for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
                CGM:ScanBag(bag)
            end
        else
            CGM:UnregisterWowEvent("BAG_UPDATE")
        end
        CGM.CGMFrame:SetTitleText(CGM.currentGuideName)
        CGM:UpdateSlider()
        if CGMOptions.savedStepIndex[guideName] then
            CGM:SetCurrentStep(CGMOptions.savedStepIndex[guideName], true)
            CGM:UpdateStepFrames()
        else
            CGM:ScrollToFirstIncomplete()
        end
        -- Map quest IDs to step indeces so we don't have to iterate all steps to find them.
        -- Also register for any relevant step-related events here.
        for i = 1, #CGM.currentGuide do
            local type = CGM.currentGuide[i].type
            if type == CGM.Types.Buy then
                CGM:RegisterWowEvent("MERCHANT_SHOW", CGM.OnMerchantShow)
            elseif type == CGM.Types.Train then
                CGM:RegisterWowEvent("TRAINER_SHOW", CGM.OnTrainerShow)
            end
            local questID = CGM.currentGuide[i].questID or CGM.currentGuide[i].questIDs
            if questID then
                if CGM.currentGuide[i].isMultiStep then
                    for j = 1, #questID do
                        GetStepIndexFromQuestID[questID[j]] = GetStepIndexFromQuestID[questID[j]] or {}
                        GetStepIndexFromQuestID[questID[j]][#GetStepIndexFromQuestID[questID[j]] + 1] = i
                    end
                else
                    GetStepIndexFromQuestID[questID] = GetStepIndexFromQuestID[questID] or {}
                    GetStepIndexFromQuestID[questID][#GetStepIndexFromQuestID[questID] + 1] = i
                end
            end
        end
        setmetatable(GetStepIndexFromQuestID, {
            __call = function(self, questID)
                return self[questID]
            end,
        })
    else
        CGM:Debug(guideName .. " hasn't been registered yet - can't set the guide")
    end
end
