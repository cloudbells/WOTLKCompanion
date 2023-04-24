local _, CGM = ...

-- Variables.
local CUI
local deleteButton
local DeleteQueue = {
    first = 0,
    last = -1
}

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
        CGM:Message("deleted " .. item.itemLink .. (item.itemCount > 1 and "x" .. item.itemCount or ""))
        PickupContainerItem(item.bag, item.slot)
        DeleteCursorItem()
    end
end

-- Called when the mouse enters the button.
local function DeleteButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if self.link then
        GameTooltip:SetHyperlink(self.link)
    end
    GameTooltip:Show()
end

-- Called when the mouse leaves the button.
local function DeleteButton_OnLeave()
    GameTooltip:Hide()
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
        CGMDeleteButton:SetItem(next.texture, next.quality, next.itemLink, next.itemCount)
    else
        CGMDeleteButton:RemoveItem()
        CGMDeleteButton:Hide()
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
    for slot = 1, GetContainerNumSlots(bag) do
        local itemGUID = Item:CreateFromBagAndSlot(bag, slot):GetItemGUID()
        if not DeleteQueue:Contains(itemGUID) then
            local texture, itemCount, _, quality, _, _, itemLink, _, _, itemID = GetContainerItemInfo(bag, slot)
            if itemID and itemsToDelete[itemID] then
                local item = {
                    bag = bag,
                    slot = slot,
                    texture = texture,
                    itemCount = itemCount,
                    quality = quality,
                    itemLink = itemLink,
                    itemID = itemID,
                    itemGUID = itemGUID
                }
                DeleteQueue:Enqueue(item)
            end
        end
    end
    if not CGMDeleteButton:HasItem() and DeleteQueue:GetCount() > 0 then
        local item = DeleteQueue:GetFirst()
        if item then
            CGMDeleteButton:SetItem(item.texture, item.quality, item.itemLink)
            CGMDeleteButton:Show()
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
function CGM.InitDeleteFrame()
    CUI = LibStub("CloudUI-1.0")
    -- Create main button.
    local deleteButton = CUI:CreateLinkButton(CGMFrame, "CGMDeleteButton", {DeleteButton_OnClick})
    deleteButton:SetSize(32, 32)
    deleteButton:SetPoint("TOPLEFT", CGMFrame, "BOTTOMLEFT", 0, -4)
    local texture = deleteButton:CreateTexture(nil, "OVERLAY")
    texture:SetTexture("Interface/Addons/ClassicGuideMaker/Media/Delete")
    texture:SetAllPoints(deleteButton)
    CUI:ApplyTemplate(deleteButton, CUI.templates.BorderedFrameTemplate)
    CUI:ApplyTemplate(deleteButton, CUI.templates.HighlightFrameTemplate)
    CUI:ApplyTemplate(deleteButton, CUI.templates.PushableFrameTemplate)
    deleteButton:HookScript("OnEnter", DeleteButton_OnEnter)
    deleteButton:HookScript("OnLeave", DeleteButton_OnLeave)
    deleteButton.HasItem = DeleteButton_HasItem
    deleteButton.SetItem = DeleteButton_SetItem
    deleteButton.RemoveItem = DeleteButton_RemoveItem
    deleteButton:Hide()
end
