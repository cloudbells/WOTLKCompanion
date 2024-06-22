local _, CGM = ...

-- Translates from ClassicLeveler format to ClassicGuideMaker format.
function CGM:ClassicLeveler_ClassicGuideMaker(fromGuide)
    CGM:Debug("translating from ClassicLeveler to ClassicGuideMaker")
    CGM:PrintTable(fromGuide[1])
    -- Should return a reference to the translated table.
end
