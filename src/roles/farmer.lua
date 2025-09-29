-- farmer.lua
-- Crop farming operations for autonomous turtles

local utils = require("lib.utils")
local navigation = require("lib.navigation")
local inventory = require("lib.inventory")
local communication = require("lib.communication")

local farmer = {}

-- Farmer configuration
farmer.config = {
    seedSlots = {1, 2, 3}, -- Slots for different seeds
    toolSlot = 4,
    waterBucketSlot = 5,
    boneMealSlot = 6,
    farmSize = {width = 9, length = 9}, -- 9x9 farm plots
    waterPlacement = 4, -- Place water every 4 blocks
    harvestWhenFull = true
}

-- Crop types and their characteristics
farmer.CROPS = {
    wheat = {
        seed = "minecraft:wheat_seeds",
        mature = "minecraft:wheat",
        growthStages = 8,
        boneMealResponsive = true
    },
    carrots = {
        seed = "minecraft:carrot",
        mature = "minecraft:carrots",
        growthStages = 8,
        boneMealResponsive = true
    },
    potatoes = {
        seed = "minecraft:potato",
        mature = "minecraft:potatoes",
        growthStages = 8,
        boneMealResponsive = true
    },
    beetroot = {
        seed = "minecraft:beetroot_seeds",
        mature = "minecraft:beetroot",
        growthStages = 4,
        boneMealResponsive = true
    },
    pumpkin = {
        seed = "minecraft:pumpkin_seeds",
        mature = "minecraft:pumpkin",
        growthStages = 8,
        boneMealResponsive = true,
        requiresSpace = true
    },
    melon = {
        seed = "minecraft:melon_seeds",
        mature = "minecraft:melon",
        growthStages = 8,
        boneMealResponsive = true,
        requiresSpace = true
    }
}

-- Initialize farmer
function farmer.init(turtleId)
    utils.info("Initializing Farmer turtle: " .. (turtleId or "unknown"))
    
    if not communication.init(turtleId) then
        utils.error("Failed to initialize communication")
        return false
    end
    
    -- Check for hoe
    if inventory.selectItem("minecraft:diamond_hoe") or 
       inventory.selectItem("minecraft:iron_hoe") or 
       inventory.selectItem("minecraft:stone_hoe") or 
       inventory.selectItem("minecraft:wooden_hoe") then
        utils.info("Farming tool found")
    else
        utils.warn("No hoe found in inventory")
    end
    
    utils.info("Farmer initialized successfully")
    return true
end

-- Check if block is farmland
function farmer.isFarmland(blockData)
    return blockData and (blockData.name == "minecraft:farmland" or blockData.name == "minecraft:dirt")
end

-- Check if block is water
function farmer.isWater(blockData)
    return blockData and blockData.name == "minecraft:water"
end

-- Check if crop is mature
function farmer.isCropMature(blockData, cropType)
    if not blockData or not cropType then return false end
    
    local crop = farmer.CROPS[cropType]
    if not crop then return false end
    
    -- For most crops, check if it's the mature block type
    if blockData.name == crop.mature then
        return true
    end
    
    -- For crops that grow in stages, check the stage
    if blockData.state and blockData.state.age then
        return blockData.state.age >= (crop.growthStages - 1)
    end
    
    return false
end

-- Get crop type from seed or mature plant
function farmer.identifyCrop(blockData)
    if not blockData then return nil end
    
    for cropType, crop in pairs(farmer.CROPS) do
        if blockData.name == crop.seed or blockData.name == crop.mature then
            return cropType
        end
    end
    return nil
end

-- Till the soil
function farmer.tillSoil()
    -- Select hoe
    if not (inventory.selectItem("minecraft:diamond_hoe") or 
            inventory.selectItem("minecraft:iron_hoe") or 
            inventory.selectItem("minecraft:stone_hoe") or 
            inventory.selectItem("minecraft:wooden_hoe")) then
        utils.warn("No hoe available for tilling")
        return false
    end
    
    local hasBlockBelow, blockDataBelow = turtle.inspectDown()
    if hasBlockBelow and (blockDataBelow.name == "minecraft:dirt" or blockDataBelow.name == "minecraft:grass_block") then
        turtle.placeDown() -- Use hoe on dirt/grass
        utils.info("Tilled soil")
        return true
    else
        utils.warn("Cannot till: unsuitable ground")
        return false
    end
end

-- Place water source
function farmer.placeWater()
    if inventory.selectItem("minecraft:water_bucket") then
        if turtle.placeDown() then
            utils.info("Placed water source")
            return true
        end
    end
    utils.warn("Cannot place water: no bucket or placement failed")
    return false
end

-- Plant a seed
function farmer.plantSeed(cropType)
    local crop = farmer.CROPS[cropType]
    if not crop then
        utils.warn("Unknown crop type: " .. cropType)
        return false
    end
    
    if inventory.selectItem(crop.seed) then
        if turtle.place() then
            utils.info("Planted " .. cropType .. " seed")
            return true
        else
            utils.warn("Failed to place seed")
            return false
        end
    else
        utils.warn("No " .. cropType .. " seeds available")
        return false
    end
end

-- Harvest a crop
function farmer.harvestCrop(cropType)
    local crop = farmer.CROPS[cropType]
    if not crop then return false end
    
    local hasBlock, blockData = turtle.inspect()
    if hasBlock and farmer.isCropMature(blockData, cropType) then
        turtle.dig()
        utils.info("Harvested " .. cropType)
        
        -- Replant immediately for automatic crops like wheat, carrots, potatoes
        if not crop.requiresSpace then
            farmer.plantSeed(cropType)
        end
        
        return true
    end
    return false
end

-- Apply bone meal to crop
function farmer.applyBoneMeal()
    if inventory.selectItem("minecraft:bone_meal") then
        turtle.place() -- Apply bone meal to the crop in front
        utils.info("Applied bone meal")
        return true
    end
    return false
end

-- Create a farm plot
function farmer.createFarmPlot(startX, startZ, cropType)
    utils.info(string.format("Creating %dx%d %s farm at (%d, %d)", 
        farmer.config.farmSize.width, farmer.config.farmSize.length, cropType, startX, startZ))
    
    local startY = navigation.position.y
    
    -- Create the farmland grid
    for x = 0, farmer.config.farmSize.width - 1 do
        for z = 0, farmer.config.farmSize.length - 1 do
            navigation.goTo(startX + x, startY, startZ + z)
            
            -- Place water every few blocks
            if (x + z) % farmer.config.waterPlacement == 0 then
                navigation.down()
                farmer.placeWater()
                navigation.up()
            else
                -- Till and plant
                farmer.tillSoil()
                farmer.plantSeed(cropType)
            end
        end
    end
    
    utils.info("Farm plot creation complete")
    return true
end

-- Tend to existing farm plot
function farmer.tendFarm(startX, startZ, cropType)
    utils.info(string.format("Tending %s farm at (%d, %d)", cropType, startX, startZ))
    
    local startY = navigation.position.y
    local harvestedCount = 0
    local plantedCount = 0
    
    for x = 0, farmer.config.farmSize.width - 1 do
        for z = 0, farmer.config.farmSize.length - 1 do
            navigation.goTo(startX + x, startY, startZ + z)
            
            local hasBlock, blockData = turtle.inspect()
            
            if hasBlock then
                local cropIdentified = farmer.identifyCrop(blockData)
                
                if cropIdentified == cropType then
                    -- Check if crop is mature
                    if farmer.isCropMature(blockData, cropType) then
                        if farmer.harvestCrop(cropType) then
                            harvestedCount = harvestedCount + 1
                        end
                    else
                        -- Apply bone meal to speed growth
                        farmer.applyBoneMeal()
                    end
                end
            else
                -- Empty farmland, plant a seed
                local hasBlockBelow, blockDataBelow = turtle.inspectDown()
                if hasBlockBelow and farmer.isFarmland(blockDataBelow) then
                    if farmer.plantSeed(cropType) then
                        plantedCount = plantedCount + 1
                    end
                end
            end
            
            -- Check if inventory is getting full
            if inventory.countEmptySlots() < 3 then
                utils.warn("Inventory nearly full, requesting storage assistance")
                communication.requestResource("storage", 0, "normal")
                break
            end
        end
        
        if inventory.countEmptySlots() < 3 then
            break
        end
    end
    
    utils.info(string.format("Farm tending complete. Harvested: %d, Planted: %d", harvestedCount, plantedCount))
    return harvestedCount
end

-- Harvest entire farm plot
function farmer.harvestFarm(startX, startZ, cropType)
    utils.info(string.format("Harvesting entire %s farm at (%d, %d)", cropType, startX, startZ))
    
    local startY = navigation.position.y
    local harvestedCount = 0
    
    for x = 0, farmer.config.farmSize.width - 1 do
        for z = 0, farmer.config.farmSize.length - 1 do
            navigation.goTo(startX + x, startY, startZ + z)
            
            if farmer.harvestCrop(cropType) then
                harvestedCount = harvestedCount + 1
            end
        end
    end
    
    utils.info(string.format("Farm harvest complete. Harvested %d crops", harvestedCount))
    return harvestedCount
end

-- Manage multiple farm plots
function farmer.manageFarms()
    local farms = {
        {x = 0, z = 0, crop = "wheat"},
        {x = 15, z = 0, crop = "carrots"},
        {x = 0, z = 15, crop = "potatoes"},
        {x = 15, z = 15, crop = "beetroot"}
    }
    
    local totalHarvested = 0
    
    for _, farm in ipairs(farms) do
        utils.info(string.format("Managing %s farm at (%d, %d)", farm.crop, farm.x, farm.z))
        
        -- Check if farm exists, create if not
        navigation.goTo(farm.x, navigation.position.y, farm.z)
        local hasBlock, blockData = turtle.inspectDown()
        
        if not hasBlock or not farmer.isFarmland(blockData) then
            utils.info("Farm doesn't exist, creating new farm plot")
            farmer.createFarmPlot(farm.x, farm.z, farm.crop)
        else
            utils.info("Existing farm found, tending to crops")
            local harvested = farmer.tendFarm(farm.x, farm.z, farm.crop)
            totalHarvested = totalHarvested + harvested
        end
        
        -- Brief pause between farms
        os.sleep(2)
    end
    
    return totalHarvested
end

-- Main farmer work loop
function farmer.workLoop()
    utils.info("Starting farmer work loop")
    
    while true do
        -- Check for messages
        local senderId, message = communication.receiveMessage(0.1)
        if message then
            if message.type == communication.MESSAGE_TYPES.PING then
                communication.handlePing(senderId)
            elseif message.type == communication.MESSAGE_TYPES.STATUS_REQUEST then
                local status = {
                    role = "farmer",
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
        
        -- Perform farming work
        utils.info("Starting farming operations")
        local totalHarvested = farmer.manageFarms()
        
        if totalHarvested > 0 then
            utils.info(string.format("Farming successful! Harvested %d crops", totalHarvested))
        else
            utils.info("No crops ready for harvest, tending to farm growth")
        end
        
        utils.info("Farming cycle complete, waiting for crops to grow...")
        os.sleep(60) -- Wait 1 minute before next cycle
    end
    
    utils.info("Farmer work loop ended")
end

-- Get farmer status
function farmer.getStatus()
    return {
        role = "farmer",
        position = {navigation.getPosition()},
        inventory = inventory.getSummary(),
        farms = farmer.config.farmSize,
        config = farmer.config
    }
end

return farmer