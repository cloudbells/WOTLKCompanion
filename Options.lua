local _, CGM = ...

-- Sets the modifier to the given value.
function CGM:SetModifier(value)
    CGMOptions.settings.modifier = value
    CGM:Debug("auto accept modifier is " .. CGM.Modifiers[value])
end

-- Sets the number of steps to the given value.
function CGM:SetNbrSteps(slider, value)
    slider.fontString:SetText("Number of steps - " .. value)
    CGMOptions.settings.nbrSteps = value
    CGM:Debug("set nbrSteps to " .. value)
    CGM:UpdateSlider()
    CGM:ResizeStepFrames()
    CGM:UpdateStepFrames()
end

-- Toggles auto accept/hand in on or off.
function CGM:ToggleAuto()
    CGMOptions.settings.autoAccept = not CGMOptions.settings.autoAccept
    CGM:Debug("auto accept is " .. (CGMOptions.settings.autoAccept and "ON" or "OFF"))
end

-- Toggles debug mode on or off.
function CGM:ToggleDebug()
    CGMOptions.settings.debug = not CGMOptions.settings.debug
    if CGMOptions.settings.debug then
        CGM:Debug("debug mode is ON")
        CGM.debugQuestFrameIDLbl:Show()
    else
        CGM:Message("debug mod is OFF.")
        CGM.debugQuestFrameIDLbl:Hide()
    end
end

-- Loads all settings.
function CGM:LoadSettings()
    CGMOptions.settings = CGMOptions.settings or {}
    CGMOptions.settings.nbrSteps = CGMOptions.settings.nbrSteps or 4
    CGMOptions.settings.debug = CGMOptions.settings.debug or false
    CGMOptions.settings.modifier = CGMOptions.settings.modifier or CGM.Modifiers.SHIFT
end

