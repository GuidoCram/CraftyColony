-- miner.lua
-- Mining and excavation operations for autonomous turtles

local utils = require("lib.utils")
local navigation = require("lib.navigation")
local inventory = require("lib.inventory")
local communication = require("lib.communication")

local miner = {}

-- Miner configuration
miner.config = {
    fuelSlot = 16,
    torchSlot = 15,
    maxDepth = 64,
    torchInterval = 8,
    stripMineWidth = 3,
    shaftSpacing = 4,
    workArea = {
        minX = -20,
        maxX = 20,
        minZ = -20,
        maxZ = 20,
        targetY = 12 -- Diamond level
    }
}

-- Valuable ores to prioritize
miner.VALUABLE_ORES = {
    "minecraft:diamond_ore",
    "minecraft:deepslate_diamond_ore",
    "minecraft:emerald_ore",
    "minecraft:deepslate_emerald_ore",
    "minecraft:gold_ore",
    "minecraft:deepslate_gold_ore",
    "minecraft:iron_ore",
    "minecraft:deepslate_iron_ore",
    "minecraft:coal_ore",
    "minecraft:deepslate_coal_ore",
    "minecraft:copper_ore",
    "minecraft:deepslate_copper_ore",
    "minecraft:lapis_ore",
    "minecraft:deepslate_lapis_ore",
    "minecraft:redstone_ore",
    "minecraft:deepslate_redstone_ore"
}

-- Blocks to avoid/ignore
miner.IGNORE_BLOCKS = {
    "minecraft:dirt",
    "minecraft:gravel",
    "minecraft:flint",
    "minecraft:cobblestone",
    "minecraft:stone",
    "minecraft:deepslate",
    "minecraft:tuff"
}

-- Initialize miner
function miner.init(turtleId)
    utils.info("Initializing Miner turtle: " .. (turtleId or "unknown"))
    
    if not communication.init(turtleId) then
        utils.error("Failed to initialize communication")
        return false
    end
    
    -- Check for pickaxe
    if not turtle.dig then
        utils.error("No pickaxe equipped for mining")
        return false
    end
    
    -- Check fuel level
    if turtle.getFuelLevel() < 100 then
        utils.warn("Low fuel level: " .. turtle.getFuelLevel())
        miner.refuel()
    end
    
    utils.info("Miner initialized successfully")
    return true
end

-- Refuel the turtle
function miner.refuel()
    local fuelItems = {"minecraft:coal", "minecraft:charcoal", "minecraft:lava_bucket"}
    
    for _, fuelType in ipairs(fuelItems) do
        if inventory.selectItem(fuelType) then
            local fuelCount = turtle.getItemCount()
            if fuelCount > 0 then
                local initialFuel = turtle.getFuelLevel()
                turtle.refuel(math.min(fuelCount, 10)) -- Don't use all fuel at once
                local fuelGained = turtle.getFuelLevel() - initialFuel
                utils.info(string.format("Refueled: gained %d fuel", fuelGained))
                return true
            end
        end
    end
    
    utils.warn("No fuel items found in inventory")
    return false
end

-- Check if block is valuable ore
function miner.isValuableOre(blockData)
    if not blockData then return false end
    
    for _, ore in ipairs(miner.VALUABLE_ORES) do
        if blockData.name == ore then
            return true
        end
    end
    return false
end

-- Check if block should be ignored
function miner.shouldIgnoreBlock(blockData)
    if not blockData then return true end
    
    for _, ignoreBlock in ipairs(miner.IGNORE_BLOCKS) do
        if blockData.name == ignoreBlock then
            return true
        end
    end
    return false
end

-- Place a torch if needed
function miner.placeTorchIfNeeded()
    local x, y, z = navigation.getPosition()
    
    -- Place torch every specified interval
    if (x + y + z) % miner.config.torchInterval == 0 then
        if inventory.selectItem("minecraft:torch") then
            navigation.turnLeft()
            navigation.turnLeft() -- Face backwards
            turtle.place()
            navigation.turnLeft()
            navigation.turnLeft() -- Face forward again
            utils.info("Placed torch for lighting")
            return true
        else
            utils.warn("No torches available")
        end
    end
    return false
end

-- Mine a single block if it's valuable
function miner.mineBlock(direction)
    direction = direction or "forward"
    local hasBlock, blockData
    
    if direction == "up" then
        hasBlock, blockData = turtle.inspectUp()
    elseif direction == "down" then
        hasBlock, blockData = turtle.inspectDown()
    else
        hasBlock, blockData = turtle.inspect()
    end
    
    if hasBlock and not miner.shouldIgnoreBlock(blockData) then
        local isValuable = miner.isValuableOre(blockData)
        
        if isValuable then
            utils.info("Mining valuable ore: " .. blockData.name)
        end
        
        -- Mine the block
        if direction == "up" then
            turtle.digUp()
        elseif direction == "down" then
            turtle.digDown()
        else
            turtle.dig()
        end
        
        return isValuable
    end
    
    return false
end

-- Dig a horizontal tunnel
function miner.digTunnel(length)
    local oreFound = 0
    
    for i = 1, length do
        -- Mine blocks in front, above, and below
        miner.mineBlock("forward")
        if miner.mineBlock("up") then oreFound = oreFound + 1 end
        if miner.mineBlock("down") then oreFound = oreFound + 1 end
        
        -- Move forward
        if not navigation.forward() then
            turtle.dig() -- Clear any blocks that appeared
            if not navigation.forward() then
                utils.error("Cannot move forward in tunnel")
                break
            end
        end
        
        -- Place torch periodically
        miner.placeTorchIfNeeded()
        
        -- Check side walls for ores
        navigation.turnLeft()
        if miner.mineBlock("forward") then oreFound = oreFound + 1 end
        navigation.turnRight()
        navigation.turnRight()
        if miner.mineBlock("forward") then oreFound = oreFound + 1 end
        navigation.turnLeft() -- Face forward again
        
        -- Check if inventory is getting full
        if inventory.countEmptySlots() < 3 then
            utils.warn("Inventory nearly full, need to return to base")
            break
        end
        
        -- Check fuel level
        if turtle.getFuelLevel() < 50 then
            utils.warn("Low fuel, attempting to refuel")
            if not miner.refuel() then
                utils.error("Cannot refuel, returning to base")
                break
            end
        end
    end
    
    return oreFound
end

-- Create a strip mine pattern
function miner.stripMine(startX, startZ, targetY)
    utils.info(string.format("Starting strip mine at (%d, %d) targeting Y level %d", startX, startZ, targetY))
    
    -- Go to starting position
    navigation.goTo(startX, navigation.position.y, startZ)
    
    -- Descend to target level
    while navigation.position.y > targetY do
        if not navigation.down() then
            turtle.digDown()
            if not navigation.down() then
                utils.error("Cannot descend to target level")
                return false
            end
        end
    end
    
    local totalOres = 0
    local shaftCount = 0
    
    -- Create parallel mining shafts
    for x = startX, startX + miner.config.workArea.maxX, miner.config.shaftSpacing do
        utils.info(string.format("Mining shaft %d at X=%d", shaftCount + 1, x))
        
        navigation.goTo(x, targetY, startZ)
        
        -- Face north and mine tunnel
        navigation.faceDirection(navigation.DIRECTIONS.NORTH)
        local ores = miner.digTunnel(math.abs(miner.config.workArea.maxZ - miner.config.workArea.minZ))
        totalOres = totalOres + ores
        
        shaftCount = shaftCount + 1
        
        -- Return to surface periodically or when inventory is full
        if inventory.countEmptySlots() < 5 or shaftCount % 3 == 0 then
            utils.info("Returning to surface for inventory management")
            navigation.goTo(startX, 64, startZ) -- Return to surface
            
            -- Request storage assistance
            communication.requestResource("storage", 0, "normal")
            os.sleep(5)
            
            -- Return to work
            navigation.goTo(x, targetY, navigation.position.z)
        end
    end
    
    utils.info(string.format("Strip mining complete. Found %d valuable ores", totalOres))
    return totalOres
end

-- Explore and mine around current position
function miner.exploreMine(radius)
    local startX, startY, startZ = navigation.getPosition()
    local oreFound = 0
    
    utils.info(string.format("Exploring mine in %dx%d area", radius * 2, radius * 2))
    
    for x = -radius, radius do
        for z = -radius, radius do
            navigation.goTo(startX + x, startY, startZ + z)
            
            -- Mine blocks at current level
            if miner.mineBlock("forward") then oreFound = oreFound + 1 end
            if miner.mineBlock("up") then oreFound = oreFound + 1 end
            if miner.mineBlock("down") then oreFound = oreFound + 1 end
            
            -- Check all four sides
            for i = 1, 4 do
                if miner.mineBlock("forward") then oreFound = oreFound + 1 end
                navigation.turnRight()
            end
        end
    end
    
    navigation.goTo(startX, startY, startZ)
    return oreFound
end

-- Main mining operation
function miner.performMining()
    local startX, startY, startZ = navigation.getPosition()
    
    -- Start strip mining operation
    local totalOres = miner.stripMine(
        miner.config.workArea.minX,
        miner.config.workArea.minZ,
        miner.config.workArea.targetY
    )
    
    -- Return to starting position
    navigation.goTo(startX, startY, startZ)
    
    return totalOres
end

-- Main miner work loop
function miner.workLoop()
    utils.info("Starting miner work loop")
    
    while true do
        -- Check for messages
        local senderId, message = communication.receiveMessage(0.1)
        if message then
            if message.type == communication.MESSAGE_TYPES.PING then
                communication.handlePing(senderId)
            elseif message.type == communication.MESSAGE_TYPES.STATUS_REQUEST then
                local status = {
                    role = "miner",
                    position = {navigation.getPosition()},
                    inventory = inventory.getSummary(),
                    fuel = turtle.getFuelLevel(),
                    active = true
                }
                communication.sendStatus(senderId, status)
            elseif message.type == communication.MESSAGE_TYPES.SHUTDOWN then
                utils.info("Shutdown message received")
                break
            end
        end
        
        -- Perform mining work
        utils.info("Starting mining operation")
        local oresFound = miner.performMining()
        
        if oresFound > 0 then
            utils.info(string.format("Mining successful! Found %d ores", oresFound))
        else
            utils.info("No ores found in this area, moving to new location...")
            -- Move to a new area
            navigation.goTo(
                math.random(-50, 50),
                miner.config.workArea.targetY,
                math.random(-50, 50)
            )
        end
        
        utils.info("Mining cycle complete, brief rest before continuing...")
        os.sleep(30)
    end
    
    utils.info("Miner work loop ended")
end

-- Get miner status
function miner.getStatus()
    return {
        role = "miner",
        position = {navigation.getPosition()},
        inventory = inventory.getSummary(),
        fuel = turtle.getFuelLevel(),
        config = miner.config
    }
end

return miner