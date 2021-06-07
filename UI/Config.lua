local _, ClassicCompanion = ...

function ClassicCompanion.loadVariables()
    ClassicCompanionOptions = ClassicCompanionOptions == nil and {} or ClassicCompanionOptions
    -- Number of steps shown (default: 6)
    ClassicCompanionOptions.nbrSteps = ClassicCompanionOptions.nbrSteps == nil and 6 or ClassicCompanionOptions.nbrSteps
end