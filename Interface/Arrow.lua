local _, WOTLKC = ...

-- Variables.
local hbd
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

-- Gets called every frame update.
local function OnUpdate(_, elapsed)
    timeSinceLast = timeSinceLast + elapsed
    if not isInInstance and timeSinceLast >= THRESHOLD then
        timeSinceLast = 0
        local playerX, playerY, instance = hbd:GetPlayerWorldPosition() -- Need to offset the coords with player coords since we aren't at 0.
        -- Get the vector for the goal. The angle is to the goal from the player's current position.
        local angle, distance = hbd:GetWorldVector(instance, playerX, playerY, goalX, goalY)
        if not hasEventFired and distance <= GOAL_DISTANCE then
            WOTLKC.Events:Fire("WOTLKC_COORDINATES_REACHED")
            hasEventFired = true
        elseif distance > GOAL_DISTANCE then
            hasEventFired = false -- Event should fire the next time the player reaches the coordinates again.
        end
        -- To get angle between the facing vector and goal vector, subtract the angle between the x axis and the facing vector.
        angle = angle - GetPlayerFacing()
        -- Use the angle to get the arrow texture coordinates.
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

-- Sets the current goal world coordinate.
function WOTLKC.UI.Arrow:SetGoal(x, y, map)
    if x and y and map then
        goalX, goalY = hbd:GetWorldCoordinatesFromZone(x, y, map)
        WOTLKCArrow:Show()
    else
        WOTLKCArrow:Hide()
    end
end

-- Called when the player changes zones.
function WOTLKC.Events:OnZoneChangedNewArea()
    isInInstance = IsInInstance()
end

-- Initializes the arrow.
function WOTLKC.UI.Arrow:InitArrow()
    isInInstance = IsInInstance()
    arrowTexture = WOTLKCArrow.texture
    arrowText = WOTLKCArrow.distanceLbl
    hbd = LibStub("HereBeDragons-2.0")
    WOTLKCArrow:HookScript("OnUpdate", OnUpdate)
end
