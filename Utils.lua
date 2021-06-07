local _, ClassicCompanion = ...

framePool = {}

-- Returns a frame from the frame pool, and creates one if there is none free.
function ClassicCompanion.getFrame()
    for _, frame in pairs(framePool) do
        if not frame.used then
            frame.used = true
            return frame
        end
    end
    framePool[#framePool + 1] = CreateFrame("Frame", nil, ClassicCompanionFrameBodyFrame, "ClassicCompanionStepFrameTemplate")
    framePool[#framePool].used = true
    return framePool[#framePool]
end

-- Copies the given table and returns the copy. If no table is given, this returns nil.
function ClassicCompanion.copy(original)
    local copy = {}
    if type(original) == "table" then
        for k, v in pairs(original) do
            copy[k] = v
        end
    else
        return nil
    end
    return copy
end
