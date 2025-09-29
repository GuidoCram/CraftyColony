-- inventory.lua
-- Inventory management utilities for ComputerCraft turtles

local utils = require("lib.utils")

local inventory = {}

-- Get total number of slots
function inventory.getSlotCount()
    return 16 -- Standard turtle inventory size
end

-- Get information about a specific slot
function inventory.getSlotInfo(slot)
    return turtle.getItemDetail(slot)
end

-- Count items of a specific type
function inventory.countItem(itemName)
    local count = 0
    for slot = 1, inventory.getSlotCount() do
        local item = turtle.getItemDetail(slot)
        if item and item.name == itemName then
            count = count + item.count
        end
    end
    return count
end

-- Find first slot containing specific item
function inventory.findItem(itemName)
    for slot = 1, inventory.getSlotCount() do
        local item = turtle.getItemDetail(slot)
        if item and item.name == itemName then
            return slot
        end
    end
    return nil
end

-- Find all slots containing specific item
function inventory.findAllItems(itemName)
    local slots = {}
    for slot = 1, inventory.getSlotCount() do
        local item = turtle.getItemDetail(slot)
        if item and item.name == itemName then
            table.insert(slots, slot)
        end
    end
    return slots
end

-- Find first empty slot
function inventory.findEmptySlot()
    for slot = 1, inventory.getSlotCount() do
        if turtle.getItemCount(slot) == 0 then
            return slot
        end
    end
    return nil
end

-- Count empty slots
function inventory.countEmptySlots()
    local count = 0
    for slot = 1, inventory.getSlotCount() do
        if turtle.getItemCount(slot) == 0 then
            count = count + 1
        end
    end
    return count
end

-- Check if inventory is full
function inventory.isFull()
    return inventory.countEmptySlots() == 0
end

-- Check if inventory is empty
function inventory.isEmpty()
    return inventory.countEmptySlots() == inventory.getSlotCount()
end

-- Select a slot with specific item
function inventory.selectItem(itemName)
    local slot = inventory.findItem(itemName)
    if slot then
        turtle.select(slot)
        return true
    end
    return false
end

-- Drop all items of a specific type
function inventory.dropAllItems(itemName, direction)
    direction = direction or "forward" -- forward, up, down
    local dropped = 0
    
    for slot = 1, inventory.getSlotCount() do
        local item = turtle.getItemDetail(slot)
        if item and item.name == itemName then
            turtle.select(slot)
            local count = turtle.getItemCount(slot)
            
            if direction == "up" then
                turtle.dropUp()
            elseif direction == "down" then
                turtle.dropDown()
            else
                turtle.drop()
            end
            
            dropped = dropped + count
        end
    end
    
    return dropped
end

-- Compact inventory by combining stackable items
function inventory.compact()
    for slot1 = 1, inventory.getSlotCount() do
        local item1 = turtle.getItemDetail(slot1)
        if item1 and item1.count < 64 then
            for slot2 = slot1 + 1, inventory.getSlotCount() do
                local item2 = turtle.getItemDetail(slot2)
                if item2 and item1.name == item2.name then
                    turtle.select(slot2)
                    turtle.transferTo(slot1)
                    break
                end
            end
        end
    end
end

-- Sort inventory alphabetically
function inventory.sort()
    local items = {}
    
    -- Collect all items
    for slot = 1, inventory.getSlotCount() do
        local item = turtle.getItemDetail(slot)
        if item then
            table.insert(items, {slot = slot, name = item.name, count = item.count})
        end
    end
    
    -- Sort by name
    table.sort(items, function(a, b) return a.name < b.name end)
    
    -- TODO: Implement actual sorting logic with turtle movements
    -- This is a placeholder for more complex sorting implementation
    utils.info("Inventory sorting initiated")
end

-- Get inventory summary
function inventory.getSummary()
    local summary = {}
    local totalItems = 0
    local usedSlots = 0
    
    for slot = 1, inventory.getSlotCount() do
        local item = turtle.getItemDetail(slot)
        if item then
            usedSlots = usedSlots + 1
            totalItems = totalItems + item.count
            
            if summary[item.name] then
                summary[item.name] = summary[item.name] + item.count
            else
                summary[item.name] = item.count
            end
        end
    end
    
    return {
        items = summary,
        totalItems = totalItems,
        usedSlots = usedSlots,
        emptySlots = inventory.getSlotCount() - usedSlots
    }
end

-- Print inventory status
function inventory.printStatus()
    local summary = inventory.getSummary()
    
    utils.info("=== Inventory Status ===")
    utils.info(string.format("Used slots: %d/%d", summary.usedSlots, inventory.getSlotCount()))
    utils.info(string.format("Total items: %d", summary.totalItems))
    
    if utils.tableLength(summary.items) > 0 then
        utils.info("Items:")
        for itemName, count in pairs(summary.items) do
            utils.info(string.format("  %s: %d", itemName, count))
        end
    else
        utils.info("Inventory is empty")
    end
end

-- Ensure we have enough of a specific item
function inventory.ensureItem(itemName, requiredCount)
    local currentCount = inventory.countItem(itemName)
    if currentCount >= requiredCount then
        return true
    else
        utils.warn(string.format("Need %d %s, but only have %d", requiredCount, itemName, currentCount))
        return false
    end
end

return inventory