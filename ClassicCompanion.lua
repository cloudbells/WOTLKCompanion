local _, ClassicCompanion = ...

local addonLoaded = false

local function init()
    ClassicCompanion.initStepFrames()
    ---TEMPORARY FOR TESTING---
    ClassicCompanionFrameTitleFrameText:SetText("Current Guide Name")
    ---------------------------
    addonLoaded = true
end

function ClassicCompanion_OnSizeChanged(self)
    if addonLoaded then
        ClassicCompanion.resizeStepFrames()
    end
end

-- Called when the frame has loaded.
function ClassicCompanion_OnLoad(self)
    self:RegisterForDrag("LeftButton")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- Called when events occur - self is the frame, event is the event, and ... are the event arguments
function ClassicCompanion_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... == "ClassicCompanion" then -- If the addon that was loaded is this one.
            print("|cFFFFFF00Classic Companion|r loaded!")
            ClassicCompanion.loadVariables()
            self:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        init()
    end
end
