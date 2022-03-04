local _, WOTLKC = ...

-- Variables.
local hbd = LibStub("HereBeDragons-2.0")
local isTurning = false
local isMoving = false
local timeSinceLast = 0
local playerContinent
local goalX, goalY, goalInstances
local isInInstance
local arrowTexture -- For optimization.
local arrowText -- Same.

-- Constants.
local THRESHOLD = 0.00 -- OnUpdate threshold.
local PI2 = math.pi * 2

-- Localized globals.
local GetPlayerMapPosition, GetWorldPosFromMapPos = C_Map.GetPlayerMapPosition, C_Map.GetWorldPosFromMapPos
local GetPlayerFacing = GetPlayerFacing
local sqrt, cos, sin, acos, floor = math.sqrt, math.cos, math.sin, math.acos, math.floor

-- Updates the player continent and checks if the player is in an instance.
local function UpdatePlayerMap()
    isInInstance = IsInInstance()
    local _, _, playerContinent = hbd:GetPlayerWorldPosition()
end

-- Gets called every frame update.
local function OnUpdate(_, elapsed)
    timeSinceLast = timeSinceLast + elapsed
    if not isInInstance and timeSinceLast >= THRESHOLD then
        timeSinceLast = 0
        local playerX, playerY, instance = hbd:GetPlayerWorldPosition() -- Need to offset the coords with player coords since we aren't at 0.
        -- Get the vector for the goal. The angle is the angle to the goal from the player's current position.
        local angle, distance = hbd:GetWorldVector(instance, playerX, playerY, goalX, goalY)
        -- To get angle between the facing vector and goal vector, subtract the angle between the x axis and the facing vector (in a normal coordinate system).
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
    if not WOTLKCArrow:GetScript("OnUpdate") then
        WOTLKCArrow:HookScript("OnUpdate", OnUpdate)
    end
    goalX, goalY, goalInstance = hbd:GetWorldCoordinatesFromZone(x, y, map)
    WOTLKCArrow:Show()
end

-- Called when the player changes zones.
function WOTLKC.EventHandlers:OnZoneChangedNewArea()
    UpdatePlayerMap()
end

-- Initializes the arrow.
function WOTLKC.UI.Arrow:InitArrow()
    UpdatePlayerMap()
    arrowTexture = WOTLKCArrow.texture
    arrowText = WOTLKCArrow.distanceLbl
end
