-- storage.lua
-- Item storage and sorting operations for autonomous turtles

local utils = require("lib.utils")
local navigation = require("lib.navigation")
local inventory = require("lib.inventory")
local communication = require("lib.communication")

local storage = {}

-- Storage configuration
storage.config = {
    baseLocation = {x = 0, y = 64, z = 0},
    chestLocations = {
        {x = 1, y = 64, z = 0, type = "ores"},
        {x = -1, y = 64, z = 0, type = "building"},
        {x = 0, y = 64, z = 1, type = "farming"},
        {x = 0, y = 64, z = -1, type = "tools"}
    },
    sortingRules = {
        ores = {"minecraft:diamond", "minecraft:emerald", "minecraft:gold_ingot", "minecraft:iron_ingot", "minecraft:coal", "minecraft:copper_ingot", "minecraft:lapis_lazuli", "minecraft:redstone"},
        building = {"minecraft:cobblestone", "minecraft:stone", "minecraft:dirt", "minecraft:sand", "minecraft:gravel", "minecraft:oak_planks", "minecraft:glass"},
        farming = {"minecraft:wheat", "minecraft:carrot", "minecraft:potato", "minecraft:beetroot", "minecraft:wheat_seeds", "minecraft:bone_meal"},
        tools = {"minecraft:pickaxe", "minecraft:axe", "minecraft:shovel", "minecraft:hoe", "minecraft:sword", "minecraft:torch"}
    }
}

-- Initialize storage manager
function storage.init(turtleId)
    utils.info("Initializing Storage turtle: " .. (turtleId or "unknown"))
    
    if not communication.init(turtleId) then
        utils.error("Failed to initialize communication")
        return false
    end
    
    utils.info("Storage manager initialized successfully")
    return true
end

-- Determine item category based on sorting rules
function storage.getItemCategory(itemName)
    for category, items in pairs(storage.config.sortingRules) do
        for _, item in ipairs(items) do
            if string.find(itemName, item) then
                return category
            end
        end
    end
    return "misc" -- Default category for uncategorized items
end

-- Find chest location for specific category
function storage.getChestLocation(category)
    for _, chest in ipairs(storage.config.chestLocations) do
        if chest.type == category then
            return chest
        end
    end
    return storage.config.chestLocations[1] -- Default to first chest
end

-- Check if there's a chest at current position
function storage.isChestPresent(direction)
    direction = direction or "front"
    local hasBlock, blockData
    
    if direction == "up" then
        hasBlock, blockData = turtle.inspectUp()
    elseif direction == "down" then
        hasBlock, blockData = turtle.inspectDown()
    else
        hasBlock, blockData = turtle.inspect()
    end
    
    return hasBlock and (blockData.name == "minecraft:chest" or blockData.name == "minecraft:barrel")
end

-- Place a chest if none exists
function storage.placeChest(direction)
    direction = direction or "front"
    
    if storage.isChestPresent(direction) then
        return true -- Chest already exists
    end
    
    if inventory.selectItem("minecraft:chest") then
        local success = false
        
        if direction == "up" then
            success = turtle.placeUp()
        elseif direction == "down" then
            success = turtle.placeDown()
        else
            success = turtle.place()
        end
        
        if success then
            utils.info("Placed chest")
            return true
        end
    end
    
    utils.warn("Cannot place chest: no chest available or placement failed")
    return false
end

-- Access chest inventory
function storage.accessChest(direction)
    direction = direction or "front"
    
    if not storage.isChestPresent(direction) then
        if not storage.placeChest(direction) then
            return false
        end
    end
    
    return true
end

-- Store item in appropriate chest
function storage.storeItem(itemName, quantity)
    local category = storage.getItemCategory(itemName)
    local chestLocation = storage.getChestLocation(category)
    
    utils.info(string.format("Storing %d %s in %s chest at (%d, %d, %d)", 
        quantity or "all", itemName, category, chestLocation.x, chestLocation.y, chestLocation.z))
    
    -- Navigate to chest location
    navigation.goTo(chestLocation.x, chestLocation.y, chestLocation.z)
    
    -- Ensure chest is present
    if not storage.accessChest("front") then
        utils.error("Cannot access storage chest")
        return false
    end
    
    -- Select and store the item
    if inventory.selectItem(itemName) then
        local itemCount = turtle.getItemCount()
        local toStore = quantity or itemCount
        
        if turtle.drop(toStore) then
            utils.info(string.format("Stored %d %s", toStore, itemName))
            return true
        else
            utils.warn("Storage chest may be full")
            return false
        end
    else
        utils.warn("Item not found in inventory: " .. itemName)
        return false
    end
end

-- Store all items from inventory into appropriate chests
function storage.storeAllItems()
    local itemsSummary = inventory.getSummary()
    local storedItems = 0
    
    utils.info("Starting bulk storage operation")
    
    for itemName, count in pairs(itemsSummary.items) do
        if storage.storeItem(itemName, count) then
            storedItems = storedItems + 1
        end
    end
    
    utils.info(string.format("Bulk storage complete. Stored %d item types", storedItems))
    return storedItems
end

-- Retrieve specific item from storage
function storage.retrieveItem(itemName, quantity)
    local category = storage.getItemCategory(itemName)
    local chestLocation = storage.getChestLocation(category)
    
    utils.info(string.format("Retrieving %d %s from %s chest", quantity, itemName, category))
    
    -- Navigate to chest location
    navigation.goTo(chestLocation.x, chestLocation.y, chestLocation.z)
    
    if not storage.accessChest("front") then
        utils.error("Cannot access storage chest")
        return false
    end
    
    -- Try to retrieve the item
    -- Note: In actual ComputerCraft, we'd need to iterate through chest slots
    -- This is a simplified version
    local emptySlot = inventory.findEmptySlot()
    if emptySlot then
        turtle.select(emptySlot)
        if turtle.suck(quantity) then
            utils.info(string.format("Retrieved %d %s", quantity, itemName))
            return true
        end
    end
    
    utils.warn("Could not retrieve item or no empty slots")
    return false
end

-- Organize and sort existing chests
function storage.organizeStorage()
    utils.info("Starting storage organization")
    
    for _, chestLocation in ipairs(storage.config.chestLocations) do
        utils.info(string.format("Organizing %s chest at (%d, %d, %d)", 
            chestLocation.type, chestLocation.x, chestLocation.y, chestLocation.z))
        
        navigation.goTo(chestLocation.x, chestLocation.y, chestLocation.z)
        
        if storage.accessChest("front") then
            -- In a real implementation, we would:
            -- 1. Empty the chest into turtle inventory
            -- 2. Sort items according to category
            -- 3. Put back only items that belong in this chest
            -- 4. Move misplaced items to correct chests
            
            utils.info("Chest organization completed")
        end
    end
    
    utils.info("Storage organization complete")
end

-- Create storage infrastructure
function storage.setupStorage()
    utils.info("Setting up storage infrastructure")
    
    -- Go to base location
    navigation.goTo(storage.config.baseLocation.x, storage.config.baseLocation.y, storage.config.baseLocation.z)
    
    -- Place chests at designated locations
    for _, chestLocation in ipairs(storage.config.chestLocations) do
        navigation.goTo(chestLocation.x, chestLocation.y, chestLocation.z)
        storage.placeChest("front")
        
        -- Place a sign if available
        if inventory.selectItem("minecraft:sign") then
            navigation.up()
            turtle.place()
            -- In real ComputerCraft, we'd write the category name on the sign
            navigation.down()
        end
    end
    
    utils.info("Storage infrastructure setup complete")
end

-- Respond to storage requests from other turtles
function storage.handleStorageRequest(senderId, requestData)
    if requestData.type == "store_items" then
        -- Wait for the requesting turtle to arrive and drop off items
        utils.info("Storage request received from turtle " .. senderId)
        communication.sendMessage(senderId, "storage_ready", {
            location = storage.config.baseLocation
        })
        
        -- Wait for items to be dropped off
        os.sleep(5)
        
        -- Pick up dropped items and store them
        for slot = 1, inventory.getSlotCount() do
            turtle.select(slot)
            turtle.suckUp() -- Pick up items from above
        end
        
        storage.storeAllItems()
        
    elseif requestData.type == "retrieve_items" then
        local itemName = requestData.itemName
        local quantity = requestData.quantity or 64
        
        if storage.retrieveItem(itemName, quantity) then
            communication.sendMessage(senderId, "items_ready", {
                itemName = itemName,
                quantity = quantity,
                location = storage.config.baseLocation
            })
        else
            communication.sendMessage(senderId, "items_unavailable", {
                itemName = itemName
            })
        end
    end
end

-- Get storage status and inventory
function storage.getStorageStatus()
    local status = {
        role = "storage",
        position = {navigation.getPosition()},
        chests = {},
        categories = {}
    }
    
    -- Check each chest
    for _, chestLocation in ipairs(storage.config.chestLocations) do
        navigation.goTo(chestLocation.x, chestLocation.y, chestLocation.z)
        
        if storage.isChestPresent("front") then
            status.chests[chestLocation.type] = {
                location = chestLocation,
                present = true
            }
        end
    end
    
    return status
end

-- Main storage work loop
function storage.workLoop()
    utils.info("Starting storage work loop")
    
    while true do
        -- Check for messages
        local senderId, message = communication.receiveMessage(0.1)
        if message then
            if message.type == communication.MESSAGE_TYPES.PING then
                communication.handlePing(senderId)
            elseif message.type == communication.MESSAGE_TYPES.STATUS_REQUEST then
                local status = storage.getStorageStatus()
                communication.sendStatus(senderId, status)
            elseif message.type == communication.MESSAGE_TYPES.RESOURCE_REQUEST then
                storage.handleStorageRequest(senderId, message.data)
            elseif message.type == communication.MESSAGE_TYPES.SHUTDOWN then
                utils.info("Shutdown message received")
                break
            end
        end
        
        -- Periodic organization
        storage.organizeStorage()
        
        -- Check if our inventory has items to store
        if not inventory.isEmpty() then
            utils.info("Found items in inventory, storing...")
            storage.storeAllItems()
        end
        
        utils.info("Storage cycle complete, monitoring for requests...")
        os.sleep(10)
    end
    
    utils.info("Storage work loop ended")
end

-- Get storage manager status
function storage.getStatus()
    return storage.getStorageStatus()
end

return storage