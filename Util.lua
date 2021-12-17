local _, ClassicCompanion = ...

-- Variables.
local framePool = {}

-- Prints the given table for debug purposes.
function ClassicCompanion:PrintTable(t, i, f)
    if type(t) == "table" then
        i = i or "    "
        f = not f
        if f then
            print("{")
        end
        for k, v in pairs(t) do
            local kt = type(k)
            local ks = i
            if kt == "function" then
                -- ks = ks .. "[function"
            elseif kt == "boolean" then
                ks = ks .. (not k and "[false" or "[true")
            elseif kt == "string" then
                ks = ks .. "[\"" .. k .. "\""
            else
                ks = ks .. "[" .. k
            end
            ks = ks .. "] = "
            local vt = type(v)
            if vt == "table" then
                print(ks .. "{")
                self:PrintTable(v, i .. "    ", true)
                print(i .. "},")
            elseif vt == "userdata" then
                print(ks .. "userdata,")
            elseif vt == "function" then
                -- print(ks .. "function,")
            elseif vt == "boolean" then
                print(ks .. (not v and "false," or "true,"))
            elseif vt == "string" then
                print(ks .. "\"" .. v .. "\",")
            else
                print(ks .. v .. ",")
            end
        end
        if f then
            print("}")
        end
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

-- Deep copies the given table and returns the copy. If no table is given, this returns the original value.
function ClassicCompanion:Copy(t)
    if type(t) == "table" then
        local c = {}
        for k, v in pairs(t) do
            c[k] = type(v) == "table" and self:Copy(v) or v
        end
        setmetatable(c, self:Copy(getmetatable(t)))
        return c
    end
    return t
end
