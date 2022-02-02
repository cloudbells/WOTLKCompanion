local _, WOTLKC = ...

-- Variables.
local dropdownButtons = {} -- Reusable dropdown buttons.
local framePool = {}

-- Returns (or creates if there is none available) a dropdown button from the pool.
local function GetDropdownButton(parent)
    for i = 1, #framePool do
        if not framePool[i]:IsLocked() then
            framePool[i]:Lock()
            return framePool[i]
        end
    end
    -- No available button was found, so create a new one and add it to the pool.
    local frame = CreateFrame("Button", "WOTLKCDropdownButton" .. #framePool + 1, parent, "WOTLKCDropdownButtonTemplate")
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

-- Adds or removes buttons as appropriate and sets the value for each button.
local function AdjustDropdownButtons(dropdownParent)
    local lastButtonIndex = #dropdownButtons -- The "index" of the last button. There will always be at least one button so we only need to attach buttons to the bottom button.
    local newValues, newColorCodes = dropdownParent:GetValues()
    local delta = #newValues - lastButtonIndex -- Add buttons if > 0, otherwise remove buttons.
    -- If delta is 0 we don't have to add or remove any buttons, only adjust values.
    if delta < 0 then
        for i = #newValues + 1, lastButtonIndex do
            dropdownButtons[i]:Hide()
            dropdownButtons[i]:Unlock()
            dropdownButtons[i] = nil
        end
    elseif delta > 0 then
        for i = lastButtonIndex + 1, #newValues do
            dropdownButtons[i] = GetDropdownButton(dropdown)
            -- Anchor it to the latest button.
            if i ~= 1 then -- First button should never be adjusted.
                dropdownButtons[i]:SetPoint("TOPLEFT", dropdownButtons[i - 1], "BOTTOMLEFT")
                dropdownButtons[i]:SetPoint("BOTTOMRIGHT", dropdownButtons[i - 1], "BOTTOMRIGHT", 0, -dropdownParent:GetHeight())
            end
            dropdownButtons[i]:Show()
        end
    end
    -- Adjust values.
    for i = 1, #newValues do
        dropdownButtons[i]:SetValue(newValues[i], newColorCodes and newColorCodes[i] or nil)
    end
end

-- Creates a dropdown with the given name in the given parent frame, containing the given values and returns it. The dropdown will call the given callback with the selected value whenever the player
-- clicks one. An optional table containing color codes may be given, and an optional initial value will set the initial value of the dropdown, otherwise the default is the first value found.
function WOTLKC:CreateDropdown(parentFrame, frameName, callback, values, colorCodes, initialValue, initialColor)
    -- Create the actual dropdown parent button (which opens/closes the dropdown itself).
    local dropdownParent = CreateFrame("Button", frameName and frameName or nil, parentFrame, "WOTLKCDropdownParentTemplate")
    dropdownParent:RegisterCallback(callback)
    dropdownParent:SetValues(values, colorCodes)
    dropdownParent:SetInitialValue(initialValue and initialValue or values[1], initialColor and initialColor or colorCodes and colorCodes[1] or nil)
    if not dropdown then
        dropdown = CreateFrame("Frame", "WOTLKCDropdown", parentFrame, "WOTLKCDropdownTemplate") -- The actual dropdown is the collapsible frame (i.e. the child of the dropdown button).
        -- First button is a special case when it comes to anchors so create it here.
        dropdownButtons[1] = GetDropdownButton(dropdown)
        dropdownButtons[1]:SetValue(values and values[1] or "")
        dropdownButtons[1]:SetPoint("TOPLEFT")
        dropdownButtons[1]:SetPoint("BOTTOMRIGHT", dropdown, "TOPRIGHT", 0, -dropdownParent:GetHeight())
        AdjustDropdownButtons(dropdownParent)
        -- Attach the dropdown frame to the first created dropdown parent so it is connected to something.
        dropdown:AttachTo(dropdownParent)
    end
    dropdownParent:HookScript("OnHide", function(self)
        dropdown:Hide() -- Necessary for if the player hides the Interface panel, so that the dropdown doesn't show for 2 seconds when opening it again.
    end)
    dropdownParent:HookScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if not dropdown:IsAttachedTo(self) then
                AdjustDropdownButtons(self)
                dropdown:AttachTo(self)
                dropdown:Show()
            elseif dropdown:IsShowing() then
                dropdown:Hide()
            else
                dropdown:Show()
            end
        else
            self:SetSelectedValue(self:GetInitialValue())
            dropdown:Hide()
        end
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    return dropdownParent
end
