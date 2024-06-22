local _, CGM = ...

local translateTo = {}

-- Delegates to T_ClassicLeveler_* functions.
function CGM:From_ClassicLeveler(fromGuide, toFormat)
    return translateTo(fromGuide, toFormat)
end

-- Initializes this.
function CGM:InitFromClassicLeveler()
    translateTo = {[CGM.GuideFormats.ClassicGuideMaker] = CGM.ClassicLeveler_ClassicGuideMaker}
    setmetatable(
        translateTo, {
            __call = function(self, fromGuide, toFormat)
                return self[toFormat](CGM, fromGuide)
            end
        })
end
