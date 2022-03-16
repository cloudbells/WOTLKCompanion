local _, WOTLKC = ...

WOTLKC:RegisterGuide({
    ["name"] = "Elwynn Forest 1-10",
    [1] = {
        ["type"] = WOTLKC.Types.Accept,
        ["questID"] = 783,
        ["text"] = "Pick up A Threat Within",
        ["map"] = 1429,
        ["x"] = 48.17,
        ["y"] = 42.95,
    },
    [2] = {
        ["type"] = WOTLKC.Types.Deliver, -- Deliver type quests don't need a "requires" field as the addon will simply check if the quest is finished and in the player's quest log.
        ["questID"] = 783,
        ["text"] = "Hand in A Threat Within",
        ["map"] = 1429,
        ["x"] = 48.93,
        ["y"] = 41.60,
    },
    [3] = {
        ["type"] = WOTLKC.Types.Accept,
        ["questID"] = 7,
        ["text"] = "Pick up Kobold Camp Cleanup",
        ["requiresSteps"] = {
            2
        },
        ["map"] = 1429,
        ["x"] = 48.93,
        ["y"] = 41.60,
    },
    [4] = {
        ["type"] = WOTLKC.Types.Accept,
        ["questID"] = 5261,
        ["text"] = "Pick up Eagan Peltskinner",
        ["requiresSteps"] = {
            2
        },
        ["lockedBySteps"] = { -- If the steps listed in this field are completed, then this becomes unavailable.
            6
        },
        ["map"] = 1429,
        ["x"] = 48.17,
        ["y"] = 42.94,
    },
    [5] = {
        ["type"] = WOTLKC.Types.Deliver,
        ["questID"] = 5261,
        ["text"] = "Hand in Eagan Peltskinner",
        ["map"] = 1429,
        ["x"] = 48.94,
        ["y"] = 40.17,
    },
    [6] = {
        ["type"] = WOTLKC.Types.Accept,
        ["questID"] = 33,
        ["text"] = "Pick up Wolves Across the Border",
        ["map"] = 1429,
        ["x"] = 48.94,
        ["y"] = 40.17,
    },
    [7] = {
        ["type"] = WOTLKC.Types.Do, -- Do type quests also don't need a "requires" field as the addon simply checks if the player is currently on the questID (or if a multiStep, one of the quest IDs).
        ["isMultiStep"] = true,
        ["questIDs"] = {
            33,
            7
        },
        ["text"] = "Do Wolves Across the Border and Kobold Camp Cleanup",
        ["map"] = 1429,
        ["x"] = 47.04,
        ["y"] = 36.90,
    },
    [8] = {
        ["type"] = WOTLKC.Types.Deliver,
        ["questID"] = 33,
        ["text"] = "Hand in Wolves Across the Border",
        ["map"] = 1429,
        ["x"] = 48.94,
        ["y"] = 40.17,
    },
    [9] = {
        ["type"] = WOTLKC.Types.Coordinate,
        ["questID"] = 33, -- Coordinate steps should have a quest ID so they can be marked as complete if the player decides to ignore it but forgets to manually skip it in the addon.
        ["text"] = "Walk over here",
        ["map"] = 1429,
        ["x"] = 48.16,
        ["y"] = 42.11,
    },
    [10] = {
        ["type"] = WOTLKC.Types.Deliver,
        ["questID"] = 7,
        ["text"] = "Hand in Kobold Camp Cleanup",
        ["map"] = 1429,
        ["x"] = 48.93,
        ["y"] = 41.60,
    },
    [11] = {
        ["type"] = WOTLKC.Types.Accept,
        ["questID"] = 3105,
        ["text"] = "Pick up Tainted Letter",
        ["requiresSteps"] = {
            10
        },
        ["map"] = 1429,
        ["x"] = 48.93,
        ["y"] = 41.60,
    },
    [12] = {
        ["type"] = WOTLKC.Types.Accept,
        ["questID"] = 15,
        ["text"] = "Pick up Investigate Echo Ridge",
        ["requiresSteps"] = {
            10
        },
        ["map"] = 1429,
        ["x"] = 48.93,
        ["y"] = 41.60,
    },
    [13] = {
        ["type"] = WOTLKC.Types.Accept,
        ["questID"] = 18,
        ["text"] = "Pick up Brotherhood of Thieves",
        ["requiresSteps"] = {
            2
        },
        ["requiresLevel"] = 2, -- Minimum level required for the step to be available.
        ["map"] = 1429,
        ["x"] = 48.17,
        ["y"] = 42.94,
    },
    [14] = {
        ["type"] = WOTLKC.Types.Grind,
        ["level"] = 2,
        ["xp"] = 400,
        ["text"] = "Grind until you're level 2, 400 xp",
        ["map"] = 1429,
        ["x"] = 47.81,
        ["y"] = 39.69,
    },
})
