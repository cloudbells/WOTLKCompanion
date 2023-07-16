local _, CGM = ...

-- Variables.
local CUI
local deleteButton
local DeleteQueue = {first = 0, last = -1}
local GetContainerNumSlots, GetContainerItemInfo = C_Container.GetContainerNumSlots, C_Container.GetContainerItemInfo

-- Returns true if the button has an item currently.
local function DeleteButton_HasItem(self)
    return self.link ~= nil
end

-- Sets the current item for the button.
local function DeleteButton_SetItem(self, texture, quality, itemLink)
    self.link = itemLink
    local c = ITEM_QUALITY_COLORS[quality]
    self:SetBorderColor(c.r, c.g, c.b)
    self.icon:SetTexture(texture)
    self.icon:Show()
    if self:IsMouseOver() then
        GameTooltip:SetHyperlink(itemLink)
    end
end

-- Removes the current item from the button.
local function DeleteButton_RemoveItem(self)
    self.icon:Hide()
    self:SetBorderColor(0.3, 0.3, 0.3)
    self.link = nil
end

-- Called when the player clicks the delete button.
local function DeleteButton_OnClick()
    local item = DeleteQueue:Dequeue()
    if item then
        CGM:Message("deleted " .. item.itemLink .. (item.itemCount > 1 and "x" .. item.itemCount .. "." or "."))
        C_Container.PickupContainerItem(item.bag, item.slot)
        DeleteCursorItem()
    end
end

-- Returns the item that's first in line.
function DeleteQueue:GetFirst()
    return self[self.first]
end

-- Returns true if the given item exists in the queue.
function DeleteQueue:Contains(itemGUID)
    for i = 0, self:GetCount() do
        local item = DeleteQueue[i]
        if item then
            if item.itemGUID == itemGUID then
                return true
            end
        end
    end
    return false
end

-- Returns the number of items in the queue.
function DeleteQueue:GetCount()
    return self.last + 1
end

-- Adds the given item to the back of the queue.
function DeleteQueue:Enqueue(item)
    local last = self.last + 1
    self.last = last
    self[last] = item
end

-- Returns the next item in the queue.
function DeleteQueue:Dequeue()
    local first = self.first
    local next = self[first + 1]
    if next then
        deleteButton:SetItem(next.texture, next.quality, next.itemLink)
    else
        deleteButton:RemoveItem()
        deleteButton:Hide()
    end
    if not (first > self.last) then
        local item = self[first]
        self[first] = nil
        self.first = first + 1
        return item
    end
end

-- Scans the player's bags for items that should be deleted.
function CGM:ScanBag(bag)
    local itemsToDelete = CGM.currentGuide.itemsToDelete
    if itemsToDelete then
        for slot = 1, GetContainerNumSlots(bag) do
            local itemGUID = Item:CreateFromBagAndSlot(bag, slot):GetItemGUID()
            if itemGUID and not DeleteQueue:Contains(itemGUID) then
                local slotInfo = GetContainerItemInfo(bag, slot)
                local itemID = slotInfo.itemID
                if itemID and itemsToDelete[itemID] then
                    local item = {
                        bag = bag,
                        slot = slot,
                        texture = slotInfo.iconFileID,
                        itemCount = slotInfo.stackCount,
                        quality = slotInfo.quality,
                        itemLink = slotInfo.hyperlink,
                        itemID = itemID,
                        itemGUID = itemGUID,
                    }
                    DeleteQueue:Enqueue(item)
                end
            end
        end
        if not deleteButton:HasItem() and DeleteQueue:GetCount() > 0 then
            local item = DeleteQueue:GetFirst()
            if item then
                deleteButton:SetItem(item.texture, item.quality, item.itemLink)
                deleteButton:Show()
            end
        end
    end
end

-- Called when a bag's inventory is changed. Deletes any items in the given bag if it's specified by the guide.
function CGM:OnBagUpdate(bag)
    if bag >= BACKPACK_CONTAINER then
        CGM:ScanBag(bag)
        CGM:Fire("ITEM_UPDATE")
    end
end

-- Initializes the delete frame.
function CGM:InitDeleteFrame()
    CGM:Debug("initializing DeleteFrame")
    CUI = LibStub("CloudUI-1.0")
    -- Create main button.
    deleteButton = CUI:CreateLinkButton(CGM.CGMFrame, "CGMDeleteButton", {DeleteButton_OnClick})
    deleteButton:SetSize(32, 32)
    deleteButton:SetPoint("TOPLEFT", CGM.CGMFrame, "BOTTOMLEFT", 0, -4)
    local texture = deleteButton:CreateTexture(nil, "OVERLAY")
    texture:SetTexture("Interface/Addons/ClassicGuideMaker/Media/Delete")
    texture:SetAllPoints(deleteButton)
    CUI:ApplyTemplate(deleteButton, CUI.templates.BorderedFrameTemplate)
    CUI:ApplyTemplate(deleteButton, CUI.templates.HighlightFrameTemplate)
    CUI:ApplyTemplate(deleteButton, CUI.templates.PushableFrameTemplate)
    deleteButton.HasItem = DeleteButton_HasItem
    deleteButton.SetItem = DeleteButton_SetItem
    deleteButton.RemoveItem = DeleteButton_RemoveItem
    deleteButton:Hide()
    return deleteButton
end
