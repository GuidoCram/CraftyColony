-- forester.lua
-- Tree farming and logging operations for autonomous turtles

local utils = require("lib.utils")
local navigation = require("lib.navigation")
local inventory = require("lib.inventory")
local communication = require("lib.communication")

local forester = {}

-- Forester configuration
forester.config = {
    saplingSlot = 1,
    boneMealSlot = 2,
    maxTreeHeight = 20,
    replantSaplings = true,
    useBoneMeal = true,
    workArea = {
        minX = -10,
        maxX = 10,
        minZ = -10,
        maxZ = 10
    }
}

-- Tree types and their characteristics
forester.TREE_TYPES = {
    oak = {
        sapling = "minecraft:oak_sapling",
        log = "minecraft:oak_log",
        leaves = "minecraft:oak_leaves"
    },
    birch = {
        sapling = "minecraft:birch_sapling",
        log = "minecraft:birch_log",
        leaves = "minecraft:birch_leaves"
    },
    spruce = {
        sapling = "minecraft:spruce_sapling",
        log = "minecraft:spruce_log",
        leaves = "minecraft:spruce_leaves"
    }
}

-- Initialize forester
function forester.init(turtleId)
    utils.info("Initializing Forester turtle: " .. (turtleId or "unknown"))
    
    if not communication.init(turtleId) then
        utils.error("Failed to initialize communication")
        return false
    end
    
    -- Check for required tools
    if not turtle.dig then
        utils.error("No tool equipped for digging")
        return false
    end
    
    utils.info("Forester initialized successfully")
    return true
end

-- Check if block is a tree log
function forester.isLog(blockData)
    if not blockData then return false end
    
    for _, treeType in pairs(forester.TREE_TYPES) do
        if blockData.name == treeType.log then
            return true
        end
    end
    return false
end

-- Check if block is leaves
function forester.isLeaves(blockData)
    if not blockData then return false end
    
    for _, treeType in pairs(forester.TREE_TYPES) do
        if blockData.name == treeType.leaves then
            return true
        end
    end
    return false
end

-- Check if block is a sapling
function forester.isSapling(blockData)
    if not blockData then return false end
    
    for _, treeType in pairs(forester.TREE_TYPES) do
        if blockData.name == treeType.sapling then
            return true
        end
    end
    return false
end

-- Detect if there's a tree at current position
function forester.detectTree()
    local hasBlock, blockData = turtle.inspect()
    return hasBlock and forester.isLog(blockData)
end

-- Cut down a tree at current position
function forester.cutTree()
    if not forester.detectTree() then
        utils.warn("No tree detected at current position")
        return false
    end
    
    utils.info("Starting tree cutting operation")
    local startX, startY, startZ = navigation.getPosition()
    local logsHarvested = 0
    
    -- Cut tree trunk going up
    while forester.detectTree() do
        turtle.dig()
        if not navigation.up() then
            utils.error("Cannot move up while cutting tree")
            break
        end
        logsHarvested = logsHarvested + 1
        
        if navigation.position.y - startY > forester.config.maxTreeHeight then
            utils.warn("Tree exceeds maximum height limit")
            break
        end
    end
    
    -- Cut any remaining logs and leaves around
    forester.clearLeavesAndLogs()
    
    -- Return to ground level
    navigation.goTo(startX, startY, startZ)
    
    utils.info(string.format("Tree cutting complete. Harvested %d logs", logsHarvested))
    return logsHarvested > 0
end

-- Clear leaves and remaining logs in the area
function forester.clearLeavesAndLogs()
    local startX, startY, startZ = navigation.getPosition()
    
    -- Check and clear in a 3x3 area around current position
    for dx = -1, 1 do
        for dz = -1, 1 do
            navigation.goTo(startX + dx, startY, startZ + dz)
            
            -- Clear column from current Y to a few blocks up
            for dy = 0, 5 do
                local hasBlock, blockData = turtle.inspectUp()
                if hasBlock and (forester.isLog(blockData) or forester.isLeaves(blockData)) then
                    turtle.digUp()
                end
                
                if dy < 5 and not navigation.up() then
                    break
                end
            end
            
            -- Return to ground level for this position
            navigation.goTo(startX + dx, startY, startZ + dz)
        end
    end
    
    -- Return to original position
    navigation.goTo(startX, startY, startZ)
end

-- Plant a sapling at current position
function forester.plantSapling()
    -- Check if ground is suitable (dirt or grass)
    local hasBlockBelow, blockDataBelow = turtle.inspectDown()
    if not hasBlockBelow then
        utils.warn("No ground to plant sapling on")
        return false
    end
    
    local suitableGround = {
        "minecraft:dirt",
        "minecraft:grass_block",
        "minecraft:podzol",
        "minecraft:mycelium"
    }
    
    local groundSuitable = false
    for _, groundType in ipairs(suitableGround) do
        if blockDataBelow.name == groundType then
            groundSuitable = true
            break
        end
    end
    
    if not groundSuitable then
        utils.warn("Ground not suitable for planting: " .. blockDataBelow.name)
        return false
    end
    
    -- Select sapling slot and plant
    if inventory.selectItem("minecraft:oak_sapling") or 
       inventory.selectItem("minecraft:birch_sapling") or 
       inventory.selectItem("minecraft:spruce_sapling") then
        
        if turtle.place() then
            utils.info("Sapling planted successfully")
            
            -- Apply bone meal if available and configured
            if forester.config.useBoneMeal and inventory.selectItem("minecraft:bone_meal") then
                for i = 1, 3 do -- Try up to 3 bone meals
                    turtle.place()
                    os.sleep(0.5)
                end
                utils.info("Applied bone meal to sapling")
            end
            
            return true
        else
            utils.warn("Failed to place sapling")
            return false
        end
    else
        utils.warn("No saplings available in inventory")
        return false
    end
end

-- Scan area for trees to harvest
function forester.scanForTrees()
    local trees = {}
    local startX, startY, startZ = navigation.getPosition()
    
    utils.info("Scanning area for trees...")
    
    for x = forester.config.workArea.minX, forester.config.workArea.maxX do
        for z = forester.config.workArea.minZ, forester.config.workArea.maxZ do
            navigation.goTo(x, startY, z)
            
            if forester.detectTree() then
                table.insert(trees, {x = x, y = startY, z = z})
                utils.info(string.format("Tree found at (%d, %d, %d)", x, startY, z))
            end
        end
    end
    
    navigation.goTo(startX, startY, startZ)
    utils.info(string.format("Scan complete. Found %d trees", #trees))
    return trees
end

-- Harvest all trees in work area
function forester.harvestArea()
    local trees = forester.scanForTrees()
    local harvestedCount = 0
    
    for _, treePos in ipairs(trees) do
        utils.info(string.format("Harvesting tree at (%d, %d, %d)", treePos.x, treePos.y, treePos.z))
        navigation.goTo(treePos.x, treePos.y, treePos.z)
        
        if forester.cutTree() then
            harvestedCount = harvestedCount + 1
            
            -- Replant if configured
            if forester.config.replantSaplings then
                forester.plantSapling()
            end
        end
        
        -- Check if inventory is getting full
        if inventory.countEmptySlots() < 3 then
            utils.warn("Inventory nearly full, requesting storage assistance")
            communication.requestResource("storage", 0, "high")
            
            -- Wait a bit or return to base for storage
            os.sleep(2)
        end
    end
    
    utils.info(string.format("Harvesting complete. Harvested %d trees", harvestedCount))
    return harvestedCount
end

-- Main forester work loop
function forester.workLoop()
    utils.info("Starting forester work loop")
    
    while true do
        -- Check for messages
        local senderId, message = communication.receiveMessage(0.1)
        if message then
            if message.type == communication.MESSAGE_TYPES.PING then
                communication.handlePing(senderId)
            elseif message.type == communication.MESSAGE_TYPES.STATUS_REQUEST then
                local status = {
                    role = "forester",
                    position = {navigation.getPosition()},
                    inventory = inventory.getSummary(),
                    active = true
                }
                communication.sendStatus(senderId, status)
            elseif message.type == communication.MESSAGE_TYPES.SHUTDOWN then
                utils.info("Shutdown message received")
                break
            end
        end
        
        -- Perform harvesting work
        local harvestedTrees = forester.harvestArea()
        
        if harvestedTrees == 0 then
            utils.info("No trees found, waiting before next scan...")
            os.sleep(10)
        else
            utils.info("Work cycle complete, brief rest before continuing...")
            os.sleep(5)
        end
    end
    
    utils.info("Forester work loop ended")
end

-- Get forester status
function forester.getStatus()
    return {
        role = "forester",
        position = {navigation.getPosition()},
        inventory = inventory.getSummary(),
        config = forester.config
    }
end

return forester