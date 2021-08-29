local _, ClassicCompanion = ...

-- Variables.
local framePool = {}

-- Prints the given table.
function ClassicCompanion:Dump(t, i, f)
    i = i or "    "
    f = not f
    if f then
        print("{")
    end
    for k, v in pairs(t) do
        local kt = type(k)
        local vt = type(v)
        local ks = i .. (kt == "function" and "[function" or kt == "boolean" and (not k and "[false" or "[true") or kt == "string" and "[\"" .. k .. "\"" or "[" .. k) .. "] = "
        if vt == "table" then
            print(ks)
            self:Dump(v, i .. "    ", true)
            print(i .. "},")
        else
            print(ks .. (vt == "function" and "function" or vt == "boolean" and (not v and "false" or "true") or vt == "string" and "\"" .. v .. "\"" or v) .. ",")
        end
    end
    if f then
        print("}")
    end
end

-- Returns a frame from the frame pool, and creates one if there is none free.
function ClassicCompanion:GetFrame()
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

-- Copies the given table and returns the copy. If no table is given, this returns the original table.
function ClassicCompanion:Copy(o)
    if type(o) == "table" then
        local copy = {}
        for k, v in pairs(o) do
            copy[k] = type(v) == "table" and self:Copy(v) or v
        end
        return copy
    end
    return o
end
