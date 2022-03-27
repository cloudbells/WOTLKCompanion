local _, WOTLKC = ...

-- Variables.
local DeleteQueue = {
    first = 0,
    last = -1
}

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
        WOTLKCDeleteButton:SetItem(next.texture, next.quality, next.itemLink, next.itemCount)
    else
        WOTLKCDeleteButton:RemoveItem()
        WOTLKCDeleteButton:Hide()
    end
    if not (first > self.last) then
        local item = self[first]
        self[first] = nil
        self.first = first + 1
        return item
    end
end

-- Scans the player's bags for items that should be deleted. Scans only the one bag if given.
function WOTLKC:ScanBag(bag)
    local itemsToDelete = WOTLKC.currentGuide.itemsToDelete
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
    if not WOTLKCDeleteButton:HasItem() and DeleteQueue:GetCount() > 0 then
        local item = DeleteQueue:GetFirst()
        if item then
            WOTLKCDeleteButton:SetItem(item.texture, item.quality, item.itemLink)
            WOTLKCDeleteButton:Show()
        end
    end
end 

-- Called when a bag's inventory is changed. Deletes any items in the given bag if it's specified by the guide.
function WOTLKC.Events:OnBagUpdate(bag)
    if bag >= BACKPACK_CONTAINER then
        WOTLKC:ScanBag(bag)
    end
end

-- Called when the player clicks the delete button.
function WOTLKC_DeleteButton_OnClick()
    local item = DeleteQueue:Dequeue()
    if item then
        WOTLKC.Logging:Message("deleted " .. item.itemLink .. (item.itemCount > 1 and "x" .. item.itemCount or ""))
        PickupContainerItem(item.bag, item.slot)
        DeleteCursorItem()
    end
end
