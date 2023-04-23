local _, CGM = ...

-- if any of x, y, or mapID are provided, they must all be provided

CGM:RegisterGuide({
    ["name"] = "Elwynn Forest 1-10",
    ["itemsToSell"] = { -- Every time the player visits a vendor, these will be automatically sold. These need to be keys and need to be true if they should be sold.
        
    },
    ["itemsToDelete"] = {
        [1372] = true,
        [4865] = true,
        [2210] = true,
        [3365] = true,
        [2654] = true,
        [1366] = true,
        [1376] = true,
        [1369] = true,
        [1378] = true,
        [3363] = true,
        [2210] = true,
        [2211] = true,
        [1364] = true,
        [1370] = true,
    },
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
        ["requiresSteps"] = {
            2
        },
        ["mapID"] = 1429,
        ["x"] = 48.93,
        ["y"] = 41.60,
    },
    [4] = {
        ["type"] = CGM.Types.Accept,
        ["questID"] = 5261,
        ["text"] = "Pick up {questName}", -- Eagan Peltskinner.
        ["requiresSteps"] = {
            2
        },
        ["lockedBySteps"] = { -- If the steps listed in this field are completed, then this becomes unavailable.
            6
        },
        ["mapID"] = 1429,
        ["x"] = 48.17,
        ["y"] = 42.94,
    },
    [5] = {
        ["type"] = CGM.Types.Deliver,
        ["questID"] = 5261,
        ["text"] = "Hand in {questName}", -- Eagan Peltskinner.
        ["mapID"] = 1429,
        ["x"] = 48.94,
        ["y"] = 40.17,
    },
    [6] = {
        ["type"] = CGM.Types.Accept,
        ["questID"] = 33,
        ["text"] = "Pick up {questName}", -- Wolves Across the Border.
        ["mapID"] = 1429,
        ["x"] = 48.94,
        ["y"] = 40.17,
    },
    [7] = {
        ["type"] = CGM.Types.Do, -- Do type quests also don't need a "requires" field as the addon simply checks if the player is currently on the questID (or if a multiStep, one of the quest IDs).
        ["isMultiStep"] = true,
        ["questIDs"] = {
            33, -- Wolves Across the Border.
            7 -- Kobold Camp Cleanup.
        },
        ["text"] = "Do {questName1} and {questName2}",
        ["mapID"] = 1429,
        ["x"] = 47.04,
        ["y"] = 36.90,
    },
    [8] = {
        ["type"] = CGM.Types.Item,
        ["requiresSteps"] = { -- Optional here. If it isn't provided, the guide will assume the step is available whenever (i.e. if the item isn't a quest item then don't provide this).
            7
        },
        ["questID"] = 33, -- The addon will mark this step as complete once this quest is turned in. Mandatory.
        ["itemIDs"] = {
            7073, -- Broken Fang.
        },
        ["itemCounts"] = {
            1, -- The player only needs 1 of 7074 (Chipped Claw).
        },
        ["text"] = "Get a {itemName1}",
        ["mapID"] = 1429,
        ["x"] = 47.04,
        ["y"] = 36.90,
    },
    [9] = {
        ["type"] = CGM.Types.Deliver,
        ["questID"] = 33,
        ["rewardID"] = 80,
        ["text"] = "Hand in {questName}", -- Wolves Across the Border.
        ["mapID"] = 1429,
        ["x"] = 48.94,
        ["y"] = 40.17,
    },
    [10] = {
        ["type"] = CGM.Types.Coordinate,
        ["questID"] = 7, -- Coordinate steps should have a quest ID so they can be marked as complete if the player decides to ignore it but forgets to manually skip it in the addon.
        ["text"] = "Walk over here ({x}, {y})",
        ["mapID"] = 1429,
        ["x"] = 48.16,
        ["y"] = 42.11,
    },
    [11] = {
        ["type"] = CGM.Types.Deliver,
        ["questID"] = 7,
        ["text"] = "Hand in {questName}", -- Kobold Camp Cleanup.
        ["mapID"] = 1429,
        ["x"] = 48.93,
        ["y"] = 41.60,
    },
    [12] = {
        ["type"] = CGM.Types.Accept,
        ["questID"] = 3105,
        ["text"] = "Pick up {questName}", -- Tainted Letter.
        ["requiresSteps"] = {
            11
        },
        ["mapID"] = 1429,
        ["x"] = 48.93,
        ["y"] = 41.60,
    },
    [13] = {
        ["type"] = CGM.Types.Accept,
        ["questID"] = 15,
        ["text"] = "Pick up {questName}", -- Investigate Echo Ridge.
        ["requiresSteps"] = {
            11
        },
        ["mapID"] = 1429,
        ["x"] = 48.93,
        ["y"] = 41.60,
    },
    [14] = {
        ["type"] = CGM.Types.Accept,
        ["questID"] = 18,
        ["text"] = "Pick up {questName}", -- Brotherhood of Thieves.
        ["requiresSteps"] = {
            2
        },
        ["requiresLevel"] = 2, -- Minimum level required for the step to be available.
        ["mapID"] = 1429,
        ["x"] = 48.17,
        ["y"] = 42.94,
    },
    [15] = {
        ["type"] = CGM.Types.Do,
        ["questID"] = 18,
        ["text"] = "Do {questName}", -- Brotherhood of Thieves.
        ["mapID"] = 1429,
        ["x"] = 52.70,
        ["y"] = 46.26,
    },
    [16] = {
        ["type"] = CGM.Types.Deliver,
        ["questID"] = 18,
        ["text"] = "Hand in {questName}", -- Brotherhood of Thieves.
        ["rewardID"] = 2224,
        ["mapID"] = 1429,
        ["x"] = 48.17,
        ["y"] = 42.95,
    },
    [17] = {
        ["type"] = CGM.Types.Accept,
        ["questID"] = 3903,
        ["text"] = "Pick up {questName}", -- Milly Osworth.
        ["requiresSteps"] = {
            9
        },
        ["requiresLevel"] = 2,
        ["mapID"] = 1429,
        ["x"] = 48.17,
        ["y"] = 42.95,
    },
    [18] = {
        ["type"] = CGM.Types.Accept,
        ["questID"] = 6,
        ["text"] = "Pick up {questName}", -- Bounty on Garrick Padfoot.
        ["requiresSteps"] = {
            15
        },
        ["requiresLevel"] = 2,
        ["mapID"] = 1429,
        ["x"] = 48.17,
        ["y"] = 42.95,
    },
    [19] = {
        ["type"] = CGM.Types.Grind,
        ["level"] = 2,
        ["xp"] = 400,
        ["text"] = "Grind until you're level 4, 400 xp",
        ["mapID"] = 1429,
        ["x"] = 47.81,
        ["y"] = 39.69,
    },
})
