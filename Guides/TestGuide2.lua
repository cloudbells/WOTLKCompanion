local _, ClassicCompanion = ...

ClassicCompanion.TestGuide2 = {
    ["title"] = "Test",
    {
        ["quest"] = 10407,
        ["text"] = "This is the first step",
        ["substep"] = false,
        ["type"] = "accept", -- accept, do, deliver, grind, die, coordinate, more?
        ["x"] = 23,
        ["y"] = 42
    },
    {
        ["quest"] = 10407,
        ["type"] = "do", -- accept, do, deliver, grind, die, coordinate, more?
        ["text"] = "This is the SECOND step",
        ["substep"] = false,
        ["x"] = 23,
        ["y"] = 42
    },
    {
        ["quest"] = 10407,
        ["type"] = "do", -- accept, do, deliver, grind, die, coordinate, more?
        ["text"] = "This is the 3rd step",
        ["substep"] = false,
        ["x"] = 23,
        ["y"] = 42
    },
}