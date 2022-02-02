local _, WOTLKC = ...

-- Variables.
local framePool = {}

-- Returns a frame from the frame pool, and creates one if there is none free.
function WOTLKC:GetStepFrame()
    for i = 1, #framePool do
        if not framePool[i]:IsLocked() then
            framePool[i]:Lock()
            return framePool[i]
        end
    end
    -- No available button was found, so create a new one and add it to the pool.
    local frame = CreateFrame("Button", "WOTLKCStepFrame" .. #framePool + 1, WOTLKCFrameBodyFrame, "WOTLKCStepFrameTemplate")
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
