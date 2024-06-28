local _, CGM = ...

-- Variables.
local CUI
local stepFrames = {}
local framePool = {}
local isLoaded = false

-- Localized globals.
local IsOnQuest, GetQuestObjectives = C_QuestLog.IsOnQuest, C_QuestLog.GetQuestObjectives
local GetItemInfo, GetItemCount = C_Item.GetItemInfo, GetItemCount

-- Constants.
local STEP_TEXT_MARGIN = 48

-- Resizes the text.
local function StepFrame_ResizeText(self, width)
    self.text:SetWidth(width)
end

-- Updates this current step.
local function StepFrame_UpdateStep(self, index, text, isAvailable, isCompleted, isActive, itemLink)
    self.text:SetText(text)
    self.index = index
    self.stepNbr:SetText(index)
    if isCompleted then
        self:SetBackgroundColor(0, 0.4, 0, 1)
    elseif not isAvailable then
        self:SetBackgroundColor(0.4, 0, 0, 1)
    elseif isActive then
        self:SetBackgroundColor(0.4, 0.4, 0, 1)
    else
        self:ResetBackgroundColor()
    end
    if itemLink then
        self.itemButton:SetAttribute("item", itemLink)
    end
    self.itemButton:SetLink(itemLink, true, true)
end

-- Clears the step.
local function StepFrame_Clear(self)
    self.text:SetText("")
    self.stepNbr:SetText("")
end

-- Called when the player clicks a step.
local function StepFrame_OnClick(self, button)
    if self.index then
        if button == "LeftButton" then
            CGM:SetCurrentStep(self.index)
            CGM:UpdateStepFrames()
        else
            CGM:MarkStepCompleted(self.index, not CGM:IsStepCompleted(self.index), true)
            CGM:UpdateStepFrames()
        end
    end
end

-- Called when the mouse enters the frame.
local function StepFrame_OnEnter(self)
    self.shouldChangeText = false
    CGM:UpdateStepFrames(self:GetID())
end

-- Called when the mouse leaves the frame.
local function StepFrame_OnLeave(self)
    self.shouldChangeText = true
    CGM:UpdateStepFrames(self:GetID())
end

-- Returns (or creates if there is none available) a step frame from the pool.
local function GetStepFrame()
    for i = 1, #framePool do
        if not framePool[i]:IsLocked() then
            framePool[i]:Lock()
            return framePool[i]
        end
    end
    -- No available button was found, so create a new one and add it to the pool.
    -- Main frame.
    local frame = CreateFrame("Button", "CGMStepFrame" .. #framePool + 1, CGMFrame.bodyFrame)
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    CUI:ApplyTemplate(frame, CUI.templates.HighlightFrameTemplate)
    CUI:ApplyTemplate(frame, CUI.templates.BackgroundFrameTemplate)
    CUI:ApplyTemplate(frame, CUI.templates.PushableFrameTemplate)
    -- Fontstrings.
    local fontInstance = CUI:GetFontNormal()
    fontInstance:SetJustifyH("LEFT")
    local stepNbr = frame:CreateFontString(nil, "OVERLAY", fontInstance:GetName())
    stepNbr:SetPoint("TOPLEFT", 4, -4)
    frame.stepNbr = stepNbr
    local text = frame:CreateFontString(nil, "OVERLAY", fontInstance:GetName())
    text:SetWordWrap(true)
    text:SetPoint("TOPLEFT", 44, -4)
    frame.text = text
    -- Top border.
    local topBorder = frame:CreateTexture(nil, "BORDER")
    topBorder:SetSize(1, 1)
    topBorder:SetColorTexture(1, 1, 1, 1)
    topBorder:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -1, 0)
    topBorder:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 1, 0)
    frame.topBorder = topBorder
    -- Item button.
    local itemButton = CUI:CreateLinkButton(frame, "CGMStepFrameItemButton" .. #framePool + 1, "SecureActionButtonTemplate", {})
    itemButton:SetAttribute("type1", "item")
    itemButton:SetPoint("RIGHT", frame, "RIGHT", -(frame:GetHeight() - itemButton:GetHeight()) / 2, 0)
    itemButton:Hide() -- temp, uncomment
    frame.itemButton = itemButton
    -- Functions.
    frame.ResizeText = StepFrame_ResizeText
    frame.UpdateStep = StepFrame_UpdateStep
    frame.Clear = StepFrame_Clear
    frame:HookScript("OnClick", StepFrame_OnClick)
    frame.shouldChangeText = true
    frame:HookScript("OnEnter", StepFrame_OnEnter)
    frame:HookScript("OnLeave", StepFrame_OnLeave)
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
function CGM:UpdateStepFrames(stepFrameIndex)
    -- CGM:Debug("updating StepFrames")
    if isLoaded and CGM.currentGuideName then
        local currentValue = CGM.CGMFrame.bodyFrame.slider:GetValue()
        local text
        local index
        local currentStep
        for i = stepFrameIndex or 1, stepFrameIndex or #stepFrames do
            local itemLink = nil
            index = currentValue + i - 1
            currentStep = CGM.currentGuide[index]
            if currentStep then
                text = currentStep.text
                local type = currentStep.type
                if CGM.currentStepIndex == index and not CGM:IsStepCompleted(index) then
                    if type == CGM.Types.Do then
                        if currentStep.items then
                            for itemID in pairs(currentStep.items) do
                                -- @TODO: for now just grab first item, need to support multiple items somehow
                                if (GetItemCount(itemID) > 0) then
                                    local _, link = GetItemInfo(itemID)
                                    itemLink = link
                                    break
                                end
                            end
                        end
                        if stepFrames[i].shouldChangeText then
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
                            elseif IsOnQuest(currentStep.questID) then
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
                    elseif type == CGM.Types.Item and stepFrames[i].shouldChangeText then
                        local itemText = ""
                        for itemID, requiredItemCount in pairs(currentStep.items) do
                            local itemName = GetItemInfo(itemID)
                            if itemName then
                                local itemCount = GetItemCount(itemID)
                                itemText =
                                    itemText .. itemName .. ": " .. (itemCount > requiredItemCount and requiredItemCount or itemCount) .. "/" ..
                                        requiredItemCount .. "\n"
                            end
                        end
                        text = #itemText > 0 and itemText or text
                    end
                end
                stepFrames[i]:UpdateStep(index, text, CGM:IsStepAvailable(index), CGM:IsStepCompleted(index), index == CGM.currentStepIndex, itemLink)
            else
                stepFrames[i]:Clear()
            end
        end
    end
end

-- Resizes each step frame to fit the parent frame.
function CGM:ResizeStepFrames()
    if isLoaded then
        -- Get rid of frames we aren't going to use.
        if #stepFrames > CGMOptions.settings.nbrSteps then
            for i = CGMOptions.settings.nbrSteps + 1, #stepFrames do
                stepFrames[i].index = nil
                stepFrames[i]:Unlock()
                stepFrames[i]:Hide()
                stepFrames[i] = nil
            end
        elseif #stepFrames < CGMOptions.settings.nbrSteps then
            -- Get new frames if necessary.
            for i = #stepFrames + 1, CGMOptions.settings.nbrSteps do
                stepFrames[i] = GetStepFrame()
                stepFrames[i]:SetID(i)
                stepFrames[i]:Show()
            end
        end
        local height = CGM.CGMFrame.bodyFrame:GetHeight()
        local nbrSteps = CGMOptions.settings.nbrSteps
        for i = 1, nbrSteps do
            local topOffset = (i - 1) * (height / nbrSteps)
            local bottomOffset = height - (i * (height / nbrSteps))
            stepFrames[i]:SetPoint("TOPLEFT", CGM.CGMFrame.bodyFrame, "TOPLEFT", 0, -topOffset)
            stepFrames[i]:SetPoint("BOTTOMRIGHT", CGM.CGMFrame.bodyFrame, "BOTTOMRIGHT", -17, bottomOffset)
            stepFrames[i]:ResizeText(stepFrames[i]:GetWidth() - STEP_TEXT_MARGIN)
            stepFrames[i].itemButton:SetPoint("RIGHT", stepFrames[i], "RIGHT",
                                              -(stepFrames[i]:GetHeight() - stepFrames[i].itemButton:GetHeight()) / 2, 0)
        end
    end
end

-- Enables ALL step frames.
function CGM:EnableAllStepFrames()
    CGM:Debug("enabling all step frames")
    if stepFrames then
        for i = 1, #stepFrames do
            stepFrames[i]:Enable()
        end
    end
end

-- Disables any unused step frames.
function CGM:DisableUnusedStepFrames()
    if stepFrames and #CGM.currentGuide < #stepFrames then
        local debug = "disabling unused step frames:"
        for i = #CGM.currentGuide + 1, #stepFrames do
            debug = debug .. " " .. i
            stepFrames[i]:ResetBackgroundColor()
            stepFrames[i]:Disable()
        end
        CGM:Debug(debug)
    end
end

-- Initializes the frames containing steps, getting frames from a frame pool.
function CGM:InitStepFrames()
    CGM:Debug("initializing StepFrames")
    CUI = LibStub("CloudUI-1.0")
    for i = 1, CGMOptions.settings.nbrSteps do
        stepFrames[i] = GetStepFrame()
        stepFrames[i]:SetID(i)
    end
    isLoaded = true
    -- Needs to be called once on addon load.
    CGM:ResizeStepFrames()
end
