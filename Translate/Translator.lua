local _, CGM = ...

-- Variables.
local translateFrom = {}

-- Translates one guide in one format to another guide in another format. Returns a reference to the translated guide (in saved vars).
function CGM:Translate(fromGuide, fromFormat, toFormat)
    if fromGuide and fromFormat and toFormat then
        if fromFormat ~= toFormat then
            return translateFrom(fromGuide, fromFormat, toFormat)
        else
            CGM:Message("Can't translate - original and destination formats are the same.")
        end
    else
        CGM:Message("need to provide a guide to translate, as well as the original format and the destination format")
    end
end

-- Initializes the translator.
function CGM:InitTranslator()
    CGM:InitFromClassicLeveler()
    translateFrom = {[CGM.GuideFormats.ClassicLeveler] = CGM.From_ClassicLeveler}
    setmetatable(
        translateFrom, {
            __call = function(self, fromGuide, fromFormat, toFormat)
                return self[fromFormat](CGM, fromGuide, toFormat)
            end
        })
end
