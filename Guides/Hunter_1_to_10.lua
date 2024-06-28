-- LuaFormatter off
local _, CGM = ...

local Accept = CGM.Types.Accept
local Do = CGM.Types.Do
local Item = CGM.Types.Item
local Deliver = CGM.Types.Deliver
local BankMailGet = CGM.Types.BankMailGet
local Buy = CGM.Types.Buy
local Grind = CGM.Types.Grind
local Coordinate = CGM.Types.Coordinate
local Train = CGM.Types.Train
local Fly = CGM.Types.Fly
local Inn = CGM.Types.Inn

-- @TODO: incorporate logout skips
-- @TODO: make sure to get optimal fel cones
CGM:RegisterGuide({
    ["name"] = "Hunter 1-10",
    ["itemsToSell"] = {
        [961] = true,
        [5606] = true,
        [5457] = true,
        [5472] = true,
        [5482] = true
    },
    [1] = {
        ["type"] = Accept,
        ["questID"] = 456,
        ["text"] = "Accept The Balance of Nature pt1",
        ["mapID"] = 1438,
        ["x"] = 58.7,
        ["y"] = 44.3
    },
    [2] = {
        ["type"] = Accept,
        ["questID"] = 458,
        ["text"] = "Accept The Woodland Protector pt1",
        ["mapID"] = 1438,
        ["x"] = 59.9,
        ["y"] = 42.5
    },
    [3] = {
        ["type"] = Do,
        ["questID"] = 456,
        ["text"] = "Kill boars and nightsabers",
        ["mapID"] = 1438,
        ["x"] = 61.36,
        ["y"] = 42.66
    },
    [4] = {
        ["type"] = Accept,
        ["questID"] = 4495,
        ["text"] = "Pick up A Good Friend",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 42.0,
        ["requiresLevel"] = 2
    },
    [5] = {
        ["type"] = Buy,
        ["text"] = "Buy 1000 arrows",
        ["mapID"] = 1438,
        ["x"] = 59.31,
        ["y"] = 41.09,
        ["items"] = {
            [2512] = 1000 -- Rough Arrow
        },
        ["cost"] = 0,
        ["unitID"] = 3589,
        ["exploit"] = true
    },
    [6] = {
        ["type"] = Deliver,
        ["questID"] = 456,
        ["text"] = "Deliver The Balance of Nature pt1",
        ["mapID"] = 1438,
        ["x"] = 58.7,
        ["y"] = 44.3,
        ["rewardID"] = 5394
    },
    [7] = {
        ["type"] = Accept,
        ["questID"] = 457,
        ["text"] = "Accept The Balance of Nature pt2",
        ["mapID"] = 1438,
        ["x"] = 58.7,
        ["y"] = 44.3
    },
    [8] = {
        ["type"] = Accept,
        ["questID"] = 3117,
        ["text"] = "Accept Etched Sigil",
        ["mapID"] = 1438,
        ["x"] = 58.7,
        ["y"] = 44.3
    },
    [9] = {
        ["type"] = Deliver,
        ["questID"] = 458,
        ["text"] = "Deliver The Woodland Protector pt1",
        ["mapID"] = 1438,
        ["x"] = 57.7,
        ["y"] = 45.2
    },
    [10] = {
        ["type"] = Accept,
        ["questID"] = 459,
        ["text"] = "Accept The Woodland Protector pt2",
        ["mapID"] = 1438,
        ["x"] = 57.7,
        ["y"] = 45.2
    },
    [11] = {
        ["type"] = Do,
        ["questID"] = 459,
        ["text"] = "Kill grell and loot Fel Moss",
        ["mapID"] = 1438,
        ["x"] = 56.01,
        ["y"] = 45.81
    },
    [12] = {
        ["type"] = Deliver,
        ["questID"] = 459,
        ["text"] = "Deliver The Woodland Protector pt2",
        ["mapID"] = 1438,
        ["x"] = 57.7,
        ["y"] = 45.1,
        ["rewardID"] = 5398
    },
    [13] = {
        ["type"] = Accept,
        ["questID"] = 916,
        ["text"] = "Accept Webwood Venom",
        ["mapID"] = 1438,
        ["x"] = 57.8,
        ["y"] = 41.7
    },
    [14] = {
        ["type"] = Deliver,
        ["questID"] = 4495,
        ["text"] = "Deliver A Good Friend",
        ["mapID"] = 1438,
        ["x"] = 54.6,
        ["y"] = 33.0
    },
    [15] = {
        ["type"] = Accept,
        ["questID"] = 3519,
        ["text"] = "Accept A Friend in Need",
        ["mapID"] = 1438,
        ["x"] = 54.6,
        ["y"] = 33.0
    },
    [16] = {
        ["type"] = Do,
        ["questID"] = 916,
        ["text"] = "Kill spiders and loot venom sacs",
        ["mapID"] = 1438,
        ["x"] = 57.01,
        ["y"] = 32.81,
    },
    [17] = {
        ["type"] = Do,
        ["questID"] = 457,
        ["text"] = "Kill boars and nightsabers",
        ["mapID"] = 1438,
        ["x"] = 58.99,
        ["y"] = 35.37,
    },
    [18] = {
        ["type"] = Deliver,
        ["questID"] = 3519,
        ["text"] = "Deliver A Friend in Need",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 42.0
    },
    [19] = {
        ["type"] = Accept,
        ["questID"] = 3521,
        ["text"] = "Accept Iverron's Antidote pt1",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 42.0
    },
    [20] = {
        ["type"] = Coordinate,
        ["text"] = "Vendor and buy arrows if necessary",
        ["mapID"] = 1438,
        ["x"] = 59.31,
        ["y"] = 41.09,
    },
    [21] = {
        ["type"] = Deliver,
        ["questID"] = 457,
        ["text"] = "Deliver The Balance of Nature pt2",
        ["mapID"] = 1438,
        ["x"] = 58.7,
        ["y"] = 44.3,
        ["rewardID"] = 6058
    },
    [22] = {
        ["type"] = Deliver,
        ["questID"] = 916,
        ["text"] = "Deliver Webwood Venom",
        ["mapID"] = 1438,
        ["x"] = 57.8,
        ["y"] = 41.7,
        ["rewardID"] = 5392
    },
    [23] = {
        ["type"] = Accept,
        ["questID"] = 917,
        ["text"] = "Accept Webwood Egg",
        ["mapID"] = 1438,
        ["x"] = 57.8,
        ["y"] = 41.7
    },
    [24] = {
        ["type"] = Deliver,
        ["questID"] = 3117,
        ["text"] = "Deliver Etched Sigil",
        ["mapID"] = 1438,
        ["x"] = 58.7,
        ["y"] = 40.4
    },
    [25] = {
        ["type"] = Train,
        ["cost"] = 210,
        ["spells"] = {
            [13163] = {
                ["name"] = "Aspect of the Monkey",
                ["rank"] = 1
            },
            [1978] = {
                ["name"] = "Serpent Sting",
                ["rank"] = 1
            },
            [1494] = {
                ["name"] = "Track Beasts",
                ["rank"] = 1
            }
        },
        ["text"] = "Train Aspect of the Monkey, Serpent Sting, and Track Beasts",
        ["mapID"] = 1438,
        ["x"] = 58.7,
        ["y"] = 40.4,
        ["requiresLevel"] = 4
    },
    [26] = {
        ["type"] = Coordinate,
        ["text"] = "Jump off to the first level from here",
        ["mapID"] = 1438,
        ["x"] = 58.2,
        ["y"] = 40.5
    },
    [27] = {
        ["type"] = Coordinate,
        ["text"] = "Jump off from here",
        ["mapID"] = 1438,
        ["x"] = 57.9,
        ["y"] = 40.7
    },
    [28] = {
        ["type"] = Item,
        ["questID"] = 3521,
        ["items"] = {
            [10641] = 4 -- Moonpetal Lily.
        },
        ["text"] = "Pick 4 flowers",
        ["mapID"] = 1438,
        ["x"] = 57.3,
        ["y"] = 39.7
    },
    [29] = {
        ["type"] = Item,
        ["questID"] = 3521,
        ["items"] = {
            [10639] = 7 -- Hyacinth Mushroom.
        },
        ["text"] = "Kill grellkin and loot 7 mushrooms",
        ["mapID"] = 1438,
        ["x"] = 54.9,
        ["y"] = 38.8
    },
    [30] = {
        ["type"] = Do,
        ["questID"] = 3521,
        ["text"] = "Kill spiders on the way to the end of the cave and loot a Webwood Ichor",
        ["mapID"] = 1438,
        ["x"] = 56.7,
        ["y"] = 34.3
    },
    [31] = {
        ["type"] = Do,
        ["questID"] = 917,
        ["text"] = "Pick up a Webwood Egg",
        ["mapID"] = 1438,
        ["x"] = 56.7,
        ["y"] = 26.5
    },
    [32] = {
        ["type"] = Coordinate,
        ["text"] = "Logout skip back out",
        ["mapID"] = 1438,
        ["x"] = 56.7,
        ["y"] = 26.6
    },
    [33] = {
        ["type"] = Deliver,
        ["questID"] = 3521,
        ["text"] = "Deliver Iverron's Antidote pt1",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 42.0
    },
    [34] = {
        ["type"] = Accept,
        ["questID"] = 3522,
        ["text"] = "Accept Iverron's Antidote pt2",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 42.0
    },
    [35] = {
        ["type"] = Coordinate,
        ["text"] = "Vendor and buy arrows if necessary",
        ["mapID"] = 1438,
        ["x"] = 59.31,
        ["y"] = 41.09,
    },
    [36] = {
        ["type"] = Deliver,
        ["questID"] = 917,
        ["text"] = "Deliver Webwood Egg",
        ["mapID"] = 1438,
        ["x"] = 57.8,
        ["y"] = 41.6,
        ["rewardID"] = 4907
    },
    [37] = {
        ["type"] = Accept,
        ["questID"] = 920,
        ["text"] = "Accept Tenaron's Summons",
        ["mapID"] = 1438,
        ["x"] = 57.8,
        ["y"] = 41.6
    },
    [38] = {
        ["type"] = Deliver,
        ["questID"] = 920,
        ["text"] = "Deliver Tenaron's Summons",
        ["mapID"] = 1438,
        ["x"] = 59.1,
        ["y"] = 39.4
    },
    [39] = {
        ["type"] = Accept,
        ["questID"] = 921,
        ["text"] = "Accept Crown of the Earth pt1",
        ["mapID"] = 1438,
        ["x"] = 59.1,
        ["y"] = 39.4
    },
    [40] = {
        ["type"] = Coordinate,
        ["text"] = "Jump off here",
        ["mapID"] = 1438,
        ["x"] = 59.5,
        ["y"] = 39.1
    },
    [41] = {
        ["type"] = Do,
        ["questID"] = 921,
        ["items"] = {
            [5185] = 1
        },
        ["text"] = "Fill the phial",
        ["mapID"] = 1438,
        ["x"] = 60.0,
        ["y"] = 33.1
    },
    [42] = {
        ["type"] = Deliver,
        ["questID"] = 3522,
        ["text"] = "Deliver Iverron's Antidote pt2",
        ["mapID"] = 1438,
        ["x"] = 54.6,
        ["y"] = 33.0,
        ["rewardID"] = 10656
    },
    [43] = {
        ["type"] = Train,
        ["cost"] = 200,
        ["spells"] = {
            [3044] = {
                ["name"] = "Arcane Shot",
                ["rank"] = 1
            },
            [1130] = {
                ["name"] = "Hunter's Mark",
                ["rank"] = 1
            },
        },
        ["text"] = "Train Arcane Shot and Hunter's Mark if you're level 6",
        ["mapID"] = 1438,
        ["x"] = 58.7,
        ["y"] = 40.4,
        ["requiresLevel"] = 6
    },
    [44] = {
        ["type"] = Deliver,
        ["questID"] = 921,
        ["text"] = "Deliver Crown of the Earth pt1",
        ["mapID"] = 1438,
        ["x"] = 59.1,
        ["y"] = 39.5
    },
    [45] = {
        ["type"] = Accept,
        ["questID"] = 928,
        ["text"] = "Accept Crown of the Earth pt2",
        ["mapID"] = 1438,
        ["x"] = 59.1,
        ["y"] = 39.5
    },
    [46] = {
        ["type"] = Coordinate,
        ["text"] = "Jump off here",
        ["mapID"] = 1438,
        ["x"] = 59.2,
        ["y"] = 40.4
    },
    [47] = {
        ["type"] = Accept,
        ["questID"] = 2159,
        ["text"] = "Accept Dolanaar Delivery",
        ["mapID"] = 1438,
        ["x"] = 61.2,
        ["y"] = 47.6
    },
    [48] = {
        ["type"] = Accept,
        ["questID"] = 488,
        ["text"] = "Accept Zenn's Bidding",
        ["mapID"] = 1438,
        ["x"] = 60.4,
        ["y"] = 56.2
    },
    -- @TODO: set this to overarching objective
    [49] = {
        ["type"] = Accept,
        ["questID"] = 997,
        ["text"] = "Accept Denalan's Earth",
        ["mapID"] = 1438,
        ["x"] = 56.1,
        ["y"] = 57.7
    },
    [50] = {
        ["type"] = Accept,
        ["questID"] = 475,
        ["text"] = "Accept A Troubling Breeze",
        ["mapID"] = 1438,
        ["x"] = 56.0,
        ["y"] = 57.3
    },
    [51] = {
        ["type"] = Train,
        ["cost"] = 100,
        ["spells"] = {
            [3044] = {
                ["name"] = "Apprentice First Aid",
                ["rank"] = 1
            }
        },
        ["text"] = "Train First Aid",
        ["mapID"] = 1438,
        ["x"] = 55.3,
        ["y"] = 56.8
    },
    [52] = {
        ["type"] = Accept,
        ["questID"] = 2438,
        ["text"] = "Accept The Emerald Dreamcatcher",
        ["mapID"] = 1438,
        ["x"] = 55.6,
        ["y"] = 56.9
    },
    [53] = {
        ["type"] = Accept,
        ["questID"] = 932,
        ["text"] = "Accept Twisted Hatred",
        ["mapID"] = 1438,
        ["x"] = 55.6,
        ["y"] = 56.9
    },
    [54] = {
        ["type"] = Accept,
        ["questID"] = 487,
        ["text"] = "Accept The Road to Darnassus if she's here",
        ["mapID"] = 1438,
        ["x"] = 55.8,
        ["y"] = 58.3
    },
    [55] = {
        ["type"] = Buy,
        ["text"] = "Buy 400 arrows and vendor",
        ["mapID"] = 1438,
        ["x"] = 55.9,
        ["y"] = 59.2,
        ["items"] = {
            [2512] = 400 -- Rough Arrow
        },
        ["cost"] = 0,
        ["unitID"] = 3610,
        ["exploit"] = true
    },
    [56] = {
        ["type"] = Deliver,
        ["questID"] = 2159,
        ["text"] = "Deliver Dolanaar Delivery",
        ["mapID"] = 1438,
        ["x"] = 55.6,
        ["y"] = 59.8,
        ["rewardID"] = 159
    },
    [57] = {
        ["type"] = Inn,
        ["text"] = "Set HS in Dolanaar",
        ["mapID"] = 1438,
        ["x"] = 55.6,
        ["y"] = 59.8,
    },
    [58] = {
        ["type"] = Train,
        ["cost"] = 200,
        ["spells"] = {
            [3044] = {
                ["name"] = "Arcane Shot",
                ["rank"] = 1
            },
            [1130] = {
                ["name"] = "Hunter's Mark",
                ["rank"] = 1
            },
        },
        ["text"] = "Train Arcane Shot and Hunter's Mark if you couldn't before",
        ["mapID"] = 1438,
        ["x"] = 56.7,
        ["y"] = 59.5,
        ["requiresLevel"] = 6
    },
    [59] = {
        ["type"] = Deliver,
        ["questID"] = 928,
        ["text"] = "Deliver Crown of the Earth pt2",
        ["mapID"] = 1438,
        ["x"] = 56.1,
        ["y"] = 61.7
    },
    [60] = {
        ["type"] = Accept,
        ["questID"] = 929,
        ["text"] = "Accept Crown of the Earth pt3",
        ["mapID"] = 1438,
        ["x"] = 56.1,
        ["y"] = 61.7
    },
    [61] = {
        ["type"] = Train,
        ["cost"] = 100,
        ["spells"] = {
            [2550] = {
                ["name"] = "Apprentice Cook",
                ["rank"] = 1
            }
        },
        ["text"] = "Train Cooking",
        ["mapID"] = 1438,
        ["x"] = 57.1,
        ["y"] = 61.3
    },
    -- @TODO: this should be overarching
    [62] = {
        ["type"] = Accept,
        ["questID"] = 4161,
        ["text"] = "Accept Recipe of the Kaldorei",
        ["mapID"] = 1438,
        ["x"] = 57.1,
        ["y"] = 61.3
    },
    [63] = {
        ["type"] = Deliver,
        ["questID"] = 997,
        ["text"] = "Deliver Denalan's Earth",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 68.5
    },
    [64] = {
        ["type"] = Accept,
        ["questID"] = 918,
        ["text"] = "Accept Timberling Seeds",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 68.5
    },
    [65] = {
        ["type"] = Accept,
        ["questID"] = 919,
        ["text"] = "Accept Timberling Sprouts",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 68.5
    },
    [66] = {
        ["type"] = Do,
        ["isMultiStep"] = true,
        ["questIDs"] = {
            918,
            919
        },
        ["text"] = "Do Timberling Seeds + Timberling Sprouts",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 68.5
    },
    [67] = {
        ["type"] = Deliver,
        ["questID"] = 918,
        ["text"] = "Deliver Timberling Seeds",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 68.5
    },
    [68] = {
        ["type"] = Accept,
        ["questID"] = 922,
        ["text"] = "Accept Rellian Greenspyre",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 68.5
    },
    [69] = {
        ["type"] = Deliver,
        ["questID"] = 919,
        ["text"] = "Deliver Timberling Sprouts",
        ["mapID"] = 1438,
        ["x"] = 60.9,
        ["y"] = 68.5,
        ["rewardID"] = 5606
    },
    [70] = {
        ["type"] = Coordinate,
        ["text"] = "Walk up this ramp towards Starbreeze Village",
        ["mapID"] = 1438,
        ["x"] = 62.2,
        ["y"] = 65.5
    },
    -- @TODO: rare here if on a fresh server
    [71] = {
        ["type"] = Do,
        ["questID"] = 2438,
        ["text"] = "Loot the Emerald Dreamcatcher",
        ["mapID"] = 1438,
        ["x"] = 68.0,
        ["y"] = 59.6
    },
    [72] = {
        ["type"] = Deliver,
        ["questID"] = 475,
        ["text"] = "Deliver A Troubling Breeze",
        ["mapID"] = 1438,
        ["x"] = 66.3,
        ["y"] = 58.5
    },
    [73] = {
        ["type"] = Accept,
        ["questID"] = 476,
        ["text"] = "Accept Gnarlpine Corruption",
        ["mapID"] = 1438,
        ["x"] = 66.3,
        ["y"] = 58.5
    },
    [74] = {
        ["type"] = Do,
        ["questID"] = 929,
        ["items"] = {
            [5619] = 1
        },
        ["text"] = "Fill the phial",
        ["mapID"] = 1438,
        ["x"] = 63.4,
        ["y"] = 58.1
    },
    -- @TODO: overarching should merge into the one below, there are no overlapping objectives anymore
    -- @TODO: should multi-do with spider legs quest
    [75] = {
        ["type"] = Do,
        ["isMultiStep"] = true,
        ["questIDs"] = {
            488,
            4161
        },
        ["text"] = "Finish Zenn's Bidding + Recipe of the Kaldorei",
        ["mapID"] = 1438,
        ["x"] = 62.6,
        ["y"] = 59.4
    },
    [76] = {
        ["type"] = Deliver,
        ["questID"] = 488,
        ["text"] = "Deliver Zenn's Bidding",
        ["mapID"] = 1438,
        ["x"] = 60.4,
        ["y"] = 56.3
    },
    [77] = {
        ["type"] = Accept,
        ["questID"] = 489,
        ["text"] = "Accept Seek Redemption!",
        ["mapID"] = 1438,
        ["x"] = 56.1,
        ["y"] = 57.7
    },
    [78] = {
        ["type"] = Deliver,
        ["questID"] = 476,
        ["text"] = "Deliver Gnarlpine Corruption",
        ["mapID"] = 1438,
        ["x"] = 56.0,
        ["y"] = 57.3
    },
    [79] = {
        ["type"] = Accept,
        ["questID"] = 483,
        ["text"] = "Accept The Relics of Wakening",
        ["mapID"] = 1438,
        ["x"] = 56.0,
        ["y"] = 57.3
    },
    [80] = {
        ["type"] = Buy,
        ["text"] = "Buy a bag and vendor",
        ["mapID"] = 1438,
        ["x"] = 55.5,
        ["y"] = 57.1,
        ["items"] = {
            [4496] = 1 -- Small Brown Pouch
        },
        ["cost"] = 500,
        ["unitID"] = 3608
    },
    [81] = {
        ["type"] = Deliver,
        ["questID"] = 2438,
        ["text"] = "Deliver The Emerald Dreamcatcher",
        ["mapID"] = 1438,
        ["x"] = 55.6,
        ["y"] = 56.9
    },
    [82] = {
        ["type"] = Accept,
        ["questID"] = 2459,
        ["text"] = "Accept Ferocitas the Dream Eater",
        ["mapID"] = 1438,
        ["x"] = 55.6,
        ["y"] = 56.9
    },
    [83] = {
        ["type"] = Accept,
        ["questID"] = 487,
        ["text"] = "Accept The Road to Darnassus if she's here",
        ["mapID"] = 1438,
        ["x"] = 55.8,
        ["y"] = 58.3
    },
    [84] = {
        ["type"] = Deliver,
        ["questID"] = 929,
        ["text"] = "Deliver Crown of the Earth pt3",
        ["mapID"] = 1438,
        ["x"] = 56.1,
        ["y"] = 61.7
    },
    [85] = {
        ["type"] = Accept,
        ["questID"] = 933,
        ["text"] = "Accept Crown of the Earth pt4",
        ["mapID"] = 1438,
        ["x"] = 56.1,
        ["y"] = 61.7
    },
    [86] = {
        ["type"] = Deliver,
        ["questID"] = 4161,
        ["text"] = "Deliver Recipe of the Kaldorei",
        ["mapID"] = 1438,
        ["x"] = 57.1,
        ["y"] = 61.3
    },
    [87] = {
        ["type"] = Train,
        ["cost"] = 600,
        ["spells"] = {
            [3127] = {
                ["name"] = "Parry",
                ["rank"] = 1
            },
            [5116] = {
                ["name"] = "Concussive Shot",
                ["rank"] = 1
            },
            [14260] = {
                ["name"] = "Raptor Strike",
                ["rank"] = 2
            }
        },
        ["text"] = "Train Parry, Concussive Shot, and Raptor Strike",
        ["mapID"] = 1438,
        ["x"] = 56.7,
        ["y"] = 59.5,
        ["requiresLevel"] = 8
    },
    [88] = {
        ["type"] = Item,
        ["questID"] = 489,
        ["items"] = {
            [3418] = 1 -- Fel Cone
        },
        ["text"] = "Pick up this Fel Cone",
        ["mapID"] = 1438,
        ["x"] = 58.8,
        ["y"] = 55.5
    },
    [89] = {
        ["type"] = Item,
        ["questID"] = 489,
        ["items"] = {
            [3418] = 2 -- Fel Cone
        },
        ["text"] = "Pick up this Fel Cone",
        ["mapID"] = 1438,
        ["x"] = 59.0,
        ["y"] = 56.1
    },
    [90] = {
        ["type"] = Do,
        ["questID"] = 2459,
        ["items"] = {
            [8049] = 1 -- Gnarlpine Necklace
        },
        ["text"] = "Kill Ferocitas and 7 Shamans, loot the necklace",
        ["mapID"] = 1438,
        ["x"] = 68.8,
        ["y"] = 53.4
    },
    [91] = {
        ["type"] = Do,
        ["questID"] = 489,
        ["text"] = "Pick up the last Fel Cone",
        ["mapID"] = 1438,
        ["x"] = 64.3,
        ["y"] = 53.8
    },
})
-- LuaFormatter on
