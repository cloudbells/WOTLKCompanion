local _, CGM = ...

CGM:RegisterGuide({
    ["name"] = "Small Guide Test",
    [1] = {
        ["type"] = CGM.Types.Accept,
        ["questID"] = 783,
        ["text"] = "Pick up {questName}", -- A Threat Within.
        ["mapID"] = 1429,
        ["x"] = 48.17,
        ["y"] = 42.95,
    },
    [2] = {
        ["type"] = CGM.Types.Deliver, -- Deliver type quests don't need a "requires" field as the addon will simply check if the quest is finished and in the player's quest log.
        ["questID"] = 783,
        ["text"] = "Hand in {questName}", -- A Threat Within.
        ["mapID"] = 1429,
        ["x"] = 48.93,
        ["y"] = 41.60,
    },
    [3] = {
        ["type"] = CGM.Types.Accept,
        ["questID"] = 7,
        ["text"] = "Pick up {questName}", -- Kobold Camp Cleanup.
        ["requiresSteps"] = {2},
        ["mapID"] = 1429,
        ["x"] = 48.93,
        ["y"] = 41.60,
    },
})
