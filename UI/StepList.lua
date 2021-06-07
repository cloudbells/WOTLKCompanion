local _, ClassicCompanion = ...

ClassicCompanion.stepFrames = {}

-- Colors the given frame the given color.
-- function ClassicCompanion.colorFrame(frame, r, g, b, a)
    -- frame:SetColorTexture(r, g, b, a)
-- end

-- Initializes the frames containing steps, getting frames from a frame pool.
function ClassicCompanion.initStepFrames()
    -- Reclaim all used frames.
    for _, frame in pairs(ClassicCompanion.stepFrames) do
        frame.used = false
    end
    for i = 1, ClassicCompanionOptions.nbrSteps do
        ClassicCompanion.stepFrames[i] = ClassicCompanion.getFrame()
        if i ~= ClassicCompanionOptions.nbrSteps then
            ClassicCompanion.stepFrames[i].index = i
            ClassicCompanion.stepFrames[i].border = ClassicCompanion.stepFrames[i]:CreateTexture(nil, "BORDER")
            ClassicCompanion.stepFrames[i].border:SetColorTexture(0, 0, 0, 1)
            ClassicCompanion.stepFrames[i].border:SetPoint("TOPRIGHT", ClassicCompanion.stepFrames[i], "BOTTOMRIGHT")
            ClassicCompanion.stepFrames[i].border:SetPoint("TOPLEFT", ClassicCompanion.stepFrames[i], "BOTTOMLEFT")
        end
    end
    ClassicCompanion.resizeStepFrames() -- Needs to be called once on addon load.
end

-- Code written by Gemt.
function ClassicCompanion.resizeStepFrames()
    local height = ClassicCompanionFrameBodyFrame:GetHeight()
    local nbrSteps = ClassicCompanionOptions.nbrSteps
    for i = 1, nbrSteps do
        local topOffset = (i - 1) * (height / nbrSteps)
        local bottomOffset = height - (i * (height / nbrSteps))
        ClassicCompanion.stepFrames[i]:SetPoint("TOPLEFT", ClassicCompanionFrameBodyFrame, "TOPLEFT", 0, -topOffset)
        ClassicCompanion.stepFrames[i]:SetPoint("BOTTOMRIGHT", ClassicCompanionFrameBodyFrame, "BOTTOMRIGHT", 0, bottomOffset)
    end
end
