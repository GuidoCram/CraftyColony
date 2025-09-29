-- builder.lua
-- Construction and building operations for autonomous turtles

local utils = require("lib.utils")
local navigation = require("lib.navigation")
local inventory = require("lib.inventory")
local communication = require("lib.communication")

local builder = {}

-- Builder configuration
builder.config = {
    blueprintSlot = 1,
    buildHeight = 10,
    materialSlots = {2, 3, 4, 5, 6, 7, 8, 9},
    supportBlocks = {"minecraft:cobblestone", "minecraft:stone", "minecraft:planks"}
}

-- Common building materials
builder.MATERIALS = {
    stone = "minecraft:stone",
    cobblestone = "minecraft:cobblestone",
    wood_planks = "minecraft:oak_planks",
    glass = "minecraft:glass",
    brick = "minecraft:bricks",
    dirt = "minecraft:dirt"
}

-- Building patterns
builder.PATTERNS = {
    wall = function(width, height) 
        local pattern = {}
        for y = 1, height do
            for x = 1, width do
                table.insert(pattern, {x = x, y = y, z = 1, block = builder.MATERIALS.cobblestone})
            end
        end
        return pattern
    end,
    
    floor = function(width, length)
        local pattern = {}
        for x = 1, width do
            for z = 1, length do
                table.insert(pattern, {x = x, y = 1, z = z, block = builder.MATERIALS.stone})
            end
        end
        return pattern
    end,
    
    tower = function(height)
        local pattern = {}
        for y = 1, height do
            -- Hollow tower with 3x3 base
            for x = 1, 3 do
                for z = 1, 3 do
                    if x == 1 or x == 3 or z == 1 or z == 3 then
                        table.insert(pattern, {x = x, y = y, z = z, block = builder.MATERIALS.stone})
                    end
                end
            end
        end
        return pattern
    end
}

-- Initialize builder
function builder.init(turtleId)
    utils.info("Initializing Builder turtle: " .. (turtleId or "unknown"))
    
    if not communication.init(turtleId) then
        utils.error("Failed to initialize communication")
        return false
    end
    
    utils.info("Builder initialized successfully")
    return true
end

-- Check if we have required building materials
function builder.checkMaterials(requiredBlocks)
    local materials = {}
    
    for _, blockInfo in ipairs(requiredBlocks) do
        local blockType = blockInfo.block
        if materials[blockType] then
            materials[blockType] = materials[blockType] + 1
        else
            materials[blockType] = 1
        end
    end
    
    local missingMaterials = {}
    for blockType, needed in pairs(materials) do
        local available = inventory.countItem(blockType)
        if available < needed then
            table.insert(missingMaterials, {
                block = blockType, 
                needed = needed, 
                available = available, 
                missing = needed - available
            })
        end
    end
    
    return missingMaterials
end

-- Request missing materials
function builder.requestMaterials(missingMaterials)
    for _, material in ipairs(missingMaterials) do
        utils.warn(string.format("Missing %d %s (have %d, need %d)", 
            material.missing, material.block, material.available, material.needed))
        
        communication.requestResource(material.block, material.missing, "high")
    end
    
    if #missingMaterials > 0 then
        utils.info("Waiting for materials to be delivered...")
        os.sleep(10)
        return false
    end
    
    return true
end

-- Place a block at specific position
function builder.placeBlockAt(x, y, z, blockType)
    local currentX, currentY, currentZ = navigation.getPosition()
    
    -- Navigate to the position
    navigation.goTo(x, y, z)
    
    -- Select the required block
    if not inventory.selectItem(blockType) then
        utils.warn("Cannot find required block: " .. blockType)
        return false
    end
    
    -- Place the block below the turtle
    if turtle.placeDown() then
        utils.info(string.format("Placed %s at (%d, %d, %d)", blockType, x, y, z))
        return true
    else
        utils.warn(string.format("Failed to place block at (%d, %d, %d)", x, y, z))
        return false
    end
end

-- Build from a pattern/blueprint
function builder.buildFromPattern(pattern, startX, startY, startZ)
    utils.info(string.format("Starting construction at (%d, %d, %d)", startX, startY, startZ))
    
    -- Check materials first
    local missingMaterials = builder.checkMaterials(pattern)
    if not builder.requestMaterials(missingMaterials) then
        utils.error("Cannot start construction: missing materials")
        return false
    end
    
    local blocksPlaced = 0
    local totalBlocks = #pattern
    
    -- Sort pattern by Y level (build from bottom up)
    table.sort(pattern, function(a, b) return a.y < b.y end)
    
    for i, blockInfo in ipairs(pattern) do
        local targetX = startX + blockInfo.x - 1
        local targetY = startY + blockInfo.y - 1
        local targetZ = startZ + blockInfo.z - 1
        
        if builder.placeBlockAt(targetX, targetY, targetZ, blockInfo.block) then
            blocksPlaced = blocksPlaced + 1
        end
        
        -- Progress update
        if i % 10 == 0 then
            utils.info(string.format("Construction progress: %d/%d blocks placed", blocksPlaced, totalBlocks))
        end
        
        -- Check inventory periodically
        if inventory.countEmptySlots() < 3 then
            utils.warn("Inventory space running low")
        end
        
        -- Brief pause to prevent overheating
        if i % 50 == 0 then
            os.sleep(1)
        end
    end
    
    utils.info(string.format("Construction complete! Placed %d/%d blocks", blocksPlaced, totalBlocks))
    return blocksPlaced == totalBlocks
end

-- Build a simple house
function builder.buildHouse(startX, startY, startZ, width, length, height)
    utils.info(string.format("Building house: %dx%dx%d at (%d, %d, %d)", width, length, height, startX, startY, startZ))
    
    local pattern = {}
    
    -- Foundation
    for x = 1, width do
        for z = 1, length do
            table.insert(pattern, {x = x, y = 1, z = z, block = builder.MATERIALS.stone})
        end
    end
    
    -- Walls
    for y = 2, height do
        for x = 1, width do
            for z = 1, length do
                -- Only place blocks on the perimeter
                if x == 1 or x == width or z == 1 or z == length then
                    table.insert(pattern, {x = x, y = y, z = z, block = builder.MATERIALS.cobblestone})
                end
            end
        end
    end
    
    -- Roof
    for x = 1, width do
        for z = 1, length do
            table.insert(pattern, {x = x, y = height + 1, z = z, block = builder.MATERIALS.wood_planks})
        end
    end
    
    -- Add door (remove blocks for entrance)
    pattern = utils.filter(pattern, function(block)
        return not (block.x == math.floor(width/2) and block.z == 1 and (block.y == 2 or block.y == 3))
    end)
    
    return builder.buildFromPattern(pattern, startX, startY, startZ)
end

-- Build a bridge
function builder.buildBridge(startX, startY, startZ, endX, endZ)
    utils.info(string.format("Building bridge from (%d, %d, %d) to (%d, %d)", startX, startY, startZ, endX, endZ))
    
    local pattern = {}
    local deltaX = endX - startX
    local deltaZ = endZ - startZ
    local distance = math.max(math.abs(deltaX), math.abs(deltaZ))
    
    -- Create bridge path
    for i = 0, distance do
        local x = math.floor(startX + (deltaX * i / distance))
        local z = math.floor(startZ + (deltaZ * i / distance))
        
        -- Bridge deck
        table.insert(pattern, {x = x - startX + 1, y = 1, z = z - startZ + 1, block = builder.MATERIALS.wood_planks})
        
        -- Railings (every few blocks)
        if i % 3 == 0 then
            table.insert(pattern, {x = x - startX + 1, y = 2, z = z - startZ + 1, block = builder.MATERIALS.wood_planks})
        end
    end
    
    return builder.buildFromPattern(pattern, startX, startY, startZ)
end

-- Repair damaged structures
function builder.repairStructure(startX, startY, startZ, width, length, height, expectedBlock)
    utils.info("Scanning and repairing structure...")
    
    local repairedBlocks = 0
    
    for x = 0, width - 1 do
        for y = 0, height - 1 do
            for z = 0, length - 1 do
                navigation.goTo(startX + x, startY + y, startZ + z)
                
                local hasBlock, blockData = turtle.inspectDown()
                
                if not hasBlock or blockData.name ~= expectedBlock then
                    utils.info(string.format("Repairing block at (%d, %d, %d)", startX + x, startY + y, startZ + z))
                    
                    if inventory.selectItem(expectedBlock) then
                        if turtle.placeDown() then
                            repairedBlocks = repairedBlocks + 1
                        end
                    else
                        utils.warn("Cannot repair: no " .. expectedBlock .. " available")
                        break
                    end
                end
            end
        end
    end
    
    utils.info(string.format("Structure repair complete. Repaired %d blocks", repairedBlocks))
    return repairedBlocks
end

-- Main builder work loop
function builder.workLoop()
    utils.info("Starting builder work loop")
    
    while true do
        -- Check for messages
        local senderId, message = communication.receiveMessage(0.1)
        if message then
            if message.type == communication.MESSAGE_TYPES.PING then
                communication.handlePing(senderId)
            elseif message.type == communication.MESSAGE_TYPES.STATUS_REQUEST then
                local status = {
                    role = "builder",
                    position = {navigation.getPosition()},
                    inventory = inventory.getSummary(),
                    active = true
                }
                communication.sendStatus(senderId, status)
            elseif message.type == communication.MESSAGE_TYPES.TASK_ASSIGNMENT then
                -- Handle building tasks
                local task = message.data
                if task.type == "build_house" then
                    builder.buildHouse(task.x, task.y, task.z, task.width, task.length, task.height)
                elseif task.type == "build_bridge" then
                    builder.buildBridge(task.startX, task.startY, task.startZ, task.endX, task.endZ)
                end
                communication.sendMessage(senderId, communication.MESSAGE_TYPES.TASK_COMPLETE, {})
            elseif message.type == communication.MESSAGE_TYPES.SHUTDOWN then
                utils.info("Shutdown message received")
                break
            end
        end
        
        -- Default construction activity (if no specific tasks)
        utils.info("Performing default construction activity")
        local x, y, z = navigation.getPosition()
        
        -- Build a small tower as default activity
        local towerPattern = builder.PATTERNS.tower(5)
        if builder.buildFromPattern(towerPattern, x + 10, y, z + 10) then
            utils.info("Default tower construction completed")
        end
        
        utils.info("Builder cycle complete, waiting for tasks...")
        os.sleep(30)
    end
    
    utils.info("Builder work loop ended")
end

-- Get builder status
function builder.getStatus()
    return {
        role = "builder",
        position = {navigation.getPosition()},
        inventory = inventory.getSummary(),
        config = builder.config
    }
end

return builder