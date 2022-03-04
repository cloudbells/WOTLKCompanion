local _, WOTLKC = ...

-- The name must be unique!
WOTLKC:RegisterGuide({
    ["name"] = "Teldrassil 1-10",
    [1] = {
        ["questID"] = 456,
        ["questName"] = "The Balance of Nature",
        ["text"] = "Pick up The Balance of Nature",
        ["type"] = WOTLKC.Types.Accept,
        ["map"] = 1438,
        ["x"] = 48.2,
        ["y"] = 42.8,
        ["substep"] = false
    },
    [2] = {
        ["questID"] = 456,
        ["questName"] = "The Balance of Nature",
        ["text"] = "Do The Balance of Nature",
        ["type"] = WOTLKC.Types.Do,
        ["map"] = 1438,
        ["x"] = 56.4,
        ["y"] = 45,
        ["substep"] = false
    },
    -- [3] = {
        -- ["questID"] = 456,
        -- ["questName"] = "The Balance of Nature",
        -- ["text"] = "Hand in The Balance of Nature",
        -- ["type"] = WOTLKC.Types.Deliver,
        -- ["map"] = 1438,
        -- ["x"] = 48.2,
        -- ["y"] = 42.8,
        -- ["substep"] = false
    -- },
    -- [4] = {
        -- ["questID"] = 457,
        -- ["questName"] = "The Balance of Nature",
        -- ["text"] = "Pick up The Balance of Nature II",
        -- ["type"] = WOTLKC.Types.Accept,
        -- ["map"] = 1438,
        -- ["x"] = 48.2,
        -- ["y"] = 42.8,
        -- ["substep"] = false
    -- },
    -- [5] = {
        -- ["questID"] = 457,
        -- ["questName"] = "The Balance of Nature",
        -- ["text"] = "Do The Balance of Nature II",
        -- ["type"] = WOTLKC.Types.Do,
        -- ["map"] = 1438,
        -- ["x"] = 61.4,
        -- ["y"] = 34.8,
        -- ["substep"] = false
    -- },
    -- [6] = {
        -- ["questID"] = 457,
        -- ["questName"] = "The Balance of Nature",
        -- ["text"] = "Hand in Balance of Nature II",
        -- ["type"] = WOTLKC.Types.Deliver,
        -- ["map"] = 1438,
        -- ["x"] = 48.2,
        -- ["y"] = 42.8,
        -- ["substep"] = false
    -- },
})
