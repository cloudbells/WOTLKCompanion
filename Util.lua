local _, CGM = ...

-- Prints the given table for debug purposes.
function CGM:PrintTable(t, i, f)
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

-- Returns an enum with the given values.
function CGM:Enum(t)
    if type(t) == "table" and #t > 0 then
        for i = 1, #t do
            if type(t[i]) == "string" then
                t[t[i]] = i
            end
        end
    end
    return t
end

-- Deep copies the given table and returns the copy. If no table is given, this returns the original value.
function CGM:Copy(t)
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

-- Returns the ID of the unit with the given unit ID.
function CGM:UnitID(unitID)
    return self:ParseIDFromGUID(UnitGUID(unitID))
end

-- Returns the ID of the given GUID.
function CGM:ParseIDFromGUID(guid)
    local _, _, _, _, _, id = strsplit("-", guid)
    return tonumber(id)
end

-- Returns the ID contained in the given chat link (e.g. an item link).
function CGM:ParseIDFromLink(link)
    return tonumber(link:match(":(%d+)"))
end

-- Returns true if the game version is classic, false otherwise.
function CGM:IsClassic()
    return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

-- Returns true if the game version is TBC, false otherwise.
function CGM:IsTBC()
    return WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
end

-- Returns true if the game version is WotLK, false otherwise.
function CGM:IsWOTLK()
    return WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
end

-- Returns true if the designated modifier key is down.
function CGM:IsModifierDown()
    local mod = CGMOptions.settings.modifier
    if mod == CGM.Modifiers.SHIFT then
        return IsShiftKeyDown()
    elseif mod == CGM.Modifiers.CTRL then
        return IsControlKeyDown()
    elseif mod == CGM.Modifiers.ALT then
        return IsAltKeyDown()
    end
    return false
end
