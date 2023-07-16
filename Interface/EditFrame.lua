local _, CGM = ...

local CUI = LibStub("CloudUI-1.0")
local editFrame

-- Called when the close button is clicked.
local function CloseButton_OnClick()
    editFrame:Hide()
end

-- Called when the mouse is down on the frame.
local function CGMEditFrame_OnMouseDown(self)
    editFrame:StartMoving()
end

-- Called when the mouse has been released from the frame.
local function CGMEditFrame_OnMouseUp(self)
    editFrame:StopMovingOrSizing()
end

-- Called when the main frame is shown.
local function CGMEditFrame_OnShow(self)
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
end

-- Called when the main frame is hidden.
local function CGMEditFrame_OnHide(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
end

-- Initializes the edit frame.
function CGM:InitEditFrame()
    CGM:Debug("initializing EditFrame")
    -- Main frame.
    CUI = LibStub("CloudUI-1.0")
    editFrame = CreateFrame("Frame", "CGMEditFrame", UIParent)
    editFrame:SetMovable(true)
    editFrame:SetResizable(true)
    editFrame:SetSize(700, 500)
    editFrame:SetClampedToScreen(true)
    editFrame:SetFrameStrata("MEDIUM")
    CUI:ApplyTemplate(editFrame, CUI.templates.BorderedFrameTemplate)
    CUI:ApplyTemplate(editFrame, CUI.templates.BackgroundFrameTemplate)
    editFrame:HookScript("OnMouseDown", CGMEditFrame_OnMouseDown)
    editFrame:HookScript("OnMouseUp", CGMEditFrame_OnMouseUp)
    editFrame:HookScript("OnShow", CGMEditFrame_OnShow)
    editFrame:HookScript("OnHide", CGMEditFrame_OnHide)
    editFrame:SetPoint("CENTER")
    editFrame:SetBackgroundColor(0, 0, 0, 0.5)
    tinsert(UISpecialFrames, editFrame:GetName())
    -- Close button.
    local closeButton = CreateFrame("Button", "CGMOptionsFrameCloseButton", editFrame)
    CUI:ApplyTemplate(closeButton, CUI.templates.HighlightFrameTemplate)
    CUI:ApplyTemplate(closeButton, CUI.templates.PushableFrameTemplate)
    CUI:ApplyTemplate(closeButton, CUI.templates.BorderedFrameTemplate)
    closeButton:SetSize(20, 20)
    local texture = closeButton:CreateTexture(nil, "ARTWORK")
    texture:SetTexture("Interface/Addons/ClassicGuideMaker/Media/CloseButton")
    texture:SetAllPoints()
    closeButton.texture = texture
    closeButton:SetPoint("TOPRIGHT")
    closeButton:HookScript("OnClick", CloseButton_OnClick)
    return editFrame
end

-- Toggles the options frame.
function CGM:ToggleEditFrame()
    if editFrame:IsVisible() then
        editFrame:Hide()
    else
        editFrame:Show()
    end
end
