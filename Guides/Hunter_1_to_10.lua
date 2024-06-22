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

CGM:RegisterGuide({
    ["name"] = "Hunter 1-10",
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
        ["type"] = Deliver,
        ["questID"] = 456,
        ["text"] = "Deliver The Balance of Nature pt1",
        ["mapID"] = 1438,
        ["x"] = 58.7,
        ["y"] = 44.3,
        ["rewardID"] = 5394
    },
    [6] = {
        ["type"] = Accept,
        ["questID"] = 457,
        ["text"] = "Accept The Balance of Nature pt2",
        ["mapID"] = 1438,
        ["x"] = 58.7,
        ["y"] = 44.3
    },
    [7] = {
        ["type"] = Accept,
        ["questID"] = 3117,
        ["text"] = "Accept Etched Sigil",
        ["mapID"] = 1438,
        ["x"] = 58.7,
        ["y"] = 44.3
    },
})
-- LuaFormatter on
