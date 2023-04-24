local _, CGM = ...

-- Variables.
local arrow
local hasGoal = false
local hbd
local CUI
local timeSinceLast = 0
local goalX, goalY
local isInInstance
local arrowTexture -- For optimization.
local arrowText -- Same.
local hasEventFired = false

-- Constants.
local THRESHOLD = 0.01 -- OnUpdate threshold.
local GOAL_DISTANCE = 5
local PI2 = math.pi * 2

-- Localized globals.
local GetPlayerFacing = GetPlayerFacing
local sqrt, cos, sin, acos, floor = math.sqrt, math.cos, math.sin, math.acos, math.floor

-- Called when the mouse is down on the arrow.
local function Arrow_OnMouseDown(self)
    self:StartMoving()
end

-- Called when the mouse is released.
local function Arrow_OnMouseUp(self)
    self:StopMovingOrSizing()
end

-- Gets called every frame update.
local function OnUpdate(_, elapsed)
    timeSinceLast = timeSinceLast + elapsed
    if not isInInstance and timeSinceLast >= THRESHOLD then
        timeSinceLast = 0
        local playerX, playerY, instance = hbd:GetPlayerWorldPosition()
        local angle, distance = hbd:GetWorldVector(instance, playerX, playerY, goalX, goalY)
        if not hasEventFired and distance <= GOAL_DISTANCE then
            CGM:Fire("CGM_COORDINATES_REACHED")
            hasEventFired = true
        elseif distance > GOAL_DISTANCE then
            hasEventFired = false
        end
        angle = angle - GetPlayerFacing()
        local cell = floor(angle / PI2 * 108 + 0.5) % 108 -- floor(angle / PI2 * NUMBER_ARROWS + 0.5) % NUMBER_ARROWS
        local column = cell % 9 -- local column = cell % NUMBER_COLUMNS
        local row = floor(cell / 9) -- local row = floor(cell / NUMBER_COLUMNS)
        local xStart = (column * 56) / 512 -- local xStart = (column * ARROW_WIDTH) / IMAGE_SIZE
        local yStart = (row * 42) / 512 -- local yStart = (row * ARROW_HEIGHT) / IMAGE_SIZE
        local xEnd = ((column + 1) * 56) / 512 -- local xEnd = ((column + 1) * ARROW_WIDTH) / IMAGE_SIZE
        local yEnd = ((row + 1) * 42) / 512 -- local yEnd = ((row + 1) * ARROW_HEIGHT) / IMAGE_SIZE
        arrowTexture:SetTexCoord(xStart, xEnd, yStart, yEnd)
        arrowText:SetText(floor(distance + 0.5) .. " yards")
    end
end

-- Initializes the arrow.
function CGM:InitArrow()
    CUI = LibStub("CloudUI-1.0")
    -- Create arrow.
    arrow = CreateFrame("Frame", "CGMArrow", UIParent)
    arrow:EnableMouse(true)
    arrow:SetClampedToScreen(true)
    arrow:SetMovable(true)
    arrow:HookScript("OnMouseDown", Arrow_OnMouseDown)
    arrow:HookScript("OnMouseUp", Arrow_OnMouseUp)
    arrow:Hide()
    arrow:SetSize(56, 42)
    arrow:SetPoint("CENTER")
    -- Arrow texture.
    local texture = arrow:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture("Interface/Addons/ClassicGuideMaker/Media/Arrow")
    texture:SetAllPoints(arrow)
    arrow.texture = texture
    -- Arrow fontstring.
    local fontInstance = CUI:GetFontNormal()
    fontInstance:SetJustifyH("LEFT")
    local distanceLbl = arrow:CreateFontString(nil, "BACKGROUND", fontInstance:GetName())
    distanceLbl:SetPoint("TOP", arrow, "BOTTOM", 0, -4)
    arrow.distanceLbl = distanceLbl
    isInInstance = IsInInstance()
    arrowTexture = arrow.texture
    arrowText = arrow.distanceLbl
    hbd = LibStub("HereBeDragons-2.0")
    arrow:HookScript("OnUpdate", OnUpdate)
end

-- Toggles the arrow.
function CGM:ToggleArrow()
    if CGMOptions.isArrowHidden and hasGoal then
        arrow:Show()
    elseif not CGMOptions.isArrowHidden then
        arrow:Hide()
    end
    CGMOptions.isArrowHidden = not CGMOptions.isArrowHidden
end

-- Sets the current goal world coordinate.
function CGM:SetGoal(x, y, mapID)
    if x and y and mapID then
        hasGoal = true
        goalX, goalY = hbd:GetWorldCoordinatesFromZone(x, y, mapID)
        if not CGMOptions.isArrowHidden then
            arrow:Show()
        end
    else
        hasGoal = false
        arrow:Hide()
    end
end

-- Called when the player changes zones.
function CGM:OnZoneChangedNewArea()
    isInInstance = IsInInstance()
end
